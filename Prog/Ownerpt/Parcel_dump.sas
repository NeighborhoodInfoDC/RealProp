/**************************************************************************
 Program:  Parcel_dump.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/17/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )

/** Macro Parcel_dump - Start Definition **/

%macro Parcel_dump( file_list=, ssl= );

  %local i ds keep_vars;
  
  %let keep_vars =
    ssl ui_proptype 
    acceptcode acceptcode_new address_id address1 address2
    address3 assess_val 
    condo_regi condo_regime_num condolot
    del_code delcode last_sale_
    last_sale_date last_sale_price last_sale1 marunitnum mat_ssl
    owner_addr owner_address_citystzip owner_address_line1
    owner_address_line2 owner_na_1 owner_name owner_name_primary
    owner_name_secondary ownername ownname2 premiseadd
    property_address proptype reasoncode regime regime_id
    saledate saleprice saletype saletype_new 
    usecode vacant_use;

  title2 "============================== " &ssl " ==============================";

  %let i = 1;
  %let ds = %scan( &file_list, &i, %str( ) );

  %do %until ( &ds = );
  
    data _null_;
      file print;
      put / "------------------------------ RealProp.&ds ------------------------------";
    run;

    data _null_;
      set RealProp.&ds (where=(compbl(ssl) in (&ssl)));
      file print;
      put / "------------------------------ RealProp.&ds / " _n_ "------------------------------";
      put (&keep_vars) (= /);
    run;

    %let i = %eval( &i + 1 );
    %let ds = %scan( &file_list, &i, %str( ) );

  %end;
  
  title2;

%mend Parcel_dump;

/** End Macro Definition **/

%let file_list = 
    parcel_base
    ownerpt_2014_01 
    itspe_facts 
    itspe_facts_2
    itspe_property_sales 
    owner_polygons_common_ownership 
    property_sale_points
    Condo_Approval_Lots 
    Condo_Relate_Table
  ;


** SF home **;
%Parcel_dump( file_list=&file_list, ssl='3535E 0081' )

** MF rental **;
%Parcel_dump( file_list=&file_list, ssl='1932 0009' '1932 0810' )
%Parcel_dump( file_list=&file_list, ssl='0515 0157' )

** Condo **;
%Parcel_dump( file_list=&file_list, ssl='3511 0030' '3511 2003' )

** Coop **;
%Parcel_dump( file_list=&file_list, ssl='2049 0006' '2049 0804' )

run;
