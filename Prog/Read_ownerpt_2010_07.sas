/**************************************************************************
 Program:  Read_ownerpt_2010_07.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   A. Williams
 Created:  9/22/2010
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
  inpath=D:\DCData\Libraries\RealProp\Raw\2010-07,
  infile=OwnerPt,
  intype=sas7bdat,
  
  /** Name of previous ownerpt data set **/
  prev_file=Ownerpt_2010_05,
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs= 179885 187428 186185 179415 179430 179431 179505 179428 179338 179339 179429 179432 179340 187163
177617 178508 178040 186998 186520 186005 187225 179810 187439 179906 179435 186210 180089 180183 186006 187226 185898
186110 187245 184505 185759 185854 185856 191471 187155 179826 179914 179915 179916 179917 179918 180008 180009 180010
180011 180012 180098 180099 180100 180193 180194 178757 178758 178759 178760 178761 178858 178773 190606 177335 177334
190517 190516 190515 190514 190513 190512 190424 191028 184932 186549 186938

  ,
  
  /** List data corrections here **/
  corrections=
      
);
