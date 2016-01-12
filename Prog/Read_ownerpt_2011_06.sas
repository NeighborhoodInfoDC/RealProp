/**************************************************************************
 Program:  Read_ownerpt_2011_06.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   R Pitingolo
 Created:  9-15-11
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
  inpath=D:\DCData\Libraries\RealProp\Raw\2011-06,
  infile=OwnerPt,
  intype=sas7bdat,
  
  /** Name of previous ownerpt data set **/
  prev_file=Ownerpt_2011_01,
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs= 186928 194349 194351 194352 194353 194073 194074 195303 195304 195401 194372 187016 195210 195211 195212 195309 195339 187327 194737

  ,
  
  /** List data corrections here **/
  corrections=
      
);

