/**************************************************************************
 Program:  DC_geocode.sas
 Library:  RealProp
 Project:  NeigborhoodInfo DC
 Author:   P. Tatian & B. Bajaj
 Created:  12/15/04
 Version:  SAS 9.1
 Environment:  Alpha only
 
 Description:  Autocall macro to geocode DC street addresses to
 parcel base.

 Modifications:
  04/12/05 PAT Added unit number to address matching (Proc SQL)
  04/20/05 PAT Temporarily removed unit number matching.
               Changed default parcel base to RealProp.Parcel_Geocode_Base.
               Use standardized address from parcel base.
               Added options for SSL, X_COORD, Y_COORD, etc. (not implemented).
               Added data set label option DS_LABEL=
  04/21/05 PAT Added dcg_num_parcels to output data set
  04/25/05 PAT Added WARD2002 to output data set.  
  04/27/05 PAT Skip parsing if address is blank.
  05/27/05 PAT Removed '&' from list of stripped punctuation marks.
               Corrected space-separated quadrant abbreviations (N W, etc.).
               Restored staddr_std= function to create standardized 
               version of _input_ address.  Option staddr_match= will
               provide the matching parcel/block address.
               Added new geo options anc2002=, cluster2000=, 
               psa2004=, zip_match=.
  06/26/05 PAT Added matching by block for addresses that could not match
               to a parcel.  User can prevent block matching by using
               block_match=N.
  08/01/05 PAT Created new match routine (%Address_match) to replace
               SQL match.
  08/13/05 PAT Added max_near_block_dist=
  08/21/05 PAT Improved labeling of address variables.
               Added geocoding results flag.
               Fully implemented ZIP code and missing quad matches.
               Match results now output to log.
               Corrected parsing problems (see Address_parse)
  08/22/05 PAT Added parameter checking.
  02/13/06 PAT Added MPRINT= option.  
               Fixed problem where a single quote in the label of the
               &STADDR variable causes an unmatched quote error by
               changing %sysfunc to %qsysfunc.
  07/29/06 PAT Added GEO_MATCH= option.

  03/28/07 DSD Added unit_match parameter to macro definition
               Added address_split_units macro call to parse unit number after
                     all other adress parsing has been completed.
	       Added addr_apt_unit parameter to macro for the apt/unit 
               number of address
  11/20/07 PAT Removed drop for end_apt on output data set if GEO_MATCH~=Y.
  11/21/08 PAT Only apply StreetAlt corrections if the original street
               name is not valid. (Protects against inadvertent recoding
               of valid street names in StreetAlt.)
  03/22/09 PAT 2.5 Standard address var (staddr_std=) now includes apt no. 
                   Added %add_staddr_std() macro call.
  04/26/10 PAT 2.6 Added QUIET= option.
  02/03/14 PAT Updated for new SAS1 server.
******************************************************************************/

/** Macro DC_geocode - Start Definition **/

