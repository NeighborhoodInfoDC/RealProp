/**************************************************************************
 Program:  Read_ownerpt_yyyy_mm.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   
 Created:  
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read latest owner point file.

 Modifications: 
  07/27/14 PAT  Added local=n parameter to %DCData_lib() to prevent 
                creation of local library reference. 
                Changed inpath= location to &_dcdata_r_path.
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp, local=n )

%Read_ownerpt_macro( 

  /** Input file information **/
  inpath=&_dcdata_r_path\RealProp\Raw\yyyy-mm,
  infile=OwnerPt,
  intype=sas7bdat,
  
  /** Name of previous ownerpt data set **/
  prev_file=Ownerpt_xxxx_zz,
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs=
  ,
  
  /** List data corrections here **/
  corrections=
      
);

