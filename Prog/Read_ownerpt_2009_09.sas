/**************************************************************************
 Program:  Read_ownerpt_2009_09.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey
 Created:  11/02/2009
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
  inpath=D:\DCData\Libraries\RealProp\Raw\2009-09,
  infile=OwnerPt,
  intype=sas7bdat,
  
  /** Name of previous ownerpt data set **/
  prev_file=Ownerpt_2009_04,
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs= 186588 184786 187456 187788 192435 186627 186628 186629 186630 186631 186721 186722 186723 186724
186725 186726 185712 186010 185824 185828 185338 190500 189643 190127 189370 190619 190715 190717 189272 189757 189849
189850 189851 190793 188479 190165 189877 189876 186844 186262 186164 186163 191451 191448 191449 191447 191446 186898
191221 190782 189625
  ,
  
  /** List data corrections here **/
  corrections=
      
);

