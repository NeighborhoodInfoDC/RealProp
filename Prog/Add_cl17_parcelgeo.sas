/**************************************************************************
 Program:  Add_bpk_parcelgeo.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  03/16/17
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description:  Add cluster 2017 geography to current parcel geo.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )


data Parcel_geo_cl17;
	set realprop.Parcel_geo;
	%Block10_to_cluster17( );
run;

data realprop.Parcel_geo_2017_09;
	set Parcel_geo_cl17;
run;
