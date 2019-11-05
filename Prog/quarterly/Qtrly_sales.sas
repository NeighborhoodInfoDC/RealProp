 filename lognew "&_dcdata_default_path\RealProp\Prog\Quarterly\Qtrly_sales.log";
 filename outnew "&_dcdata_default_path\RealProp\Prog\Quarterly\Qtrly_sales.lst";
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
 11/05/19 LH Update path to default and cluster2017
**************************************************************************/


%Make_sales_formats()



proc tabulate data=Realpr_l.Sales_clean_&g_rpt_yr._&g_rpt_qtr format=comma16. noseps missing;
  where cluster2017 ~= '' and Ward2012 ~= '' and put( saledate, dtrngB. ) ~= '';
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
