/**************************************************************************
 Program:  Parcel_geo_ownerpt_2012_06.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   R Grace		
 Created:  08/03/2012
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Update Parcel_geo with new parcels from Ownerpt.

 Modifications: Updated with 2012_06 ownerpt data
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

%Parcel_geo_update( update_file=Ownerpt_2012_06, finalize=Y)

run;

signoff;
