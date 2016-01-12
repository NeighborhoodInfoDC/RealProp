/************************************************************************
 Program:  Upload_parcel_geo_2012geogs.sas
 Library:  RealProp
 Project:  DC Data Warehouse
 Author:   R. Grace
 Created:  07/30/2012
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Upload Parcel_geo dataset with 2012 geographies to Alpha.  
			   Replace current parcel_geo dataset with parcel_geo dataset 
			   containing 2012 geographies.

 Modifications:
************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp );

**Rename parcel_geo with 2012 geographies to parcel_geo**;

data realprop.parcel_geo (label = "DC real property parcels - geographic identifiers" sortedby=ssl);
	set realprop.parcel_geo_2012geogs;
run;

** Upload data set to Alpha **;

rsubmit;

proc upload status=no
  inlib=realprop 
  outlib=realprop memtype=(data);
  select parcel_geo
  ;

run;

** Purge older versions of data sets **;

options noxwait;

x "purge [dcdata.realprop.data]*.*";

** Register data set with metadata system **;

%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=parcel_geo,
  creator_process=parcel_geo.sas,
  restrictions=None,
  revisions=%str(Updated parcel_geo with new geographies geo2010 anc2012 psa2012 ward2012 GeoBG2010 GeoBlk2010 GeoBG2000.))
run;

endrsubmit;
