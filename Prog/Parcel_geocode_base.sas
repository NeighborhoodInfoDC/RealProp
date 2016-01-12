/**************************************************************************
 Program:  Parcel_geocode_base.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/19/05
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Create parcel base file for geocoding.  For now,
 eliminates multiple address entries for condo units, etc. but for
 future should be able to switch between unit and non-unit matching.

 Modifications:
  04/20/05  Added census tract and block, neighborhood cluster IDs
  04/25/05  Added 2002 wards.
  04/27/05  Added corrections for BAY LN & MONTEREY LN to Ownerpt.
  05/16/05  NLOWNUMBER is now filled in for all parcels, not just ranges.
  05/16/05  Added 2004 PSAs (PSA2004), 2002 ANCs (ANC2002), 
            ZIP Codes (ZIP), neighborhood clusters (official OP definitions, 
            CLUSTER2000))
  05/25/05  Added DEL_CODE variable.
**************************************************************************/

%let LOCAL = ;        /*** Set to * to run locally, blank to run remotely ***/
%let obs = 1000000;   /*** Full data set ***/
/*%let obs = 100;*/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
&LOCAL %include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp )

&LOCAL %syslput LOCAL=&LOCAL;
&LOCAL %syslput obs=&obs;

&LOCAL rsubmit;

%let source = Ownerpt_2005_03;
%let revisions = %str(Added DEL_CODE variable.);

** Merge parcel data with geo IDs **;
** Drop parcels without complete street addresses **;

data A;

  merge 
    RealProp.&source
     (keep=ssl proptype premiseadd recordno del_code
           ustreetname qdrntname lownumber highnumber unitnumber
           x_coord y_coord
      where=(lownumber not in ( "", "0", "00", "000", "0000" ) and 
             ustreetname ~= "" and qdrntname ~= "")
      in=in_parcel
      obs=&obs)
    RealProp.Ownerpt_geo
      (keep=ssl Geo2000 GeoBlk2000 cluster_tr2000 ward2002
            Zip Anc2002 Psa2004 Cluster2000)
      ;
  by ssl;
  
  if in_parcel;
         
  length PREMISEADD_std PREMISEADD_nounit $ 80;
  length odd_even_range 3;
  
  ** UI vers. street numbers **;
  ***** NB: eventually, add 1/2 etc. to ULOWNUMBER **;
  
  length nlownumber nhighnumber 8 ulownumber $ 12;
  
  ** Numeric high and low street numbers **;

  nlownumber = input( LOWNUMBER, 4. );
  
  nhighnumber = input( HIGHNUMBER, 4. );
  
  if nhighnumber in ( 0, . ) then nhighnumber = .n;
  
  ** Check ranges **;
  
  if nhighnumber > 0 then do;
  
    ** Parcel has an address range **;
  
    if abs( nlownumber - nhighnumber ) >= 1000 or
       nlownumber >= nhighnumber then do;
         %warn_put( msg="Invalid street no. range: " recordno= ssl= nlownumber= nhighnumber= PREMISEADD= );
       delete;
    end;    

    /*** nlownumber = input( LOWNUMBER, 4. ); ***/
    ulownumber = "NA";

    if mod( nlownumber, 2 ) ~= mod( nhighnumber, 2 ) then
      odd_even_range = 1;
    else 
      odd_even_range = 0;
    
  end;
  else do;
  
    ** Parcel has a single address **;
    
    /*** nlownumber = .n; ***/
    ulownumber = left( put( input( LOWNUMBER, 4. ), 4. ) );

    odd_even_range = .n;

  end;
    
  label
    ulownumber = "House number of the property address (UI cleaned, 'NA'=multiple addresses)"
    nlownumber = "Starting house number of the property address (numeric)"
    nhighnumber = "Ending house number of the property address (numeric, only if multiple addresses)"
    odd_even_range = "Parcel address range is mixed odd/even";

  format odd_even_range yesno.;

  ** Standardized addresses **;
    
  if nhighnumber > 0 then
    PREMISEADD_nounit = 
      trim( put( nlownumber, 4. ) ) || " - " ||
      trim( left( put( nhighnumber, 4. ) ) ) || " " ||
      trim( ustreetname ) || " " ||
      trim( qdrntname );
  else
    PREMISEADD_nounit = 
      trim( ulownumber ) || " " ||
      trim( ustreetname ) || " " ||
      trim( qdrntname );
  
  /*** SKIP UNTIL UNIT MATCHING IS ADDED ***
  if unitnumber ~= "" then
    PREMISEADD_std = 
      trim( PREMISEADD_nounit ) || " # " || 
      trim( unitnumber );
  else
  *******/
    PREMISEADD_std = 
      trim( PREMISEADD_nounit );

  PREMISEADD_nounit = left( compbl( upcase( PREMISEADD_nounit ) ) );
  PREMISEADD_std = left( compbl( upcase( PREMISEADD_std ) ) );
  
  label
    PREMISEADD_std = "Standardized property address";
  
  ** Property type order for selection **;
  
  select ( proptype );
    when ( "1" ) porder = 1;
    when ( "3" ) porder = 2;
    when ( "4" ) porder = 3;
    when ( " " ) porder = 4;
    when ( "2" ) porder = 5;
    when ( "5" ) porder = 6;
    when ( "6" ) porder = 7;
    otherwise
      put "Unknown PROPTYPE: " recordno= ssl= proptype=;
  end;

  drop lownumber highnumber;

run;

proc sort data=A;
  by PREMISEADD_nounit descending porder descending ssl;

run;

data RealProp.Parcel_geocode_base 
      (label="DC real property parcels - geocoding match base (source: &source)");

  set A;
  by PREMISEADD_nounit;
  
  retain num_parcels;
  
  if first.PREMISEADD_nounit then num_parcels = 0;
  
  num_parcels + 1;
  
  if last.PREMISEADD_nounit then do;
  
    output;
  
  end;
  
  label 
    num_parcels = "Number of real property parcels with same address";
  
  drop porder PREMISEADD_nounit;
  
run;

%File_info( data=RealProp.Parcel_geocode_base, freqvars=num_parcels odd_even_range )

** Update metadata **;

&LOCAL %Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=Parcel_geocode_base,
  creator_process=Parcel_geocode_base.sas,
  restrictions=None,
  revisions=&revisions
);

run;

&LOCAL endrsubmit;

&LOCAL signoff;
