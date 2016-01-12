/**************************************************************************
 Program:  Upload_ownerpt_2005_05.sas
 Library:  RealProp
 Project:  DC Data Warehouse
 Author:   P. Tatian
 Created:  08/25/05
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Upload and register real property update file for 05/2005.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

rsubmit;

%let filename = Ownerpt_2005_05;
%let revisions = %str(New File);

proc upload status=no
	inlib=RealProp
	outlib=RealProp memtype=(data);
	select &filename;
run;

x "purge [dcdata.realprop.data]*.*";

run;

%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=&filename,
  creator_process=Read_&filename..sas,
  restrictions=None,
  revisions=&revisions
);

endrsubmit;

signoff;
