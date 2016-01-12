/**************************************************************************
 Program:  Parcel_geo_ownerpt_yyyy_mm.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   
 Created:  
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Update Parcel_geo with new parcels from Ownerpt.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )

options mprint nosymbolgen mlogic;

%Parcel_geo_update( update_file=Ownerpt_2013_03, finalize=Y )

run;

