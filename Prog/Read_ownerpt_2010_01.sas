/**************************************************************************
 Program:  Read_ownerpt_2010_01.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   A. Williams
 Created:  3/4/2010
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
  inpath=D:\DCData\Libraries\RealProp\Raw\2010-01,
  infile=OwnerPt,
  intype=sas7bdat,
  
  /** Name of previous ownerpt data set **/
  prev_file=Ownerpt_2009_11,
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs= 187770 188349 189249 179790 185753 185755 185852 185949 185519 185239 178990 178984 180416 191814
191813 191812 191811 191810 191723 191722 179494 190967 185322 185708

  ,
  
  /** List data corrections here **/
  corrections=
      
);

