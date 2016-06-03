 filename lognew "&_dcdata_l_path\RealProp\Prog\Quarterly\Table1.log";
 filename outnew "&_dcdata_l_path\RealProp\Prog\Quarterly\Table1.lst";
 proc printto print=outnew log=lognew new;
 run;
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
 07/15/14 MSW Updated for new SAS1 server and updated for Winter 2013. 
 06/03/16 LH  Packaged quarterly programs together. 
**************************************************************************/


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
proc printto;
run;
