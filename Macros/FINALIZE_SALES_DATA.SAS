/**************************************************************************
 Program:  Finalize_sales_data.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/31/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to create final versions of
 Sales_master and Sales_res_clean data sets.

 Modifications:
  02/03/14 PAT  Updated for new SAS1 server.
                Changed outlib= default to RealPr_r.
                Changed ds_lib= parameter in %Dc_update_meta_file() to 
                RealProp.
**************************************************************************/

/** Macro Finalize_sales_data - Start Definition **/

%macro Finalize_sales_data(
  inlib=work,
  inds=,
  outds=,
  outlib=RealPr_r,
  which=,
  register=Y,
  revisions=%str(Updated with %MCapitalize(&new_extract).)  
);

	%let register = %upcase(&register);

	%if %upcase(&which) = MASTER %then %do;
	  %let _in_full = &inlib..&inds;
	%end;
	%else %do;
	  %let _in_full = &inlib..&inds (where=(clean_sale));
	%end;

	** Get last sales date to include in data set label **;

	  proc sql noprint;
	    select max(saledate) into :_max_saledate
	    from &_in_full;
	    quit;
	  run;

	  data _null_;
	    call symput("_max_saledate_fmt",left(put(&_max_saledate,mmddyy10.)));
	  run;

	** Delete existing copy of output data set **;
	proc datasets lib=&outlib nolist;
	  delete &outds /memtype=data;
	quit;

	** Copy and label output data set **;

	data &outlib..&outds (sortedby=ssl sale_num
	   %if %upcase(&which)=MASTER %then %do;	    	
	    	label="Property sales master file, sales through &_max_saledate_fmt., DC"
	   %end;
	   %else %do;
	    	label="Property sales, single-family & condo, cleaned, sales 01/01/1995 - &_max_saledate_fmt., DC"
	   %end;
	  );

	  set &_in_full;

	  label  sale_num = "Sequential number of sale (for SSL)";

	run;

/*
	** Sort data and copy to output data set name **;
	proc sort data=&inlib..&inds out=&outlib..&outds;
	by ssl saledate;
	run;

	** Delete input data set **;
	proc datasets lib=&inlib nolist;
	  delete &inds /memtype=data;
	quit;
*/

	/**x "purge [dcdata.&outlib..data]&outds..*";**/

	%if &register = Y %then %do;

	** Register output data set with metadata system **;

	%Dc_update_meta_file(
	  ds_lib=RealProp/*&outlib*/,
	  ds_name=&outds,
	  creator_process=Update_sales_&cyear._&cmo..sas,
	  restrictions=None,
	  revisions=&revisions
	)

	%end;

%mend Finalize_sales_data;

/** End Macro Definition **/
