************************************************************************
* Program:  RealProp_formats.sas
* Library:  RealProp
* Project:  DC Data Warehouse
* Author:   P. Tatian
* Created:  7/28/04
* Version:  SAS 8.2
* Environment:  PC
* 
* Description:  Create formats for real property data
*  NB:  File "D:\DCData\Libraries\RealProp\Doc\UseCode & UI_proptype.xls" 
        must be open to create $USECODE format.
        
   
>>> NB:  THIS PROGRAM DOESN'T WORK IN SAS 9 BECAUSE IT USES DBMS/ENGINES
   

  Modifications:
   04/14/05  Updated formats $TAXTYPE, $USECODE.  
             Added $YESNO, YESNO, $CLASS3D.
   03/14/06  Added $UIPRTYP & $USEUIPT.
   03/28/06  Updated $ACCEPT, added $ACCPTNW.
   12/08/08  Added 'M7 MULTI-SPECULATIVE' to $ACCPTNW.
************************************************************************;

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( RealProp )

libname inf dbdbf 'D:\DCData\Libraries\RealProp\Raw\Codes' ver=4
        class2=ClassCodeDesc taxtype2=MixTxTypeDesc;

** $YESNO & YESNO **;

proc format library=RealProp;
  value $yesno
    'Y' = 'Yes'
    'N' = 'No';
  value yesno
    1 = 'Yes'
    0 = 'No';

run;

** $PROPTYP **;

%Data_to_format( 
  fmtlib=RealProp, 
  fmtname=$proptyp, 
  inds=inf.ptype, 
  value=pt_code,
  label=upcase( substr( pt_desc, 1, 1 ) ) || lowcase( substr( pt_desc, 2 ) )
)

** $USECODE **;

filename usecodef dde "excel|D:\DCData\Libraries\RealProp\Doc\[UseCode & UI_proptype.xls]Correspondence!r2c2:r110c3" lrecl=256 notab;

data usecode (compress=no);

  infile usecodef missover dsd dlm='09'x;
  
  length code $ 3 description $ 80;
  
  input code description;

run;

%Data_to_format( 
  fmtlib=RealProp, 
  fmtname=$usecode, 
  inds=usecode, 
  value=code,
  label=description
)

** $UIPRTYP **;

filename uiprtypf dde "excel|D:\DCData\Libraries\RealProp\Doc\[UseCode & UI_proptype.xls]UI_proptype!r2c1:r17c2" lrecl=256 notab;

data uiprtyp (compress=no);

  infile uiprtypf missover dsd dlm='09'x;
  
  length code $ 2 description $ 80;
  
  input code description;

run;

%Data_to_format( 
  fmtlib=RealProp, 
  fmtname=$uiprtyp, 
  inds=uiprtyp, 
  value=code,
  label=description
)

** $USEUIPT **;

filename useuiptf dde "excel|D:\DCData\Libraries\RealProp\Doc\[UseCode & UI_proptype.xls]Correspondence!r2c1:r110c2" lrecl=256 notab;

data useuipt (compress=no);

  infile useuiptf missover dsd dlm='09'x;
  
  length ui_proptype $ 2 usecode $ 3;
  
  input ui_proptype usecode;

run;

%Data_to_format( 
  fmtlib=RealProp, 
  fmtname=$useuipt, 
  inds=useuipt, 
  value=usecode,
  label=ui_proptype,
  otherlabel="99"
)

** $HOMESTD **;

%Data_to_format( 
  fmtlib=RealProp, 
  fmtname=$homestd, 
  inds=inf.homestd, 
  value=hs_code,
  label=hs_desc
)

** $CLASS (old 2-digit version, pre-2005) **;

%Data_to_format( 
  fmtlib=RealProp, 
  fmtname=$class, 
  inds=inf.class,
  value=cl_code,
  label=cl_desc
)

