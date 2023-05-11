/**************************************************************************
 Program:  Update_sales_2023_05.sas
 Library:  RealProp
 Project:  Urban-Greater DC
 Author:   Rob Pitingolo
 Created:  5/11/23
 Version:  SAS 9.4
 Environment: SAS on Windows 10
 
 Description:  Update Sales_master and Sales_res_clean data sets on
 Alpha with latest Ownerpt file.

 Modifications:
**************************************************************************/

%include "\\SAS1\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )
%DCData_lib( MAR )

%Update_sales( year=2023, month=05, finalize=Y )