%macro DC_geocode( 

  data= ,                     /* Input data set */
  id= ,                       /* ID var(s) (opt.) */
  staddr= ,                   /* Street address (char. var.) */
  zip= ,                      /* 5-digit ZIP code (char. var., opt.) */

  out= ,                      /* Output data set */
  ds_label= ,                 /* Output data set label (in quotes, opt.) */

  staddr_std=&staddr._std,      /* Standardized address (blank to omit) */

  geo_match=y,                /* Perform geo. matching with parcels (Y/N) */

  keep_geo=staddr_match ssl x_coord y_coord geo2000 geoblk2000
           cluster_tr2000 ward2002 anc2002 cluster2000 psa2004
           zip_match dcg_num_parcels,  /* List of geo vars to keep in geocoded file */

  staddr_match=&staddr._match,  /* Matching parcel/block street address (blank to omit) */
  ssl=ssl,                    /* SSL ID output var name (blank to omit) */
  x_coord=x_coord,            /* X coordinate output var name (blank to omit) */
  y_coord=y_coord,            /* Y coordinate output var name (blank to omit) */
  geo2000=geo2000,            /* Census tract ID (blank to omit) */
  geoblk2000=geoblk2000,      /* Census block ID (blank to omit) */
  cluster_tr2000=cluster_tr2000,  /* 2000 neighborhood cluster, tract-based (blank to omit) */
  ward2002=ward2002,          /* 2002 ward (blank to omit) */
  anc2002=anc2002,            /* 2002 ANC (blank to omit) */
  cluster2000=cluster2000,    /* 2000 neighborhood cluster (blank to omit) */
  psa2004=psa2004,            /* 2004 Police Service Area (blank to omit) */
  zip_match=zip_match,        /* Matching parcel/block ZIP code (blank to omit)*/
  dcg_num_parcels=dcg_num_parcels,  /* Number of parcels matching address */

  dcg_match_score=dcg_match_score,  /* Match score */

  match_score_min=50,            /** Minimum score for a match **/

  block_match=Y,              /* Match to blocks if address has no exact parcel match (Y/N) */
  unit_match=y,                /* Perform unit matching with parcels (Y/N) */

  max_near_block_dist=500,    /* Maximum difference between street nos. for near block matches */

  parcelfile=Realpr_r.Parcel_Geocode_Base,   /* Base parcel file for matching */
  hashfmt=$pbhash.,           /* Hash table format for base parcel file */
  stvalidfmt=$stvalid,        /* Format for validating street names */
  staltfmt=$strtalt,          /* Format with alternate street name spellings */
  punct_list=%str(,.*''""<>;[]{}|_+=^$@!~`%:?),    /* List of punctuation to strip */

  listunmatched=Y,              /* List nonmatching addresses (Y/N, def. Y) */
  quiet=N,                     /* Suppress warning messages (Y/N, def. N) */
  debug=N,                     /* Print debugging information (Y/N, def. N) */
  mprint=N                     /* Print resolved macro code in LOG (Y/N, def. N) */
  
  );

  %let mversion = 2.6;
  %let mdate = 05/02/10;
  %let mname = DC_geocode;

  %let listunmatched = %upcase( &listunmatched );
  %let debug = %upcase( &debug );
  %let geo_match = %upcase( &geo_match );
  %let block_match = %upcase( &block_match );
  %let quiet = %upcase( &quiet );
  %let mprint = %upcase( &mprint );

  %push_option( mprint )

  %if &debug ~= Y and &mprint = N %then %do;
    options nomprint;
  %end;
  %else %do;
    options mprint;
  %end;

  %note_mput( macro=&mname, msg=&mname macro version &mversion (&mdate) written by %str(Peter Tatian, Beata Bajaj & David DOrio). )
  %note_mput( macro=&mname, msg=(c) 2008 The Urban Institute/NeighborhoodInfo DC - All Rights Reserved. )

  %note_mput( macro=&mname, msg=Starting macro. )

  %** Check for required parameters **;

  %if &data = %then %do;
    %err_mput( macro=&mname, msg=The macro parameter data= cannot be blank. )
    %goto exit;
  %end;

  %if &out = %then %do;
    %err_mput( macro=&mname, msg=The macro parameter out= cannot be blank. )
    %goto exit;
  %end;

  %if &staddr = %then %do;
    %err_mput( macro=&mname, msg=The macro parameter staddr= cannot be blank. )
    %goto exit;
  %end;

  %if &dcg_match_score = %then %do;
    %err_mput( macro=&mname, msg=The macro parameter dcg_match_score= cannot be blank. )
    %goto exit;
  %end;

  %** Check for valid keywords in keep_geo= **;

  %let geo_valid = /staddr_match/ssl/x_coord/y_coord/geo2000/geoblk2000/
                   /cluster_tr2000/ward2002/anc2002/cluster2000/psa2004/
                   /zip_match/dcg_num_parcels/;

  %let geo_valid = %upcase( &geo_valid );
  %let u_keep_geo = %upcase( &keep_geo );

  %let i = 1;
  %let gkw = %scan( &u_keep_geo, &i );

  %do %while ( &gkw ~= );

    %if %index( &geo_valid, /&gkw/ ) = 0 %then %do;
      %err_mput( macro=&mname, msg=Invalid keyword %upcase(&gkw) found in KEEP_GEO= parameter. )
      %goto exit;
    %end;
  
    %let i = %eval( &i + 1 );
    %let gkw = %scan( &u_keep_geo, &i );

  %end;

  %** Check that ZIP_MATCH is included if ZIP= is specified **;

  %if &zip ~= %then %do;
    %if &zip_match= or %index( &u_keep_geo, ZIP_MATCH ) = 0 %then %do;
      %err_mput( macro=&mname, msg=If ZIP code to be used to match addresses (ZIP=) then ZIP_MATCH must be included in output data set. )
      %err_mput( macro=&mname, msg=i.e. ZIP_MATCH= must be omitted entirely or be nonblank, and )
      %err_mput( macro=&mname, msg=KEEP_GEO= must be omitted entirely or include ZIP_MATCH. )
      %goto exit;
    %end;
  %end;

  %** Complete any previous run blocks before checking for data set **;         

  run;      

  %** Check for input data set and          **;
  %** get label for street address variable **;

  %let dsid=%sysfunc(open(&data,i));
  %if &dsid %then %do;
      %let staddr_lbl=%qsysfunc(varlabel(&dsid,%sysfunc(varnum(&dsid,&staddr))));
      %let rc=%sysfunc(close(&dsid));
  %end;
  %else %do;
    %err_mput( macro=&mname, msg=The input data set %upcase(&data) does not exist or could not be opened. )
    %goto exit;
  %end;

  ** Read, clean, and parse address data **;

  %note_mput( macro=&mname, msg=Cleaning and parsing address data. )

  data _dcg_indat (compress=no);
  
    set &data;
    
    length _dcg_scrub_addr _dcg_adr_street_clean $ 500;

    if &staddr = "" then goto _dc_geocode_end;
    
    _dcg_scrub_addr = upcase( left( &staddr ) );
    
    _dcg_scrub_addr = tranwrd( _dcg_scrub_addr, "N.W.", "NW " );
    _dcg_scrub_addr = tranwrd( _dcg_scrub_addr, "N.E.", "NE " );
    _dcg_scrub_addr = tranwrd( _dcg_scrub_addr, "S.W.", "SW " );
    _dcg_scrub_addr = tranwrd( _dcg_scrub_addr, "S.E.", "SE " );
    
    ** Strip punctuation **;
     
    _dcg_scrub_addr = 
      left( translate( _dcg_scrub_addr, repeat( " ", length( "&punct_list" ) ),
                       "&punct_list" ) );
    
    ** Remove extra spaces **;
    
    _dcg_scrub_addr = compbl( _dcg_scrub_addr );

    ** Correct space-separated quadrant abbreviations **;

    _dcg_scrub_addr = tranwrd( _dcg_scrub_addr, " N W ", " NW " );
    _dcg_scrub_addr = tranwrd( _dcg_scrub_addr, " S W ", " SW " );
    _dcg_scrub_addr = tranwrd( _dcg_scrub_addr, " N E ", " NE " );
    _dcg_scrub_addr = tranwrd( _dcg_scrub_addr, " S E ", " SE " );

    ** Parse address **;

    %Address_parse( address=_dcg_scrub_addr, var_prefix=_dcg_adr_ )    

    if _dcg_adr_street = "" then goto _dc_geocode_end;

    ** Clean street address (apply StreetAlt.xls corrections) **;
    ** Only apply if original street name is not valid        **;

    if put( _dcg_adr_street, &stvalidfmt.. ) = " " then do;
      _dcg_adr_street_clean = put( _dcg_adr_street, &staltfmt.. );
    end;
    else do;
      _dcg_adr_street_clean = _dcg_adr_street;
    end;

    file log;

    ** Check for valid street names **;

    if put( _dcg_adr_street_clean, &stvalidfmt.. ) = " " and "&quiet" ~= "Y" then do;
      %warn_put( macro=&mname, 
                 msg="Street not found: " _dcg_adr_street_clean "(" &staddr ")" )
    end;

    _dc_geocode_end:    

    %if &debug=Y %then %do;

    file print;
    
    if _n_ = 1 then put // "******************  CLEANING & PARSING RESULTS  ******************" //;
    
    put '--------------------------------------------------------------';
    put _n_= / &staddr= / _dcg_scrub_addr= / ( _dcg_adr_: ) (= /);

    file log;

    %end;

/***
    %if %length( &staddr_std ) > 0 %then %do;
      rename &staddr._std=&staddr_std;
    %end;
    %else %do;
      drop &staddr._std;
    %end;
***/

  run;

   *******************************************************************************
   ***** this is a new macro that gets the APT or UNITNUMBER from an address *****
   ***** added by DSD 2/28/2007                                            *******
   *******************************************************************************;
  
   %** Parse out unit number from street address **;
   %address_split_units(inlib=work,inds=_dcg_indat,outlib=work,outds=_dcg_indat, debug=&debug)

   %if &staddr_std ~= %then %do;

     %** Add standardized address variable **;
     %add_staddr_std( inds=_dcg_indat, outds=_dcg_indat, staddr_std=&staddr._std )

   %end;

  %if &geo_match = Y %then %do;

  ** Match cleaned addresses with parcel base file **;

  %note_mput( macro=&mname, msg=Starting parcel match. Parcel base file is %upcase(&parcelfile). )

  %Address_match( 
    parcelfile=&parcelfile,
    hashfmt=&hashfmt,
    addrfile=_dcg_indat,
    out=&out,
    ds_label=&ds_label, 
    addr_street=_dcg_adr_street_clean,
    addr_street_lbl=&staddr_lbl,
    addr_number=_dcg_adr_begnum,
    addr_dir=_dcg_adr_quad,
    addr_zip=&zip,
    addr_apt_unit=_dcg_adr_apt_unit,
    parcel_street=ustreetname,
    parcel_ulownumber=ulownumber,
    parcel_nlownumber=nlownumber,
    parcel_nhighnumber=nhighnumber,
    parcel_dir=qdrntname,
    block_match=&block_match,
    unit_match=&unit_match ,
    geolist=&keep_geo,
    staddr_match=&staddr_match,
    ssl=&ssl, 
    x_coord=&x_coord,
    y_coord=&y_coord,
    geo2000=&geo2000,
    geoblk2000=&geoblk2000,
    cluster_tr2000=&cluster_tr2000,
    ward2002=&ward2002,
    anc2002=&anc2002,
    cluster2000=&cluster2000,
    psa2004=&psa2004,
    zip_match=&zip_match,
    match_score_min=&match_score_min,
    max_near_block_dist=&max_near_block_dist,
    dcg_num_parcels=&dcg_num_parcels,
    dcg_match_score=&dcg_match_score,
    debug=&debug,
    drop=
             %if &debug ~= Y %then %do;
               _dcg_: _temp_:
               USTREETNAME QDRNTNAME
               ULOWNUMBER NLOWNUMBER NHIGHNUMBER 
             %end;
  )

  %if &listunmatched = Y %then %do;

  %note_mput( macro=&mname, msg=Printing unmatched addresses to output (LISTUNMATCHED=Y). )

  proc print data=&out n='TOTAL UNMATCHED ADDRESSES: ';
    where &dcg_match_score < &match_score_min;
    var &id &staddr &staddr_std &zip &dcg_match_score;
    title2 '***************** UNMATCHED ADDRESSES *****************';

  run;
  title2;

  %end;
  %else %do;
    %note_mput( macro=&mname, msg=At users request (LISTUNMATCHED=N) unmatched addresses will not be printed. )
  %end;

  %end;       /** %if &geo_match = Y **/
  %else %do;

  %note_mput( macro=&mname, msg=Parcel matching will be skipped (%upcase(geo_match)=&geo_match). )

  data &out
          %if %length( &ds_label ) > 0 %then %do;
            (label=&ds_label)
          %end;
    ;

    set _dcg_indat

    (drop=_dcg_: 
      %if &geo_match = Y %then %do;
        end_apt
      %end;
    )
    ;

  run;

  %end;

  %exit:

  %pop_option( mprint )

  %note_mput( macro=&mname, msg=Exiting macro. )

%mend DC_geocode;

/** End Macro Definition **/

