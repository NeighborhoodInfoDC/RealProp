/**************************************************************************
 Program:  Address_match.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/01/05
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to match addresses to parcel base.

 Modifications:
  08/13/05  Allow near block matches, added max_near_block_dist=.
            Added block_match= to allow supression of all block matching.
  08/18/05  Assume quadrant if unique.
  08/21/05  Prevent search from going beyond st num + block dist
            Reports match sucesss rate in log.
            Better labeling of matching st. address var.
  03/28/07  DSD- Add unit_match parameter to macro call. Default = Y
  03/08/07  DSD- Added ui_proptype=11 to unit matching
  04/20/07  DSD- added sort to make sure that the parcelfile is sorted 
		by  hashkey nlownumber nhighnumber 
  04/20/07 DSD- added PARCEL match key
  04/20/07 DSD- added NUM_MATCH_KEYS variable that is used anywhere that the length
	        of the match string needs the total # of keys. Replaced the 
		occurances of ST_NAME match key with NUM_MATCH_KEYS where it was
		being used to identify the length of the match string.
  04/20/2007 DSD- changed the EXACT_MATCH_MIN value from 91 to 111
  07/26/2007 PAT- added _adm_hashkey to debug output for address to match.
 Next steps:  
  Print best match for nonmatches
  02/03/14 PAT  Updated for new SAS1 server.
**************************************************************************/

/** Macro Address_match - Start Definition **/

%macro Address_match( 
  parcelfile=,
  addrfile=,
  out=, 
  ds_label=,
  hashfmt=$pbhash.,
  addr_street=,
  addr_dir=,
  addr_number=,
  addr_zip=,
  addr_apt_unit=,            /** Unit or Apartment Number **/
  addr_street_lbl=,          /** Label for street address **/
  parcel_street=,
  parcel_dir=,
  parcel_ulownumber=,
  parcel_nlownumber=,
  parcel_nhighnumber=,
  block_match=Y,
  geolist=,
  staddr_match=,
  ssl=, 
  x_coord=,
  y_coord=,
  geo2000=,
  geoblk2000=,
  cluster_tr2000=,
  ward2002=,
  anc2002=,
  cluster2000=,
  psa2004=,
  zip_match=,
  unit_match=Y,                 /** Match by Unit or Apartment number option **/
  dcg_num_parcels=,
  dcg_match_score=,
  max_near_block_dist=500,
  match_score_min=50,            /** Minimum score for a match **/
  drop=,                         /** List of vars to drop from output data set (opt.) **/
  mname=DC_Geocode,              /** Name of calling macro for messages **/
  debug=N
  );

  %let debug = %upcase( &debug );
  %let block_match = %upcase( &block_match );

  %if &max_near_block_dist = %then %let max_near_block_dist = 0;  
  %else %if &max_near_block_dist < 0 %then %let max_near_block_dist = 0;  

  %if &block_match = N %then %do;
    %let max_near_block_dist = 0;
    %note_mput( macro=&mname, msg=At users request (BLOCK_MATCH=N) no block matching will be performed. )
  %end;
  %else %do;
    %note_mput( 
      macro=&mname, 
      msg=Maximum difference in street nos. for near block match (MAX_NEAR_BLOCK_DIST=) is &max_near_block_dist.. )
  %end;
  
  %if &debug = Y %then %let premiseadd = premiseadd;
  %else %let premiseadd = ;

  %** List of optional geographic identifer vars in parcel base file **;

