/**************************************************************************
 Program:  Read_itspe_files.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  05/11/2020
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)

 Description:  Read ITS Public Extract, ITSPE Facts, and Cama Sales


 Modifications: 10-3-16 Update with new data -RP
                02-03-17 Update with Q4-2016 data -RP
                09-27-17 Updste with new data -IM
                03-20-18 Update with new data -NS
				10-3-16 Update with Q2-2016 data -RP
                12-8-16 Update with Q3-2016 data -RP
                5-25-18 Update with Q1-2018 data -RP
                5-25-18 Update with Q2-2018 data -WO
                5-11-2020 Update with new data - EN
                1-7-2021 update with new data -AH
				6-23-2022 replaced ITSPE property sales (no longer published) with Tax System Property Sales (CAMA)

**************************************************************************/

%include "\\sas1\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp );

** Note revisions **;
%let revisions = Updated through 2022-06;

/* Path to raw data csv files and names */

%let filepath = &_dcdata_r_path\RealProp\Raw\2022-06\;

%let PEfile = Integrated_Tax_System_Public_Extract.csv;
%let FactsFile = Integrated_Tax_System_Public_Extract_Facts.csv;
%let SalesFile = Tax_System_Property_Sales_(CAMA).csv;

/** Read ITS Public Extract File **/

filename fimport "&filepath.&pefile." lrecl=2000;

