/**************************************************************************
 Program:  Update_sales_2021_01.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Ananya Hariharan
 Created:  February 25, 2021
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Update Sales_master and Sales_res_clean data sets on
 Alpha with latest Ownerpt file.

 Modifications:
  07/27/14 PAT  Added local=n parameter to %DCData_lib() to prevent 
                creation of local library reference. 
**************************************************************************/

%include "\\SAS1\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp, local=n )

%Update_sales( year=2021, month=01, finalize=N )

