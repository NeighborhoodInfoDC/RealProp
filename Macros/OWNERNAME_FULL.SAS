/**************************************************************************
 Program:  Ownername_full.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/27/09
 Version:  SAS 9.1
 Environment:  Windows/Alpha
 
 Description:  Autocall macro to create Ownername_full variable
 (combined names of property owners).

 Modifications:
  02/03/14 PAT  Updated for new SAS1 server.
**************************************************************************/

/** Macro Ownername_full - Start Definition **/

%macro Ownername_full( var=Ownername_full, Ownname2_exists=Y );

  %let Ownname2_exists = %upcase( &Ownname2_exists );

  %let ownername = left( compbl( upcase( translate( ownername, '&', '+' ) ) ) );
  %let ownname2 = left( compbl( upcase( translate( ownname2, '&', '+' ) ) ) );

  length &var $ 150;

  %if &Ownname2_exists = Y %then %do;
    if ownname2 = '' then &var = &ownername;
    else &var = trim( &ownername ) || ' + ' || &ownname2;
  %end;
  %else %do;
    &var = &ownername;
  %end;
  
  label &var = "Name(s) of property owners";

%mend Ownername_full;

/** End Macro Definition **/


