/**************************************************************************
 Program:  Parcel_rental_units.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/29/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create rental unit counts for parcels using MAR unit
 data.

 Modifications:
  10/04/14 PAT Removed restriction in_last_ownerpt=1.
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp, local=n )
%DCData_lib( MAR, local=n )

%let PARCEL = '1601    1076';
%let ADDRESS = 224798;

proc print data=RealProp.Parcel_base n;
  where ssl in: ( &PARCEL );
  id ssl;
  var ui_proptype usecode proptype in_last_ownerpt premiseadd no_units;
  title2 'RealProp.Parcel_base';
run;

proc print data=Mar.Address_ssl_xref n;
  where address_id in ( &ADDRESS );
  id address_id;
  by address_id;
  **where ssl = '0004N   2001';
  title2 'Mar.Address_ssl_xref';
run;

proc print data=Mar.Address_unit n;
  where address_id in ( &ADDRESS );
  id address_id;
  by address_id;
  title2 'Mar.Address_unit';
run;

title2;

proc sql noprint;
  create table Address_ssl_xref_pb as
  select
    coalesce( Addr.ssl, Parcel.ssl ) as ssl, 
    Addr.address_id, Addr.lot_type,
    Parcel.ui_proptype, Parcel.in_last_ownerpt
  from 
    RealProp.Parcel_base as Parcel
    left join
    Mar.Address_ssl_xref as Addr
  on Parcel.ssl = Addr.ssl
  where /*in_last_ownerpt = 1 and*/ not( missing( address_id ) ) and
    ui_proptype in ( '10', '12', '13', '19' )
  order by Parcel.ssl, Addr.address_id;
quit;

proc print data=Address_ssl_xref_pb;
  where ssl in: ( &PARCEL ) or address_id in ( &ADDRESS );
  id ssl;
  title2 'Address_ssl_xref_pb';
run;

data Address_ssl_xref_pb_2;

  set Address_ssl_xref_pb;
  by ssl address_id;
  
  if lot_type = 'CONDO' then do;
    if first.ssl then output;
  end;
  else do;
    output;
  end;

run;

proc print data=Address_ssl_xref_pb_2;
  where ssl in: ( &PARCEL ) or address_id in ( &ADDRESS );
  id ssl;
  title2 'Address_ssl_xref_pb_2';
run;

proc sql noprint;
  create table Address_ssl_xref_pb_units as
  select
    coalesce( Parcel.address_id, Unit.address_id ) as address_id,
    Parcel.*,
    Unit.Status, Unit.Unittype, Unit.Unitnum
  from 
    Address_ssl_xref_pb_2 as Parcel
    left join
    Mar.Address_unit as Unit
  on Parcel.address_id = Unit.address_id
  where ( ui_proptype = '13' or put( unittype, $unittyp. ) = 'Rental' ) and not( missing( unitnum ) )
  order by ssl, Unit.address_id, Unit.Unitnum;
quit;

proc print data=Address_ssl_xref_pb_units n;
  where ssl in: ( &PARCEL ) or address_id in ( &ADDRESS );
  id ssl address_id;
  by ssl address_id;
  title2 'Address_ssl_xref_pb_units';
run;

proc freq data=Address_ssl_xref_pb_units;
  tables ui_proptype * unittype * lot_type * status / list missing nocum;
run;

/*
proc print data=Address_ssl_xref_pb_units (obs=500);
  where ui_proptype = '10' and put( unittype, $unittyp. ) = 'Condo';
  **where ui_proptype = '12' and lot_type = 'CONDO';
  id ssl;
run;
*/

title2;

** Summarize unit counts **;

proc format;
  value $sslx
    ' ', '0000    0000' = 'Missing'
    other = 'Not missing';
run;


data Address_ssl_xref_pb_units_b;

  set Address_ssl_xref_pb_units;
  ***where put( ssl, $sslx. ) = 'Not missing' and not( missing( status ) );
    
  select ( put( status, $status. ) );
    when ( 'Active', 'Assigned' )
      Units_active = 1;
    when ( 'Retire' )
      Units_retired = 1;
    otherwise do;
      %warn_put( msg='Unrecognized status code: ' ssl= address_id= status= );
    end;
  end;

/*
  select ( put( unittype, $unittyp. ) );
    when ( 'Condo' )
      Units_condo = 1;
    when ( 'Rental' )
      Units_rental = 1;
    otherwise do;
      %warn_put( msg='Unrecognized unit type code: ' ssl= address_id= unit_id= unittype= );
    end;
  end;
*/

  array units{*} Units_: ;
  
  do i = 1 to dim( units );
    if units{i} = . then units{i} = 0;
  end;

