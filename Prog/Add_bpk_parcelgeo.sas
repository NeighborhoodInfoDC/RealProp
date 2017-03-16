/**************************************************************************
 Program:  Add_bpk_parcelgeo.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  03/16/17
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description:  Add bridge park geography to current parcel geo.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )


data Parcel_geo_addbpk;
	set realprop.Parcel_geo;
	%Block10_to_bpk( );
run;

data realprop.parcel_geo_2017_03;
	set Parcel_geo_addbpk;
run;
