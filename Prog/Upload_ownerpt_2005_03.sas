/**************************************************************************
 Program:  Upload_ownerpt_2005_03.sas
 Library:  RealProp
 Project:  DC Data Warehouse
 Author:   P. Tatian
 Created:  04/07/05
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Upload and register real property update file for 03/2005.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

rsubmit;

%let filename = Ownerpt_2005_03;
%let revisions = %str(Added corrections for BAY LN & MONTEREY LN in USTREETNAME.);

proc upload status=no
	inlib=RealProp
	outlib=RealProp memtype=(data);
	select &filename;
run;

x "purge [dcdata.realprop.data]*.*";

proc upload status=no
	inlib=RealProp
	outlib=RealProp memtype=(catalog);
	select formats;
	
run;

%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=&filename,
  creator_process=Read_&filename..sas,
  restrictions=Confidential,
  revisions=&revisions
);

endrsubmit;

signoff;
