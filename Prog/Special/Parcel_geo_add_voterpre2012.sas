/**************************************************************************
 Program:  Parcel_geo_add_voterpre2012.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/28/14
 Version:  SAS 9.2
 Environment:  Remote Windows session (SAS1)
 
 Description:  Add voterpre2012 to Parcel_geo.

 Modifications:
**************************************************************************/

%include "F:\DCData\SAS\Inc\StdRemote.sas";

** Define libraries **;
%DCData_lib( RealProp )

data Parcel_geo (label="DC real property parcels - geographic identifiers");

  set RealProp.Parcel_geo;
  
  %Block10_to_vp12()

run;

proc datasets library=RealProp memtype=(data);
  change Parcel_geo=xxx_Parcel_geo /memtype=data;
  copy in=work out=RealProp memtype=data;
    select Parcel_geo;
quit;

%File_info( data=RealProp.Parcel_geo, freqvars=voterpre2012 )

%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=Parcel_geo,
  creator_process=Parcel_geo_add_voterpre2012.sas,
  restrictions=None,
  revisions=%str(Added var voterpre2012 to data set.)
)

