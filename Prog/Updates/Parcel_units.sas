/**************************************************************************
 Program:  Parcel_units.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/29/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create housing unit counts for parcels using MAR unit
 data.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp, local=n )
%DCData_lib( MAR, local=n )


%let address_file = Address_points_view;

%let revisions = Update with latest parcel and address data.;


proc sql noprint;
  create table Parcel_unit_xref as
  select 
    coalesce( ssl.address_id, unit.address_id ) as address_id, 
    ssl.ssl, ssl.ui_proptype, ssl.in_last_ownerpt,
    unit.fulladdress, unit.active_res_occupancy_count, unit.address_type
    from (
      select coalesce( a.ssl, b.ssl ) as ssl, a.ui_proptype, a.in_last_ownerpt, b.address_id
      from RealProp.Parcel_base as a right join Mar.Address_ssl_xref as b
      on a.ssl = b.ssl
      where a.in_last_ownerpt and b.ssl not in ( ' ', '0000    0000' )
    ) as ssl
    full join Mar.&address_file as unit
    on ssl.address_id = unit.address_id
  order by ssl.ssl, unit.address_id;
quit;

run;

proc summary data=Parcel_unit_xref;
  by ssl;
  id ui_proptype;
  var active_res_occupancy_count;
  output 
    out=Parcel_units 
      (drop=_type_ _freq_
       where=(ssl~="")) 
    sum=Total_res_units;
  label 
    active_res_occupancy_count = "Total residential units (for condo unit records, total units in building)"
    ssl = "Property Identification Number (Square/Suffix/Lot)";
run;


%Finalize_data_set( 
  /** Finalize data set parameters **/
  data=Parcel_units,
  out=Parcel_units,
  outlib=RealProp,
  label='MAR housing unit counts for active DC real property parcels',
  sortby=ssl,
  /** Metadata parameters **/
  revisions=%str(&revisions)
)

