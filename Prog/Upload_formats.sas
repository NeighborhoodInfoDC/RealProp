/**************************************************************************
 Program:  Upload_formats.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/15/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Upload formats to RealProp library.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

proc catalog catalog=RealProp.formats;
  contents;
  title2 "Local version of RealProp format catalog";

run;

rsubmit;

proc upload status=no
	inlib=RealProp
	outlib=RealProp memtype=(catalog);
	select formats;
	
run;

x "purge [dcdata.RealProp.data]formats.*";

proc catalog catalog=RealProp.formats;
  contents;
  title2 "Remote version of RealProp format catalog";

run;

endrsubmit;

signoff;

