/**************************************************************************
 Program:  Parcel_geo_ownerpt_yyyy_mm.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Irvin Mull
 Created:  9/28/2017
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

%Parcel_geo_update( update_file=Ownerpt_2017_09, finalize=Y )

run;

