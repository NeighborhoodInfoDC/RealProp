/**************************************************************************
 Program:  Update_sales_2012_07.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   B Losoya	
 Created:  11/13/2012
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Update Sales_master and Sales_res_clean data sets on
 Alpha with latest Ownerpt file.

 Modifications: BJL Updated for 2nd Quarter 2012 
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

rsubmit;

%Update_sales( year=2012, month=07, finalize=Y )

run;

endrsubmit;

signoff;
