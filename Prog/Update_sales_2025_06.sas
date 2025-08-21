/**************************************************************************
 Program:  Update_sales_2025_06.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Rodrigo G
 Created:  8/20/25
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description:  Update Sales_master and Sales_res_clean data sets 
 with latest Ownerpt file.

 Modifications:
**************************************************************************/

%include "F:\DCData\SAS\Inc\StdRemote.sas";

** Define libraries **;
%DCData_lib( RealProp )
%DCData_lib( MAR )


%Update_sales( year=2025, month=06 )


run;

