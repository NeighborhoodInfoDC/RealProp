/**************************************************************************
 Program:  Update_sales.sas
 Library:  Realprop
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/09/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to update sales with latest Ownerpt file.
 Created from D. D'Orio Realprop_driver program.

 Modifications:
  01/28/08 PAT For non-finalized run, end data sets saved in WORK library.
  04/06/09 PAT Updated version.
  04/10/09 PAT Corrected inlib= problem in %Finalize_sales_data invocation.
  04/20/09 PAT Corrected problem with %Finalize_sales_data invocation.
  12/31/13 PAT Updated for new SAS1 server.
  02/03/14 PAT Corrected reference to RealProp library to RealPr_r.
**************************************************************************/

%macro Update_sales( year=, month=, finalize=N, debug=N );

*********************************************************************
Include timer functions to measure program performance
*********************************************************************;
/**%include "[dcdata.realprop.prog]timer_funcs.sas";**/
%include "&_dcdata_r_path\RealProp\Prog\Updates\timer_funcs.sas";

*********************************************************************
Include Parameter file for all DCSALES programs
*********************************************************************;
%Sales_pars()

%** PT: New global macro parameter G_DEBUG **;
%if %upcase( &debug ) = Y %then %let g_debug = YES;
%else %let g_debug = NO;

*******************************************************************
	RECREATING HISTORICAL DATA 
	NOTE: This was done  2-APR-2006. Unless something has
	      changed, these variables should always be set to NO.
*******************************************************************;

*******************************************************************;
*** set this to YES if you need to recreate pre 2002 records ***;
*******************************************************************;
%let recreate_pre2002= NO;

*******************************************************************;
*** set this to YES if you need to recreate historical data set
    from OWNERPT_2006_03 back ***;
*******************************************************************;
%let recreate_history = NO;


*******************************************************************
	CREATING NEW RECORDS FROM A NEW EXTRACT
*******************************************************************;
**** when adding a new file, set this to YES ****;
%let add_files = YES;

*******************************************************************;
*** prefix of extract data should always be OWNERPT_ unless they change the name ****;
*******************************************************************;
%let pre=OWNERPT_;

      **********************************************************************;
      ***  this is the year and month of the extract you want to add    ****;
      ***  when adding a file, the following parameters MUST be set     ****;
      **********************************************************************;
	%global cmo cyr cyear;

	%let cmo = &month;
	%let cyear = &year;
	%let cyr = %substr( &year, 3, 2 );
	
      ****************************************************************
       These are the names of the new extract and old files that will
       be used in the programs. Unless something changes, these should 
       never need to be edited 
      ***************************************************************;
     
	**** name of new extract *****;
	%let new_extract=RealPr_r.&pre.&cyear._&cmo;

	**** name of SALES data set from last run *****;
	%let sales_dataset=SALES_RES_CLEAN;
	%***let sales_dataset=TEST_SALES_RES_CLEAN;  /**** TEMPORARY CHANGE ****/

	**** name of MASTER data set from last run *****;
	%let master_inlib = RealPr_r;
	%let master_dataset=SALES_MASTER;
	%***let master_dataset=TEST_SALES_MASTER;  /**** TEMPORARY CHANGE ****/

	**** name of NEW sales data set ******;
	%let output_sales_ds=TEST_SALES;

	**** name of NEW MASTER data set ******;
	%let output_master_ds=TEST_MASTER;

	**** number of Obs to print for debugging *****;
	%let debug_obs=5;

*******************************************************************
	CLEAN THE NEW DATA FILE
	
*******************************************************************;
*** set this to YES if you want to clean the new files          ***;
*** cleaning the files applies the following exclusions:        ***;

%let clean_files= YES;
%let clean_files_in_lib= WORK;
%let clean_files_out_lib= WORK;

************************************************************************************
	FINALIZE THE NEW DATA FILE
************************************************************************************
**** after cleaning the new data set, finalize the data by setting this to YES   ***
**** this macro drops the appropriate variables and re-sets lengths to the       ***
**** appropriate lengths                                                        ***;

%if %upcase( &finalize ) = Y %then %do;
  %let finalize_data = YES;
  %** Libraries for finalized data sets **;
  %let finalize_in_lib=work;
  %let finalize_out_lib=realpr_r;
%end;
%else %do;
  %let finalize_data = NO;
  %** Libraries for non-finalized data sets **;
  %let finalize_in_lib=work;
  %let finalize_out_lib=work;
%end;

***********************************************************************************
	MERGE GEOGRAPHY VARIABLES ON TO THE NEW DATA FILE
************************************************************************************;

%let  merge_geovars = YES;
%let geo_var_ds=Parcel_geo;
%let geo_var_ds_lib=realpr_r;

%let  merge_geovars_in_lib = realpr_r;
%let  merge_geovars_out_lib = work;

***********************************************************************************
	CREATE OWNER OCCUPIED VARIABLES ON TO THE NEW SALES DATA FILE
************************************************************************************;

%let  create_owner_occ = YES;
%let  owner_occ_in_lib = work;
%let  owner_occ_out_lib = realpr_r;

***********************************************************************************
      SUMMARIZE NEW DATA FILES
***********************************************************************************;

%let print_summary = YES;

%put -----  GLOBAL AND LOCAL MACRO VARIABLES  -----;
%put _global_;
%put _local_;

***************************************************************************** 
***************************************************************************** 
***************************************************************************** 
    DRIVER STARTS HERE. CODE SHOULD NOT BE EDITED FROM THIS POINT ON WITHOUT
    CONSULTING WITH PETER TATIAN
