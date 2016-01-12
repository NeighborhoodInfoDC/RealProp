/**************************************************************************
 Program:  Cleaning_summary.sas
 Library:  RealProp
 Project:  DC Data Warehouse
 Author:   P. Tatian
 Created:  02/11/07
 Version:  SAS 9.1
 Environment:  Alpha only

 Description: Summary of cleaning exclusions for sales.

 Modifications:
  11/20/07 PAT Changed Pct. Clean (of Master) to Pct. Market (of Master).
  02/16/09 PAT Use market_sale var now stored in Sales_master
  02/03/14 PAT Updated for new SAS1 server.
**************************************************************************/

%macro Cleaning_summary( master=, clean= );

data Master_clean (compress=no);

  set 
    &master       (keep=ssl saledate saleprice ui_proptype acceptcode saletype ratio landarea market_sale
        where=(&propType_code and &saledate_code) 
        in=inMaster)
    &clean
       (keep=ssl saledate saleprice ui_proptype acceptcode saletype ratio landarea
        in=inCleanSales);

    if inMaster then type = 1;
    else type = 2;

    in_Master = inMaster;
    in_CleanSales = inCleanSales;

run;

proc format;
  value type
    1 = 'Master'
    2 = 'Clean';

proc tabulate data=Master_clean format=comma10.0 noseps missing;
  class saledate ui_proptype;
  var in_Master Market_sale in_CleanSales;
  format saledate year4. ui_proptype $UIPRTYP.;
  table
    all='Single-Family Homes & Condominiums' ui_proptype=' ',
    all='Total' saledate=' ',
    sum='Number of sales' * ( in_Master='Master' Market_sale='Market' in_CleanSales='Clean' )
    pctsum<in_Master>='Pct. Market (of Master)' * Market_sale=' ' * f=comma10.1
    pctsum<Market_sale>='Pct. Clean (of Market)' * in_CleanSales=' ' * f=comma10.1
  ;
 title2 "Sales Cleaning Summary";
run;
title2;

%mend Cleaning_summary;
