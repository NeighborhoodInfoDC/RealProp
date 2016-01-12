/**************************************************************************
 Program:  2012_OneTime_Parcel_geo_update.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   R. grace
 Created:  07/02/2012
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  One time update to Parcel_geo file with 2010 tracts and blocks and 2012 ANCs, PolSAs, and Wards.

 Modifications:
**************************************************************************/
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp );
libname maps "D:\DCData\Libraries\RealProp\Maps\Geogs_2012";

/*Download most recent parcel_geo*/
rsubmit;

proc download status=no
  inlib=RealProp 
  outlib=RealProp memtype=(data);
  select parcel_geo;

run;

endrsubmit;

/***The following code is modified from parcel_geo_update.sas***/

	  /** Macro Xfer_dbf - Start Definition **/

	  %macro Xfer_dbf( inds=, var=, keep= );

	    data &inds (rename = (ssl_r = ssl));

		  length ssl_r $17.;
	      /*set dbmsdbf.&inds;*/
	      set maps.JOIN_&inds;
	      
	      %Octo_&var( check=y )
	      
	      format _all_;
	      informat _all_;
	      
		  ssl_r = ssl;

	      keep ssl_r &var &keep;

	    run;

	    proc sort data=&inds;
	      by ssl;

	    run;

	  %mend Xfer_dbf;

	  /** End Macro Definition **/

	  ** Extract individual DBF files to SAS, creating standard variables **;

	  %Xfer_dbf( inds=Block10, var=GeoBlk2010, keep=GEOID10)

	  %Xfer_dbf( inds=ward12, var=ward2012 )

	  %Xfer_dbf( inds=PSA12, var=psa2012 )

	  %Xfer_dbf( inds=anc12, var=anc2012 )

** Merge files together, create remaining geographic IDs **;

  data Geogs_2012 ;

    merge ANC12 Block10 PSA12 Ward12;
    by ssl;
    
    **2010 Census tract and Block Groups**;
    
    length Geo2010 $ 11 GeoBG2010 $12;

    Geo2010 = GeoBlk2010;
    GeoBG2010 = GeoBlk2010;

	label
      Geo2010 = "Full census tract ID (2010): ssccctttttt"
	  GeoBG2010 = "Full census block group ID (2010): sscccttttttb";

    /*
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
    */

	format geo2010 $geo10a. anc2012 $anc12a. psa2012 $psa12a. ward2012 $ward12a. 
			GeoBG2010 $bg10a. GeoBlk2010 $blk10a.;

    label
     Ssl = "Property Identification Number (Square/Suffix/Lot)"
	 geoid10 = "OCTO tract ID (2010)" 
    ;

  run;
/***End parcel_geo_update modification***/

proc sort data = geogs_2012;
by ssl;

proc sort data=realprop.parcel_geo out=parcel_geo;
by ssl;
run;

/*Merge new 2012 geographies onto parcel_geo file*/
data realprop.parcel_geo_2012geogs;
	merge parcel_geo Geogs_2012;
	by ssl;

	**2000 Block Groups**;
	length GeoBG2000 $12;

    GeoBG2000 = GeoBlk2000;

    label GeoBG2000 = "Full census block group ID (2000): sscccttttttb";
    format GeoBG2000 $bg00a.;

	format GeoBlk2000 $blk00a.; 
run;

proc compare base= realprop.parcel_geo compare=realprop.parcel_geo_2012geogs listvars;
run;

%File_info( data=realprop.parcel_geo_2012geogs, freqvars=anc2012 psa2012 ward2012 geo2010 )



