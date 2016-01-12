/**************************************************************************
 Program:  Update_sales_yyyy_mm.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   
 Created:  
 Version:  SAS 9.2
 Environment:  Remote Windows session (SAS1)
 
 Description:  Update Sales_master and Sales_res_clean data sets on
 Alpha with latest Ownerpt file.

 Modifications:
**************************************************************************/

%include "F:\DCData\SAS\Inc\StdRemote.sas";

** Define libraries **;
%DCData_lib( RealProp )

options mprint symbolgen mlogic;

%Update_sales( year=2013, month=03, finalize=Y )


proc compare base=RealProp.Sales_master compare=work.TEST_MASTER_03_2013 maxprint=(40,32000) novalues;
  id ssl sale_num;
run;

proc compare base=RealProp.Sales_res_clean compare=WORK.TEST_SALES_03_2013 maxprint=(40,32000) novalues;
  id ssl sale_num;
run;
