/**************************************************************************
 Program:  Sales_sum_cl00.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/05/06
 Version:  SAS 9.2
 Environment:  Remote Windows session (SAS1)
 
 Description:  Create summary property sales indicators for 
 Cluster2000.
 
 Adapted from Sales_sum_all.sas.

 Modifications:
  04/02/07 PAT Added remaining geographies.
  01/29/07 PAT Added support for partial year data.
  04/20/09 PAT Updated for 2008 data.
  09/01/12 PAT Added new geos: Anc2012, Psa2012, Geo2010, Ward2012.
               Removed geos Casey_nbr2003 and Casey_ta2003.
  09/09/12 PAT Added register= parameter for testing.
               Special update for new 2010/2012 geos.
  01/13/14 PAT  Updated for new SAS1 server.
  03/30/14 PAT Added voterpre2012 summary. 
  07/28/14 PAT Updated for sales through 2013-Q4.
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp, local=n )

/**rsubmit;**/

/** Update with latest full year and quarter of sales data available **/
%let end_yr = 2013;
%let end_qtr = 4;

/** Change to N for testing, Y for final batch mode run **/
%let register = N;

/** Leave this macro var blank unless doing a special update **/
%let revisions_sales_sum = ;


%************  DO NOT CHANGE BELOW THIS LINE  ************;

%**** Initialize macro variables ****;

%let register = %upcase( &register );

%let start_yr = 1995;
%let start_date = "01jan&start_yr"d;

%let end_date = %sysfunc( intnx( QTR, "01jan&end_yr"d, %eval( &end_qtr - 1 ), END ) );
%put end_date = %sysfunc( putn( &end_date, mmddyy10. ) );

%let lib  = RealProp;
%let data = Sales_res_clean;

proc sql noprint;
  select 
    left( put( datepart( modate ), worddatx12. ) ), 
    left( put( timepart( modate ), timeampm8. ) ) 
  into :filemod_dt, :filemod_tm
  from dictionary.tables
  where libname=%upcase("&lib") and memname=%upcase("&data");
quit;

*options obs=200;

data Sales (compress=no);

  set &lib..&data;
  where &start_date <= saledate <= &end_date;

  saledate_yr = year( saledate );
  
  sales_tot = 1;
  sales_sf = 0;
  sales_condo = 0;
  
  %dollar_convert( saleprice, r_mprice_tot, saledate_yr, &end_yr )
  
  select ( ui_proptype );
    when( '10' ) do;      *** Single family homes ***;
      mprice_sf = saleprice;
      r_mprice_sf = r_mprice_tot;
      sales_sf = 1;
    end;
    when( '11' ) do;      *** Condominiums ***;
      mprice_condo = saleprice;
      r_mprice_condo = r_mprice_tot;
      sales_condo = 1;
    end;
  end;
  
  format saleprice ;
  
  rename saleprice = mprice_tot;
  
run;

/** Macro Summarize - Start Definition **/

%macro Summarize( level= );

%let level = %upcase( &level );

%if %sysfunc( putc( &level, $geoval. ) ) ~= %then %do;
  %let filesuf = %sysfunc( putc( &level, $geosuf. ) );
  %let level_lbl = %sysfunc( putc( &level, $geolbl. ) );
  %let level_fmt = %sysfunc( putc( &level, $geoafmt. ) );
%end;
%else %do;
  %err_mput( macro=Summarize, msg=Level (LEVEL=&level) is not recognized. )
  %goto exit;
%end;

** Summarize by specified geographic level **;

proc summary data=Sales nway completetypes;
    class &level /preloadfmt;
    class saledate_yr;
    format &level &level_fmt;
  var sales_: mprice_: r_mprice_: ;
  output 
    out=Sales&filesuf (drop=_freq_ _type_  compress=no) 
    sum(sales_:)=
    median(mprice_: r_mprice_:)=;
  label
    sales_tot = "Number of sales, s.f. & condo"
    sales_sf = "Number of sales, single-family"
    sales_condo = "Number of sales, condominiums"
    mprice_tot = "Median sales price ($), s.f. & condo"
    mprice_sf = "Median sales price ($), single-family"
    mprice_condo = "Median sales price ($), condominiums"
    r_mprice_tot = "Median sales price (&end_yr $), s.f. & condo"
    r_mprice_sf = "Median sales price (&end_yr $), single-family"
    r_mprice_condo = "Median sales price (&end_yr $), condominiums";
  
run;

** Recode missing number of sales to 0 **;

data Sales&filesuf (compress=no);

  set Sales&filesuf;
  
  array a_sales{*} sales_: ;
  
  do i = 1 to dim( a_sales );
    if missing( a_sales{i} ) then a_sales{i} = 0;
  end;
  
  drop i;
  
run;

%let file_lbl = Property sales summary, residential (single-family & condo), &start_yr to &end_yr-Q&end_qtr, DC, &level_lbl;

%Super_transpose( 
  data=Sales&filesuf,
  out=Realprop.Sales_sum&filesuf (label="&file_lbl" sortedby=&level),
  var=
    sales_tot sales_sf sales_condo 
    mprice_tot mprice_sf mprice_condo
    r_mprice_tot r_mprice_sf r_mprice_condo,
  id=saledate_yr,
  by=&level,
  mprint=y
)

quit;

%if &end_qtr < 4 %then %do;
  proc datasets library=RealProp memtype=(data) nolist;
    modify Sales_sum&filesuf;
    label
      sales_tot_&end_yr = "Number of sales, s.f. & condo, &end_yr-Q&end_qtr"
      sales_sf_&end_yr = "Number of sales, single-family, &end_yr-Q&end_qtr"
      sales_condo_&end_yr = "Number of sales, condominiums, &end_yr-Q&end_qtr"
      mprice_tot_&end_yr = "Median sales price ($), s.f. & condo, &end_yr-Q&end_qtr"
      mprice_sf_&end_yr = "Median sales price ($), single-family, &end_yr-Q&end_qtr"
      mprice_condo_&end_yr = "Median sales price ($), condominiums, &end_yr-Q&end_qtr"
      r_mprice_tot_&end_yr = "Median sales price (&end_yr $), s.f. & condo, &end_yr-Q&end_qtr"
      r_mprice_sf_&end_yr = "Median sales price (&end_yr $), single-family, &end_yr-Q&end_qtr"
      r_mprice_condo_&end_yr = "Median sales price (&end_yr $), condominiums, &end_yr-Q&end_qtr";
  quit;
%end;

/**x "purge [dcdata.realprop.data]Sales_sum&filesuf..*";**/

%file_info( data=RealProp.Sales_sum&filesuf, printobs=0 )

run;

** Register metadata **;

%if &register = Y %then %do;

  %if &revisions_sales_sum = %then 
    %let revisions = Updated through &end_yr-Q&end_qtr with &lib..&data (%trim(&filemod_dt), %trim(&filemod_tm)).;
  %else 
    %let revisions = &revisions_sales_sum;

  %put revisions=&revisions;

  %Dc_update_meta_file(
    ds_lib=RealProp,
    ds_name=Sales_sum&filesuf,
    creator_process=Sales_sum_all.sas,
    restrictions=None,
    revisions=%str(&revisions)
  )
  
%end;

run;

%exit:

%mend Summarize;

/** End Macro Definition **/

%Summarize( level=cluster2000 )

run;

/**endrsubmit;**/

/**signoff;**/

