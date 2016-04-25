/**************************************************************************
 Program:  Compare_files.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/16/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Compare Ownerpt source files.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )

%File_info( data=RealProp.ownerpt_2014_01, printobs=0, stats= )

run;

ods html body="&_dcdata_l_path\RealProp\Prog\Ownerpt\Compare_files.html" style=Minimal;
ods listing close;

%Compare_file_struct( 
  lib=RealProp, 
  file_list=
    ownerpt_2014_01 
    itspe_facts itspe_facts_2 itspe_property_sales itspe_vacant_property 
    owner_points owner_points__all_fields owner_polygons_common_ownership 
    property_sale_points 
    Condo_Approval_Lots Condo_Relate_Table,
  csv_out="&_dcdata_l_path\RealProp\Prog\Ownerpt\Compare_files.csv"
  )

run;

ods html close;
ods listing;
