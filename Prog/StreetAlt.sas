/**************************************************************************
 Program:  StreetAlt.sas
 Library:  RealProp
 Project:  DC Data Warehouse
 Author:   P. Tatian
 Created:  04/21/05
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect

 Description:  Create data set with alternate street spellings
               (i.e., corrections) for parcel geocoding.
               
 NB:  The file K:\Metro\PTatian\DCData\Libraries\RealProp\Prog\StreetAlt.xls
      must be open before running this program.
      
 NB:  Do NOT make changes to this program without asking Peter Tatian first.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

filename xin dde "excel|K:\Metro\PTatian\DCData\Libraries\RealProp\Prog\[StreetAlt.xls]StreetAlt!r6c1:r1000c2" lrecl=256 notab;

data StreetAlt;

  length streetname altname $ 50;
  
  infile xin missover dsd dlm='09'x;

  input altname streetname;

  streetname = left( compbl( upcase( streetname ) ) );
  altname = left( compbl( upcase( altname ) ) );

run;

** Upload file to Alpha **;

rsubmit;

proc upload status=no
  data=StreetAlt 
  out=StreetAlt;

run;

** Check for conflicting entries of alternate street spellings and
** invalid correct street names;

proc sort data=StreetAlt nodupkey;
  by altname streetname;

data _null_;

  set StreetAlt;
  by altname;

  if not last.altname then do;
    %err_put( msg="Conflicting entries for incorrect spelling of " altname " in StreetAlt.xls." )
    %err_put( msg="Alternate street name spelling list NOT updated." )
    %err_put( msg="Please edit the StreetAlt.xls file and rerun this program." )
    abort return;
  end;
  
  if put( streetname, $stvalid. ) = " " then do;
    %err_put( msg="Invalid entry for correct spelling of " streetname " in StreetAlt.xls." )
    %err_put( msg="Correct street name spelling must match listing in ValidStreets.txt." )
    %err_put( msg="Alternate street name spellings NOT updated." )
    %err_put( msg="Please edit the StreetAlt.xls file and rerun this program." )
    abort return;
  end;

run;

** Create $STRTALT format for correcting street names **;

%Data_to_format(
  FmtLib=Realprop,
  FmtName=$strtalt,
  Data=StreetAlt,
  Value=altname,
  Label=streetname
)

run;

endrsubmit;

signoff;

