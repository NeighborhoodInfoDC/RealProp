/**************************************************************************
 Program:  Read_ownerpt_2010_09.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   A. Williams
 Created:  10/4/2010
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
  inpath=D:\DCData\Libraries\RealProp\Raw\2010-09,
  infile=OwnerPt,
  intype=sas7bdat,
  
  /** Name of previous ownerpt data set **/
  prev_file=Ownerpt_2010_07,
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs=
191442 192710 192713 192714 192665 192711 192666 192667 192712 192715 192709 191131 188007 188490
188759 191953 146 752 372 275 387 286 353 265 730 753 373 133 136 291 192325 189423 189425 189515 189520 193573 191025 76991
168793 168875 168876 168877 168878 168879 168964 168965 168966 168967 168968 167670 167671 167770 168846 168847 168848
167771 172320 172321 172322 906 194126 194035 194034 191613 191612 191611 191610 191716 191715 191714 193493 189926 191996
190904

  ,
  
  /** List data corrections here **/
  corrections=
      
);

