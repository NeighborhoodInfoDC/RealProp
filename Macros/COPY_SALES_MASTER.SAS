/**************************************************************************
 Program:  Copy_sales_master.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/06/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to copy sales master file
 keeping only final variables. 

 Modifications:
  02/03/14 PAT  Updated for new SAS1 server.
**************************************************************************/

%macro Copy_sales_master( inds=, outds= );

  data &outds;

    set &inds;

    keep &id_vars &geo_vars &update_vars &no_update_vars &clean_vars 
         &owner_occ_sale_vars &prev_vars_w_suffix;

  run;
       
%mend Copy_sales_master;

