/**************************************************************************
 Program:  Read_cama.sas
 Library:  RealProp
 Project:  Urban-Greater DC
 Author:   Leah Hendey
 Created:  05/17/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read Computer Assisted Mass Appraisal (CAMA) from OTR

 Modifications: 

**************************************************************************/
%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp );



%macro read_cama; 
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
	  Price = "Most recent property sale price"
	  	AC = "Air conditioning in residence"
		AYB = "The earliest time the main portion of the building was built. It is not affected by subsequent construction."
		BATHRM = "Number of bathrooms"
		BEDRM = "Number of bedrooms"
		BLDG_NUM = "Building Number" 
		CNDTN = "Overall Condition"
		CNDTN_D = "Overall Condition description"
		EXTWALL = "Exterior wall"
		EXTWALL_D = "Exterior wall description"
		EYB = "The calculated or apparent year, that an improvement was built that is most often more recent than actual year built."
		FIREPLACES = "Number of fireplaces"
		GBA = "Gross building area in square feet"
		GRADE = "Building grade"
		GRADE_D = "Building grade Description"
		HEAT = "Heat type code"
		HEAT_D = "Heat type description"
		HF_BATHRM = "Number of half bathrooms"
		INTWALL = "Interior wall code"
		INTWALL_D = "Interior wall description"
		KITCHENS = "Number of kitchens"
		NUM_UNITS = "Number of units"
		QUALIFIED = "Qualified"
		ROOF = "Roof type"
		ROOF_D = "Roof type description"
		ROOMS = "Number of rooms"
		SALE_NUM = "Sale number (always 1 to get most recent sale)"
		SALEdate = "Date of Sale"
		STORIES = "Number of stories in primary dwelling"
		STRUCT = "Structure type"
		STRUCT_D = "Structure type description"
		STYLE = "Building style"
		STYLE_D	= "Building style description"
		YR_Rmdl = "Last year residence was remodeled"
		EXTRACTDAT = "Date file was uploaded to the Open Data Portal" 

	;

   run;

 /*add code for COMM pt and CONDO PT*/ 
    data WORK.CAMA_commpt  ;
 	infile "&filepath.Computer_Assisted_Mass_Appraisal__Commercial.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
    informat OBJECTID $4. ;
    informat SSL comma32. ;
    informat BLDG_NUM best32. ;
    informat SECT_NUM best32. ;
    informat STRUCT_CL $1. ;
    informat STRUCT_CL_D $12. ;
    informat GRADE best32. ;
    informat GRADE_D $9. ;
    informat EXTWALL $2. ;
    informat EXTWALL_D $14. ;
    informat WALL_HGT best32. ;
    informat NUM_UNITS best32. ;
    informat c_SALEDATE yymmdd10. ;
    informat PRICE best32. ;
    informat QUALIFIED $1. ;
    informat AYB best32. ;
    informat YR_RMDL best32. ;
    informat EYB best32. ;
    informat SALE_NUM best32. ;
    informat LIVING_GBA best32. ;
    informat c_USECODE best32. ;
    informat LANDAREA best32. ;
    informat GIS_LAST_MOD_DTTM yymmdd10. ;
    format OBJECTID $4. ;
    format SSL comma12. ;
    format BLDG_NUM best12. ;
    format SECT_NUM best12. ;
    format STRUCT_CL $1. ;
    format STRUCT_CL_D $12. ;
    format GRADE best12. ;
    format GRADE_D $9. ;
    format EXTWALL $2. ;
    format EXTWALL_D $14. ;
    format WALL_HGT best12. ;
    format NUM_UNITS best12. ;
    format SALEDATE yymmdd10. ;
    format PRICE best12. ;
    format QUALIFIED $1. ;
    format AYB best12. ;
    format YR_RMDL best12. ;
    format EYB best12. ;
    format SALE_NUM best12. ;
    format LIVING_GBA best12. ;
    format USECODE best12. ;
    format LANDAREA best12. ;
    format c_GIS_LAST_MOD_DTTM yymmdd10. ;
 input
             OBJECTID $
             SSL
             BLDG_NUM
             SECT_NUM
             STRUCT_CL $
             STRUCT_CL_D $
             GRADE
             GRADE_D $
             EXTWALL $
             EXTWALL_D $
             WALL_HGT
             NUM_UNITS
             c_SALEDATE
             PRICE
             QUALIFIED $
             AYB
             YR_RMDL
             EYB
             SALE_NUM
             LIVING_GBA
             c_USECODE
             LANDAREA
             c_GIS_LAST_MOD_DTTM
 ;
 if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
 run;



       ssl = left( upcase( ssl ) );
       SALEDATE = input( substr( c_SALEDATE, 1, 10 ), yymmdd10. );
       

       
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

       format SALEDATE yymmdd10. usecode $USECODE. ;

       drop  c_SALEDATE c_GIS_LAST_MOD_DTTM c_usecode _i_;

       label
         OBJECTID="Object ID Provided by OTR"
         Ssl = "Property Identification Number (Square/Suffix/Lot)"
         Usecode = "Property Use Codes"
         Landarea = "Square footage of property from the recorded deed"
         Price = "Most recent property sale price"
           AYB = "The earliest time the main portion of the building was built. It is not affected by subsequent construction."
           BLDG_NUM = "Building Number"
           EXTWALL = "Exterior wall"
           EXTWALL_D = "Exterior wall description"
           EYB = "The calculated or apparent year, that an improvement was built that is most often more recent than actual year built."
           FIREPLACES = "Number of fireplaces"
           GRADE = "Building grade"
           GRADE_D = "Building grade Description"
		   LIVING_GBA = "Gross building area in square feet"
           NUM_UNITS = "Number of units"
           QUALIFIED = "Qualified"
           SALE_NUM = "Sale number (always 1 to get most recent sale)"
           SALEdate = "Date of Sale"
		   SECT_NUM = "Section number"
           STRUCT_CL_D = "Structure Material"
           Struct_Cl = "Structure class code"
           STYLE = "Building style"
           STYLE_D = "Building style description"
           YR_Rmdl = "Last year residence was remodeled"
           EXTRACTDAT = "Date file was uploaded to the Open Data Portal"
		   WALL_HGT = "Wall height (Comm)"
		   YR_Rmdl = "Last year residence was remodeled"
       ;

      run;

    data WORK.CAMA_condopt  ;
 	infile "&filepath.Computer_Assisted_Mass_Appraisal__Condominium.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
             informat OBJECTID $2. ;
    informat SSL comma32. ;
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
    informat HEAT_D $12. ;
    informat AC $1. ;
    informat FIREPLACES best32. ;
    informat SALEDATE yymmdd10. ;
    informat PRICE best32. ;
    informat QUALIFIED $1. ;
    informat SALE_NUM best32. ;
    informat LIVING_GBA best32. ;
    informat USECODE best32. ;
    informat LANDAREA best32. ;
    informat GIS_LAST_MOD_DTTM yymmdd10. ;
    format OBJECTID $2. ;
    format SSL comma12. ;
    format BLDG_NUM best12. ;
    format CMPLX_NUM best12. ;
    format AYB best12. ;
    format YR_RMDL best12. ;
    format EYB best12. ;
    format ROOMS best12. ;
    format BEDRM best12. ;
    format BATHRM best12. ;
    format HF_BATHRM best12. ;
    format HEAT best12. ;
    format HEAT_D $12. ;
    format AC $1. ;
    format FIREPLACES best12. ;
    format SALEDATE yymmdd10. ;
    format PRICE best12. ;
    format QUALIFIED $1. ;
    format SALE_NUM best12. ;
    format LIVING_GBA best12. ;
    format USECODE best12. ;
    format LANDAREA best12. ;
    format GIS_LAST_MOD_DTTM yymmdd10. ;
 input
             OBJECTID $
             SSL
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
             SALEDATE
             PRICE
             QUALIFIED $
             SALE_NUM
             LIVING_GBA
             USECODE
             LANDAREA
             GIS_LAST_MOD_DTTM
 ;
 if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
 run;



       ssl = left( upcase( ssl ) );
       SALEDATE = input( substr( c_SALEDATE, 1, 10 ), yymmdd10. );
       
       
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

       format SALEDATE yymmdd10.  usecode $USECODE. ;

       drop  c_SALEDATE c_GIS_LAST_MOD_DTTM c_usecode _i_;

       label
         OBJECTID="Object ID Provided by OTR"
         Ssl = "Property Identification Number (Square/Suffix/Lot)"
         Usecode = "Property Use Codes"
         Landarea = "Square footage of property from the recorded deed"
         Price = "Most recent property sale price"
           AC = "Air conditioning in residence"
           AYB = "The earliest time the main portion of the building was built. It is not affected by subsequent construction."
           BATHRM = "Number of bathrooms"
           BEDRM = "Number of bedrooms"
           BLDG_NUM = "Building Number"
		   CMPLX_NUM="Complex Number"
           EYB = "The calculated or apparent year, that an improvement was built that is most often more recent than actual year built."
           FIREPLACES = "Number of fireplaces"
           LIVING_GBA = "Gross building area in square feet"
           HEAT = "Heat type code"
           HEAT_D = "Heat type description"
           HF_BATHRM = "Number of half bathrooms"
           QUALIFIED = "Qualified"
           ROOMS = "Number of rooms"
           SALE_NUM = "Sale number (always 1 to get most recent sale)"
           YR_Rmdl = "Last year residence was remodeled"
           
       ;

      run;
%mend;
