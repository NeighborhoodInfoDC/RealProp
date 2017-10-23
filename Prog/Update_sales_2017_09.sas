/**************************************************************************
 Program:  Update_sales_2017_09.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Irvin Mull	
 Created:  10/23/2017
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description:  Update Sales_master and Sales_res_clean data sets on
 Alpha with latest Ownerpt file.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )
%DCData_lib( MAR )

%Update_sales( year=2017, month=09, finalize=N )

run;

