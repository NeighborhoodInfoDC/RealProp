/**************************************************************************
 Program:  Read_ownerpt_2007_11.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/25/08
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
  inpath=D:\DCData\Libraries\RealProp\Raw\2007-11,
  infile=OwnerPt,
  intype=sas7bdat,
  
  /** Name of previous ownerpt data set **/
  prev_file=Ownerpt_2007_09,
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs=183133 184046 184047 184048 182962 183215 186745 
    186744 186746 184062 183242 183763 187046 187045
    183320 183789
  ,
  
  /** List data corrections here **/
  corrections=
      
);

