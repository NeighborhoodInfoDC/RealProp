/**************************************************************************
 Program:  Update_sales_2009_09.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey
 Created:  11/03/2009
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

%Update_sales( year=2009, month=09, finalize=Y )

run;

endrsubmit;

signoff;
