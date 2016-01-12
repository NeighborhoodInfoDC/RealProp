/**************************************************************************
 Program:  Prev_sales.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/06/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to add vars for previous sales transaction.

 Modifications:
  02/03/14 PAT  Updated for new SAS1 server.
**************************************************************************/

%macro Prev_sales( inds=, outds=, cleanup=Y );

  %let cleanup = %upcase( &cleanup );

** Add previous sale vars **;

data _Prev_sales;

  set &inds (keep=ssl sale_num &prev_vars);
  by ssl sale_num;

  if not last.ssl then do;
    sale_num = sale_num + 1;
    output;
  end;

  rename 
    %Rename_stmt( vars=&prev_vars, suffix=_prev, quiet=n )
  ;

run;

** Create variable labels **;

proc sql noprint;
  select catx('',name,'_prev','="',label,', previous sale','"') into :_prev_var_labels separated by ' '
  from dictionary.columns
  where libname="%upcase(work)" and memname="%upcase(&inds)" and 
        indexw( "%upcase(&prev_vars)", upcase( name ) );
quit;

data &outds;

  merge 
    &inds 
      (in=in1) 
    _Prev_sales (in=in2);
  by ssl sale_num;

  if not in2 then do;
    saledate_prev = .u;
    saleprice_prev = .u;
  end;

  label
    &_prev_var_labels
  ;

run;

%if &cleanup = Y %then %do;

  ** Cleanup temporary files **;

  proc datasets nolist library=work memtype=(data);
    delete _Prev_sales;
  quit;

%end;

%mend Prev_sales;

