/**************************************************************************
 Program:  Parcel_geo_update.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/03/06
 Version:  SAS 9.2
 Environment:  Windows
 
 Description:  Autocall macro to update Parcel_geo file with latest
 parcel-geography joins.

 Modifications:
  02/12/07 PAT Updated program for SAS v9 w/o DBMS/Engines.
  07/06/12 RAG Updated to include 2012 Ward, ANCs, and PSAs, and 2010 Tracts.
  11/06/13 RAG Updated to include keep_vars parameter.
  12/19/13 PAT Updated for new SAS1 server.
  03/30/14 PAT Added voterpre2012 var to output data set. 
**************************************************************************/

/** Macro Parcel_geo_update - Start Definition **/

%macro Parcel_geo_update( 
  update_file=, 
  geo_file=RealPr_r.Parcel_geo,
  out_file=Parcel_geo_&update_file,
  map_path=&_dcdata_r_path\RealProp\Maps,
  map_prefix=Parcel_join_,
  finalize=N,
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
  
  %let ds_label = DC real property parcels - geographic identifiers;
  
  /**%syslput update_file=&update_file;**/
  /**%syslput out_file=&out_file;**/
  /**%syslput geo_file=&geo_file;**/
  /**%syslput finalize=&finalize;**/
  /**%syslput retain_temp=&retain_temp;**/
  /**%syslput info=&info;**/
  /**%syslput meta=&meta;**/
  /**%syslput ds_label=&ds_label;**/
  
  ** Compile joined mapping files together **;
  
  /*
  libname dbmsdbf dbdbf "&map_path\&update_file" ver=4 width=12 dec=2
          anc02=&map_prefix.anc02
          block=&map_prefix.block
          nbhclus=&map_prefix.nbhclus
          polsa=&map_prefix.polsa
          ward02=&map_prefix.ward02
          zip=&map_prefix.zip;
  */
  
  libname inlib "&map_path\&update_file";

  %let xfer_files = ;

  /** Macro Xfer_dbf - Start Definition **/

  %macro Xfer_dbf( inds=, var=, keep= );

    %let xfer_files = &xfer_files &inds;

    data &inds;

      /*set dbmsdbf.&inds;*/
      set inlib.&map_prefix.&inds;
      
      %Octo_&var( )
      
      format _all_;
      informat _all_;
      
      keep ssl &var &keep;

    run;

    proc sort data=&inds;
      by ssl;

    run;

  %mend Xfer_dbf;

  /** End Macro Definition **/

  options obs=max;

  ** Extract individual DBF files to SAS, creating standard variables **;

  %Xfer_dbf( inds=block, var=GeoBlk2000, keep=CJRTRACTBL x_coord y_coord )

  %Xfer_dbf( inds=ward02, var=ward2002 )

  %Xfer_dbf( inds=polsa, var=psa2004 )

  %Xfer_dbf( inds=anc02, var=anc2002 )

  %Xfer_dbf( inds=zip, var=zip )

  %Xfer_dbf( inds=nbhclus, var=cluster2000 )

  %Xfer_dbf( inds=Block10, var=GeoBlk2010, keep=GEOID10)

  %Xfer_dbf( inds=ward12, var=ward2012 )

  %Xfer_dbf( inds=PSA12, var=psa2012 )

  %Xfer_dbf( inds=anc12, var=anc2012 )



  ** Merge files together, create remaining geographic IDs **;

  data Parcel_geo_update;

    length CJRTRACTBL $ 12;

    merge &xfer_files;
    by ssl;
    
    ** Census tract **;
    
    length Geo2000 $ 11 Geo2010 $ 11;/*Added 2012 vars 07/06/12 RAG*/

    Geo2000 = GeoBlk2000;
    Geo2010 = GeoBlk2010;/*Added 2012 vars 07/06/12 RAG*/
   
    label
      Geo2000 = "Full census tract ID (2000): ssccctttttt"
      Geo2010 = "Full census tract ID (2010): ssccctttttt";/*Added 2012 vars 07/06/12 RAG*/
   
    ** Tract-based neighborhood clusters **;
    
    %Block00_to_cluster_tr00()
    
    ** Casey target area neighborhoods **;
    
    %Tr00_to_cta03()
    %Tr00_to_cnb03()
    
    ** East of the river **;
    
    %Tr00_to_eor()
    
    ** City **;
    
    length City $ 1;
    
    city = "1";
    
    label city = "Washington, D.C.";
    
    ** Voting precincts 2012 **;
    
    %Block10_to_vp12()
    
    format geo2000 $geo00a. anc2002 $anc02a. psa2004 $psa04a. ward2002 $ward02a.
     	   geo2010 $geo10a. anc2012 $anc12a. psa2012 $psa12a. ward2012 $ward12a./*Added 2012 vars 07/06/12 RAG*/
		   zip $zipa. cluster2000 $clus00a. city $city.;
    
    label
      CJRTRACTBL = "OCTO tract/block ID"
      Ssl = "Property Identification Number (Square/Suffix/Lot)"
    ;
      
  run;

  /*************************************
  ** Upload update file to Alpha **;
  
  **rsubmit;
  
  options obs=max;

  proc upload status=no
    inlib=Work 
    outlib=Work memtype=(data);
  select Parcel_geo_update;
  
  run;
  ******************************************/

  ** Begin update **;

  data &out_file (label="&ds_label [updated by &update_file]" compress=no);

    update 
      &geo_file
      Parcel_geo_update
      updatemode=nomissingcheck;
    by ssl;
    
  run;
  
  **endrsubmit;

  %** Retain update-specific base file in RealProp library **;

  %if &retain_temp = Y %then %do;

    %note_mput( macro=Parcel_geo_update, msg=Temporary updated parcel geo file (RealProp.&out_file) will be retained (RETAIN_TEMP=&retain_temp). )
    
    **rsubmit;

    ** Copy &out_file to RealProp library **;

    proc copy in=work out=RealProp;
      select &out_file / memtype=data;
    run;

    /**x "purge [dcdata.realprop.data]&out_file..*";**/
    
    run;
    
    **endrsubmit;

  %end;

  %** Process final version of updated parcel geo file **;

  %if &finalize = Y %then %do;

    %note_mput( macro=Parcel_geo_update, msg=Existing parcel geo file (&geo_file) will be replaced (FINALIZE=&finalize). )

    ** Replace existing base file **;
    
    **rsubmit;

    data &geo_file (label="&ds_label" sortedby=ssl);
      set &out_file;
    run;
    
    **endrsubmit;

    %let per_pos = %sysfunc(indexc("&geo_file",'.'));
    %let len = %sysfunc( length( "&geo_file" ) );

    %if &per_pos > 0 %then %do;
      %let geo_file_dsname = %sysfunc( substr( "&geo_file", %eval(&per_pos+1), %eval(&len-(&per_pos+1)) ) );
    %end;
    %else %do; 
      %let geo_file_dsname = &geo_file;
    %end;
    
    /**%syslput geo_file_dsname=&geo_file_dsname;**/
    
    **rsubmit;

    /**x "purge /keep=2 [dcdata.realprop.data]&geo_file_dsname..*";**/
    
    run;
    
    **endrsubmit;
    
    %if &meta = Y %then %do;
    
      ** Update metadata entry **;

      **rsubmit;

      %Dc_update_meta_file(
        ds_lib=Realprop,
        ds_name=&geo_file_dsname,
        creator_process=Parcel_geo_&update_file..sas,
        restrictions=None,
        revisions=Updated with &update_file..
      )
      
      run;
      
      **endrsubmit;
      
    %end;

    %put Revisions=Updated with &update_file..;

    %let info_file = &geo_file;

  %end;
  %else %do;

    %let info_file = &out_file;

    %warn_mput( macro=Parcel_geo_update, msg=Existing parcel geo file (&geo_file) will NOT be replaced because FINALIZE=&finalize.. )

  %end;

  /**%syslput info_file=&info_file;**/

  %if &info = Y %then %do;
    **rsubmit;
    %file_info( data=&info_file, 
                freqvars=geo2000 Ward2002 Anc2002 Psa2004 geo2010 Ward2012 Anc2012 Psa2012 voterpre2012 cluster_tr2000 Cluster2000 Zip
                         casey_ta2003 casey_nbr2003 eor city ) /*Added 2012 vars 07/06/12 RAG*/
    run;
    **endrsubmit;
  %end;

  %exit:
  
  %note_mput( macro=Parcel_geo_update, msg=Exiting macro. )

%mend Parcel_geo_update;

/** End Macro Definition **/

