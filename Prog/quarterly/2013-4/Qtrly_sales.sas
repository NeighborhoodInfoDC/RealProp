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
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )

%Init_macro_vars( rpt_yr=2013, rpt_qtr=4, sales_qtr_offset=0)

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

