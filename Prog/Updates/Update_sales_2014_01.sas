/**************************************************************************
 Program:  Update_sales_2014_01.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  6-30-14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Update Sales_master and Sales_res_clean data sets on
 Alpha with latest Ownerpt file.

 Modifications:
  07/27/14 PAT Changed month= parameter to 01. Program not rerun.
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";


** Define libraries **;
%DCData_lib( RealProp )

%Update_sales( year=2014, month=01, finalize=Y )

