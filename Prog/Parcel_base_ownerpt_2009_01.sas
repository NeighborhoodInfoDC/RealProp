/**************************************************************************
 Program:  Parcel_base_ownerpt_2009_01.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   A. Williams
 Created:  3/4/2009
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Update Parcel_base file with latest Ownerpt.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

%let update_file = Ownerpt_2009_01;
%let finalize    = N;


%syslput update_file = &update_file;
%syslput finalize = &finalize;

rsubmit;

%Parcel_base_ownerpt_update( update_file=&update_file, finalize=&finalize )

run;

endrsubmit;


%Parcel_base_export_noxy( update_file=&update_file )


signoff;
