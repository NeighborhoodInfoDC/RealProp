/**************************************************************************
 Program:  Occ_afford_sales.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/05/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Determine share of affordable home and condo sales by
occupation wage levels.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )
%DCData_lib( Ipums )

** Select cases for highlighting **;

data Renter_hhlds;

  merge 
    Ipums.Acs_2011_dc
      (keep=serial pernum ownershpd occ hhtype gq hhincome hud_inc nchild numprec rentgrs hhwt raced related relate age
            sex hispan uhrswork wkswork2
       where=(ownershpd in ( 21, 22 ) and gq in ( 1, 2 ))
       in=in1)
    Ipums.Acs_2011_fam_pmsa99;
  by serial;
    
  if in1;
  
  if ( pernum = 1 or ( related in ( 101, 201, 1114 ) ) ) and age >= 16 then is_hhh_spouse = 1;
  else is_hhh_spouse = 0;
  
  if uhrswork >= 35 and wkswork2 = 6 then is_ft_worker = 1;
  else is_ft_worker = 0;

  format occ occac10f.;

run;

proc means data=Renter_hhlds;

proc tabulate data=Renter_hhlds (where=(pernum=1)) format=comma12.0 noseps missing;
  class hud_inc;
  var hhincome;
  weight hhwt;
  table 
    /** Rows **/
    hud_inc=' ',
    /** Columns **/
    n
    hhincome * ( median min max )
  ;
run;

proc univariate data=Renter_hhlds;
  where pernum = 1;
  var hhincome rentgrs;
run;

proc freq data=Renter_hhlds order=freq;
  where is_ft_worker and is_hhh_spouse;
  tables numprec nchild hhtype hud_inc uhrswork wkswork2 occ /nocum;
  weight hhwt;
  format occ occac10f.;
run;

proc print data=Renter_hhlds (obs=50);
  where hud_inc = 2 and is_ft_worker and is_hhh_spouse;
  id serial;
  by hud_inc;
  var hhincome occ;
  format occ occac10f60.;
  /*
  var occ numprec hhtype hhincome raced;
  format occ ;
  */
run;

proc print data=Renter_hhlds (obs=50);
  where hud_inc = 3 and is_ft_worker and is_hhh_spouse;
  id serial;
  by hud_inc;
  var hhincome occ;
  format occ occac10f60.;
  /*
  var occ numprec hhtype hhincome raced;
  format occ ;
  */
run;

proc print data=Renter_hhlds (obs=50);
  where hud_inc = 4 and is_ft_worker and is_hhh_spouse;
  id serial;
  by hud_inc;
  var hhincome occ;
  format occ occac10f60.;
  /*
  var occ numprec hhtype hhincome raced;
  format occ ;
  */
run;

proc print data=Renter_hhlds (obs=50);
  where hud_inc = 5 and is_ft_worker and is_hhh_spouse;
  id serial;
  by hud_inc;
  var hhincome occ;
  format occ occac10f60.;
  /*
  var occ numprec hhtype hhincome raced;
  format occ ;
  */
run;

proc sort data=Renter_hhlds out=Renter_hhlds_select;
  where serial in ( 255910, 256428, 256556, 256402, 257156, 257196, 256167, 256246, 256409, 255938, 256099, 256472, 256185, 256340, 256265 )
        and is_hhh_spouse;
  by hud_inc;
run;

proc print data=Renter_hhlds_select;
  id serial;
  by hud_inc;
  var occ numprec hhtype hhincome raced hispan is_ft_worker;
  format occ occac10f.;
run;

%let serial_select = serial in ( 256428, 257156, 256265, 255938 );


** Household details **;

title2 '---FINAL HOUSEHOLD SELECTIONS---';

proc print data=Renter_hhlds;
  where pernum = 1 and &serial_select;
  id serial;
  var numprec hhtype hhincome hud_inc raced hispan;
run;

proc print data=Renter_hhlds;
  where &serial_select;
  by serial;
  id pernum;
  var occ is_ft_worker age sex relate;
  format occ occac10f.;
run;

%let EFF_INT_RATE = 4.62;

** Calculate maximum affordable home price **;

data A;

  set Renter_hhlds (keep=serial hhincome pernum);
  where pernum = 1 and &serial_select;

  max_price = %max_afford_price( annual_inc=hhincome, annual_int_rate=&EFF_INT_RATE );
  
run;

proc print data=A;
  id serial;
run;

data Sales; 

  set RealProp.Sales_res_clean
    (keep=saledate saleprice ward2012
     where=(year(saledate)=2011));

run;

/** Macro afford_sales - Start Definition **/

%macro afford_sales( max_price );

  proc format;
    value afford_sales
      low-&max_price = 'Affordable'
      &max_price<-high = 'Not affordable';
  run;

  proc freq data=sales;
    tables saleprice;
    format saleprice afford_sales.;
    title3 "Max price = &max_price";
    title4 "Affordable sales in all wards";
  run;

  proc freq data=sales;
    where ward2012 in ( '7', '8' );
    tables saleprice;
    format saleprice afford_sales.;
    title4 'Affordable sales in wards 7 and 8';
  run;
  
  title3;

%mend afford_sales;

/** End Macro Definition **/

%afford_sales( 143943.76 )
%afford_sales( 160965.39 )
%afford_sales( 277526.53 )
%afford_sales( 407038.91 )

title2;

