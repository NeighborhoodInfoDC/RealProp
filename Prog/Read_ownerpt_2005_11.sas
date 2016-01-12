/**************************************************************************
 Program:  Read_ownerpt_2005_11.sas
 Library:  RealProp
 Project:  DC Data Warehouse
 Author:   B. Williams
 Created:  12/20/05
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Read owner point file Ownerpt.dbf.
               File version 2 downloaded from dcgis.dc.gov on 12/20/05.

 Modifications: 1/5/06 - Dlete Duplicate Observations and compare current 
				extraction with previous extraction.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp );

%Read_ownerpt_macro( 
  inpath=D:\DCData\Libraries\RealProp\Raw\2005-11 /*,
  obs=1000,*/	);
  
  corrections=
    ** Delete duplicate parcel records **;
    if recordno in ( 169876, 178308, 178221, 178212, 166929, 178648 )
      then delete;
   

** Compare current extract with previous version **;
rsubmit;

proc compare base=Realprop.Ownerpt_2005_11 compare=Realprop.Ownerpt_2005_05 maxprint=(40,32000);
  id ssl;
run;

endrsubmit;
	
signoff;

