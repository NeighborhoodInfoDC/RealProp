/**************************************************************************
 Program:  Rename_stmt.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/18/09
 Version:  SAS 9.2
 Environment:  Windows
 
 Description:  Autocall macro to generate rename statement from var list.

 Modifications:
   02/03/14 PAT  Updated for new SAS1 server.
****************************************************************************/

/** Macro Rename_stmt - Start Definition **/

%macro Rename_stmt(  
  vars=,                   /** List of variable names **/
  prefix = ,               /** Prefix to add before variable names (optional) **/
  suffix = ,               /** Suffix to add after variable names (optional) **/
  reverse = N,             /** Reverse order of variables **/
  quiet=Y                  /** Suppress log messages? (Y/N) **/
);

  %let quiet = %upcase( &quiet );
  %let reverse = %upcase( &reverse );
  
  %if &quiet ~= Y %then %do;
    %note_mput( macro=Rename_stmt, msg=Processing vars=(&vars) )
  %end;

  %let i = 1;
  %let item = %scan( &vars, &i, %str( ) );
  %let rename_code = ;

  %do %while ( %length( &item ) > 0 );
  
    %if &reverse = Y %then 
      %let rename_code = &rename_code &prefix&item&suffix=&item;
    %else
      %let rename_code = &rename_code &item=&prefix&item&suffix;
    
    %let i = %eval( &i + 1 );
    %let item = %scan( &vars, &i, %str( ) );
    
  %end;
  
  %if &quiet ~= Y %then %do;
    %note_mput( macro=Rename_stmt, msg=Rename_code=(&rename_code) )
  %end;

  &rename_code

%mend Rename_stmt;

/** End Macro Definition **/


