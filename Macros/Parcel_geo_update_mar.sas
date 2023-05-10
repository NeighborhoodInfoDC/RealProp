/**************************************************************************
 Program:  Parcel_geo_update_mar.sas
 Library:  RealProp
 Project:  Urban-Greater DC
 Author:   Rob Pitingolo
 Created:  7/7/22
 Version:  SAS 9.4
 Environment:  Windows Desktop
 
 Description:  Autocall macro to update Parcel_geo file with latest
 parcel-geography joins.

 Modifications:
**************************************************************************/

/** Macro Parcel_geo_update_mar - Start Definition **/

%macro Parcel_geo_update_mar(
  update_date=,
  update_file=Ownerpt_&update_date.,
  base_file=RealPr_r.Parcel_base_ownerpt_&update_date.,
  geo_vars =ssl x_coord y_coord
    Address_id anc2002 anc2012 city cluster2000 cluster2017
	cluster_tr2000 eor geo2000 geo2010 geo2020 geobg2020 geoblk2020
	psa2004 psa2012 psa2019 voterpre2012 ward2002 ward2012 ward2022 zip
	stantoncommons bridgepk,
  revisions=
);

%note_mput( macro=Parcel_geo_update_mar, msg=Starting macro. )
  
%** Check for nonmissing update file **;

%if &update_file = %then %do;
    %err_mput( macro=Parcel_geo_update_mar,
               msg=An update file must be correctly specified in the UPDATE_FILE= parameter. )
    %goto exit;;
  %end;

%if &base_file = %then %do;
    %err_mput( macro=Parcel_geo_update_mar,
               msg=A parcel base file must be correctly specified in the BASE_FILE= parameter. )
    %goto exit;;
  %end;

%let ds_label = DC real property parcels - geographic identifiers;

/* Combine SSLs with Address Points to get DC geographies for SSLs */
proc sql;
    create table ssl_addresses as
    select x.ssl, y.* 
	from mar.address_ssl_xref as x left join mar.address_points_view as y
    on x.address_id = y.address_id;
quit;

/* Some SSLs can cover multiple addresses but for this purpose we can de-duplicate */
proc sort data = ssl_addresses out = ssl_addresses_nodup nodupkey; by ssl; run;

/* Load parcel base */
proc sort data = &base_file. out = Parcel_base ; by ssl; run;

/* Merge parcel base with SSL geos, output non-matches */
data parcels_marmatch parcels_nomarmatch;
	merge Parcel_base (in=a) ssl_addresses_nodup (in=b);
	by ssl;
	if a;
	if a and b then marmatch = 1;

	drop address_id;
	address_id_fix=(scan(address_id,1,','))+0;
	rename address_id_fix = address_id;

	if marmatch = 1 then do;
		output parcels_marmatch;
	end;
	else do;
		output parcels_nomarmatch;
	end;
run;


/* Split out records with full addresses and those without */
data parcels_togeocode parcels_noaddress;
	set parcels_nomarmatch;

	/* Define regular expression pattern for 5 or 9 digit zip code */
    re = prxparse('/\b\d{5}(?:-\d{4})?\b/i');

    /* Search for zip code in PREMISEADD */
    if prxmatch(re, PREMISEADD) then
        ZIP9 = prxposn(re, 0, PREMISEADD);

    /* Set ZIP9 to missing if it does not match pattern */
    else ZIP9 = .;

    /* Remove any non-digit characters from ZIP9 */
    ZIP9 = compress(ZIP9,,'kd');
    
    /* Set ZIP9 to missing if it is not exactly 5 or 9 digits */
    if not (length(ZIP9) in (5, 9)) then ZIP9 = .;

	/* Create a final 5-digit consistent zipcode variable */
	length premzip $5.;
	premzip = substr(ZIP9, 1, 5);
	format premzip $zipv.;

	/* Create and output a clean address variable excluding city, state and zip */
	if lownumber ^= "" and streetname ^= "" and qdrntname ^= "" then do;
		newaddress = compbl(lownumber || " " || streetname || " " || qdrntname);
		output parcels_togeocode;
	end;

	/* Output a dataset for records with no clean address data */
	else do;
		output parcels_noaddress;
	end;

run;

