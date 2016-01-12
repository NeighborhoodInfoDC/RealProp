/**************************************************************************
 Program:  Streets.sas
 Library:  RealProp
 Project:  DC Data Warehouse
 Author:   P. Tatian
 Created:  03/02/05
 Version:  SAS 8.2
 Environment:  Local Windows session (desktop)

 Description:  Create data set with list of unique DC street names.
               Create format $STVALID for validating street names.

 Modifications:
  04/06/05  Street name cleaning now done in main parcel file.
            No longer creates permanent data set.
  04/20/05  Creates ValidStreets.txt file with list of street names.
  06/07/06  Print contents of format library after creating format.
  10/13/14 PAT Updated for SAS1.
               Replaced old list with L:\Libraries\RealProp\Prog\Geocode\ValidStreets - 20141013.txt.
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp, local=n )

*options obs=100;

data Streets;

  infile "L:\Libraries\RealProp\Prog\Geocode\ValidStreets - 20141013.txt" dsd stopover;

  length ustreetname $ 200;

  input ustreetname;

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

