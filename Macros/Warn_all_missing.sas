/**************************************************************************
 Program:  Warn_all_missing.sas
 Library:  RealProp
 Project:  Urban-Greater DC
 Author:   Rob Pitingolo
 Created:  02/10/2026
 Version:  SAS 9.4
 Environment:  Windows on SAS1
 
 Description:  Autocall macro to check a list of variables and print a warning
			   if all rows are missing. 

 Modifications:
**************************************************************************/

/** Macro Warn_all_missing - Start Definition **/

%macro warn_all_missing (ds=, varlist=);

data _null_;
  set &ds end=eof;

  /* create one retained flag per variable */
  %local i v;
  %let i=1;
  %let v=%scan(&varlist,&i,%str( ));
  %do %while(%length(&v));
    retain any_&v 0;
    if not missing(&v) then any_&v = 1;
    %let i=%eval(&i+1);
    %let v=%scan(&varlist,&i,%str( ));
  %end;

  if eof then do;
    %let i=1;
    %let v=%scan(&varlist,&i,%str( ));
    %do %while(%length(&v));
      if not any_&v then putlog "WARNING: &v is missing for ALL rows in &ds..";
      %let i=%eval(&i+1);
      %let v=%scan(&varlist,&i,%str( ));
    %end;
  end;
run;

%mend warn_all_missing;

/** End Macro Definition **/

