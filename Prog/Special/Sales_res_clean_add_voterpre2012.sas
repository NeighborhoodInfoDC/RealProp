/**************************************************************************
 Program:  Sales_res_clean_add_voterpre2012.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/30/14
 Version:  SAS 9.2
 Environment:  Remote Windows session (SAS1)
 
 Description:  Add voterpre2012 to RealProp.Sales_res_clean.

 Modifications:
**************************************************************************/

%include "F:\DCData\SAS\Inc\StdRemote.sas";

** Define libraries **;
%DCData_lib( RealProp )

%File_info( data=RealProp.Sales_res_clean, printobs=0  )

%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=Sales_res_clean,
  creator=blosoya,
  creator_process=Update_sales_2013_09.sas,
  restrictions=None,
  revisions=%str(Updated with Realprop.ownerpt_2013_09 (corrected).)
)

data Sales_res_clean (label="Property sales, single-family & condo, cleaned, sales 01/01/1995 - 08/13/2013, DC");

  set RealProp.Sales_res_clean;
  
  %Block10_to_vp12()

run;

proc datasets library=RealProp memtype=(data);
  change Sales_res_clean=xxx_Sales_res_clean /memtype=data;
  copy in=work out=RealProp memtype=data;
    select Sales_res_clean;
quit;

%File_info( data=RealProp.Sales_res_clean, printobs=0, freqvars=voterpre2012 )

%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=Sales_res_clean,
  creator_process=Sales_res_clean_add_voterpre2012.sas,
  restrictions=None,
  revisions=%str(Added var voterpre2012 to data set.)
)


