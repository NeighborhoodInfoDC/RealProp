/**************************************************************************
 Program:  Read_ownerpt_2009_01.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   A. Williams
 Created:  02/26/2009
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
  inpath=D:\DCData\Libraries\RealProp\Raw\2009-01,
  infile=OwnerPt,
  intype=sas7bdat,
  
  /** Name of previous ownerpt data set **/
  prev_file=Ownerpt_2008_11,
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs=   186608 190535 189237 190157 186928 187719 189904 187342 187343 187344 187345 187346 187347 187348
				  187349 187350 187351 187352 188378 188468 188590 188684 188658 191439 191425 191546 191671 191673 191676 191681 191684
				  191709 191710 191711 191712 189310 189302 189125 184179 192095 192094 187754 189225 189219 189218 189744 189741 189742
				  189740 189739 187086 190852

  ,
  
  /** List data corrections here **/
  corrections=
      
);

