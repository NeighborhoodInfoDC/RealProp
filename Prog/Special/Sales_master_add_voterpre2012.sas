/**************************************************************************
 Program:  Sales_master_add_voterpre2012.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/29/14
 Version:  SAS 9.2
 Environment:  Remote Windows session (SAS1)
 
 Description:  Add voterpre2012 to RealProp.Sales_master.

 Modifications:
**************************************************************************/

%include "F:\DCData\SAS\Inc\StdRemote.sas";

** Define libraries **;
%DCData_lib( RealProp )

%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=Sales_master,
  creator=blosoya,
  creator_process=Update_sales_2013_09.sas,
  restrictions=None,
  revisions=%str(Updated with Realprop.ownerpt_2013_09 (corrected).)
)

data Sales_master (label="Property sales master file, sales through 08/23/2013, DC");

  set RealProp.Sales_master;
  
  %Block10_to_vp12()

run;

proc datasets library=RealProp memtype=(data);
  change Sales_master=xxx_Sales_master /memtype=data;
  copy in=work out=RealProp memtype=data;
    select Sales_master;
quit;

%File_info( data=RealProp.Sales_master, printobs=0, freqvars=voterpre2012 )

%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=Sales_master,
  creator_process=Sales_master_add_voterpre2012.sas,
  restrictions=None,
  revisions=%str(Added var voterpre2012 to data set.)
)
