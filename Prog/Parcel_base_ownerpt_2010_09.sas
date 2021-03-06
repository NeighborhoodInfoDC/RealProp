/**************************************************************************
 Program:  Parcel_base_ownerpt_2010_09.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   A. Williams	
 Created:  10/4/2010
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Update Parcel_base file with latest Ownerpt.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

%let update_file = Ownerpt_2010_09;
%let finalize    = Y;


%syslput update_file = &update_file;
%syslput finalize = &finalize;

rsubmit;

%Parcel_base_ownerpt_update( update_file=&update_file, finalize=&finalize )

run;

endrsubmit;


%Parcel_base_export_noxy( update_file=&update_file )


signoff;
