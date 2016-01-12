/**************************************************************************
 Program:  Table1.sas
 Library:  Realprop
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  9/18/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create Table DC Sales by Ward (Old HsngMon Table 1)
 

 Modifications:
 07/09/13 LH Moved from HsngMon library to Realprop.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Realprop )

%Init_macro_vars( rpt_yr=2012, rpt_qtr=3, sales_qtr_offset=0 )

%Make_sales_formats()

******  Single family  ******;

%Table1_data( ui_proptype='10' )

** Number of sales **;

%Table1_output( start_row=12, var=avg_sales, data=avg_sales )

** Median sales price **;

%Table1_output( start_row=20, var=saleprice_adj, data=avg_sales, fmt=lblA. )

** Percent change, median sales price **;

%Table1_output( start_row=28, var=price_chg, data=sales_chg, fmt=lblB. )

** Owner-occupied sales **;

%Table1_output( start_row=33, var=owner_occ_sale_mean, data=own_occ_sales, fmt=lst4qtr. )


******  Condominiums  ******;

%Table1_data( ui_proptype='11' )

** Number of sales **;

%Table1_output( start_row=41, var=avg_sales, data=avg_sales )

** Median sales price **;

%Table1_output( start_row=49, var=saleprice_adj, data=avg_sales, fmt=lblA. )

** Percent change, median sales price **;

%Table1_output( start_row=57, var=price_chg, data=sales_chg, fmt=lblB. )

** Owner-occupied sales **;

%Table1_output( start_row=62, var=owner_occ_sale_mean, data=own_occ_sales, fmt=lst4qtr. )


run;
