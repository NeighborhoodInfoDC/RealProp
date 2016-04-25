/**************************************************************************
 Program:  Acceptcode_old.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/18/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Autocall macro to recreate old coding of ACCEPTCODE
 variable in real property data.

 Modifications:
**************************************************************************/

/** Macro Acceptcode_old - Start Definition **/

%macro Acceptcode_old( var=acceptcode, newvar=acceptcode_old );

    ** Recode ACCEPTCODE **;
    
    length &newvar $ 2;
    
    select ( &var );
      when ( 'BUYER=SELLER' ) &newvar = '03';
      when ( 'FORECLOSURE' ) &newvar = '05';
      when ( 'GOVT PURCHASE' ) &newvar = '06';
      when ( 'LANDSALE' ) &newvar = '09';
      when ( 'M1 MULTI-VERIFIED SALE' ) &newvar = '98';
      when ( 'M2 MULTI-UNASSESSED' ) &newvar = '02';
      when ( 'M3 MULTI-BUYER-SELLER' ) &newvar = '03';
      when ( 'M4 MULTI-UNUSUAL' ) &newvar = '04';
      when ( 'M5 MULTI-FORECLOSURE' ) &newvar = '05';
      when ( 'M6 MULTI-GOVT PURCHASE' ) &newvar = '06';
      when ( 'M7 MULTI-SPECULATIVE' ) &newvar = '07';
      when ( 'M8 MULTI-MISC' ) &newvar = '08';
      when ( 'M9 MULTI-LAND SALE' ) &newvar = '09';
      when ( 'MARKET' ) &newvar = '01';
      when ( 'MISC' ) &newvar = '08';
      when ( 'SPECULATIVE' ) &newvar = '07';
      when ( 'TAX DEED' ) &newvar = '98';
      when ( 'UNASSESSED' ) &newvar = '02';
      when ( 'UNUSUAL' ) &newvar = '04';
      when ( '' ) &newvar = '';
      otherwise do;
        %warn_put( msg="&var value unknown: " _n_= ssl= &var= )
      end;
    end;

%mend Acceptcode_old;

/** End Macro Definition **/

