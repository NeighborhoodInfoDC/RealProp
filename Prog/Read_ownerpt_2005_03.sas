/**************************************************************************
 Program:  Read_ownerpt_2005_03.sas
 Library:  RealProp
 Project:  DC Data Warehouse
 Author:   P. Tatian
 Created:  03/22/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Read owner point file Raw\2005-03\Ownerpt.dbf.

 Modifications: 
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp );

%Read_ownerpt_macro( 

  /** Input file information **/
  inpath=D:\DCData\Libraries\RealProp\Raw\2005-03,
  
  /** Name of previous ownerpt data set **/
  prev_file=Ownerpt_2004_12,
  
  /** Number of obs. to process **/
  /* obs=1000, */
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs=
  164902 175664 173188 174932 171156 171154 171150 175439 171922 173662 171891 162615 175049 172542
  ,
  
  /** List data corrections here **/
  corrections=
      
);
   
