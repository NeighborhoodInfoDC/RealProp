/**************************************************************************
 Program:  Update_sales_2019_09.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Eleanor Noble
 Created:  10/28/2019
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


%Update_sales( year=2019, month=09, finalize = N )


run;

