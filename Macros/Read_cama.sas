/**************************************************************************
 Program:  Read_cama.sas
 Library:  RealProp
 Project:  Urban-Greater DC
 Author:   Leah Hendey
 Created:  05/17/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read Computer Assisted Mass Appraisal (CAMA) from OTR

 Note: Most lots have one building in the cama file, assigned BLDG_NUM of one in the table. 
	   For parcels where multiple buildings exist, the primary building (such as the main residence) is assigned BLDG_NUM = 1.
		The other buildings or structures have BLDG_NUM values in random sequential order. After the primary structure,
		there is no way to associate BLDG_NUM > 2 records with any particular structure on the lot.

 Modifications: 

**************************************************************************/

%macro read_cama(filedate= , update_file=, revisions=, deduplicate=); 
/* Path to raw data csv files and names */

%let filepath = &_dcdata_r_path\RealProp\Raw\&filedate.\;

/*read CAMA res pt*/ 
 data WORK.CAMA_respt  ;
 	infile "&filepath.Computer_Assisted_Mass_Appraisal__Residential.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
	  informat OBJECTID $4. ;
	  informat SSL $17. ;
	  informat BATHRM best32. ;
	  informat HF_BATHRM best32. ;
	  informat HEAT best32. ;
	  informat HEAT_D $14. ;
	  informat AC $1. ;
	  informat NUM_UNITS best32. ;
	  informat ROOMS best32. ;
	  informat BEDRM best32. ;
	  informat AYB best32. ;
	  informat YR_RMDL best32. ;
	  informat EYB best32. ;
	  informat STORIES best32. ;
	  informat c_SALEDATE $20. ; 
	  informat PRICE best32. ;
	  informat QUALIFIED $1. ;
	  informat SALE_NUM best32. ;
	  informat GBA best32. ;
	  informat BLDG_NUM best32. ;
	  informat STYLE best32. ;
	  informat STYLE_D $15. ;
	  informat STRUCT best32. ;
	  informat STRUCT_D $13. ;
	  informat GRADE best32. ;
	  informat GRADE_D $13. ;
	  informat CNDTN best32. ;
	  informat CNDTN_D $9. ;
	  informat EXTWALL best32. ;
	  informat EXTWALL_D $14. ;
	  informat ROOF best32. ;
	  informat ROOF_D $14. ;
	  informat INTWALL best32. ;
	  informat INTWALL_D $14. ;
	  informat KITCHENS best32. ;
	  informat FIREPLACES best32. ;
	  informat c_USECODE $3. ;
	  informat LANDAREA best32. ;
	  informat c_GIS_LAST_MOD_DTTM $20. ;
  
      input
	  OBJECTID $
	  SSL
	  BATHRM
	  HF_BATHRM
	  HEAT
	  HEAT_D $
	  AC $
	  NUM_UNITS
	  ROOMS
	  BEDRM
	  AYB
	  YR_RMDL
	  EYB
	  STORIES
	  c_SALEDATE $
	  PRICE
	  QUALIFIED $
	  SALE_NUM
	  GBA
	  BLDG_NUM
	  STYLE
	  STYLE_D $
	  STRUCT
	  STRUCT_D $
	  GRADE
	  GRADE_D $
	  CNDTN
	  CNDTN_D $
	  EXTWALL
	  EXTWALL_D $
	  ROOF
	  ROOF_D $
	  INTWALL
	  INTWALL_D $
	  KITCHENS
	  FIREPLACES
	  c_USECODE $
	  LANDAREA
	  c_GIS_LAST_MOD_DTTM $
   ;

	ssl = left( upcase( ssl ) );
    SALEDATE = input( substr( c_SALEDATE, 1, 10 ), yymmdd10. );
	EXTRACTDAT = input( substr( c_GIS_LAST_MOD_DTTM, 1, 10 ), yymmdd10. );

	if saledate <= '01jan1900'd or saledate > EXTRACTDAT then do;
      if price in ( 0, . ) then do;
        saledate = .n;
       price = .n;
      end;
      else do;
        %warn_put(  msg="Invalid sale date (will be set to .U): " / ssl= saledate= 
                       "SALEDATE(unformatted)=" saledate best16. " " price= );
        saledate = .u;
      end;
    end;
    
 
    ** Sale price missing values **;
    
    if price in ( ., 0 ) then do;
      if saledate = .n then price = .n;
      else if price = . then price = .u;
    end;

	usecode = right(c_usecode);

	* then fill them with zeros;
	if trim(usecode) ~= "" then do;	
		do _i_ = 1 to length(usecode) while (substr(usecode,_i_,1) = " ");
			substr(usecode,_i_,1) = "0";
		end;
	end;
  
  	format SALEDATE yymmdd10. EXTRACTDAT yymmdd10. usecode $USECODE. ; 

	drop  c_SALEDATE c_GIS_LAST_MOD_DTTM c_usecode _i_;

	label
 	  OBJECTID="Object ID Provided by OTR"
	  Ssl = "Property Identification Number (Square/Suffix/Lot)"
	  Usecode = "Property Use Codes"
	  Landarea = "Square footage of property from the recorded deed"
	  Price = "Price on last sale"
	  	AC = "Air conditioning in residence"
		AYB = "The earliest time the main portion of the building was built. It is not affected by subsequent construction."
		BATHRM = "Number of bathrooms"
		BEDRM = "Number of bedrooms"
		BLDG_NUM = "Building number (Building #1 is primary building on the lot)"  
		CNDTN = "Overall Condition (ResPT only)"
		CNDTN_D = "Overall Condition description (ResPT only)"
		EXTWALL = "Exterior wall"
		EXTWALL_D = "Exterior wall description"
		EYB = "The calculated or apparent year, that an improvement was built that is most often more recent than actual year built."
		FIREPLACES = "Number of fireplaces"
		GBA = "Gross building area in square feet (ResPT only)"
		GRADE = "Building grade (CAMA ResPt Source)"
		GRADE_D = "Building grade Description (CAMA Respt Source)"
		HEAT = "Heat type code"
		HEAT_D = "Heat type description"
		HF_BATHRM = "Number of half bathrooms"
		INTWALL = "Interior wall code (ResPT only)"
		INTWALL_D = "Interior wall description (ResPT only)"
		KITCHENS = "Number of kitchens (ResPT only)"
		NUM_UNITS = "Number of units"
		QUALIFIED = "Qualified"
		ROOF = "Roof type (ResPT only)"
		ROOF_D = "Roof type description (ResPT only)"
		ROOMS = "Number of rooms"
		SALE_NUM = "Sale number"
		SALEdate = "Date of last sale"
		STORIES = "Number of stories in primary dwelling (ResPT only)"
		STRUCT = "Structure type (ResPT only)"
		STRUCT_D = "Structure type description (ResPT only)"
		STYLE = "Building style (ResPT only)"
		STYLE_D	= "Building style description (ResPT only)"
		YR_Rmdl = "Last year residence was remodeled"
		EXTRACTDAT = "Date file was uploaded to the Open Data Portal" 

	;

   run;

    data WORK.CAMA_commpt  ;
 	infile "&filepath.Computer_Assisted_Mass_Appraisal__Commercial.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
    informat OBJECTID $4. ;
    informat SSL $17. ;
    informat BLDG_NUM best32. ;
    informat SECT_NUM best32. ;
    informat STRUCT_CL $1.;
    informat STRUCT_CL_D $12. ;
    informat GRADE_commpt best32. ;
    informat GRADE_commpt_D $9. ;
    informat c_EXTWALL  $2.;
    informat EXTWALL_D $14. ;
    informat WALL_HGT best32. ;
    informat NUM_UNITS best32. ;
    informat c_SALEDATE $20. ;
    informat PRICE best32. ;
    informat QUALIFIED $1. ;
    informat AYB best32. ;
    informat YR_RMDL best32. ;
    informat EYB best32. ;
    informat SALE_NUM best32. ;
    informat LIVING_GBA best32. ;
    informat c_USECODE $3.;
    informat LANDAREA best32. ;
    informat c_GIS_LAST_MOD_DTTM $20. ;

 input
             OBJECTID $
             SSL $
             BLDG_NUM
             SECT_NUM
             STRUCT_CL $
             STRUCT_CL_D $
             GRADE_commpt
             GRADE_commpt_D $
             c_EXTWALL $
             EXTWALL_D $
             WALL_HGT
             NUM_UNITS 
             c_SALEDATE $
             PRICE
             QUALIFIED $
             AYB
             YR_RMDL
             EYB
             SALE_NUM
             LIVING_GBA
             c_USECODE $
             LANDAREA
             c_GIS_LAST_MOD_DTTM $
 ;
 if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */

       ssl = left( upcase( ssl ) );
       SALEDATE = input( substr( c_SALEDATE, 1, 10 ), yymmdd10. );
       EXTRACTDAT = input( substr( c_GIS_LAST_MOD_DTTM, 1, 10 ), yymmdd10. );

	   
		if saledate <= '01jan1900'd or saledate > EXTRACTDAT then do;
	      if price in ( 0, . ) then do;
	        saledate = .n;
	       price = .n;
	      end;
	      else do;
	        %warn_put(  msg="Invalid sale date (will be set to .U): " / ssl= saledate= 
	                       "SALEDATE(unformatted)=" saledate best16. " " price= );
	        saledate = .u;
	      end;
	    end;
	      
       ** Sale price missing values **;

       if price in ( ., 0 ) then do;
         if saledate = .n then price = .n;
         else if price = . then price = .u;
       end;

    	usecode = right(c_usecode);

		* then fill them with zeros;
		if trim(usecode) ~= "" then do;	
			do _i_ = 1 to length(usecode) while (substr(usecode,_i_,1) = " ");
				substr(usecode,_i_,1) = "0";
			end;
		end;

		*editing extwall to match respt (uses numeric codes);

		if c_extwall="AS" then EXTWALL=25; *Asphalt siding not in respt;
			if c_extwall="AS" then EXTWALL_D="Asphalt Siding"; 
		if c_extwall="BR" then extwall=14; *assigning brick to common brick;
		if c_extwall="BV" then extwall=10; 
		if c_extwall="C" then extwall=18;
		if c_extwall="CB" then extwall=12;
		if c_extwall="MS" then extwall=3;
		if c_extwall="S" then extwall=17;
		if c_extwall="SV" then extwall=11;
		if c_extwall="SU" then extwall=5;
		if c_extwall="0" then extwall=0; *assigning "typical" to "default";
		if c_extwall="WS" then extwall=6; 
	  
       format EXTRACTDAT SALEDATE yymmdd10. usecode $USECODE. ;

       drop  c_SALEDATE c_GIS_LAST_MOD_DTTM c_usecode _i_ c_extwall;

       label
         OBJECTID="Object ID Provided by OTR"
         Ssl = "Property Identification Number (Square/Suffix/Lot)"
         Usecode = "Property Use Codes"
         Landarea = "Square footage of property from the recorded deed"
         Price = "Price of last sale"
           AYB = "The earliest time the main portion of the building was built. It is not affected by subsequent construction."
           BLDG_NUM = "Building Number on Property (1 is primary building)"
           EXTWALL = "Exterior wall"
           EXTWALL_D = "Exterior wall description"
           EYB = "The calculated or apparent year, that an improvement was built that is most often more recent than actual year built."
           GRADE_commpt = "Building grade (CommPt Source)"
           GRADE_commpt_D = "Building grade Description (CommPt Source)"
		   LIVING_GBA = "Living gross building area in square feet"
           NUM_UNITS = "Number of units"
           QUALIFIED = "Qualified"
           SALE_NUM = "Sale number"
           SALEdate = "Date of last sale"
		   SECT_NUM = "Section number (CommPT only)"
           STRUCT_CL_D = "Structure class description (CommPT only)" 
           Struct_Cl = "Structure class code (CommPT only)"
           YR_Rmdl = "Last year residence was remodeled"
           EXTRACTDAT = "Date file was uploaded to the Open Data Portal"
		   WALL_HGT = "Wall height (CommPT only)"
		   YR_Rmdl = "Year structure was remodeled"
       ;

      run;

    data WORK.CAMA_condopt  ;
 	infile "&filepath.Computer_Assisted_Mass_Appraisal__Condominium.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
	    informat OBJECTID $4. ;
	    informat SSL $17. ;
	    informat BLDG_NUM best32. ;
	    informat CMPLX_NUM best32. ;
	    informat AYB best32. ;
	    informat YR_RMDL best32. ;
	    informat EYB best32. ;
	    informat ROOMS best32. ;
	    informat BEDRM best32. ;
	    informat BATHRM best32. ;
	    informat HF_BATHRM best32. ;
	    informat HEAT best32. ;
	    informat HEAT_D $14. ;
	    informat AC $1. ;
	    informat FIREPLACES best32. ;
	    informat c_SALEDATE $20. ;
	    informat PRICE best32. ;
	    informat QUALIFIED $1. ;
	    informat SALE_NUM best32. ;
	    informat LIVING_GBA best32. ;
	    informat c_USECODE $3. ;
	    informat LANDAREA best32. ;
	    informat c_GIS_LAST_MOD_DTTM $20.;
  
 		input
             OBJECTID $
             SSL $
             BLDG_NUM
             CMPLX_NUM
             AYB
             YR_RMDL
             EYB
             ROOMS
             BEDRM
             BATHRM
             HF_BATHRM
             HEAT
             HEAT_D $
             AC $
             FIREPLACES
             c_SALEDATE $
             PRICE
             QUALIFIED $
             SALE_NUM
             LIVING_GBA
             c_USECODE $
             LANDAREA
             c_GIS_LAST_MOD_DTTM $
 ;
 if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */

       ssl = left( upcase( ssl ) );
       SALEDATE = input( substr( c_SALEDATE, 1, 10 ), yymmdd10. );
       EXTRACTDAT = input( substr( c_GIS_LAST_MOD_DTTM, 1, 10 ), yymmdd10. );

	   
		if saledate <= '01jan1900'd or saledate > EXTRACTDAT then do;
	      if price in ( 0, . ) then do;
	        saledate = .n;
	       price = .n;
	      end;
	      else do;
	        %warn_put(  msg="Invalid sale date (will be set to .U): " / ssl= saledate= 
	                       "SALEDATE(unformatted)=" saledate best16. " " price= );
	        saledate = .u;
	      end;
	    end;
       
       ** Sale price missing values **;

       if price in ( ., 0 ) then do;
         if saledate = .n then price = .n;
         else if price = . then price = .u;
       end;

       usecode = right(c_usecode);

       * then fill them with zeros;
       if trim(usecode) ~= "" then do;
           do _j_ = 1 to length(usecode) while (substr(usecode,_j_,1) = " ");
               substr(usecode,_j_,1) = "0";
           end;
       end;

       format EXTRACTDAT SALEDATE yymmdd10.  usecode $USECODE. ;

       drop  c_SALEDATE c_GIS_LAST_MOD_DTTM c_usecode _j_;

       label
         OBJECTID="Object ID Provided by OTR"
         Ssl = "Property Identification Number (Square/Suffix/Lot)"
         Usecode = "Property use code"
         Landarea = "Square footage of property from the recorded deed"
         Price = "Price of last sale"
           AC = "Air conditioning in residence"
           AYB = "The earliest time the main portion of the building was built. It is not affected by subsequent construction."
           BATHRM = "Number of bathrooms"
           BEDRM = "Number of bedrooms"
           BLDG_NUM = "Building number on property"
		   CMPLX_NUM="Complex Number (CondoPT only)"
		   EXTRACTDAT = "Date file was uploaded to the Open Data Portal"
           EYB = "The calculated or apparent year, that an improvement was built that is most often more recent than actual year built."
           FIREPLACES = "Number of fireplaces"
           LIVING_GBA = "Living gross building area in square feet"
           HEAT = "Heat type code"
           HEAT_D = "Heat type description"
           HF_BATHRM = "Number of half bathrooms"
           QUALIFIED = "Qualified"
           ROOMS = "Number of rooms"
           SALE_NUM = "Sale number "
		   SALEdate = "Date of last sale"
           YR_Rmdl = "Last year residence was remodeled"
           
       ;

      run;



	  /*merge files and figure out how to deal with duplicates*/ 

	data Cama;
	set CAMA_commpt (in=a) CAMA_condopt (in=b) CAMA_respt (in=c);

	if a then cama="CommPt";
	if b then cama="CondoPt";
	if c then cama="ResPt";

	label Cama="Origin file for CAMA data"
	;

	drop objectid;
		 

	run;
	

	%dup_check( 
	    data=Cama, 
	    by=ssl bldg_num, 
	    id=cama usecode Struct_d STRUCT_CL_D price saledate,
	    printnumdups=N,
	    out=_dup_check_out
	  )
	  run;

	  title2;
  
  /***review output to see changes** - MAY NEED TO ADJUST CODE BELOW**/

	data cama2;
		set cama;

	  *deal with duplicates between COMM PT and Res PT;

	*remove respt observation;

		&deduplicate. 

		run;

