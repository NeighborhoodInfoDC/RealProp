/**************************************************************************
 Program:  Read_CAMA_yyyy_mm.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   B. Losoya
 Created:  
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read latest CAMA files.

 Modifications: 
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )

%Read_ownerpt_macro( 

  /** Input file information **/
  inpath=&_dcdata_l_path\RealProp\Raw\yyyy-mm-CAMA,
  infile=CAMARespt,
  intype=sas7bdat,
  
  /** Name of previous ownerpt data set **/
  prev_file=CAMARespt_xxxx_zz,
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs=
  ,
  
  /** List data corrections here **/
  corrections=
      
)
%Read_ownerpt_macro( 

  /** Input file information **/
  inpath=&_dcdata_l_path\RealProp\Raw\yyyy-mm-CAMA,
  infile=CommRespt,
  intype=sas7bdat,
  
  /** Name of previous ownerpt data set **/
  prev_file=CAMACommpt_xxxx_zz,
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs=
  ,
  
  /** List data corrections here **/
  corrections=
      
)
%Read_ownerpt_macro( 

  /** Input file information **/
  inpath=&_dcdata_l_path\RealProp\Raw\yyyy-mm-CAMA,
  infile=CAMACondopt,
  intype=sas7bdat,
  
  /** Name of previous ownerpt data set **/
  prev_file=CAMACondopt_xxxx_zz,
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs=
  ,
  
  /** List data corrections here **/
  corrections=
      
);

