/**************************************************************************
 Program:  Format_nbhd.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/24/13
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Create $nbhd. format for real property assessor
neighborhood codes.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

** Start submitting commands to remote server **;

rsubmit;

data Ownerpt;

  set RealProp.ownerpt_2012_07 (keep=nbhd nbhdname);
  
  where not( missing( nbhd ) or missing( nbhdname ) );
  
  nbhdname = left( propcase( nbhdname ) );

  nbhdname = tranwrd( nbhdname, 'Ne', 'NE' );
  nbhdname = tranwrd( nbhdname, 'Sw', 'SW' );
  nbhdname = tranwrd( nbhdname, 'Ii', 'II' );
  nbhdname = tranwrd( nbhdname, 'Afb', 'AFB' );

  nbhdname = tranwrd( nbhdname, 'HawthorNE', 'Hawthorne' );
  
run;

proc sort data=Ownerpt nodupkey;
  by nbhd nbhdname;

%Dup_check(
  data=Ownerpt,
  by=nbhd,
  id=nbhdname,
  out=_dup_check,
  listdups=Y,
  count=dup_check_count,
  quiet=N,
  debug=N
)

%Data_to_format(
  FmtLib=RealProp,
  FmtName=$nbhd,
  Desc=Real property assessor nbhd,
  Data=Ownerpt,
  Value=nbhd,
  Label=nbhdname,
  OtherLabel=,
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=Y,
  Contents=Y
  )


run;

endrsubmit;

** End submitting commands to remote server **;

run;

signoff;