/*  
  Units_condo_active = Units_condo * Units_active;
  Units_rental_active = Units_rental * Units_active;
*/

  label 
    Ssl = 'Property Identification Number (Square/Suffix/Lot)'
    Units_active = 'Active units'
    Units_retired = 'Retired units'
    /*
    Units_condo = 'Condominium units (active + retired)'
    Units_condo_active = 'Active condominium units'
    Units_rental = 'Rental units (active + retired)'
    Units_rental_active = 'Active rental units'
    */
    ;

  drop i;

run;


proc summary data=Address_ssl_xref_pb_units_b;
  by ssl;
  id ui_proptype;
  var Units_: ;
  output 
    out=RealProp.Parcel_rental_units 
      (drop=_type_ _freq_
       label='DC real property parcels - MAR rental/coop unit counts') 
    sum= ;
run;

%File_info( data=RealProp.Parcel_rental_units, printobs=40, freqvars=ui_proptype )



ENDSAS;

proc summary data=Address_ssl_xref_pb_units;
  by ssl;
  var 

%Dup_check(
  data=Address_ssl_xref_pb_units,
  by=ssl,
  id=address_id in_last_ownerpt lot_type ,
  out=_dup_check,
  listdups=Y,
  count=dup_check_count,
  quiet=N,
  debug=N
)


%Data_to_format(
  FmtLib=work,
  FmtName=$ssl_pb,
  Desc=,
  Data=RealProp.Parcel_base (where=(in_last_ownerpt)),
  Value=ssl,
  Label=ssl,
  OtherLabel="",
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=N,
  Contents=N
  )

proc sql noprint;
  create table Parcel_unit_xref as
  select 
    coalesce( ssl.address_id, unit.address_id ) as address_id, 
    ssl.ssl, ssl.lot_type,
    unit.fulladdress, unit.unitnum, unit.unit_id, unit.status, unit.Unittype
    from Mar.Address_ssl_xref as ssl
    full join Mar.Address_unit as unit
    on ssl.address_id = unit.address_id
  where not( missing( put( ssl.ssl, $ssl_pb. ) ) ) and not( missing( unit.unit_id ) )
  order by ssl.ssl, unit.address_id, unit.unit_id;
quit;

run;

proc freq data=Parcel_unit_xref;
  tables status * unittype * lot_type / list missing nocum;
  format ssl $sslx.;
run;


proc print data=Parcel_unit_xref (obs=200);
  where ssl = '0004N   2001';
  id ssl;
  title2 'Parcel_unit_xref';
run;


** Summarize unit counts **;

data Parcel_unit_xref_b;

  set Parcel_unit_xref;
  where put( ssl, $sslx. ) = 'Not missing' and not( missing( status ) );
    
  select ( put( status, $status. ) );
    when ( 'Active', 'Assigned' )
      Units_active = 1;
    when ( 'Retire' )
      Units_retired = 1;
    otherwise do;
      %warn_put( msg='Unrecognized status code: ' ssl= address_id= unit_id= status= );
    end;
  end;

  select ( put( unittype, $unittyp. ) );
    when ( 'Condo' )
      Units_condo = 1;
    when ( 'Rental' )
      Units_rental = 1;
    otherwise do;
      %warn_put( msg='Unrecognized unit type code: ' ssl= address_id= unit_id= unittype= );
    end;
  end;
  
  array units{*} Units_: ;
  
  do i = 1 to dim( units );
    if units{i} = . then units{i} = 0;
  end;
  
  Units_condo_active = Units_condo * Units_active;
  Units_rental_active = Units_rental * Units_active;
  
  label 
    Ssl = 'Property Identification Number (Square/Suffix/Lot)'
    Units_active = 'Active units'
    Units_condo = 'Condominium units (active + retired)'
    Units_condo_active = 'Active condominium units'
    Units_rental = 'Rental units (active + retired)'
    Units_rental_active = 'Active rental units'
    Units_retired = 'Retired units';

  drop i;

run;

proc summary data=Parcel_unit_xref_b;
  by ssl;
  var Units_: ;
  output 
    out=RealProp.Parcel_rental_units 
      (drop=_type_ _freq_
       label='DC real property parcels - MAR condo/rental unit counts') 
    sum= ;
run;

%File_info( data=RealProp.Parcel_rental_units, printobs=100 )

 