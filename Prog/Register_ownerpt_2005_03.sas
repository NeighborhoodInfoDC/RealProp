/**************************************************************************
 Program:  Register_ownerpt_2005_03.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/24/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Register file Ownerpt_2005_03 with metadata system.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

%Register_ownerpt_macro(

  /** Name of data set (without library) **/
  filename=Ownerpt_2005_03,
  
  /** Latest file revisions **/
  revisions=%str(Added UI_PROPTYPE.)
)

run;

signoff;