/*********** removed ********************************************************
  %let geolist = staddr_match ssl x_coord y_coord geo2000 geoblk2000
                 cluster_tr2000 ward2002 anc2002 cluster2000 psa2004
                 zip_match dcg_num_parcels;
************ end removed ***************************************************/
                 
  %** Match flag keys **;
  %let NUM_MATCH_KEYS=10;

  %let PARCEL = 10;
  %let ST_NAME = 9;
  %let ST_NUM_PARCEL = 8;
  %let ST_NUM_BLOCK = 7;
  %let ST_NUM_NEAR_BLK = 6;
  %let QUAD_EXACT = 5;
  %let QUAD_NOTNEEDED = 4;
  %let QUAD_OVERRIDE = 3;
  %let ZIP_EXACT = 2;
  %let ZIP_OVERRIDE = 1;

  %** Minimum value for exact match score **;
  
  %let EXACT_MATCH_MIN = 111;


  ** sort parcel file to make sure that the records are listed correctly ***;  
  /*** remove for now, not enough space to sort *****
  proc sort  data=  &parcelfile;
  by hashkey nlownumber nhighnumber;
  run;
 ****************************************************/
  ** Match all addresses to parcel base **;

  data &out
          %if %length( &ds_label ) > 0 %then %do;
            (label=&ds_label)
          %end;
    ;

    set &addrfile end=eof;
    
    %if &debug = Y %then %do;
      put "==========================================================================================================";
      put "Address to match: " (_n_ &addr_number &addr_street &addr_dir &addr_apt_unit &addr_zip) (=);
      put "==========================================================================================================";
    %end;

    ** Search for first parcel record to compare to address **; 
    
    length _adm_hashkey $ 100;

    if put( &addr_street, $stvalid. ) ~= " " then do;

    ** Valid street name, so find starting obs. in base file for match search **;

    /***PT 07/26/07*** _adm_hashnumber = 100 * int( &addr_number / 100 ); ***/
    _adm_hashnumber = max( 100 * ( int( (&addr_number) / 100 ) - ceil( (&max_near_block_dist) / 100 ) ), 0 );

    do until ( _adm_obsselect > 0 or _adm_hashnumber < 0 );
    
      _adm_hashkey = trim( &addr_street ) || put( _adm_hashnumber, z5. );
      
      _adm_obsselect = input( put( _adm_hashkey, &hashfmt ), 16. );
      
      _adm_hashnumber = _adm_hashnumber - 100;

    end;

    %if &debug = Y %then %do;
      put "     " (_adm_hashkey _adm_obsselect) (=);
    %end;

    end;
    else do;

      ** Invalid street name - no need to search for a match **;

      _adm_obsselect = .;

    end;

    _adm_match_score = 0;
    _adm_match_score_hold = 0;
    _adm_match_found = 0;
    _adm_near_block_dist_hold = 1000000;
      
    if _adm_obsselect > 0 then do;
      ** Search through parcel records
      ** Stop searching when one of following is true:
      **   No longer on same street
      **   An exact match was found
      **   An error occurred (searched beyond end of file)
      **   Starting parcel/block street number is beyond maximum dist. for a near block match
      **;
	    
      do until ( &parcel_street ~= &addr_street or _adm_match_found or _ERROR_ or 
                 &parcel_nlownumber - &addr_number > &max_near_block_dist );
      
        set &parcelfile 
              (keep=&parcel_street &parcel_dir &parcel_nlownumber &parcel_nhighnumber
                    &parcel_ulownumber parcel_match block_match odd_even_range
                    unique_quad_city unique_quad_zip unitnumber
                    &premiseadd ui_proptype
               %** Create list of geo vars to keep **;
               %let i = 1;
               %let geovar = %scan( &geolist, &i );
               %do %while ( &geovar ~= );
                 %if &&&geovar ~= %then %do;
                   &geovar
                 %end;
                 %let i = %eval( &i + 1 );
                 %let geovar = %scan( &geolist, &i );
               %end;
               %** Rename geo vars as specified in macro parameters **;
               rename=(
                 %let i = 1;
                 %let geovar = %scan( &geolist, &i );
                 %do %while ( &geovar ~= );
                   %if &&&geovar ~= %then %do;
                     &geovar=&&&geovar
                   %end;
                   %let i = %eval( &i + 1 );
                   %let geovar = %scan( &geolist, &i );
                 %end;
                 )
               )
          point=_adm_obsselect;

        if ( &parcel_street = &addr_street ) then do;        
          %if &debug = Y %then %do;
	    put "--------------------------------------------------------------------------------------------------";
            put " >>> Address read: " (&ssl &parcel_nlownumber &parcel_nhighnumber &parcel_street &parcel_dir 
                unitnumber &zip_match unique_quad_city unique_quad_zip ui_proptype ) (=);
		if ui_proptype='91' then do;
			put "ui_proptype = 91";
		end;
	    put "--------------------------------------------------------------------------------------------------";
          %end;
          
          ** Initialize match flags **;
          
          length _adm_match_flags $ &NUM_MATCH_KEYS;
          
          _adm_match_flags = repeat( "0", &NUM_MATCH_KEYS );

          substr( _adm_match_flags, &ST_NAME, 1 ) = '1'; 
        
          ** Test for street quadrant match **;
          
          if &parcel_dir = &addr_dir then 
            /** Exact quadrant match **/
            substr( _adm_match_flags, &QUAD_EXACT, 1 ) = '1';
          else if &addr_dir = '' then do;
            if unique_quad_city 
              %if &addr_zip ~= %then %do;
                or ( unique_quad_zip and &addr_zip = &zip_match )
              %end;
              then 
              /** Quadrant missing but unique in city or ZIP code **/
              substr( _adm_match_flags, &QUAD_NOTNEEDED, 1 ) = '1';
          end;
          else do;
            if unique_quad_city 
              %if &addr_zip ~= %then %do;
                or ( unique_quad_zip and &addr_zip = &zip_match )
              %end;
              then 
              /** Quadrant does not match but unique in city or ZIP code **/
              substr( _adm_match_flags, &QUAD_OVERRIDE, 1 ) = '1';
          end;
          
          ** Test for exact parcel or block street number match **;          
          if &addr_number = input( &parcel_ulownumber, ?? 4. ) or
               ( ( &parcel_nlownumber <= &addr_number <= &parcel_nhighnumber ) and
                 ( mod( &parcel_nlownumber, 2 ) = mod( &addr_number, 2 ) or 
                   odd_even_range ) 
               ) 
            then do;
              if parcel_match then 
                substr( _adm_match_flags, &ST_NUM_PARCEL, 1 ) = '1';
              %if &block_match = Y %then %do;
                else if block_match then
                  substr( _adm_match_flags, &ST_NUM_BLOCK, 1 ) = '1';
              %end;

          end;

          %if &block_match = Y and &max_near_block_dist > 0 %then %do;

            ** Test for near block match **;
            
            else if block_match and 
                    ( mod( &parcel_nlownumber, 2 ) = mod( &addr_number, 2 ) or 
                      odd_even_range ) then do;
            
              _adm_near_block_dist = min( abs( &parcel_nlownumber - &addr_number ),
                                          abs( &parcel_nhighnumber - &addr_number ) );
                                        
              %if &debug = Y %then %do;
                put "    " _adm_near_block_dist= ;
              %end;
              
              if _adm_near_block_dist <= &max_near_block_dist then
                substr( _adm_match_flags, &ST_NUM_NEAR_BLK, 1 ) = '1';

            end;
          %end;

          ** Test for ZIP code match (if ZIP provided) **;
            
          %if &addr_zip ~= %then %do;
            
            if &addr_zip = &zip_match then 
              substr( _adm_match_flags, &ZIP_EXACT, 1 ) = '1';

          %end;
	  *** check for exact parcel matches *****;
                        if(
                             substr( _adm_match_flags, &ST_NAME , 1 ) = '1' AND
                             substr( _adm_match_flags, &ST_NUM_PARCEL , 1 ) = '1'  AND
                                  (
                                  substr( _adm_match_flags, &QUAD_EXACT , 1 ) = '1' OR
                                  substr( _adm_match_flags, &QUAD_NOTNEEDED , 1 ) = '1' OR
                                  substr( _adm_match_flags, &QUAD_OVERRIDE , 1 ) = '1'
                                  )
			        %if &addr_zip ~= %then %do;
                                  AND
                                  (substr( _adm_match_flags, &ZIP_EXACT , 1 ) = '1' OR
                                  substr( _adm_match_flags, &ZIP_OVERRIDE , 1 ) = '1')
			        %end;
                            )
                           then  do;
			   %if &unit_match = Y %then %do;
			   *** all match flags are set, but now need to check proptype ***;

	                           if ui_proptype = '11' then do;
					*** unit number matches - exact parcel matc ****;
	                           	if compress(&addr_apt_unit) = compress(unitnumber) then do; 
		                                substr( _adm_match_flags, &PARCEL, 1 ) = '1';
					end;
					*** unit number doesnt match - reset flags ****;
	                                else do;
		                                _adm_match_flags  = '0000000000';   
	                                end;
				   end;
				   else do;
	    	                         if ui_proptype = '91' and compress(&addr_apt_unit) ^= '' then do;
	        	                        /** Condo building = nonparcel match (do nothing) **/
	                	            end;
					    else do;
						if compress(&addr_apt_unit) ^= '' then do;
						end;
						else do;
	                                		substr( _adm_match_flags, &PARCEL, 1 ) = '1';			   
						end;
					    end;
				   end;
			   %end;
			   %else %do;
                                substr( _adm_match_flags, &PARCEL, 1 ) = '1';			   
			   %end;
	                   end;
			
          
          ** Compute match score **;
          _adm_match_score = 
            input( put( input( _adm_match_flags, binary&NUM_MATCH_KEYS.. ), 
                        matchscr. ), 8. );
          


          %if &debug = Y %then %do;
            put "    Score:  " _adm_match_score= _adm_match_flags=;
          %end;

          ** If new high score, hold geo vars **;
          
          if ( _adm_match_score > _adm_match_score_hold ) and 
             ( ( substr( _adm_match_flags, &ST_NUM_NEAR_BLK, 1 ) = '1' and 
                 _adm_near_block_dist < _adm_near_block_dist_hold ) or
               substr( _adm_match_flags, &ST_NUM_NEAR_BLK, 1 ) = '0' )
                 then do;

            %let i = 1;
            %let geovar = %scan( &geolist &premiseadd, &i );
            %do %while ( &geovar ~= );
              %if &&&geovar ~= %then %do;
                _adm_&&&geovar = &&&geovar;
              %end;
              %let i = %eval( &i + 1 );
              %let geovar = %scan( &geolist &premiseadd, &i );
            %end;
            
     	    _adm_ui_proptype =  ui_proptype ;
            _adm_unit_number = unitnumber;
            _adm_parcel_match = parcel_match;
            _adm_block_match = block_match;
            _adm_match_score_hold = _adm_match_score;
            
            if substr( _adm_match_flags, &ST_NUM_NEAR_BLK, 1 ) = '1' then
              _adm_near_block_dist_hold = _adm_near_block_dist;
            
            %if &debug = Y %then %do;
              put "    New high score.";
            %end;
          
          end;
          
          if _adm_match_score >= &EXACT_MATCH_MIN then _adm_match_found = 1;
          
          /************** removed ************************************************
          if &parcel_dir = &addr_dir and  
             ( &addr_number = input( &parcel_ulownumber, ?? 4. ) or
               ( ( &parcel_nlownumber <= &addr_number <= &parcel_nhighnumber ) and
                 ( mod( &parcel_nlownumber, 2 ) = mod( &addr_number, 2 ) or 
                   odd_even_range )
               )
             ) 
            then do;
            %if &debug = Y %then %do;
              put "  Address matched!";
            %end;
            _adm_match_found = 1;
            output;
          end;
          **************** end removed **********************************************/
          
        end;
        
        _adm_obsselect = _adm_obsselect + 1;
        
      end;
      
    end;
    
    ** If matching address found, copy hold vars back to
    ** original geo vars and write obs.
    ** Otherwise, clear geo vars and write obs.;
      
    if _adm_match_score_hold >= &match_score_min then do;
    
      %if &debug = Y %then %do;
        put "  Address matched!";
      %end;
      
      ** Increment match counters **;
      
      _adm_match_count + 1;
      
      if _adm_block_match then _adm_block_match_count + 1;
      
      ** Copy geo vars **;
      
      %let i = 1;
      %let geovar = %scan( &geolist &premiseadd, &i );
      %do %while ( &geovar ~= );
        %if &&&geovar ~= %then %do;
          &&&geovar = _adm_&&&geovar;
        %end;
        %let i = %eval( &i + 1 );
        %let geovar = %scan( &geolist &premiseadd, &i );
      %end;
      
      ui_proptype= _adm_ui_proptype;
      unitnumber = _adm_unit_number;
      parcel_match = _adm_parcel_match;
      block_match = _adm_block_match;

      str_addr_unit=compress(&addr_apt_unit);
    end;
    else do;
    
      %if &debug = Y %then %do;
        put "  Address not matched";
      %end;
      %** Clear values of geo vars **;
      %let i = 1;
      %let geovar = %scan( &geolist &premiseadd, &i );
      %do %while ( &geovar ~= );
        %if &&&geovar ~= %then %do;
          if vtype( &&&geovar ) = 'N' then &&&geovar = .;
          else &&&geovar = '';
        %end;
        %let i = %eval( &i + 1 );
        %let geovar = %scan( &geolist &premiseadd, &i );
      %end;
      &parcel_street = "";
      &parcel_dir = "";
      &parcel_nlownumber = .;
      &parcel_nhighnumber = .;
      &parcel_ulownumber= "";
      parcel_match=0;
      block_match=0;
      ui_proptype='';
    end;
    
    %if &dcg_match_score ~= %then %do;
      &dcg_match_score = _adm_match_score_hold;
      label &dcg_match_score = '%DCGeocode address match score';
    %end;
    
    output;

    ** At end of file, print matching results in log **;
    
    if eof then do;
    
      _adm_note = "Geocoding matched " || 
                  left( put( _adm_match_count, comma16. ) ) ||
                  " out of " || left( put( _n_, comma16. ) ) ||
                  " addresses ( " || left( put( _adm_match_count / _n_, percent12.1 ) ) ||
                  " ):  " || 
                  left( put( _adm_match_count - _adm_block_match_count, comma16. ) ) ||
                  " parcel matches, " || 
                  left( put( _adm_block_match_count, comma16. ) ) || 
                  " block matches.";
                  
      _adm_note = compbl( _adm_note );
      
      put /;
      %note_put( macro=&mname, msg=_adm_note );
      put /;
      
    end;
    
    %** Labels for address vars **;
    
    %if &staddr_match ~= and %index( %upcase(&geolist), STADDR_MATCH ) %then %do;
      label &staddr_match = "Address of matching parcel/block for &addr_street_lbl";
    %end;
      
    %if &zip_match ~= and %index( %upcase(&geolist), ZIP_MATCH ) %then %do;
      label &zip_match = "ZIP code of matching parcel/block for &addr_street_lbl";
    %end;

    %let drop_list = &drop;
      
    %if &debug ~= Y %then %let drop_list = &drop_list
        _adm_: 
        &addr_street &addr_number &addr_dir
        &parcel_street &parcel_dir &parcel_nlownumber &parcel_nhighnumber
        &parcel_ulownumber parcel_match block_match odd_even_range
        unique_quad_city unique_quad_zip
        ;
    
    %if &drop_list ~= %then %do;
      drop &drop_list;
    %end;
    
  run;

%mend Address_match;

/** End Macro Definition **/


