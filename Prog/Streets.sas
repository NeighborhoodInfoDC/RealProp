/**************************************************************************
 Program:  Streets.sas
 Library:  RealProp
 Project:  DC Data Warehouse
 Author:   P. Tatian
 Created:  03/02/05
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect

 Description:  Create data set with list of unique DC street names.
               Create format $STVALID for validating street names.

 Modifications:
  04/06/05  Street name cleaning now done in main parcel file.
            No longer creates permanent data set.
  04/20/05  Creates ValidStreets.txt file with list of street names.
  06/07/06  Print contents of format library after creating format.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

rsubmit;

*options obs=100;

data Streets;

  set Realprop.OWNERPT_2005_03 (keep=ustreetname);

  where ustreetname ~= "";

run;

proc sort
  data=Streets
  nodupkey;
  by ustreetname;

run;

%File_info( data=Streets, printobs=40, stats= );

** Create $STVALID format for validating street names **;

title2 "Remote RealProp format library";

%Data_to_format(
  FmtLib=Realprop,
  FmtName=$stvalid,
  Data=Streets,
  Value=ustreetname,
  Label=ustreetname,
  OtherLabel=" ",
  Print=N,
  Desc="Geocoding/valid street names",
  Contents=Y
)

run;
title2;

proc download status=no
  data=Streets 
  out=Streets;

run;

endrsubmit;

** Print list of street names for reference **;

filename fexport "K:\Metro\PTatian\DCData\Libraries\RealProp\Prog\ValidStreets.txt" lrecl=256;

proc export data=Streets
    outfile=fexport
    dbms=csv replace;

run;

signoff;