data ITS_Public_Extract;

  infile FIMPORT delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;

  		informat INTERNALID best32.;
		informat SSL $17. ;
		informat SQUARE $4.;
		informat SUFFIX $4.;
		informat LOT $4.;
		informat ARN $100.;
		informat ASRNAME $1.;
		informat PROPTYPE $99.;
		informat TRIGROUP $1.;
		informat in_usecode best32.;
		informat LANDAREA best32.;
		informat PREMISEADD $99.;
		informat NBHD $2.;
		informat SUBNBHD $1.;
		informat UNITNUMBER $10. ;
		informat OWNERNAME $99.;
		informat CAREOFNAME $99.;
		informat ADDRESS1 $99.;
        informat ADDRESS2 $99.;
		informat CITYSTZIP $40.;
		informat OLDLAND best32.;
		informat OLDIMPR best32.;
		informat OLDTOTAL best32.;
		informat NEWLAND best32.;
		informat NEWIMPR best32.;
		informat NEWTOTAL best32.;
		informat PHASELAND best32.;
		informat PHASEBUILD best32.;
		informat PARTPART $1.;
		informat VACLNDUSE $1.;
		informat LOWNUMBER $4.;
		informat STREETNAME $60. ;
		informat QDRNTNAME $2.;
		informat DELCODE $1.;
		informat HSTDCODE $1.;
		informat CLASSTYPE best32.;
		informat TAXRATE best32.;
        informat MIXEDUSE $1.;
		informat MIX1TXTYPE $2.;
		informat MIX1CLASS best32.;
		informat MIX1RATE best32.;
		informat MIX1LNDPCT best32.;
		informat MIX1LNDVAL best32.;
		informat MIX1BLDPCT best32.;
		informat MIX1BLDVAL best32.;
		informat MIX2TXTYPE $2.;
		informat MIX2CLASS best32.;
		informat MIX2RATE best32.;
		informat MIX2LNDPCT best32.;
		informat MIX2LNDVAL best32.;
		informat MIX2BLDPCT best32.;
		informat MIX2BLDVAL best32.;
		informat OWNOCCT $3.;
		informat COOPUNITS best32.;
		informat PCHILDCODE $1.;
		informat ABTLOTCODE $4.;
		informat SALEPRICE best32.;
		informat c_SALEDATE $32.;
		informat ACCEPTCODE $30.;
		informat SALETYPE $20.;
		informat c_DEEDDATE $32.;
		informat ASSESSMENT best32.;
		informat ANNUALTAX best32.;
		informat c_DUEDATE1 $10.;
		informat AMTDUE1 best32.;
		informat c_DUEDATE2 $10.;
		informat AMTDUE2 best32.;
		informat c_DUEDATE3 $10.;
		informat AMTDUE3 best32.;
		informat TOTDUEAMT best32.;
		informat TOTCOLAMT best32.; 
		informat TOTBALAMT best32.;
		informat c_EXTRACTDAT $32.;
		informat CAPCURR $13.;
        informat CAPPROP $10.;
		informat REASONCD $1.;
		informat CY1YEAR $4.;
		informat CY1TXSALE $10.;
		informat CY1TAX best32.;
		informat CY1PEN best32.;
		informat CY1INT best32.;
		informat CY1FEE best32.;
		informat CY1TOTDUE best32.;
		informat CY1COLL best32.;
		informat CY1BAL best32.;
		informat CY1CR best32.;
		informat CY2YEAR $4.;
		informat CY2TXSALE $10.;
		informat CY2TAX best32.;
		informat CY2PEN best32.;
		informat CY2INT best32.;
		informat CY2FEE best32.;
		informat CY2TOTDUE best32.;
		informat CY2COLL best32.;
		informat CY2BAL best32.;
		informat CY2CR best32.;
		informat PY1YEAR $4.;
		informat PY1TXSALE $10.;
		informat PY1TAX best32.;
		informat PY1PEN best32.;
		informat PY1INT best32.;
		informat PY1FEE best32.;
		informat PY1TOTDUE best32.;
		informat PY1COLL best32.;
		informat PY1BAL best32.;
		informat PY1CR best32.;
		informat PY2YEAR $4.;
		informat PY2TXSALE $10.;
		informat PY2TAX best32.;
		informat PY2PEN best32.;
		informat PY2INT best32.;
		informat PY2FEE best32.;
		informat PY2TOTDUE best32.;
		informat PY2COLL best32.;
		informat PY2BAL best32.;
		informat PY2CR best32.;
		informat PY3YEAR $4.;
		informat PY3TXSALE $10.;
		informat PY3TAX best32.;
		informat PY3PEN best32.;
		informat PY3INT best32.;
		informat PY3FEE best32.;
		informat PY3TOTDUE best32.;
		informat PY3COLL best32.;
		informat PY3BAL best32.;
		informat PY3CR best32.;
		informat PY4YEAR $4.;
		informat PY4TXSALE $10.;
		informat PY4TAX best32.;
		informat PY4PEN best32.;
		informat PY4INT best32.;
		informat PY4FEE best32.;
		informat PY4TOTDUE best32.;
		informat PY4COLL best32.;
		informat PY4BAL best32.;
		informat PY4CR best32.;
		informat PY5YEAR $4.;
		informat PY5TXSALE $10.;
		informat PY5TAX best32.;
		informat PY5PEN best32.;
		informat PY5INT best32.;
		informat PY5FEE best32.;
		informat PY5TOTDUE best32.;
		informat PY5COLL best32.;
		informat PY5BAL best32.;
		informat PY5CR best32.;
		informat PY6YEAR $4.;
		informat PY6TXSALE $10.;
		informat PY6TAX best32.;
		informat PY6PEN best32.;
		informat PY6INT best32.;
		informat PY6FEE best32.;
		informat PY6TOTDUE best32.;
		informat PY6COLL best32.;
		informat PY6BAL best32.;
		informat PY6CR best32.;
		informat PY7YEAR $4.;
		informat PY7TXSALE $10.;
		informat PY7TAX best32.;
		informat PY7PEN best32.;
		informat PY7INT best32.;
		informat PY7FEE best32.;
		informat PY7TOTDUE best32.;
		informat PY7COLL best32.;
		informat PY7BAL best32.;
		informat PY7CR best32.;
		informat PY8YEAR $4.;
		informat PY8TXSALE $10.;
		informat PY8TAX best32.;
		informat PY8PEN best32.;
		informat PY8INT best32.;
		informat PY8FEE best32.;
		informat PY8TOTDUE best32.;
		informat PY8COLL best32.;
		informat PY8BAL best32.;
		informat PY8CR best32.;
		informat PY9YEAR $4.;
		informat PY9TXSALE $10.;
		informat PY9TAX best32.;
		informat PY9PEN best32.;
		informat PY9INT best32.;
		informat PY9FEE best32.;
		informat PY9TOTDUE best32.;
		informat PY9COLL best32.;
		informat PY9BAL best32.;
		informat PY9CR best32.;
		informat PY10YEAR $4.;
		informat PY10TXSALE $10.;
		informat PY10TAX best32.;
		informat PY10PEN best32.;
		informat PY10INT best32.;
		informat PY10FEE best32.;
		informat PY10TOTDUE best32.;
		informat PY10COLL best32.;
		informat PY10BAL best32.;
		informat PY10CR best32.;
		informat c_LASTPAYDT $10.;
		informat OWNNAME2 $99.;
		informat INST_NO $10.;
		informat MORTGAGECO $99.;
		informat NBHDNAME $30.;
		informat PRMS_WARD best32.;
		informat PRESSL $17.;
		informat PIPARENTLOT $17.;
		informat BIDNAME $80.;
		informat BIDTOTALDUE best32.;
		informat BIDCOLLECTED best32.;
		informat BIDBALANCE best32.;
		informat SEWSTOTALDUE best32.;
		informat SEWSCOLLECTED best32.;
		informat SEWSBALANCE best32.;
		informat PACETOTALDUE best32.;
		informat PACECOLLECTED best32.;
		informat PACEBALANCE best32.;
		informat SWWSADTOTALDUE best32.;
		informat SWWSADCOLLECTED best32.;
		informat SWWSADBALANCE best32.;
        informat OBJECTID best32. ;
        
        input
        INTERNALID 
		SSL $
		SQUARE $
		SUFFIX $
		LOT $
		ARN $
		ASRNAME $
		PROPTYPE $
		TRIGROUP $
		in_usecode 
		LANDAREA 
		PREMISEADD $
		NBHD $
		SUBNBHD $
		UNITNUMBER $
		OWNERNAME $
		CAREOFNAME $
		ADDRESS1 $
		ADDRESS2 $
		CITYSTZIP $
		OLDLAND 
		OLDIMPR 
		OLDTOTAL 
		NEWLAND 
		NEWIMPR 
		NEWTOTAL 
		PHASELAND 
		PHASEBUILD 
		PARTPART $
		VACLNDUSE $
		LOWNUMBER $
		STREETNAME $
		QDRNTNAME $
		DELCODE $
		HSTDCODE $
		CLASSTYPE 
		TAXRATE 
		MIXEDUSE $
		MIX1TXTYPE $
		MIX1CLASS 
		MIX1RATE 
		MIX1LNDPCT 
		MIX1LNDVAL 
		MIX1BLDPCT 
		MIX1BLDVAL 
		MIX2TXTYPE $
		MIX2CLASS 
		MIX2RATE 
		MIX2LNDPCT 
		MIX2LNDVAL 
		MIX2BLDPCT 
		MIX2BLDVAL 
		OWNOCCT $
		COOPUNITS 
		PCHILDCODE $
		ABTLOTCODE $
		SALEPRICE 
		c_SALEDATE $
		ACCEPTCODE $
		SALETYPE $
		c_DEEDDATE $
		ASSESSMENT 
		ANNUALTAX 
		c_DUEDATE1 $
		AMTDUE1 
		c_DUEDATE2 $
		AMTDUE2 
		c_DUEDATE3 $
		AMTDUE3 
		TOTDUEAMT 
		TOTCOLAMT  
		TOTBALAMT 
		c_EXTRACTDAT $
		CAPCURR $
		CAPPROP $
		REASONCD $
		CY1YEAR $
		CY1TXSALE $
		CY1TAX 
		CY1PEN 
		CY1INT 
		CY1FEE 
		CY1TOTDUE 
		CY1COLL 
		CY1BAL 
		CY1CR 
		CY2YEAR $
		CY2TXSALE $
		CY2TAX 
		CY2PEN 
		CY2INT 
		CY2FEE 
		CY2TOTDUE 
		CY2COLL 
		CY2BAL 
		CY2CR 
		PY1YEAR $
		PY1TXSALE $
		PY1TAX 
		PY1PEN 
		PY1INT 
		PY1FEE 
		PY1TOTDUE 
		PY1COLL 
		PY1BAL 
		PY1CR 
		PY2YEAR $
		PY2TXSALE $
		PY2TAX 
		PY2PEN 
		PY2INT 
		PY2FEE 
		PY2TOTDUE 
		PY2COLL 
		PY2BAL 
		PY2CR 
		PY3YEAR $
		PY3TXSALE $
		PY3TAX 
		PY3PEN 
		PY3INT 
		PY3FEE 
		PY3TOTDUE 
		PY3COLL 
		PY3BAL 
		PY3CR 
		PY4YEAR $
		PY4TXSALE $
		PY4TAX 
		PY4PEN 
		PY4INT 
		PY4FEE 
		PY4TOTDUE 
		PY4COLL 
		PY4BAL 
		PY4CR 
		PY5YEAR $
		PY5TXSALE $
		PY5TAX 
		PY5PEN 
		PY5INT 
		PY5FEE 
		PY5TOTDUE 
		PY5COLL 
		PY5BAL 
		PY5CR 
		PY6YEAR $
		PY6TXSALE $
		PY6TAX 
		PY6PEN 
		PY6INT 
		PY6FEE 
		PY6TOTDUE 
		PY6COLL 
		PY6BAL 
		PY6CR 
		PY7YEAR $
		PY7TXSALE $
		PY7TAX 
		PY7PEN 
		PY7INT 
		PY7FEE 
		PY7TOTDUE 
		PY7COLL 
		PY7BAL 
		PY7CR 
		PY8YEAR $
		PY8TXSALE $
		PY8TAX 
		PY8PEN 
		PY8INT 
		PY8FEE 
		PY8TOTDUE 
		PY8COLL 
		PY8BAL 
		PY8CR 
		PY9YEAR $
		PY9TXSALE $
		PY9TAX 
		PY9PEN 
		PY9INT 
		PY9FEE 
		PY9TOTDUE 
		PY9COLL 
		PY9BAL 
		PY9CR 
		PY10YEAR $
		PY10TXSALE $
		PY10TAX 
		PY10PEN 
		PY10INT 
		PY10FEE 
		PY10TOTDUE 
		PY10COLL 
		PY10BAL 
		PY10CR 
		c_LASTPAYDT $
		OWNNAME2 $
		INST_NO $
		MORTGAGECO $
		NBHDNAME $
		PRMS_WARD 
		PRESSL $
		PIPARENTLOT $
		BIDNAME $
		BIDTOTALDUE 
		BIDCOLLECTED 
		BIDBALANCE 
		SEWSTOTALDUE 
		SEWSCOLLECTED 
		SEWSBALANCE 
		PACETOTALDUE 
		PACECOLLECTED 
		PACEBALANCE 
		SWWSADTOTALDUE 
		SWWSADCOLLECTED 
		SWWSADBALANCE 
		OBJECTID 
		;

		/* Format dates */
        SALEDATE = input( substr( c_SALEDATE, 1, 10 ), yymmdd10. );
        DEEDDATE = input( substr( c_DEEDDATE, 1, 10 ), yymmdd10. );
        EXTRACTDAT = input( substr( c_EXTRACTDAT, 1, 10 ), yymmdd10. );
		LASTPAYDT = input( substr( c_LASTPAYDT, 1, 10 ), yymmdd10. );
		DUEDATE1 = input ( (catx("/", substr(c_DUEDATE1,5,4), substr(c_DUEDATE1,1,2), substr(c_DUEDATE1,3,2))), yymmdd10. );
		DUEDATE2 = input ( (catx("/", substr(c_DUEDATE2,5,4), substr(c_DUEDATE2,1,2), substr(c_DUEDATE2,3,2))), yymmdd10. );
		DUEDATE3 = input ( (catx("/", substr(c_DUEDATE3,5,4), substr(c_DUEDATE3,1,2), substr(c_DUEDATE3,3,2))), yymmdd10. );
		format SALEDATE DEEDDATE EXTRACTDAT LASTPAYDT DUEDATE1 DUEDATE2 DUEDATE3 mmddyy10.;

        usecode = put(in_usecode,z3.);

		drop OBJECTID c_SALEDATE c_DEEDDATE c_EXTRACTDAT c_LASTPAYDT c_DUEDATE1 c_DUEDATE2 c_DUEDATE3 in_usecode;

