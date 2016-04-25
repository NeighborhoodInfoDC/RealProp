/**************************************************************************
 Program:  Contents_ownerpt.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/18/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )

%File_info( data=RealProp.ownerpt_2014_01, printobs=5  )

%let freqvars = proptype usecode del_code hstd_code acceptcode acceptcode_new saletype class3 class3ex
 lottype mix1class_3d mix2class_3d mix1txtype mix2txtype reasoncode res
 saletype saletype_new

;

proc freq data=RealProp.ownerpt_2014_01;
  tables &freqvars;
  format &freqvars;
run;
