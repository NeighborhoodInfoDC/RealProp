************************************************************************
* Program:  RealProp_formats_salecod.sas
* Library:  RealProp
* Project:  DC Data Warehouse
* Author:   L Hendey
* Created:  1/15/10
* Version:  SAS 9.1
* Environment:  PC
* 
* Description:  Add sales code  format for real property data
***********;

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

proc format library=Realprop;
value salecod
                                                                                                           
1="Trustees Deed (matching sale) and REO"
2="Trustees Deed (matching sale) and Not REO"
3="Trustees Deed (no matching sale) and REO"
4="Trustees Deed (no matching sale) and Not REO"
5="Distressed Sale & REO"
6="Distressed Sale & not REO"
7="Market Sale (more than a year after last Fc/default notice)"
8="Market Sale - no previous fc/default episode"
9="REO Exit"
10="REO Transfer"
11="Buyer=Seller"
12="Other";

value salesht

1="Market Sale"
2="REO Entry"
3="Foreclosure (non REO)"
4="Distressed (non REO)"
5="REO Exit"
6="Other Non-Market"
;

value outsale

0="No Foreclosure Episode"
1="Currently In Foreclosure"
2="Completed Foreclosure"
3="Distressed Sale"
4="Avoided Foreclosure"
;
run;

proc catalog catalog=RealProp.Formats;
  modify salecod (desc="Sale Code (Market, REO, Etc.)")  / entrytype=format;
  modify salesht (desc="Sale Code - Collapsed Categories")  / entrytype=format;
  modify outsale (desc="Collapsed Foreclosure Episode Outcome Code") / entrytype=format;
  contents;
quit;

** Start submitting commands to remote server **;

rsubmit;

proc upload status=no
  inlib=REALPROP 
  outlib=REALPROP memtype=(catalog);
  select formats;
run;

proc catalog catalog=REALPROP.Formats;
  contents;
quit;

run;

endrsubmit;

** End submitting commands to remote server **;

run;

signoff;
