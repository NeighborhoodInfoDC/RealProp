/**************************************************************************
 Program:  Parcel_base_ownerpt_yyyy_mm.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   BL
 Created:  1/16/2014
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Update Parcel_base file with latest Ownerpt.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )

%let update_file = Ownerpt_2013_03;
%let finalize    = Y;

%Parcel_base_ownerpt_update( 
  update_file=&update_file, 
  finalize=&finalize,
  keep_vars = 
    /** New keep var list for files 3/2013 and later **/
    ssl premiseadd ui_proptype no_units 
    abtlotcode acceptcode address1 address2 address3 
    arn asr_name assess_val basebuild baseland 
    careofname deed_date del_code highnumber hstd_code 
    landarea lot lownumber mix1bldpct mix1bldval mix1lndpct 
    mix1lndval mix1rate mix1txtype mix2bldpct mix2bldval 
    mix2lndpct mix2lndval mix2rate mix2txtype mixeduse 
    nbhd nbhdname new_impr new_land new_total 
    no_ownocct no_units old_impr old_land old_total ownername 
    part_part pchildcode phasebuild 
    phasecycle phaseland premiseadd proptype qdrntname 
    reasoncode saledate saleprice saletype square ssl 
    streetcode streetname sub_nbhd suffix tax_rate trigroup 
    ui_proptype unitnumber usecode ustreetname vaclnduse
  )

%Parcel_base_export_noxy( update_file=&update_file )

