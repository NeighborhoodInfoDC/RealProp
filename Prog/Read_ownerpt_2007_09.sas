/**************************************************************************
 Program:  Read_ownerpt_2007_09.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/20/07
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
  inpath=D:\DCData\Libraries\RealProp\Raw\2007-09,
  infile=OwnerPt,
  intype=sas7bdat,
  
  /** Name of previous ownerpt data set **/
  prev_file=Ownerpt_2007_05,
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs=
  186246 186723 186724 186725 185944 185269 186922 185689 186893 186856 187130 187131 185026
  ,
  
  /** List data corrections here **/
  corrections=
      
);