/**** NO LONGER HAVE THIS FILE ****

** $CLASS3D (new 3-digit version, 2005-later) **;

%Data_to_format( 
  fmtlib=RealProp, 
  fmtname=$class3d, 
  inds=inf.class2,
  value=put( input( class, 2. ), z3. ),
  label=desc
)

**********************************/

** $TAXTYPE **;

%Data_to_format( 
  fmtlib=RealProp, 
  fmtname=$taxtype, 
  inds=inf.taxtype, 
  value=tx_type,
  label=tx_newtext
)

** $ACCEPT **;

data accode (compress=no);

  set inf.accode end=eof;
  
  output;
  
  if eof then do;
    accept_cod = '98';
    accept_des = 'Other';
    output;
  end;
  
run;

%Data_to_format( 
  fmtlib=RealProp, 
  fmtname=$accept, 
  inds=accode, 
  value=accept_cod,
  label=accept_des
)

** $ACCPTNW (new 2005 code) **;

proc format library=RealProp;
  value $accptnw
    'BUYER=SELLER' = 'Buyer=Seller'
    'FORECLOSURE' = 'Foreclosure'
    'GOVT PURCHASE' = 'Government Purchase'
    'LANDSALE' = 'Landsale'
    'M1 MULTI-VERIFIED SALE' = 'M1 Multi-Verified Sale'
    'M2 MULTI-UNASSESSED' = 'M2 Multi-Unassessed'
    'M3 MULTI-BUYER-SELLER' = 'M3 Multi-Buyer-Seller'
    'M4 MULTI-UNUSUAL' = 'M4 Multi-Unusual'
    'M5 MULTI-FORECLOSURE' = 'M5 Multi-Foreclosure'
    'M6 MULTI-GOVT PURCHASE' = 'M6 Multi-Govt Purchase'
    'M7 MULTI-SPECULATIVE' = 'M7 Multi-Speculative'
    'M8 MULTI-MISC' = 'M8 Multi-Misc'
    'M9 MULTI-LAND SALE' = 'M9 Multi-Land Sale'
    'MARKET' = 'Market'
    'MISC' = 'Misc'
    'SPECULATIVE' = 'Speculative'
    'TAX DEED' = 'Tax Deed'
    'UNASSESSED' = 'Unassessed'
    'UNUSUAL' = 'Unusual';

proc format library=RealProp fmtlib;
  select $accptnw;

run;

** $SALETYP **;

%Data_to_format( 
  fmtlib=RealProp, 
  fmtname=$saletyp, 
  inds=inf.saletype (obs=3),  /** Only first 3 codes have valid labels **/
  value=sale_code,
  label=sale_desc
)

** $SLTYPNW (new sale type since 2005) **;

proc format library=RealProp;
  value $SLTYPNW
    'I' = 'Improved'
    'V' = 'Vacant';
run;


** Label and list formats **;

proc catalog catalog=RealProp.formats;
  modify yesno (desc="Yes/No (Y/N)") /entrytype=formatc;
  modify yesno (desc="Yes/No (1/0)") /entrytype=format;
  modify accept (desc="Property sale acceptance code") /entrytype=formatc;
  modify accptnw (desc="Property sale acceptance code (2005 new)") /entrytype=formatc;
  modify class (desc="Tax class code (2-digit)") /entrytype=formatc;
  modify class3d (desc="Tax class code (3-digit)") /entrytype=formatc;
  modify homestd (desc="Homestead exemption code") /entrytype=formatc;
  modify proptyp (desc="Property type code") /entrytype=formatc;
  modify saletyp (desc="Sales type code") /entrytype=formatc;
  modify sltypnw (desc="Sales type code (new)") /entrytype=formatc;
  modify taxtype (desc="Property tax type code") /entrytype=formatc;
  modify uiprtyp (desc="UI property type code") /entrytype=formatc;
  modify usecode (desc="Property use code") /entrytype=formatc;
  modify useuipt (desc="USECODE to UI_PROPTYPE conversion") /entrytype=formatc;
  contents;
  quit;
  
