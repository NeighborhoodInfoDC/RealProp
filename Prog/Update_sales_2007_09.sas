/**************************************************************************
 Program:  Update_sales_2007_09.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/20/07
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

***options mprint symbolgen mlogic;

%Update_sales( year=2007, month=09, finalize=Y, debug=N )

run;

endrsubmit;

signoff;
