/**************************************************************************
 Program:  Read_ownerpt_2009_04.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   A. Williams
 Created:  06/30/09
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
  inpath=D:\DCData\Libraries\RealProp\Raw\2009-04,
  infile=OwnerPt,
  intype=sas7bdat,
  
  /** Name of previous ownerpt data set **/
  prev_file=Ownerpt_2009_01,
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs= 187789 186575 185638 188299 189491 186421 189148 189149 189249 189250 189251 189252 189253 189254
189353 189354 189355 189636 189852 189437 189441 188922 191628 191432 191730 190675 190677 190771 190867 190870 191258
191350 191351 191352 186083 185981 186371 181697 192337 192259 192258 190135 186379 186373 186278 185500 185497 185498
185496 185495 189557 191587

  ,
  
  /** List data corrections here **/
  corrections=
      
);


