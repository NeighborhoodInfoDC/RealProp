/**************************************************************************
 Program:  Parcel_base_ownerpt_update.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/02/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to update Parcel_base file with latest
 Ownerpt file.
 
 Modifications:
  08/03/06  PT Added revisions= parameter.  Added OWNNAME2 to output ds.
               Expanded length of OWNERNAME to 70 chars.
  12/19/13 PAT Updated for new SAS1 server.
  4/21/16 Update for new version of ownerpt
**************************************************************************/

/** Macro Parcel_base_ownerpt_update - Start Definition **/

%macro Parcel_base_ownerpt_update( 
  update_file=, 
  base_file=RealPr_r.Parcel_base, 
  geo_file=RealPr_r.Parcel_geo,
  out_file=Parcel_base_&update_file,
  out_file2=RealPr_r.Parcel_base_&update_file,
  revisions=Updated with &update_file..,
  finalize=N,
  meta=Y,
  retain_temp=N,
  check_geo=Y,
  list_changes=Y,
  info=Y,
  keep_vars =
    ssl premiseadd ui_proptype no_units
    abtlotcode acceptcode address1 address2 address3 
    arn asr_name assess_val basebuild baseland 
    careofname deed_date del_code highnumber hstd_code inst_no
    landarea lot lownumber mix1bldpct mix1bldval mix1lndpct
    mix1lndval mix1rate mix1txtype mix2bldpct mix2bldval
    mix2lndpct mix2lndval mix2rate mix2txtype mixeduse
    mortgageco nbhd nbhdname new_impr new_land new_total
    no_ownocct no_units old_impr old_land old_total ownername
    part_part pchildcode phasebuild
    phasecycle phaseland premiseadd proptype qdrntname
    reasoncode saledate saleprice saletype square ssl
    streetcode streetname sub_nbhd suffix tax_rate trigroup
    ui_proptype unitnumber usecode ustreetname vaclnduse
    ,
  /*** TEMPORARY DEBUGGING OPTIONS ***/
  firstobs=1,  
  obs=1000000
);

  %note_mput( macro=Parcel_base_ownerpt_update, msg=Starting macro. )
  
  %** Check for nonmissing update file **;

  %if &update_file = %then %do;
    %err_mput( macro=Parcel_base_ownerpt_update,
               msg=An update file must be specified in the UPDATE_FILE= parameter. ) 
    %goto exit;
  %end;

  %** Check for existence of update file **;
  
  %if not %Dataset_exists( RealPr_r.&update_file ) %then %do;
    %err_mput( macro=Parcel_base_ownerpt_update,
               msg=The specified update file UPDATE_FILE=&update_file does not exist. ) 
    %goto exit;
  %end;

  %** Check that update was not already applied **;

  proc sql noprint;
    select max( ownerpt_extractdat ) into :_update_date
    from RealPr_r.&update_file (obs=1);
    select max( ownerpt_extractdat_last ) into :_base_date
    from &base_file;
  quit;

  %put _update_date=&_update_date;
  %put _base_date=&_base_date;

  %if &_update_date <= &_base_date %then %do;
    %err_mput( macro=Parcel_base_ownerpt_update,
               msg=The update file &update_file (or a later one) has already been applied to this base file. )
    %err_mput( macro=Parcel_base_ownerpt_update,
               msg=Cannot apply a previous update to the current &base_file file. ) 
    %goto exit;
  %end;

  %let update_file = %MCapitalize( &update_file );
  %let finalize = %upcase( &finalize );
  %let retain_temp = %upcase( &retain_temp );
  %let check_geo = %upcase( &check_geo );
  %let list_changes = %upcase( &list_changes );
  %let info = %upcase( &info );
  %let meta = %upcase( &meta );

  %let ds_label = DC real property parcels - parcel base file;

  %** Identify updates that do not have x/y coordinates **;

  %if &update_file = Ownerpt_2001_04 or &update_file = Ownerpt_2001_10a 
      or &update_file = Ownerpt_2001_10b or &update_file = Ownerpt_2003_01
      or &update_file = Ownerpt_2003_07 or &update_file = Ownerpt_2004_01
  %then
    %let xy_vars = ;
  %else
    %let xy_vars = x_coord y_coord;

  %** Identify updates that do not have Ownname2 **;

  %if    &update_file = Ownerpt_2001_04 
      or &update_file = Ownerpt_2001_10a 
      or &update_file = Ownerpt_2001_10b 
      or &update_file = Ownerpt_2002_05
      or &update_file = Ownerpt_2002_09
      or &update_file = Ownerpt_2002_11
      or &update_file = Ownerpt_2003_01
      or &update_file = Ownerpt_2003_07 
      or &update_file = Ownerpt_2004_01
      or &update_file = Ownerpt_2004_07
      or &update_file = Ownerpt_2004_12
  %then
    %let ownname2 = ;
  %else
    %let ownname2 = ownname2;

  ** Begin update **;

  data &out_file (label="&ds_label [updated by &update_file]" compress=no);
  
    ** Adjust length of ownername var. (was changed from 40 to 70) **;
    
    length OWNERNAME $ 70 ;

    update 
      &base_file
      RealPr_r.&update_file
       (keep=&keep_vars &xy_vars &ownname2 ownerpt_extractdat recordno
        rename=(recordno=ownerpt_recordno_last ownerpt_extractdat=ownerpt_extractdat_last
                premiseadd=premiseadd_new ui_proptype=ui_proptype_new)
        in=in_update
        where=(del_code~=1)
        /**WHERE=(UI_PROPTYPE_NEW IN ('10','11','12'))**/  /** TEMPORARY FILTER FOR OWNER-OCC. HOUSING ONLY **/
        firstobs=&firstobs obs=&obs)
      updatemode=nomissingcheck;
    by ssl;
    
    if in_update then do;
      if missing( ownerpt_extractdat_first ) then do;
        ** New parcel **;
        new_ownerpt_parcel = 1;
        ownerpt_extractdat_first = ownerpt_extractdat_last;
        ownerpt_recordno_first = ownerpt_recordno_last;
      end;
      else do;
        ** Existing parcel **;
        new_ownerpt_parcel = 0;
		/* Commented out error for new ownerpt, RP 4-20-16 */
       /* %if &list_changes = Y %then %do;
          if premiseadd ~= premiseadd_new then do;
            %note_put( macro=Parcel_base_ownerpt_update, 
                       msg="Parcel address has changed: " ssl= / 
                           "      " premiseadd= / "  " premiseadd_new= )
          end;
          if ui_proptype ~= ui_proptype_new then do;
            %note_put( macro=Parcel_base_ownerpt_update, 
                       msg="Parcel property type has changed: " ssl= / 
                           "      " ui_proptype= / "  " ui_proptype_new= )
          end;
        %end;*/
      end;
      premiseadd = premiseadd_new;
      ui_proptype = ui_proptype_new;
    end;
    else do;
      ** No update **;
      new_ownerpt_parcel = 0;
    end;

    in_last_ownerpt = in_update;

    drop premiseadd_new ui_proptype_new;

    label
      in_last_ownerpt = "Parcel was in most recent Ownerpt update [&update_file]"
      new_ownerpt_parcel = "New parcel as of most recent Ownerpt update [&update_file]";

  run;

  /*%file_info( data=Parcel_base_&update_file, printobs=20 )

  proc freq data=Parcel_base_&update_file;
    tables in_last_ownerpt * new_ownerpt_parcel / missing list;
  */ 

  run;

  %if &check_geo = Y %then %do;

    ** Check for presence of parcel in Parcel_geo file & output missing parcels **;

    data Pb_nogeo_&update_file._xy (compress=no)
         Pb_nogeo_&update_file._noxy (drop=x_coord y_coord compress=no);

      merge 
        &out_file (where=(not missing(ssl)) keep=ssl premiseadd x_coord y_coord)
        &geo_file (where=(not missing(ssl)) keep=ssl in=in_geo);
      by ssl;

      if not in_geo;

      if not( missing( x_coord ) or missing( y_coord ) ) then
        output Pb_nogeo_&update_file._xy;
      else
        output Pb_nogeo_&update_file._noxy;

    run;

    proc sql noprint;
      select count(*) into :_count_xy
      from Pb_nogeo_&update_file._xy;
      select count(*) into :_count_noxy
      from Pb_nogeo_&update_file._noxy;
    quit;

    %if &_count_xy > 0 %then %do;

      %warn_mput( macro=Parcel_base_ownerpt_update, 
                  msg=&_count_xy parcels with X/Y coordinates have no matching record in &geo_file file. )

      /**********************
      proc download status=no
        inlib=Work 
        outlib=Work memtype=(data);
        select Pb_nogeo_&update_file._xy;
      run;
      ********************/
          
    %end;

    %if &_count_noxy > 0 %then %do;
      %warn_mput( macro=Parcel_base_ownerpt_update, 
                  msg=&_count_noxy parcels without X/Y coordinates have no matching record in &geo_file file. )
    %end;
    
    /*******
    proc print data=Pb_nogeo_&update_file._xy (obs=20);
      title2 "Pb_nogeo_&update_file._xy";
    run;

    proc print data=Pb_nogeo_&update_file._noxy (obs=20);
      title2 "Pb_nogeo_&update_file._noxy";
    run;

    title2;      
    ********/

  %end;
  %else %do;
    %warn_mput( macro=Parcel_base_ownerpt_update, msg=Matching parcels in geo base file (&geo_file) will NOT be checked because CHECK_GEO=&check_geo.. )
  %end;

  %** Retain update-specific base file in RealProp library **;

  %if &retain_temp = Y %then %do;

    %note_mput( macro=Parcel_base_ownerpt_update, msg=Temporary updated parcel base (RealProp.&out_file) will be retained (RETAIN_TEMP=&retain_temp). )

    ** Copy &out_file to RealProp library **;

    proc copy in=work out=RealProp;
      select &out_file / memtype=data;
    run;

    %let out_file_res = &out_file;
    /**x "purge [dcdata.realprop.data]&out_file_res..*";**/

  %end;

  %** Process final version of updated parcel base file **;

    %note_mput( macro=Parcel_base_ownerpt_update, msg=Existing parcel base (&base_file) will be replaced in a batch session )

    ** Replace existing base file **;

	  %Finalize_data_set( 
	  /** Finalize data set parameters **/
	  finalize=&finalize,
	  data=&out_file.,
	  out=parcel_base,
	  outlib=realprop,
	  label="&ds_label.",
	  sortby=ssl,
	  /** Metadata parameters **/
	  restrictions=None,
	  revisions=%str(&revisions),
	  /** File info parameters **/
	  printobs=5,
	  freqvars=ui_proptype
	  );

	  ** Saved dated copy of base file **;

	  %Finalize_data_set( 
	  /** Finalize data set parameters **/
	  finalize=&finalize,
	  data=&out_file.,
	  out=Parcel_base_&update_file,
	  outlib=realprop,
	  label="&ds_label.",
	  sortby=ssl,
	  /** Metadata parameters **/
	  restrictions=None,
	  revisions=%str(&revisions),
	  /** File info parameters **/
	  printobs=5,
	  freqvars=ui_proptype
	  );


    %let per_pos = %sysfunc(indexc("&base_file",'.'));
    %let len = %sysfunc( length( "&base_file" ) );

    %if &per_pos > 0 %then %do;
      %let base_file_dsname = %sysfunc( substr( "&base_file", %eval(&per_pos+1), %eval(&len-(&per_pos+1)) ) );
    %end;
    %else %do; 
      %let base_file_dsname = &base_file;
    %end;
    

    %let info_file = &out_file;


  proc freq data=&info_file;
    tables in_last_ownerpt * new_ownerpt_parcel / missing list;
    title2 ;
    title3 'Notes:  No/No   = Inactive parcels';
    title4 '        Yes/No  = Active, pre-existing parcels';
    title5 '        Yes/Yes = Active, new parcels';

  run;
  
  title2;

  %Dup_check(
    data=&info_file,
    by=ssl,
    id=premiseadd unitnumber x_coord y_coord,
    out=_dup_check,
    listdups=Y,
    count=dup_check_count,
    quiet=N,
    debug=N
  )

  %exit:
  
  
  %note_mput( macro=Parcel_base_ownerpt_update, msg=Exiting macro. )

%mend Parcel_base_ownerpt_update;

/** End Macro Definition **/

