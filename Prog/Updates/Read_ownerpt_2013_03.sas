/**************************************************************************
 Program:  Read_ownerpt_2013_09.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Brianna Losoya
 Created:  1/16/2014
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read latest owner point file.

 Modifications: 
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )

%Read_ownerpt_macro( 

  /** Input file information **/
  inpath=&_dcdata_l_path\RealProp\Raw\2013-09,
  infile=OwnerPt,
  intype=sas7bdat,
  
  /** Name of previous ownerpt data set **/
  prev_file=Ownerpt_2013_03,
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs=
  ,
  
  /** List data corrections here **/
  corrections=
      
);

