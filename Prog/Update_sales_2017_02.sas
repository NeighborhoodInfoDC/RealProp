/**************************************************************************
 Program:  Update_sales_2017_02.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  2-7-17
 Version:  SAS 9.4
 
 Description:  Update Sales_master and Sales_res_clean data sets on
 SAS1 with latest Ownerpt file.

 Modifications:
**************************************************************************/

*%include "F:\DCData\SAS\Inc\StdRemote.sas";
%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )
%DCData_lib( MAR )

%Update_sales( year=2017, month=02, finalize=N )

run;

