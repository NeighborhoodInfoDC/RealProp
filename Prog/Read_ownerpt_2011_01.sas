/**************************************************************************
 Program:  Read_ownerpt_2011_01.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   A. Williams
 Created:  2/22/2011
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
  inpath=D:\DCData\Libraries\RealProp\Raw\2011-01,
  infile=OwnerPt,
  intype=sas7bdat,
  
  /** Name of previous ownerpt data set **/
  prev_file=Ownerpt_2010_11,
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs= 191128 191299

  ,
  
  /** List data corrections here **/
  corrections=
      
);

