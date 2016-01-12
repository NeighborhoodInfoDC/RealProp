/**************************************************************************
 Program:  Read_ownerpt_2005_05.sas
 Library:  RealProp
 Project:  DC Data Warehouse
 Author:   P. Tatian
 Created:  03/23/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Read owner point file Raw\2005-05\Ownerpt.dbf.

 Modifications: 
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp );

%Read_ownerpt_macro( 

  /** Input file information **/
  inpath=D:\DCData\Libraries\RealProp\Raw\2005-05,
  
  /** Name of previous ownerpt data set **/
  prev_file=Ownerpt_2005_03,
  
  /** Number of obs. to process **/
  /* obs=1000, */
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs=
  176547 175549 176641
  ,
  
  /** List data corrections here **/
  corrections=
      
);
   
