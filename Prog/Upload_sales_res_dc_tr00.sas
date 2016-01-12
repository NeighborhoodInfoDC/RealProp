/**************************************************************************
 Program:  Upload_finalrpta_t.sas
 Library:  HMDA
 Project:  DC Data Warehouse
 Author:   Audrey Droesch	
 Created:  May 25, 2005
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description: Uploading rpta datasets and formats to Alpha 

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries (local=inlib in upload step)**;
%DCData_lib( RealProp );

rsubmit;
proc upload status=no
	inlib=RealProp 
	outlib=RealProp memtype=(data);
	select sales_res_dc_tr00;
run;


	


%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=sales_res_dc_tr00,
  creator_process=rpta_indicators.sas,
  restrictions=none,
  revisions=Initial file creation.
);

proc upload status=no
	inlib=RealProp 
	outlib=RealProp memtype=(data);
	select sales_res_dc_city;
run;


	


%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=sales_res_dc_city,
  creator_process=rpta_indicators.sas,
  restrictions=none,
  revisions=Initial file creation.
);

endrsubmit;

signoff;
