/**************************************************************************
 Program:  Update_sales_2009_11.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   A. Williams
 Created:  1/6/10
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Update Sales_master and Sales_res_clean data sets on
 Alpha with latest Ownerpt file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

rsubmit;

%Update_sales( year=2009, month=11, finalize=Y )

run;

endrsubmit;

signoff;