run;


%Finalize_data_set(
  /** Finalize data set parameters **/
  data=ITS_Public_Extract,
  out=ITS_Public_Extract,
  outlib=realprop,
  label="ITS Public Extract File from DC Open Data",
  sortby=ssl,
  /** Metadata parameters **/
  restrictions=None,
  revisions=%str(&revisions),
  /** File info parameters **/
  printobs=5
);


/** Read ITSPE Facts File **/

filename fimport "&filepath.&factsfile." lrecl=2000;

data ITSPE_Facts;

  infile FIMPORT delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;

		informat SSL $17. ;
		informat ASSESSOR_NAME $30. ;
        informat LAND_USE_CODE best32.;
        informat LAND_USE_DESCRIPTION $80.;
        informat LANDAREA best32.;
        informat PROPERTY_ADDRESS $99.;
        informat OTR_NEIGHBORHOOD_CODE best32.;
        informat OTR_NEIGHBORHOOD_NAME $60.;
        informat OWNER_NAME_PRIMARY $99.;
        informat CAREOF_NAME $99.;
        informat OWNER_ADDRESS_LINE1 $99.;
        informat OWNER_ADDRESS_LINE2 $99.;
        informat OWNER_ADDRESS_CITYSTZIP $40.;
        informat APPRAISED_VALUE_PRIOR_LAND best32.;
        informat APPRAISED_VALUE_PRIOR_IMPR best32.;
        informat APPRAISED_VALUE_PRIOR_TOTAL best32.;
		informat APPRAISED_VALUE_PROPOSED_LAND best32.;
		informat APPRAISED_VALUE_PROPOSED_IMPR best32.;
		informat APPRAISED_VALUE_PROPOSED_TOTAL best32.;
        informat APPRAISED_VALUE_CURRENT_LAND best32.;
        informat APPRAISED_VALUE_CURRENT_BLDG best32.;
        informat VACANT_USE $3.;
        informat HOMESTEAD_DESCRIPTION $20.;
        informat TAX_TYPE_DESCRIPTION $50.;
        informat TAXRATE best32.;
        informat MIXED_USE $1.;
        informat OWNER_OCCUPIED_COOP_UNITS best32.;
        informat LAST_SALE_PRICE best32.;
        informat c_LAST_SALE_DATE $32.;
        informat c_DEED_DATE $32.;
        informat CURRENT_ASSESSMENT_CAP best32.;
        informat PROPOSED_ASSESSMENT_CAP best32.;
        informat OWNER_NAME_SECONDARY $99.;
        informat ADDRESS_ID $358.;
        informat c_LASTMODIFIEDDATE $32.;
		informat APPRAISED_VALUE_CURRENT_TOTAL best32.;
		informat OBJECTID best32. ;

        input
        SSL $
		ASSESSOR_NAME $
		LAND_USE_CODE 
		LAND_USE_DESCRIPTION $
		LANDAREA 
		PROPERTY_ADDRESS $
		OTR_NEIGHBORHOOD_CODE 
		OTR_NEIGHBORHOOD_NAME $
		OWNER_NAME_PRIMARY $
		CAREOF_NAME $
		OWNER_ADDRESS_LINE1 $
		OWNER_ADDRESS_LINE2 $
		OWNER_ADDRESS_CITYSTZIP $
		APPRAISED_VALUE_PRIOR_LAND 
		APPRAISED_VALUE_PRIOR_IMPR 
		APPRAISED_VALUE_PRIOR_TOTAL 
		APPRAISED_VALUE_PROPOSED_LAND 
		APPRAISED_VALUE_PROPOSED_IMPR 
		APPRAISED_VALUE_PROPOSED_TOTAL 
		APPRAISED_VALUE_CURRENT_LAND 
		APPRAISED_VALUE_CURRENT_BLDG 
		VACANT_USE $
		HOMESTEAD_DESCRIPTION $
		TAX_TYPE_DESCRIPTION $
		TAXRATE 
		MIXED_USE $
		OWNER_OCCUPIED_COOP_UNITS 
		LAST_SALE_PRICE 
		c_LAST_SALE_DATE $
		c_DEED_DATE $
		CURRENT_ASSESSMENT_CAP 
		PROPOSED_ASSESSMENT_CAP 
		OWNER_NAME_SECONDARY $
		ADDRESS_ID $
		c_LASTMODIFIEDDATE $
		APPRAISED_VALUE_CURRENT_TOTAL 
		OBJECTID 
		;

        LAST_SALE_DATE = input( substr( c_LAST_SALE_DATE, 1, 10 ), yymmdd10. );
        DEED_DATE = input( substr( c_DEED_DATE, 1, 10 ), yymmdd10. );
        LASTMODIFIEDDATE = input( substr( c_LASTMODIFIEDDATE, 1, 10 ), yymmdd10. );
  		format LAST_SALE_DATE DEED_DATE LASTMODIFIEDDATE mmddyy10.;

        drop OBJECTID c_LAST_SALE_DATE c_DEED_DATE c_LASTMODIFIEDDATE landarea taxrate;

