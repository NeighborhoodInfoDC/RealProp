/**************************************************************************
 Program:  Update_sales_2026_02.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   
 Created:  
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description:  Update Sales_master and Sales_res_clean data sets 
 with latest Ownerpt file.

 Modifications: Update for 2026 data
**************************************************************************/

%include "L:\SAS\Inc\StdRemote.sas";

** Define libraries **;
%DCData_lib( RealProp )
%DCData_lib( MAR )


%Update_sales( year=2026, month=02 )


run;

