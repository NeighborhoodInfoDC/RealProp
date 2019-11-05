/**************************************************************************
 Program:  Run_qtrly_sales.sas
 Library:  Realprop
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey
 Created:  06/03/16
 Version:  SAS 9.4
 Environment:  Windows 
 
 Description:  Run primary quarterly housing programs

 Modifications:
 11/05/19 LH Update path to default.
 
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;

%DCData_lib( RealProp )
%Init_macro_vars( rpt_yr=2019, rpt_qtr=2, sales_qtr_offset=0 )



%include "&_dcdata_default_path\realprop\Prog\quarterly\Download_sales_clean.sas";
%include "&_dcdata_default_path\realprop\Prog\quarterly\Qtrly_sales.sas";
%include "&_dcdata_default_path\realprop\Prog\quarterly\Qtrly_sales_ward.sas";
%include "&_dcdata_default_path\realprop\Prog\quarterly\Table1.sas";
%include "&_dcdata_default_path\realprop\Prog\quarterly\Table4.sas";
