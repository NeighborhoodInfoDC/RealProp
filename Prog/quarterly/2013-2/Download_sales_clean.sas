/**************************************************************************
 Program:  Download_sales_clean.sas
 Library:  Realprop
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  9/18/09
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Download latest sales data for Housing Monitor report.
 WINTER 2013

 Modifications:
  07/09/13 LH  Moved from HsngMon Library to RealProp
  06/26/14 MW  Moved to L drive and updated for SAS1 Server
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;

%DCData_lib( RealProp )

%Init_macro_vars( rpt_yr=2013, rpt_qtr=2, sales_qtr_offset=0 )

%let data = Sales_res_clean;
%let out  = Sales_clean_&g_rpt_yr._&g_rpt_qtr;

** Get data from a year earlier for neighborhood cluster table **;

data _null_;
  start_dt=intnx('year',&g_sales_start_dt,-1,'sameday');
  put start_dt= mmddyy.;
  call symput( 'start_dt', start_dt );
run;


** Start submitting commands to remote server **;


*options obs=100;
%let end_dt=&g_sales_end_dt;
data realpr_l.&out (label="Clean property sales for &g_rpt_title DC Quarterly Sales Data" compress=no);

  set realpr_r.&data;
  where &start_dt <= saledate <= &end_dt;
  
  saledate_yr = year( saledate );
  
  %dollar_convert( saleprice, saleprice_adj, saledate_yr, &g_sales_end_yr, series=CUUR0000SA0L2 )
  
  pct_owner_occ_sale = 100 * owner_occ_sale;

  label
    saledate_yr = "Property sale year"
    saleprice_adj = "Property sale price (&g_sales_end_yr $)"
    pct_owner_occ_sale = "Pct. owner-occupied sale";

  keep ssl saleprice saledate ui_proptype ward2012 cluster_tr2000 geo2000 saledate_yr owner_occ_sale
       saleprice_adj pct_owner_occ_sale ;

run;


** End submitting commands to remote server **;

%file_info( data=realpr_l.&out, printobs=20, 
            freqvars=ward2012 cluster_tr2000 ui_proptype saledate_yr owner_occ_sale )

proc freq data=realpr_l.&out;
  tables saledate;
  format saledate yyq.;

proc tabulate data=realpr_l.&out missing noseps;
  var pct_owner_occ_sale;
  class saledate_yr;
  table all='Total' saledate_yr=' ', pct_owner_occ_sale * (n nmiss mean);
run;


