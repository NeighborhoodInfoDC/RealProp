/**************************************************************************
 Program:  UI_proptype.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/25/05
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro for adding UI_PROPTYPE (UI property
 type code) to real property data.

 Modifications:
  03/16/06  New 2-digit codes that include all property types.
**************************************************************************/

/** Macro Ui_proptype - Start Definition **/

%macro Ui_proptype;

  length ui_proptype $ 2;
  
  ui_proptype = put( usecode, $useuipt. );
  
  if ui_proptype = '19' and unitnumber = '' and not( no_units > 0 ) then do;
    if proptype = '1' then ui_proptype = '10';
    else if proptype in ( '3', '4' ) then ui_proptype = '13';
  end;

  label ui_proptype = 'UI property type code';
  
  format ui_proptype $uiprtyp.;
  
%mend Ui_proptype;

/** End Macro Definition **/