*delete straight dups for 	"2359    0837" 		"2745A   0074";
			 
		proc sort data=cama2 out=cama3 nodupkey EQUALS;
		by ssl bldg_num;

		run;
		

	%Finalize_data_set( 
	  data=cama3,
	  out=cama_building,
	  outlib=realprop,
	  label="Computer Assisted Mass Appraisal (CAMA) Property Characteristics - Building Level file",
	  sortby=ssl bldg_num,
	  revisions=%str(&revisions),
	  freqvars=cama usecode bldg_num
	)

	
	  ** Saved dated copy of base file **;

	  %Finalize_data_set( 
	  /** Finalize data set parameters **/
	  data=cama3,
	  out=cama_building_&update_file,
	  outlib=realprop,
	  label="Computer Assisted Mass Appraisal (CAMA) Property Characteristics - Building Level file, &update_file",
	  sortby=ssl bldg_num,
	  /** Metadata parameters **/
	  revisions=%str(&revisions),
	  /** File info parameters **/
	  printobs=5,
	  freqvars=cama usecode bldg_num
	  );


*create parcel-level file;

	*get number of buildings on a parcel; 
	proc summary data=cama3;
	by ssl;
	id cama EXTRACTDAT ;
	output out=cama_sum;
	run;
	
	*select out only first observation by ssl  - most should be bldg #1; 
	proc sort data=cama3 out=cama_bldg1 nodupkey equals;
	by ssl;
	run;
	data cama4;

	merge cama_bldg1 cama_sum (rename=(_freq_=num_bldg) drop= EXTRACTDAT cama _type_);
	by ssl;

	if num_bldg > 1 then multi_bldg=1; else multi_bldg=0; 

	label num_bldg="Number of buildings on parcel"
		  multi_bldg="Parcel has more than one building";	
		;

	run;


	%Finalize_data_set( 
	  data=cama4,
	  out=cama_parcel,
	  outlib=realprop,
	  label="Computer Assisted Mass Appraisal (CAMA) - Parcel file Bldg 1 Characteristics",
	  sortby=ssl,
	  revisions=%str(&revisions),
	  freqvars=cama usecode num_bldg multi_bldg
	)

	  ** Saved dated copy of base file **;

	  %Finalize_data_set( 
	  /** Finalize data set parameters **/
	  data=cama4,
	  out=cama_parcel_&update_file,
	  outlib=realprop,
	  label="Computer Assisted Mass Appraisal (CAMA) - Parcel file Bldg 1 Characteristics, &update_file",
	  sortby=ssl,
	  /** Metadata parameters **/
	  revisions=%str(&revisions),
	  /** File info parameters **/
	  printobs=5,
	  freqvars=cama usecode num_bldg multi_bldg
	  );

%mend read_cama;
