/**************************************************************************
 Program:  Contents_owner_ply.sas
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

%File_info( data=RealProp.owner_polygons_common_ownership, printobs=5, 
  freqvars=proptype usecode delcode hstdcode acceptcode saletype condolot address2 arn class3 class3ex 
    lot_type mix1class mix2class mix1txtype mix2txtype
    res reservatio saletype


)

run;
