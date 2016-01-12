/**************************************************************************
 Program:  Clean_sales.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/06/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to add cleaning vars to 
 sales transactions file.

 Modifications:
  12/31/13 PAT  Updated for new SAS1 server.
**************************************************************************/

%macro Clean_sales( inds=, outds=, cleanup=Y );

  %let cleanup = %upcase( &cleanup );

** Flag market, clean sales **;

data _Clean_market _Clean_no_market;

  set &inds;

  saledate_yr = year( saledate );

  if landarea <= 0 then landarea = .u;

  ** Flag market sales **;
  %set_where(which=SALES);
  length Market_sale 3;
  if &whereCode then Market_sale = 1;
  else Market_sale = 0;
  label Market_sale = "Single fam. home/condo market sale";
  format Market_sale dyesno.;

  if Market_sale then do;
    if new_total > 0 then Ratio = saleprice / new_total;
    output _Clean_market;
  end;
  else output _Clean_no_market;  

  label Ratio = "Ratio of sale price to total current appraised value (SALEPRICE/NEW_TOTAL)";

run;

proc sort data=_Clean_market;
  by ui_proptype saledate_yr;

proc univariate data=_Clean_market noprint;
  by ui_proptype saledate_yr;
  var saleprice landarea ratio;
  output out=_Clean_Sales_ptiles 
    n=_freq_
    p1=saleprice_p1 landarea_p1 ratio_p1 
    p99=saleprice_p99 landarea_p99 ratio_p99;
run;

proc print data=_Clean_Sales_ptiles;
  by ui_proptype;
  id saledate_yr;
  var _freq_ saleprice_p: landarea_p: ratio_p: ;
  title2 'Sales exclusion criteria';
run;
title2;

** Combine percentiles with market sales and flag excluded sales **;

data _Clean_market_excl;

  merge _Clean_market _Clean_Sales_ptiles;
  by ui_proptype saledate_yr;

  length Ratio_excluded Price_excluded Area_excluded Clean_sale 3;

  if max( saleprice_p1, &saleprice_min ) <= saleprice <= min( saleprice_p99, &saleprice_max ) then price_excluded = 0;
  else price_excluded = 1;

  if missing( landarea ) or 
     ( max( landarea_p1, &landarea_min ) <= landarea <= min( landarea_p99, &landarea_max ) ) then area_excluded = 0;
  else area_excluded = 1;

  if missing( ratio ) or 
     ( max( ratio_p1, &ratio_min ) <= ratio <= min( ratio_p99, &ratio_max ) ) then ratio_excluded = 0;
  else ratio_excluded = 1;

  Clean_sale = not( price_excluded or area_excluded or ratio_excluded );

  label
    ratio_excluded = "Market sale excluded based on price/appraised value ratio"
    price_excluded = "Market sale excluded based on price"
    area_excluded  = "Market sale excluded based on parcel land area"
    clean_sale = "Clean residential property sale";

  format ratio_excluded price_excluded area_excluded clean_sale dyesno.;

run;

** Recombine market and nonmarket transactions **;

proc sort data=_Clean_market_excl;
  by ssl sale_num;
run;

data &outds;

  set _Clean_market_excl _Clean_no_market (in=in_no_mkt);
  by ssl sale_num;

  if in_no_mkt then do;
    price_excluded = .n;
    area_excluded = .n;
    ratio_excluded = .n;
    clean_sale = .n;
  end;

run;

%if &cleanup = Y %then %do;

  ** Cleanup temporary files **;

  proc datasets nolist library=work memtype=(data);
    delete _Clean_:;
  quit;

%end;

%mend Clean_sales;