/* Geocode records with full addresses */
%DC_mar_geocode(
  data = parcels_togeocode,
  staddr = newaddress,
  /* Do NOT output SSL from the geocode macro or it will overwrite existing SSL and create false duplicates*/
  keep_geo = Address_id Anc2002 Anc2012 Cluster_tr2000 Geo2000 Geo2010 Geo2020
  			 GeoBg2020 GeoBlk2020 Psa2004 Psa2012 VoterPre2012 Ward2002 Ward2012 Ward2022,
  out = parcels_geocoded
);

/* Recombine MAR matched, MAR geocoded, and unmatched records */
data Parcel_geo_update;
  	set Parcels_marmatch (in=a)
		Parcels_geocoded (in=b)
		Parcels_noaddress (in=c);

	/* Add city variable to all records */
	length City $ 1;
    city = "1";
    label city = "Washington, D.C.";

	/* Clean up ZIP variable */
	ZIP = input(put(ZIP, $ZIPV.), 5.);
	if ZIP  = "    ." then ZIP = "";

	** Flag for data matched to MAR **;
	if a then mar_matched = 1;
		else mar_matched = 0;
	label mar_matched = "Geography matched to MAR-SSL xref";

	** Flag for data geocoded by MAR **;
	if b then mar_geocoded = 1;
		else mar_geocoded = 0;
	label mar_geocoded = "Geography geocoded by MAR geocoder";

	** Flag for whether record has geography variables **;
	if a then GeoRec = 1 ;
		else if _status_ = "Found" then GeoRec = 1;
		else GeoRec = 0;
	Label GeoRec = "Geography Available for Record";

	** Drop missing SSL record **;
	if ssl ^= " ";

	 ** Tract-based neighborhood clusters **;
    %Block20_to_cluster_tr00();
    
    ** East of the river **;
    %Tr00_to_eor();

	 ** Voting precincts 2012 **;
    %Block20_to_vp12();

	** Bridge park geographies 2017 **;
	%Block20_to_bpk( );

	** 2017 Neighborhood Clusters  **;
	%Block20_to_cluster17 ();

	** Stanton Commons **;
	%Block20_to_stantoncommons ();

	** Zip codes **;
	if ZIP ^= " " then do;
	%Block20_to_zip ();
	end;

	format geo2000 $geo00a. anc2002 $anc02a. psa2004 $psa04a. ward2002 $ward02a.
     	   geo2010 $geo10a. anc2012 $anc12a. psa2012 $psa12a. ward2012 $ward12a.
		   geo2020 $geo20a. ward2022 $ward22a.
		   zip $zipa. cluster2000 $clus00a. city $city. cluster2017 $clus17a. 
		   stantoncommons $stanca. bridgepk $bpka.;
    
    label
      Ssl = "Property Identification Number (Square/Suffix/Lot)"
    ;

	keep mar_matched mar_geocoded GeoRec &geo_vars.;
run;

%Finalize_data_set( 
	  /** Finalize data set parameters **/
	  data=Parcel_geo_update,
	  out=Parcel_geo,
	  outlib=realprop,
	  label="&ds_label.",
	  sortby=ssl,
	  /** Metadata parameters **/
	  restrictions=None,
	  revisions=%str(&revisions.),
	  /** File info parameters **/
	  printobs=5,
	  freqvars=anc2002 anc2012 city eor geo2000 geo2010 geo2020
	  psa2012 voterpre2012 ward2002 ward2012 ward2022 zip mar_matched mar_geocoded GeoRec
	  );

%Finalize_data_set( 
	  /** Finalize data set parameters **/
	  data=Parcel_geo_update,
	  out=Parcel_geo_&update_date.,
	  outlib=realprop,
	  label=%str(&ds_label. update &update_date.),
	  sortby=ssl,
	  /** Metadata parameters **/
	  restrictions=None,
	  revisions=%str(&revisions.),
	  /** File info parameters **/
	  printobs=5,
	  freqvars=anc2002 anc2012 city eor geo2000 geo2010 geo2020
	  psa2012 voterpre2012 ward2002 ward2012 ward2022 zip mar_matched mar_geocoded GeoRec
	  );

  %exit:
  
  %note_mput( macro=Parcel_geo_update, msg=Exiting macro. )

%mend Parcel_geo_update_mar;


/* End of Macro */
