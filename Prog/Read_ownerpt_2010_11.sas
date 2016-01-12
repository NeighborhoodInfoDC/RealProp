/**************************************************************************
 Program:  Read_ownerpt_2010_11.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Rebecca Grace
 Created:  12/09/2010
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read latest owner point file.

 Modifications: 
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp );

%Read_ownerpt_macro( 

  /** Input file information **/
  inpath=D:\DCData\Libraries\RealProp\Raw\2010-11,
  infile=OwnerPt,
  intype=sas7bdat,
  
  /** Name of previous ownerpt data set **/
  prev_file=Ownerpt_2010_09,
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs=
  ,
  
  /** List data corrections here **/
  corrections=
      
);

