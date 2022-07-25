/**************************************************************************
 Program:  Update_sales_2022_06.sas
 Library:  RealProp
 Project:  Urban-Greater DC
 Author:   Rob Pitingolo
 Created:  July 22, 2022
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

%Update_sales( year=2022, month=06, finalize=Y )

