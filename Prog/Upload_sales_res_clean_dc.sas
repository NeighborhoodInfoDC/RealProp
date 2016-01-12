/**************************************************************************
 Program:  Upload_sales_res_clean_dc.sas
 Library:  HMDA
 Project:  DC Data Warehouse
 Author:   Audrey Droesch	
 Created:  May 14, 2005
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description: Uploading rpta datasets and formats to Alpha 

 Modifications:
  08/26/05 PAT Added full geographic identifiers, UI_PROPTYPE, SALEDATE_YR 
               Use older tract, cluster IDs if parcel not in Ownerpt_geo.
               (Temporary fix until can improve coverage of Ownerpt_geo)
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp );

rsubmit;

proc upload status=no
	data=realprop.newdcsales_geo_200503
	out=sales_res_clean_dc;
run;

** Correct problem with length of SSL var **;;

data sales_res_clean_dc_2;

  length ssl_new $ 17;

  set sales_res_clean_dc;

  ssl_new = left( ssl );
  
  rename ssl_new=ssl;
  
  drop ssl;

run;

proc sort data=sales_res_clean_dc_2;
  by ssl saledate;

** Add geographic information **;

data RealProp.Sales_res_clean_dc
       (label='Property sales history, residential (single family & condo) parcels, cleaned, sales through 01/27/2005, DC'
        sortedby=ssl saledate
       );

  merge 
    sales_res_clean_dc_2 (in=in1 rename=(geo2000=geo2000_old))
    Realprop.Ownerpt_geo (drop=ownerpt_extractdat);
  by ssl;

  if in1;

  ** Add UI property type code **;
  
  %Ui_proptype
  
  ** Year of sale **;
  
  saledate_yr = year( saledate );
  
  **** TEMPORARY FIX UNTIL WE CAN IMPROVE OWNERPT_GEO COVERAGE ****;
  
  if missing( geo2000 ) then geo2000 = geo2000_old;
  
  if missing( Cluster_tr2000 ) and not( missing( clusterui ) ) then 
    Cluster_tr2000 = put( clusterui, z2. );
    
  *****************************************************************;
  
  format acceptcode $accept.;
  
  label
    geo2000_old = 'Census 2000 Tract ID: ssccctttttt [OLD]'
    saledate_yr = 'Year of property sale date'
    saledate = 'Property sale date'
    saleprice = 'Property sale price ($)'
    clusnew = 'City cluster ID assigned by UI [OLD]'
    lot= 'Lot'
	square= 'Square'
	suffix= 'Suffix'
  ;

run;

x "purge [dcdata.realprop.data]sales_res_clean_dc.*";

** Register file with metadata system **;

%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=sales_res_clean_dc,
  creator_process=cluster assignment HNC05_2.sas,
  restrictions=none,
  revisions=%str(Use older tract, cluster IDs if parcel not in Ownerpt_geo. Added full geographic identifiers, vars UI_PROPTYPE & SALEDATE_YR.)
)

** Descriptive info **;

%file_info( data=RealProp.sales_res_clean_dc )

proc format;
  value $blank
    ' ' = 'Blank'
    other = 'Nonblank';

proc freq data=RealProp.sales_res_clean_dc;
  tables saledate saledate_yr 
         geo2000 Cluster_tr2000 
         proptype usecode saletype Ui_proptype 
         / missing;
  format saledate yyq. geo2000 $blank.;

run;

endrsubmit;

signoff;
