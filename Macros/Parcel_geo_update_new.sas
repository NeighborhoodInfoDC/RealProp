/**************************************************************************
 Program:  Parcel_geo_update_new.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  4/18/16
 Version:  SAS 9.4
 Environment:  Windows Desktop
 
 Description:  Autocall macro to update Parcel_geo file with latest
 parcel-geography joins.

 Modifications:
  04/18/16 RMP - Re-wrote Parcel_geo_update to comply with new ownerpt.
  10/17/16 PAT - Added missing geo_file_dsname macro var, needed for 
                 metadata registration.
**************************************************************************/

/** Macro Parcel_geo_update - Start Definition **/

%macro Parcel_geo_update_new( 
  update_file=Ownerpt_&update_date., 
  geo_file=RealPr_r.Parcel_geo,
  out_file=Parcel_geo_&update_file,
  finalize=,
  meta=Y,
  retain_temp=N,
  info=Y,
  keep_vars =
);

  %note_mput( macro=Parcel_geo_update, msg=Starting macro. )
  
  %** Check for nonmissing update file **;

  %if &update_file = %then %do;
    %err_mput( macro=Parcel_geo_update,
               msg=An update file must be specified in the UPDATE_FILE= parameter. )
    %goto exit;
  %end;

  %let update_file = %MCapitalize( &update_file );
  %let finalize = %upcase( &finalize );
  %let retain_temp = %upcase( &retain_temp );
  %let info = %upcase( &info );
  %let meta = %upcase( &meta );
  %let geo_file_dsname = %scan( &geo_file, 2, . );
  
  %let ds_label = DC real property parcels - geographic identifiers;
  

/* Pull in existing parcel_geo to match back existing SSLs */
data old_parcel_geo;
	set &geo_file.;
	/* Flag for records matched to this file */
	inpg = 1;
run;

proc sort data = old_parcel_geo; by ssl; run;
proc sort data = RealPr_r.Parcel_base_&update_file. out = Parcel_base_&update_file._all; by ssl; run;


/* Merge new parcel base with existing parcel_geo */
data mergegeo;
	merge Parcel_base_&update_file._all (in=a) old_parcel_geo;
	by ssl;
	if a;
run;


/* Retain matched records for later */
data PB_&update_file._retain;
	set mergegeo (where=(inpg=1));
run;

/* Unmatched records for geocoding */
data PB_&update_file._needgeo;
		set mergegeo (where=(inpg^=1));
		
		/** Recode address to get rid of unit numbers **/
		/*newadd = LOWNUMBER || " " || ustreetname || " " || QDRNTNAME;*/
		newadd = PREMISEADD;
run;

/** Use MAR geocoder to obtain missing geographies **/
%DC_mar_geocode(
  data = PB_&update_file._needgeo,
  staddr = newadd,
  /* Do NOT output SSL from the geocode macro or it will overwrite existing SSL and create false duplicates*/
  keep_geo = Address_id Anc2002 Anc2012 Cluster_tr2000 Geo2000 Geo2010
  			 GeoBg2010 GeoBlk2010 Psa2004 Psa2012 VoterPre2012 Ward2002 Ward2012,
  out = PB_&update_file._geo
);


/** Combine files and final cleanup */
 data Parcel_geo_update;
  	set PB_&update_file._geo 
		(drop= _matched_ _notes_ _score_  address_id 
		m_addr m_city m_obs m_state m_zip newadd newadd_std x y )

	Pb_&update_file._retain (in=b);

	length City $ 1;
    city = "1";
    label city = "Washington, D.C.";

	** Flag for data geocoded by MAR **;
	if b then mar_matched = 0;
		else mar_matched = 1;
	label mar_matched = "New Geography matched by MAR Geocoder";

	** Flag for whether record has geography variables **;
	if b then GeoRec = 1 ;
		else if _status_ = "Found" then GeoRec = 1;
		else GeoRec = 0;
	Label GeoRec = "Geography Available for Record";


	 ** Tract-based neighborhood clusters **;
    %Block00_to_cluster_tr00();
    
    ** Casey target area neighborhoods **;
    %Tr00_to_cta03();
    %Tr00_to_cnb03();
    
    ** East of the river **;
    %Tr00_to_eor();

	 ** Voting precincts 2012 **;
    %Block10_to_vp12();

	** Bridge park geographies 2017 **;
	%Block00_to_bpk( );

	** 2017 Neighborhood Clusters  **;
	%Block10_to_cluster17 ();

	** Stanton Commons **;
	%Block10_to_stantoncommons ();

	format geo2000 $geo00a. anc2002 $anc02a. psa2004 $psa04a. ward2002 $ward02a.
     	   geo2010 $geo10a. anc2012 $anc12a. psa2012 $psa12a. ward2012 $ward12a.
		   zip $zipa. cluster2000 $clus00a. city $city. cluster2017 $clus17a. 
		   stantoncommons $stanca. bridgepk $bpka.;
    
    label
      CJRTRACTBL = "OCTO tract/block ID"
      Ssl = "Property Identification Number (Square/Suffix/Lot)"
    ;

	keep &keep_vars.;
run;

proc sort data = Parcel_geo_update; by ssl; run;


  ** Begin update **;

  data &out_file (label="&ds_label [updated by &update_file]" compress=no);

    update 
      &geo_file
      Parcel_geo_update
      updatemode=nomissingcheck;
    by ssl;
    
    ** Recode x/y coordinate missing values **;
    if not( 380000 < x_coord < 410000 ) then x_coord = .u;
    if not( 120000 < y_coord < 150000 ) then y_coord = .u;
    
  run;
  

  %** Process final version of updated parcel geo file and dated parcel geo file **;

   %Finalize_data_set( 
	  /** Finalize data set parameters **/
	  data=&out_file.,
	  out=Parcel_geo,
	  outlib=realprop,
	  label="&ds_label.",
	  sortby=ssl,
	  /** Metadata parameters **/
	  restrictions=None,
	  revisions=%str(&revisions.),
	  /** File info parameters **/
	  printobs=5,
	  freqvars=geo2000 Ward2002 Anc2002 Psa2004 geo2010 Ward2012 Anc2012 Psa2012 voterpre2012 cluster_tr2000 Cluster2000 Zip
                         casey_ta2003 casey_nbr2003 eor city cluster2017 stantoncommons bridgepk
	  );

	%Finalize_data_set( 
	  /** Finalize data set parameters **/
	  data=&out_file.,
	  out=Parcel_geo_&update_date.,
	  outlib=realprop,
	  label="&ds_label.",
	  sortby=ssl,
	  /** Metadata parameters **/
	  restrictions=None,
	  revisions=%str(&revisions.),
	  /** File info parameters **/
	  printobs=5,
	  freqvars=geo2000 Ward2002 Anc2002 Psa2004 geo2010 Ward2012 Anc2012 Psa2012 voterpre2012 cluster_tr2000 Cluster2000 Zip
                         casey_ta2003 casey_nbr2003 eor city cluster2017 stantoncommons bridgepk
	  );

  %exit:
  
  %note_mput( macro=Parcel_geo_update, msg=Exiting macro. )

%mend Parcel_geo_update_new;

/** End Macro Definition **/

