/**************************************************************************
 Program:  Num_units_all.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/03/06
 Version:  SAS 9.2
 Environment:  Remote Windows session (SAS1)
 
 Description:  Create counts of single-family, condo, and coop units from
 real property database.  Currently does counts by tracts,
 clusters, wards, and city.

 Modifications:
  08/07/06  PAT Added units_sf_condo and units_owner.
  11/17/06  PAT Updated to use Parcel_base & Parcel_geo files.
  01/29/07  PAT Added support for partial year data.
  04/20/09 PAT Updated for 2008 data.
  08/03/12  RAG Updated to include 2010 and 2012 geographies
  01/13/14 PAT  Updated for new SAS1 server.
  03/30/14 PAT Added voterpre2012 summary. 
  07/27/14 PAT Updated for 2014-Q1.
**************************************************************************/

%include "F:\DCData\SAS\Inc\StdRemote.sas";

** Define libraries **;
%DCData_lib( RealProp )

/**rsubmit;**/

%let end_yr = 2014;
%let end_qtr = 1;

%************  DO NOT CHANGE BELOW THIS LINE  ************;

%**** Initialize macro variables ****;

%let start_yr = 1995;
%let start_date = "01jan&start_yr"d;

%let end_date = %sysfunc( intnx( QTR, "01jan&end_yr"d, %eval( &end_qtr - 1 ), END ) );
%put end_date = %sysfunc( putn( &end_date, mmddyy10. ) );

%let lib  = RealProp;
%let data = Parcel_base;

proc sql noprint;
  select 
    left( put( datepart( modate ), worddatx12. ) ), 
    left( put( timepart( modate ), timeampm8. ) ) 
  into :filemod_dt, :filemod_tm
  from dictionary.tables
  where libname=%upcase("&lib") and memname=%upcase("&data");
quit;

%let revisions = Updated through &end_yr-Q&end_qtr with &lib..&data (%trim(&filemod_dt), %trim(&filemod_tm)).;

%put revisions=&revisions;

*options obs=1000;

** Create count vars **;

data Num_units_raw (compress=no);

  merge 
    &lib..&data 
      (keep=ssl ownerpt_extractdat_first ownerpt_extractdat_last ui_proptype no_units
       where=(ui_proptype in ( '10', '11', '12' ))
       in=in1)
    RealProp.Parcel_geo
      (drop=cjrtractbl x_coord y_coord);
  by ssl;
  
  if in1;
  
  if ui_proptype = '10' then units_sf = 1;
  else if ui_proptype = '11' then units_condo = 1;
  
  units_coop = no_units;
  
  units_sf_condo = sum( units_sf, units_condo, 0 );
  units_owner = sum( units_sf, units_condo, units_coop, 0 );
  
  ** Output individual obs. for each year **;
  
  do year = &start_yr to &end_yr;
  
    if year( ownerpt_extractdat_first ) <= max( year, 2001 ) <= year( ownerpt_extractdat_last ) 
      then output;
  
  end;

  label
    units_sf = 'Number of single-family homes'
    units_condo = 'Number of condominium units'
    units_coop = 'Number of cooperative units'
    units_sf_condo = 'Number of single-family homes and condominium units'
    units_owner = 'Number of ownership units (s.f./condo/coop)';
  
run;


/** Macro Summarize - Start Definition **/

%macro Summarize( level= );

%let level = %upcase( &level );

%if %sysfunc( putc( &level, $geoval. ) ) ~= %then %do;
  %let filesuf = %sysfunc( putc( &level, $geosuf. ) );
  %let level_lbl = %sysfunc( putc( &level, $geolbl. ) );
  %let level_fmt = %sysfunc( putc( &level, $geoafmt. ) );
%end;
%else %do;
  %err_mput( macro=Summarize, msg=Level (LEVEL=&level) is not recognized. )
  %goto exit;
%end;

** Summarize by specified geographic level **;

proc summary data=Num_units_raw nway completetypes;
  class &level /preloadfmt;
  class year;
  format &level &level_fmt;
  var units_: ;
  output out=Num_units&filesuf (drop=_freq_ _type_) sum=;
run;

%Super_transpose( 
  data=Num_units&filesuf,
  out=Num_units&filesuf._tr,
  var=units_sf units_condo units_coop units_sf_condo units_owner,
  id=year,
  by=&level,
  mprint=y
)

data RealProp.Num_units&filesuf 
       (sortedby=&level 
        label="Single-family, condominium, and cooperative unit counts, &start_yr to &end_yr-Q&end_qtr, DC, &level_lbl");

  set Num_units&filesuf._tr;
  
  array a{*} units_: ;
  
  do i = 1 to dim( a );
    if a{i} = . then a{i} = 0;
  end;
  
  format &level ;
  
  drop i;

run;

%if &end_qtr < 4 %then %do;
  proc datasets library=RealProp memtype=(data) nolist;
    modify Num_units&filesuf;
    label
      units_sf_&end_yr = "Number of single-family homes, &end_yr-Q&end_qtr"
      units_condo_&end_yr = "Number of condominium units, &end_yr-Q&end_qtr"
      units_coop_&end_yr = "Number of cooperative units, &end_yr-Q&end_qtr"
      units_sf_condo_&end_yr = "Number of single-family homes and condominium units, &end_yr-Q&end_qtr"
      units_owner_&end_yr = "Number of ownership units (s.f./condo/coop), &end_yr-Q&end_qtr";
  quit;
%end;

/**x "purge [dcdata.realprop.data]Num_units&filesuf..*";**/

%file_info( data=RealProp.Num_units&filesuf, printobs=0 )

run;

** Register metadata **;

%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=Num_units&filesuf,
  creator_process=Num_units_all.sas,
  restrictions=None,
  revisions=%str(&revisions)
)

run;

%exit:

%mend Summarize;

/** End Macro Definition **/

%Summarize( level=city )
%Summarize( level=anc2002 )
%Summarize( level=psa2004 )
%Summarize( level=eor )
%Summarize( level=geo2000 )
%Summarize( level=cluster_tr2000 )
%Summarize( level=ward2002 )
%Summarize( level=casey_nbr2003 )
%Summarize( level=casey_ta2003 )
%Summarize( level=zip )
%Summarize( level=anc2012 )
%Summarize( level=psa2012 )
%Summarize( level=geo2010 )
%Summarize( level=ward2012 )
%Summarize( level=voterpre2012 )

run;

/**endrsubmit;**/

/**signoff;**/

