/**************************************************************************
 Program:  Usecode_Uiprtyp_formats.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/04/11
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create $usecode, $uiprtyp, and $useuipt formats.

 NB:  File "D:\DCData\Libraries\RealProp\Doc\UseCode & UI_proptype.xls" 
      must be open before running this program.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( RealProp )

** $USECODE **;

filename usecodef dde "excel|D:\DCData\Libraries\RealProp\Doc\[UseCode & UI_proptype Oct-2011.xls]Correspondence!r2c2:r110c3" lrecl=256 notab;

data usecode (compress=no);

  infile usecodef missover dsd dlm='09'x;
  
  length code $ 3 description $ 80;
  
  input code description;

run;

filename usecodef clear;

%Data_to_format( 
  fmtlib=RealProp, 
  fmtname=$usecode, 
  desc="Property use code",
  inds=usecode, 
  value=code,
  label=description,
  print=y
)

** $UIPRTYP **;

filename uiprtypf dde "excel|D:\DCData\Libraries\RealProp\Doc\[UseCode & UI_proptype Oct-2011.xls]UI_proptype!r2c1:r17c2" lrecl=256 notab;

data uiprtyp (compress=no);

  infile uiprtypf missover dsd dlm='09'x;
  
  length code $ 2 description $ 80;
  
  input code description;

run;

filename uiprtypf clear;

%Data_to_format( 
  fmtlib=RealProp, 
  fmtname=$uiprtyp, 
  desc="UI property type code",
  inds=uiprtyp, 
  value=code,
  label=description,
  print=y
)

** $USEUIPT **;

filename useuiptf dde "excel|D:\DCData\Libraries\RealProp\Doc\[UseCode & UI_proptype Oct-2011.xls]Correspondence!r2c1:r110c2" lrecl=256 notab;

data useuipt (compress=no);

  infile useuiptf missover dsd dlm='09'x;
  
  length ui_proptype $ 2 usecode $ 3;
  
  input ui_proptype usecode;

run;

filename useuiptf clear;

%Data_to_format( 
  fmtlib=RealProp, 
  fmtname=$useuipt, 
  desc="USECODE to UI_PROPTYPE conversion",
  inds=useuipt, 
  value=usecode,
  label=ui_proptype,
  otherlabel="99",
  print=y
)

run;

proc catalog catalog=RealProp.Formats;
  contents;
quit;

run;

