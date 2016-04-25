/**************************************************************************
 Program:  Contents_parcel_base.sas
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

%File_info( data=RealProp.Parcel_base, printobs=5  )

proc freq data=RealProp.Parcel_base;
  tables
    proptype usecode del_code hstd_code acceptcode /*acceptcode_new*/ saletype;
  format 
    proptype usecode del_code hstd_code acceptcode /*acceptcode_new*/ saletype;

run;
