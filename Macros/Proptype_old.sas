/**************************************************************************
 Program:  Proptype_old.sas
 Library:  RealProp
 Project:  Urban-Greater DC
 Author:   Rob Pitingolo
 Created:  08/17/22
 Version:  SAS 9.4
 Environment:  Windows 10
 
 Description:  Autocall macro to recreate old coding of Proptype
 variable in real property data.

 Modifications:
**************************************************************************/

/** Macro Proptype_old - Start Definition **/

%macro Proptype_old ( var=Proptype, newvar=Proptype_old);

    ** Recode PROPTYPE**;
    
    length &newvar $ 1;
    
	select ( upcase( &var ) );
      when ( 'RESIDENTIAL-SINGLE FAMILY (DET' ) &newvar = '1';
      when ( 'RESIDENTIAL-SINGLE FAMILY (MIS' ) &newvar = '1';
	  when ( 'RESIDENTIAL-SINGLE FAMILY (NC)' ) &newvar = '1';
	  when ( 'RESIDENTIAL-SINGLE FAMILY (ROW' ) &newvar = '1';
	  when ( 'RESIDENTIAL-SINGLE FAMILY (SEM' ) &newvar = '1';
	  when ( 'COMMERCIAL-BANKS-FINANCIAL' ) &newvar = '2';
	  when ( 'COMMERCIAL-BANKS-FINANCIAL' ) &newvar = '2';
	  when ( 'COMMERCIAL-INDUSTRIAL (MISCELL' ) &newvar = '2';
	  when ( 'COMMERCIAL-OFFICE (CONDOMINIUM' ) &newvar = '2';
	  when ( 'COMMERCIAL-OFFICE (LARGE)' ) &newvar = '2';
	  when ( 'COMMERCIAL-OFFICE (MISCELLANEO' ) &newvar = '2';
	  when ( 'COMMERCIAL-OFFICE (SMALL)' ) &newvar = '2';
	  when ( 'COMMERCIAL-PLANNED DEVELOPMENT' ) &newvar = '2';
	  when ( 'COMMERCIAL-RETAIL (CONDOMINIUM' ) &newvar = '2';
	  when ( 'COMMERCIAL-RETAIL (MISCELLANEO' ) &newvar = '2';
	  when ( 'COMMERCIAL-SPECIFIC PURPOSE (M' ) &newvar = '2';
	  when ( 'FAST FOOD RESTAURANT' ) &newvar = '2';
	  when ( 'INDUSTRIAL-RAW MATERIAL HANDLI' ) &newvar = '2';
	  when ( 'INDUSTRIAL-TRUCK TERMINAL' ) &newvar = '2';
	  when ( 'INDUSTRIAL-WAREHOUSE (1 STORY)' ) &newvar = '2';
	  when ( 'INDUSTRIAL-WAREHOUSE (CONDOMIN' ) &newvar = '2';
	  when ( 'INDUSTRIAL-WAREHOUSE (MULTI-ST' ) &newvar = '2';
	  when ( 'OFFICE-CONDOMINIUM (HORIZONTAL' ) &newvar = '2';
	  when ( 'OFFICE-CONDOMINIUM (VERTICAL)' ) &newvar = '2';
	  when ( 'RESTAURANTS' ) &newvar = '2';
	  when ( 'STORE-BARBER-BEAUTY SHOP' ) &newvar = '2';
	  when ( 'STORE-DEPARTMENT' ) &newvar = '2';
	  when ( 'STORE-MISCELLANEOUS' ) &newvar = '2';
	  when ( 'STORE-RESTAURANT' ) &newvar = '2';
	  when ( 'STORE-SHOPPING CENTER-MALL' ) &newvar = '2';
	  when ( 'STORE-SMALL (1 STORY)' ) &newvar = '2';
	  when ( 'STORE-SUPER MARKET' ) &newvar = '2';
	  when ( 'THEATERS AND ENTERTAINMENT' ) &newvar = '2';
	  when ( 'CONDOMINIUM-COMBINED (HORIZONT' ) &newvar = '3';
	  when ( 'CONDOMINIUM-COMBINED (VERTICAL' ) &newvar = '3';
	  when ( 'CONDOMINIUM-INVESTMENT (HORIZO' ) &newvar = '3';
	  when ( 'CONDOMINIUM-INVESTMENT (VERTIC' ) &newvar = '3';
	  when ( 'COOPERATIVE-MIXED USE (HORIZON' ) &newvar = '3';
	  when ( 'COOPERATIVE-MIXED USE (VERTICA' ) &newvar = '3';
	  when ( 'RESIDENTIAL-APARTMENT (ELEVATO' ) &newvar = '3';
	  when ( 'RESIDENTIAL-APARTMENT (WALKUP)' ) &newvar = '3';
	  when ( 'RESIDENTIAL-CONDOMINIUM (HORIZ' ) &newvar = '3';
	  when ( 'RESIDENTIAL-CONDOMINIUM (VERTI' ) &newvar = '3';
	  when ( 'RESIDENTIAL-CONVERSION (5 UNIT' ) &newvar = '3';
	  when ( 'RESIDENTIAL-CONVERSION (LESS T' ) &newvar = '3';
	  when ( 'RESIDENTIAL-CONVERSION (MORE T' ) &newvar = '3';
	  when ( 'RESIDENTIAL-COOPERATIVE (HORIZ' ) &newvar = '3';
	  when ( 'RESIDENTIAL-COOPERATIVE (VERTI' ) &newvar = '3';
	  when ( 'RESIDENTIAL-FLATS (LESS THAN 5' ) &newvar = '3';
	  when ( 'RESIDENTIAL-MIXED USE' ) &newvar = '3';
	  when ( 'RESIDENTIAL-MULTIFAMILY (MISCE' ) &newvar = '3';
	  when ( 'HOTEL (LARGE)' ) &newvar = '5';
	  when ( 'HOTEL (SMALL)' ) &newvar = '5';
	  when ( 'INN' ) &newvar = '5';
	  when ( 'MOTEL' ) &newvar = '5';
	  when ( 'GARAGE-MULTIFAMILY' ) &newvar = '6';
	  when ( 'PARKING LOT-SPECIAL PURPOSE' ) &newvar = '6';
	  when ( 'RESIDENTIAL-GARAGE' ) &newvar = '6';
	  when ( 'VACANT-FALSE-ABUTTING' ) &newvar = '6';
	  when ( 'VACANT-PERMIT' ) &newvar = '6';
	  when ( 'VACANT-RESIDENTIAL USE' ) &newvar = '6';
	  when ( 'VACANT-TRUE' ) &newvar = '6';
	  when ( 'VACANT-UNIMPROVED PARKING' ) &newvar = '6';
	  when ( 'VACANT-ZONING LIMITS' ) &newvar = '6';
	  when ( 'VEHICLE SERVICE STATION (KIOSK' ) &newvar = '6';
	  when ( 'VEHICLE SERVICE STATION (MARKE' ) &newvar = '6';
	  when ( 'VEHICLE SERVICE STATION (VINTA' ) &newvar = '6';
	  when ( 'COMMERCIAL-GARAGE-VEHICLE SALE' ) &newvar = '6';
	  when ( 'COMMERCIAL-PARKING GARAGE' ) &newvar = '6';
	  when ( 'RESIDENTIAL-CONDOMINIUM (GARAG' ) &newvar = '6';
	  when ( 'CLUB-PRIVATE' ) &newvar = '';
	  when ( 'DORMITORY' ) &newvar = '';
	  when ( 'EDUCATIONAL' ) &newvar = '';
	  when ( 'EMBASSY-CHANCERY-ETC.' ) &newvar = '';
	  when ( 'FRATERNITY/SORORITY HOUSE' ) &newvar = '';
	  when ( 'HEALTH CARE FACILITY' ) &newvar = '';
	  when ( 'INDUSTRIAL-LIGHT' ) &newvar = '';
	  when ( 'MEDICAL' ) &newvar = '';
	  when ( 'MUSEUMS-LIBRARY-GALLERY' ) &newvar = '';
	  when ( 'PUBLIC SERVICE' ) &newvar = '';
	  when ( 'RECREATIONAL' ) &newvar = '';
	  when ( 'RELIGIOUS' ) &newvar = '';
	  when ( 'RESIDENTIAL-TRANSIENT (MISCEL' ) &newvar = '';
	  when ( 'SPECIAL PURPOSE (MEMORIAL)' ) &newvar = '';
	  when ( 'SPECIAL PURPOSE (MISCELLANEOUS' ) &newvar = '';
	  when ( 'TOURIST HOMES' ) &newvar = '';
      when ( '' ) &newvar = '';
      otherwise do;
        %warn_put( msg="&var value unknown: " _n_= ssl= &var= )
      end;
    end;



%mend Proptype_old;


/** Macro Proptype_old - End Definition **/