run;

%Finalize_data_set(
  /** Finalize data set parameters **/
  data=ITSPE_Facts,
  out=ITSPE_Facts,
  outlib=realprop,
  label="ITS Facts File from DC Open Data",
  sortby=ssl,
  /** Metadata parameters **/
  restrictions=None,
  revisions=%str(&revisions),
  /** File info parameters **/
  printobs=5
);


/** Read CAMA Sales File **/

filename fimport "&filepath.&Salesfile." lrecl=2000;

data Cama_property_sales;

  infile FIMPORT delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;

		informat OBJECTID best32.;
		informat ROW_NUMBER best32.;
		informat SSL $17.;
		informat c_SALE_DATE $32.;
		informat SALE_PRICE best32.;
		informat QUALIFIED $1.;
		informat SALE_CODE $2.;
		informat SALE_CURR_OWNER best32.;
		informat c_GIS_LAST_MOD_DTTM $32.;

		input
		OBJECTID
		ROW_NUMBER
		SSL $
		c_SALE_DATE $
		SALE_PRICE
		QUALIFIED $
		SALE_CODE $
		SALE_CURR_OWNER
		c_GIS_LAST_MOD_DTTM $
		;

		SALE_DATE = input( substr( c_SALE_DATE, 1, 10 ), yymmdd10. );
		GIS_LAST_MOD_DTTM = input( substr( c_GIS_LAST_MOD_DTTM, 1, 10 ), yymmdd10. );

  	format SALE_DATE GIS_LAST_MOD_DTTM mmddyy10.;

	drop OBJECTID c_SALE_DATE c_GIS_LAST_MOD_DTTM;

run;

%Finalize_data_set(
  /** Finalize data set parameters **/
  data=Cama_property_sales,
  out=Cama_property_sales,
  outlib=realprop,
  label="Tax System Property Sales (CAMA) from DC Open Data",
  sortby=ssl,
  /** Metadata parameters **/
  restrictions=None,
  revisions=%str(&revisions),
  /** File info parameters **/
  printobs=5
);




/* End of Program */
