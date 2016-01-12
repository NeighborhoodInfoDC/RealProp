/**************************************************************************
 Program:  Units_sum_all.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/17/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Create counts of single-family, condo, and coop units from
 real property database.  Currently does counts by tracts,
 clusters, wards, and city.

 Modifications:
  08/07/06  PAT Added units_sf_condo and units_owner.
  11/17/06  PAT Updated to use Parcel_base & Parcel_geo files.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

rsubmit;

%let start_yr = 1995;
%let end_yr  = 2006;

*options obs=1000;

** Create count vars **;

data Num_units_raw (compress=no);

  merge 
    RealProp.Parcel_base 
      (keep=ssl ownerpt_extractdat_first ownerpt_extractdat_last ui_proptype no_units
       where=(ui_proptype in ( '10', '11', '12' ))
       in=in1)
    RealProp.Parcel_geo
      (keep=ssl geo2000 cluster_tr2000 ward2002 city);
  by ssl;
  
  if in1;
  
  ***if not( missing( geo2000 ) ) then city = '1';
  
  ***label city = 'Washington, D.C.';
  
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

/**************
%File_info( data=Num_units_raw, freqvars=year )

RUN;

ENDRSUBMIT;

SIGNOFF;

ENDSAS;
*****************/

/** Macro Summarize - Start Definition **/

%macro Summarize( level= );

%let level = %upcase( &level );

%if &level = GEO2000 %then %do;
  %let filesuf = tr00;
  %let level_lbl = Census tract (2000);
  %let level_fmt = $geo00a.;
%end;
%else %if &level = CLUSTER_TR2000 %then %do;
  %let filesuf = cltr00;
  %let level_lbl = Neighborhood cluster (tract-based, 2000);
  %let level_fmt = $clus00a.;
%end;
%else %if &level = WARD2002 %then %do;
  %let filesuf = wd02;
  %let level_lbl = Wards (2002);
  %let level_fmt = $ward02a.;
%end;
%else %if &level = CITY %then %do;
  %let filesuf = city;
  %let level_lbl = City;
  %let level_fmt = $1.;
%end;
%else %do;
  %err_mput( macro=Summarize, msg=Level (LEVEL=&level) is not recognized. )
  %goto exit;
%end;

** Tracts **;

proc summary data=Num_units_raw nway completetypes;
  %*if &level ~= CITY %then %do;
    class &level /preloadfmt;
    class year;
    format &level &level_fmt;
  %*end;
  var units_: ;
  output out=Num_units_&filesuf (drop=_freq_ _type_) sum=;
run;

%Super_transpose( 
  data=Num_units_&filesuf,
  out=Num_units_&filesuf._tr,
  var=units_sf units_condo units_coop units_sf_condo units_owner,
  id=year,
  by=&level,
  mprint=y
)

data RealProp.Units_sum_&filesuf 
       (%*if &level ~= CITY %then %do;
          sortedby=&level 
        %*end;
        label="Single-family, condominium, and cooperative unit counts from real property data, &level_lbl level");

  set Num_units_&filesuf._tr;
  
  array a{*} units_: ;
  
  do i = 1 to dim( a );
    if a{i} = . then a{i} = 0;
  end;
  
  /*
  units_total_&year = units_sf_&year + units_condo_&year;
  */
  
  /*
  label
    units_sf_&year = "Number of single-family homes, &year"
    units_condo_&year = "Number of condominium units, &year"
    units_total_&year = "Total housing units (s.f. & condo.), &year";
  */

  %*if &level ~= CITY %then %do;
    format &level ;
  %*end;

  drop i;

run;

%file_info( data=RealProp.Units_sum_&filesuf )

run;

** Register metadata **;

/*
%Delete_metadata_file( 
  ds_lib=RealProp,
  ds_name=Num_units_&filesuf,
  meta_lib=metadat,
  meta_pre=meta,
  update_notify=ptatian@ui.urban.org
)
*/

/*
%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=Num_units_&filesuf,
  creator_process=Num_units.sas,
  restrictions=None,
  revisions=%str(&revisions)
)
*/

/*
proc download status=no
  data=RealProp.Units_sum_&filesuf 
  out=RealProp.Units_sum_&filesuf;
*/

run;

%exit:

%mend Summarize;

/** End Macro Definition **/

%let revisions=New file.;

%Summarize( level=city )
%Summarize( level=geo2000 )
%Summarize( level=cluster_tr2000 )
%Summarize( level=ward2002 )

run;

endrsubmit;

signoff;
