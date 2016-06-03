 filename lognew "&_dcdata_l_path\RealProp\Prog\Quarterly\Qtrly_sales.log";
 filename outnew "&_dcdata_l_path\RealProp\Prog\Quarterly\Qtrly_sales.lst";
 proc printto print=outnew log=lognew new;
 run;
/**************************************************************************
 Program:  Qtrly_sales.sas
 Library:  Realprop
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  9/19/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Single-family home and condominium quarter-to-
 quarter sales trends. (Old HsngMon Figure 1)
 
 Modifications:
 07/09/13 LH Moved from HsngMon library to Realprop.
 06/03/16 LH  Packaged quarterly programs together. 
**************************************************************************/


%Make_sales_formats()



proc tabulate data=Realprop.Sales_clean_&g_rpt_yr._&g_rpt_qtr format=comma16. noseps missing;
  where cluster_tr2000 ~= '' and Ward2012 ~= '' and put( saledate, dtrngB. ) ~= '';
  class saledate ui_proptype;
  var saleprice_adj;
  table 
    ui_proptype=' ',
    saledate='By quarter', 
    n='Number of sales'
    saleprice_adj="Price ($ &g_sales_end_yr)" * median=' '
    / box=_page_ row=float condense;
  format saledate dtrngB. ui_proptype $uiprtyp.;

run;

proc printto;
run;
