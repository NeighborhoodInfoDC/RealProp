/**************************************************************************
 Program:  StreetAlt.sas
 Library:  RealProp
 Project:  DC Data Warehouse
 Author:   P. Tatian
 Created:  04/21/05
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)

 Description:  Create data set with alternate street spellings
               (i.e., corrections) for parcel geocoding.
               
 NB:  The file L:\Libraries\RealProp\Prog\Geocode\StreetAlt.xls
      must be open before running this program.
      
 NB:  Do NOT make changes to this program without asking Peter Tatian first.

 Modifications:
  06/07/06  Print contents of format library after creating format.
  10/13/14  Updated for SAS1.
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp, local=n )

filename xin dde "excel|&_dcdata_r_path\RealProp\Geocode\[StreetAlt.xls]StreetAlt!r6c1:r5000c2" lrecl=256 notab;

data StreetAlt;

  length streetname altname $ 50;
  
  infile xin missover dsd dlm='09'x;

  input altname streetname;

  streetname = left( compbl( upcase( streetname ) ) );
  altname = left( compbl( upcase( altname ) ) );

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
  Label=streetname,
  DefaultLen=40,
  Desc="Geocoding/alt. street name spellings",
  Contents=Y
)

run;

