/**************************************************************************
 Program:  Update_sales_2013_09.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   B Losoya	
 Created:  02/03/2014
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Update Sales_master and Sales_res_clean data sets on
 Alpha with latest Ownerpt file.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )



%Update_sales( year=2013, month=09, finalize=Y )

run;