***************************************************************************** 
***************************************************************************** 
***************************************************************************** ;

	***************************************************************************** 
	    This recreates the pre-2002 data. This will probably never be done again 
	***************************************************************************** ;
	%if %upcase(&recreate_pre2002) = YES %then %do;
		**** create pre-2002 data *****;
		%***create_pre2002();
	%end;

	***************************************************************************** 
	     This recreates all of the data using the raw ownerpoint files from
	     realprop.OWNERPT_2006_03 back to 2001. This will probably never be done 
	     again. If this is run again, it will overwrite files that are named:
		 test_sales and test_master. Rename any current files bu this name or 
		 change the  OUTDS macro parameter.
	*****************************************************************************;
	%if %upcase(&recreate_history) = YES %then %do;
		**** recreate historical data *****;
		%***create_master(which=MASTER,outds=test_master);
		%***create_master(which=SALES,outds=test_sales);
	%end;

	***************************************************************************** 
	     This creates the new extract and adds it on to the MASTER and SALES files.
	     This will be run every time we get a new OWNERPOINT file
	*****************************************************************************;
	%if %upcase(&add_files) = YES %then %do;

		%Start_timer( label=Update_all_sale_transactions )

		%Update_all_sale_transactions( update_file=&new_extract, prev_sale=&master_inlib..&master_dataset, outds=_New_sales_master )

		%Check_timer( )
	%end;

	%if &merge_geovars = YES %then %do;
                %Start_timer( label=Geo_vars )
		%Geo_vars( inds=_New_sales_master, outds=_New_sales_master_w_geo )
                %Check_timer( )
	%end;
	
	***************************************************************************** 
	     This cleans the recreated files and will have to be done each time
	     for the SALES data set. Never for the MASTER.
	*****************************************************************************;
	%if %upcase(&clean_files) = YES %then %do;
                %Start_timer( label=Clean_sales )
		**** exclude cases based on parameters in PARS file ****;
		%Clean_sales( inds=_New_sales_master_w_geo, outds=_New_sales_master_w_excl )
                %Check_timer( )
	%end;

	%if &create_owner_occ = YES %then %do;
                %Start_timer( label=create_own_occ )
		** Add owner_occ_sale **;
		%create_own_occ( inds=_New_sales_master_w_excl, outds=_New_sales_master_w_ownocc )
                %Check_timer( )
	%end;

	%**********************************************************************
	  Create vars for previous sale
	%**********************************************************************;

        %Start_timer( label=%str(Prev_sales) )
	%Prev_sales( inds=_New_sales_master_w_ownocc, outds=_New_sales_master_w_prev )
        %Check_timer( )
	
      	***************************************************************************** 
	     Copy MASTER and SALES files after adding the new MASTER and
	     SALES records. This will need to be run on any recreated files, or on the
	     new version of the files after the new observations are added.
	*****************************************************************************;

	**** Create permanent test version of MASTER data set ****;
        %Start_timer( label=%str(Copy_sales_master) );
	%Copy_sales_master( inds=_New_sales_master_w_prev, outds=&output_master_ds._&cmo._&cyear )
        %Check_timer( );

	********************************************************************************************************
		Finalize data sets
	********************************************************************************************************;

	%if %upcase(&finalize_data) = YES %then %do;

	%note_mput( macro=Update_sales, 
                    msg=Writing final MASTER data set to %upcase( &finalize_out_lib..&master_dataset ).
	)

	%Finalize_sales_data(
		inds=&output_master_ds._&cmo._&cyear, 
		outds=&master_dataset,
		inlib=&finalize_in_lib,
		outlib=&finalize_out_lib,
		which=MASTER
	)

	%note_mput( macro=Update_sales, 
                    msg=Writing final CLEAN SALES data set to %upcase( &finalize_out_lib..&sales_dataset ).
	)

	%finalize_sales_data(
		inds=&master_dataset, 
		outds=&sales_dataset,
		inlib=&finalize_out_lib,
		outlib=&finalize_out_lib,
		which=SALES
	)

	%let master_summary = &finalize_out_lib..&master_dataset;
	%let sales_summary = &finalize_out_lib..&sales_dataset;

	%end;
	%else %do;

	%note_mput( macro=Update_sales, 
                    msg=Data set %upcase(RealProp.&master_dataset) will NOT be replaced because FINALIZE=&finalize.)

	%note_mput( macro=Update_sales, 
                    msg=Data set %upcase(RealProp.&sales_dataset) will NOT be replaced because FINALIZE=&finalize.)

	%let master_summary = &finalize_out_lib..&output_master_ds._&cmo._&cyear;
	%let sales_summary = &finalize_out_lib..&output_sales_ds._&cmo._&cyear;

	data &sales_summary / view=&sales_summary;
		set &master_summary;
		where clean_sale;
	run;

	%end;

	********************************************************************************************************
		Summarize output files 
	********************************************************************************************************;

        %if %upcase(&print_summary) = YES %then %do;

                %Start_timer( label=print_summary )
	
        	%let freqvars = ui_proptype acceptcode saletype;
        	%if &create_owner_occ = YES %then %let freqvars = &freqvars owner_occ_sale;
        	%if &merge_geovars = YES %then %let freqvars = &freqvars ward2002;

		%File_info( data=&master_summary, printobs=5, freqvars=&freqvars )
		%File_info( data=&sales_summary, printobs=5, freqvars=&freqvars )

		%Sales_summary( data=&sales_summary )

		%Cleaning_summary( 
			master=&master_summary, 
			clean=&sales_summary )

                %Check_timer( )

	%end;

%mend Update_sales;
