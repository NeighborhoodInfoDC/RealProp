/**************************************************************************
 Program:  Parcel_geo_ownerpt_2014_01.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  6-30-14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Update Parcel_geo with new parcels from Ownerpt.

 Modifications:
  07/27/14 PAT Changed update_file= parameter to Ownerpt_2014_01.
               Program not rerun.
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )

%Parcel_geo_update( update_file=Ownerpt_2014_01, finalize=Y )

run;

