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

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp, local=n )
%DCData_lib( MAR, local=n )

proc print data=RealProp.Parcel_base n;
  where ssl in ( '1932    0810', '1932    0009' );
  id ssl;
  var ui_proptype in_last_ownerpt premiseadd;
  title2 'RealProp.Parcel_base';
run;

proc print data=Mar.Address_ssl_xref n;
  where address_id = 262667;
  **where ssl = '0004N   2001';
  title2 'Mar.Address_ssl_xref';
run;

proc print data=Mar.Address_unit n;
  where address_id = 262667;
  title2 'Mar.Address_unit';
run;

ENDSAS;

title2;

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

proc format;
  value $sslx
    ' ', '0000    0000' = 'Missing'
    other = 'Not missing';
run;

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
    out=RealProp.Parcel_units 
      (drop=_type_ _freq_
       label='DC real property parcels - MAR condo/rental unit counts') 
    sum= ;
run;

%File_info( data=RealProp.Parcel_units, printobs=100 )

 