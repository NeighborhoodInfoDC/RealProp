/**************************************************************************
 Program:  Parcel_geo_ownerpt_2019_09.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Eleanor Noble
 Created:  10/8/2019
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Update Parcel_geo with new parcels from Ownerpt.

 Modifications:
  07/27/14 PAT  Added local=n parameter to %DCData_lib() to prevent 
                creation of local library reference. 
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp, local=n )

%Parcel_geo_update( update_file=Ownerpt_2019_09, finalize=N )

run;

