/**************************************************************************
 Program:  Parcel_geo_ownerpt_2013_01.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   R Grace
 Created:  04/03/2013
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Update Parcel_geo with new parcels from Ownerpt.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

%Parcel_geo_update( update_file=Ownerpt_2013_01, finalize=Y )

run;

signoff;
