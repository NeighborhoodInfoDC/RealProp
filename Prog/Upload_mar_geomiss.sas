/**************************************************************************
 Program:  Upload_mar_geomiss.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/25/07
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Upload MAR addresses with geographic IDs added.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

%let map_path=&_dcdata_path\RealProp\Maps;
%let update_file = Mar_geomiss;
%let map_prefix=Parcel_join_;

%syslput update_file=&update_file;

libname inlib "&map_path\&update_file";

%let xfer_files = ;

/** Macro Xfer_dbf - Start Definition **/

%macro Xfer_dbf( inds=, var=, keep= );

  %let xfer_files = &xfer_files &inds;

  data &inds;

    set inlib.&map_prefix.&inds;
    
    %Octo_&var( )
    
    format _all_;
    informat _all_;
    
    keep ssl ADDRESS_ID &var &keep;

  run;

  proc sort data=&inds nodupkey;
    by ssl ADDRESS_ID;

  run;

%mend Xfer_dbf;

/** End Macro Definition **/

options obs=max;

** Extract individual DBF files to SAS, creating standard variables **;

%Xfer_dbf( inds=block, var=GeoBlk2000, keep=cjrtractbl x_coord y_coord )

%Xfer_dbf( inds=ward02, var=ward2002 )

%Xfer_dbf( inds=polsa, var=psa2004 )

%Xfer_dbf( inds=anc02, var=anc2002 )

%Xfer_dbf( inds=zip, var=zip )

%Xfer_dbf( inds=nbhclus, var=cluster2000 )

** Merge files together, create remaining geographic IDs **;

data &update_file._geo;

  length CJRTRACTBL $ 12;

  merge &xfer_files;
  by ssl ADDRESS_ID;
  
  ** Census tract **;
  
  length Geo2000 $ 11;

  Geo2000 = GeoBlk2000;
  
  label
    Geo2000 = "Full census tract ID (2000): ssccctttttt";
  
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
  
  format geo2000 $geo00a. anc2002 $anc02a. psa2004 $psa04a. ward2002 $ward02a.
         zip $zipa. cluster2000 $clus00a. city $city.;
  
  label
    CJRTRACTBL = "OCTO tract/block ID"
    Ssl = "Property Identification Number (Square/Suffix/Lot)"
    x_coord = "Longitude of parcel center (MD State Plane Coord., NAD 1983 meters)"
    y_coord = "Latitude of parcel center (MD State Plane Coord., NAD 1983 meters)"
  ;
    
run;


** Upload update file to Alpha **;

rsubmit;

options obs=max;

proc upload status=no
  inlib=Work 
  outlib=RealProp memtype=(data);
select &update_file._geo;

run;

%File_info( data=RealProp.&update_file._geo, freqvars=ward2002 )

run;

endrsubmit;

signoff;

