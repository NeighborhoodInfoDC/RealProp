/**************************************************************************
 Program:  Max_afford_price.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/06/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Autocall macro function to calculate maximum
 affordable home purchase price from given income. 

 Default parameters are standard assumptions for a first-time 
 homebuyer with 30-year fixed rate mortgage, 10% downpayment, and PMI.

 Return value: Maximum affordable purchase price (numeric).
 
 Example use (in a data step):
 
   price = %max_afford_price( annual_inc=201010, annual_int_rate=4.62 );

 Modifications:
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

