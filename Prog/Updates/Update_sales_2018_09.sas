/**************************************************************************
 Program:  Update_sales_2018_09.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   
 Created:  
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description:  Update Sales_master and Sales_res_clean data sets 
 with latest Ownerpt file.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )
%DCData_lib( MAR )


%Update_sales( year=2018, month=09 )


run;

