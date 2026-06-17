/**************************************************************************
 jenner-check bundle: Max_afford_price (RealProp/Macros/Max_afford_price.sas)

 The %max_afford_price() autocall macro from this repository is a macro
 function that returns the maximum affordable home purchase price for a
 given annual income, using the project's standard first-time-homebuyer
 assumptions (30-year fixed, 10% down, PMI). This bundle inlines the macro
 exactly as written upstream and calls it in a DATA step over a small set
 of income / interest-rate scenarios.
**************************************************************************/

%macro max_afford_price(
  annual_inc = ,           /** Annual income **/
  annual_int_rate = ,      /** Annual mortgage interest rate (%) **/
  afford_pct = 28,         /** Pct of income assumed to be affordable (%) **/
  annual_pmi_pct = 0.7,    /** Annual PMI amount as pct. of loan (%) **/
  mo_tax_ins_pct = 25,     /** Tax + insurance as pct of monthly mortgage pmt **/
  down_payment_pct = 10,   /** Mortgage downpayment (%) **/
  loan_term_mos = 360      /** Mortgage term (months) **/
);

  %local _mo_pmt _mo_int_rate _loan_mult;

  %let _mo_pmt = ( (&afford_pct) / 100 ) * ( (&annual_inc) / 12 );

  %let _mo_int_rate = (&annual_int_rate)/100/12;

  %let _loan_mult = ( (&_mo_int_rate) * ( ( 1 + (&_mo_int_rate) )**(&loan_term_mos) ) ) /
                      ( ( ( 1 + (&_mo_int_rate) )**(&loan_term_mos) ) - 1 );

  ( (&_mo_pmt) / ( ( (&_loan_mult) * (1 + ((&mo_tax_ins_pct)/100) ) +
                     ( (&annual_pmi_pct)/100/12) ) *
                   ( 1 - ( (&down_payment_pct)/100 ) ) ) )

%mend max_afford_price;

/* Caller: maximum affordable purchase price across income scenarios.
   The first row matches the worked example in the macro header
   (annual_inc=201010, annual_int_rate=4.62). */
data afford;
  length scenario $ 20;

  scenario = "Example (header)";
  annual_inc = 201010; int_rate = 4.62;
  price = %max_afford_price( annual_inc=annual_inc, annual_int_rate=int_rate );
  output;

  scenario = "Median household";
  annual_inc = 90000; int_rate = 6.50;
  price = %max_afford_price( annual_inc=annual_inc, annual_int_rate=int_rate );
  output;

  scenario = "Lower income";
  annual_inc = 55000; int_rate = 6.50;
  price = %max_afford_price( annual_inc=annual_inc, annual_int_rate=int_rate );
  output;

  scenario = "Higher income";
  annual_inc = 150000; int_rate = 5.75;
  price = %max_afford_price( annual_inc=annual_inc, annual_int_rate=int_rate );
  output;

  format price dollar14.;
run;

proc print data=afford label noobs;
  var scenario annual_inc int_rate price;
  label scenario = "Scenario" annual_inc = "Annual income"
        int_rate = "Interest rate (%)" price = "Max affordable price";
  title "Maximum affordable home price by income (RealProp %max_afford_price)";
run;
