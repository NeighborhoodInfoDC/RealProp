/**************************************************************************
 Program:  Read_itspe_files.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  01/16/16
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read ITS Public Extract, ITSPE Facts, and ITSPE Sales

 Modifications: 10-3-16 Update with new data -RP
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp );

/* Path to raw data csv files and names */

%let filepath = &_dcdata_r_path\RealProp\Raw\2016-10\;
%let PEfile = Integrated_Tax_System_Public_Extract.csv;
%let FactsFile = Integrated_Tax_System_Public_Extract_Facts.csv;
%let SalesFile = Integrated_Tax_System_Public_Extract_Property_Sales.csv;

/** Read ITS Public Extract File **/

filename fimport "&filepath.&pefile." lrecl=2000;

data realprop.ITS_Public_Extract;

  infile FIMPORT delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;

	informat OBJECTID_1 best32. ;
	informat OBJECTID best32. ;
	informat SSL $20. ;
	informat SQUARE	$4.;
	informat SUFFIX	$6.;
	informat LOT $4.;
	informat ARN $1.;
	informat ASRNAME $1.;
	informat PROPTYPE $1.;
	informat TRIGROUP $1.;
	informat in_usecode best32.;
	informat LANDAREA best32.;
	informat PREMISEADD $45.;
	informat NBHD $3.;
	informat SUBNBHD $1.;
	informat UNITNUMBER $20.;
	informat OWNERNAME $60.;
	informat CAREOFNAME $60.;
	informat ADDRESS1 $30.;
	informat ADDRESS2 $30.;
	informat CITYSTZIP $40.;
	informat BASELAND best32.; 
	informat BASEBUILD best32.;
	informat OLDLAND $9.;					
	informat OLDIMPR $9.;
	informat OLDTOTAL $9.;
	informat NEWLAND $9.;
	informat NEWIMPR $9.;
	informat NEWTOTAL $9.;
	informat PHASELAND best32.;
	informat PHASEBUILD best32.;
	informat PHASECYCLE $1.;
	informat PARTPART $1.;
	informat VACLNDUSE $1.;
	informat LOWNUMBER $4.;
	informat HIGHNUMBER $4.;
	informat STREETNAME	$30. ;
	informat STREETCODE	$4.;
	informat QDRNTNAME	$4.;
	informat DELCODE $1.;
	informat HSTDCODE $1.;	
	informat CLASSTYPE best32.;
	informat TAXRATE best32.;
	informat MIXEDUSE $1.;
	informat MIX1TXTYPE $2.;
	informat MIX1CLASS best32.;
	informat MIX1RATE best32.;
	informat MIX1LNDPCT best32.;
	informat MIX1LNDVAL	best32.; 
	informat MIX1BLDPCT	best32.; 
	informat MIX1BLDVAL best32.; 
	informat MIX2TXTYPE $2.;
	informat MIX2CLASS best32.;
	informat MIX2RATE best32.;
	informat MIX2LNDPCT best32.;
	informat MIX2LNDVAL	best32.; 
	informat MIX2BLDPCT	best32.; 
	informat MIX2BLDVAL best32.; 
	informat OWNOCCT $3.;
	informat COOPUNITS best32.;
	informat PCHILDCODE	$1.; 
	informat ABTLOTCODE	$10.;
	informat SALEPRICE best32.;
	informat c_SALEDATE $20.;
	informat ACCEPTCODE $30.;
	informat SALETYPE $20.;
	informat c_DEEDDATE $20.;
	informat ASSESSMENT	best32.; 									
	informat ANNUALTAX	best32.; 
	informat DUEDATE1	best32.; 
	informat AMTDUE1	best32.; 
	informat DUEDATE2	best32.; 
	informat AMTDUE2	best32.; 
	informat DUEDATE3	best32.; 
	informat AMTDUE3	best32.; 
	informat TOTDUEAMT	best32.; 
	informat TOTCOLAMT	best32.; 
	informat TOTBALAMT	best32.; 
	informat c_EXTRACTDAT $20.;
	informat DEEDSTATUS $1.;
	informat CAPCURR	$13.;
	informat CAPPROP $10.;
	informat REASONCD	$1.; 		
	informat TXSALEDESC	$1.;
	informat CLASS3	best32.;
	informat CLASS3EX	$1.;
	informat CY1YEAR $16.;
	informat CY1TXSALE	$10.;
	informat CY1TAX	best32.; 
	informat CY1PEN	best32.; 
	informat CY1INT	best32.; 
	informat CY1FEE	best32.; 
	informat CY1TOTDUE	best32.;
	informat CY1COLL best32.;	
	informat CY1BAL	best32.; 
	informat CY1CR best32.; 
	informat CY2YEAR $16.;
	informat CY2TXSALE	$10.;
	informat CY2TAX	best32.; 
	informat CY2PEN	best32.; 
	informat CY2INT	best32.; 
	informat CY2FEE	best32.; 
	informat CY2TOTDUE	best32.;
	informat CY2COLL best32.;	
	informat CY2BAL	best32.; 
	informat CY2CR best32.; 
	informat PY1YEAR $16.;
	informat PY1TXSALE	$10.;
	informat PY1TAX	best32.; 
	informat PY1PEN	best32.; 
	informat PY1INT	best32.; 
	informat PY1FEE	best32.; 
	informat PY1TOTDUE	best32.;
	informat PY1COLL best32.;	
	informat PY1BAL	best32.; 
	informat PY1CR best32.; 
	informat PY2YEAR $16.;
	informat PY2TXSALE	$10.;
	informat PY2TAX	best32.; 
	informat PY2PEN	best32.; 
	informat PY2INT	best32.; 
	informat PY2FEE	best32.; 
	informat PY2TOTDUE	best32.;
	informat PY2COLL best32.;	
	informat PY2BAL	best32.; 
	informat PY2CR best32.; 
	informat PY3YEAR $16.;
	informat PY3TXSALE	$10.;
	informat PY3TAX	best32.; 
	informat PY3PEN	best32.; 
	informat PY3INT	best32.; 
	informat PY3FEE	best32.; 
	informat PY3TOTDUE	best32.;
	informat PY3COLL best32.;	
	informat PY3BAL	best32.; 
	informat PY3CR best32.; 
	informat PY4YEAR $16.;
	informat PY4TXSALE	$10.;
	informat PY4TAX	best32.; 
	informat PY4PEN	best32.; 
	informat PY4INT	best32.; 
	informat PY4FEE	best32.; 
	informat PY4TOTDUE	best32.;
	informat PY4COLL best32.;	
	informat PY4BAL	best32.; 
	informat PY4CR best32.; 
	informat PY5YEAR $16.;
	informat PY5TXSALE	$10.;
	informat PY5TAX	best32.; 
	informat PY5PEN	best32.; 
	informat PY5INT	best32.; 
	informat PY5FEE	best32.; 
	informat PY5TOTDUE	best32.;
	informat PY5COLL best32.;	
	informat PY5BAL	best32.; 
	informat PY5CR best32.; 
	informat PY6YEAR $16.;
	informat PY6TXSALE	$10.;
	informat PY6TAX	best32.; 
	informat PY6PEN	best32.; 
	informat PY6INT	best32.; 
	informat PY6FEE	best32.; 
	informat PY6TOTDUE	best32.;
	informat PY6COLL best32.;	
	informat PY6BAL	best32.; 
	informat PY6CR best32.; 
	informat PY7YEAR $16.;
	informat PY7TXSALE	$10.;
	informat PY7TAX	best32.; 
	informat PY7PEN	best32.; 
	informat PY7INT	best32.; 
	informat PY7FEE	best32.; 
	informat PY7TOTDUE	best32.;
	informat PY7COLL best32.;	
	informat PY7BAL	best32.; 
	informat PY7CR best32.; 
	informat PY8YEAR $16.;
	informat PY8TXSALE	$10.;
	informat PY8TAX	best32.; 
	informat PY8PEN	best32.; 
	informat PY8INT	best32.; 
	informat PY8FEE	best32.; 
	informat PY8TOTDUE	best32.;
	informat PY8COLL best32.;	
	informat PY8BAL	best32.; 
	informat PY8CR best32.; 
	informat PY9YEAR $16.;
	informat PY9TXSALE	$10.;
	informat PY9TAX	best32.; 
	informat PY9PEN	best32.; 
	informat PY9INT	best32.; 
	informat PY9FEE	best32.; 
	informat PY9TOTDUE	best32.;
	informat PY9COLL best32.;	
	informat PY9BAL	best32.; 
	informat PY9CR best32.; 
	informat PY10YEAR $16.;
	informat PY10TXSALE	$10.;
	informat PY10TAX	best32.; 
	informat PY10PEN	best32.; 
	informat PY10INT	best32.; 
	informat PY10FEE	best32.; 
	informat PY10TOTDUE	best32.;
	informat PY10COLL best32.;	
	informat PY10BAL	best32.; 
	informat PY10CR best32.; 
	informat LASTPAYDT $10.;
	informat OWNNAME2 $30.;

	input
	OBJECTID_1 
	OBJECTID 
	SSL $
	SQUARE	$
	SUFFIX	$
	LOT $
	ARN $
	ASRNAME  $
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
	BASELAND  
	BASEBUILD 
	OLDLAND $				
	OLDIMPR $
	OLDTOTAL $
	NEWLAND $
	NEWIMPR $
	NEWTOTAL $
	PHASELAND 
	PHASEBUILD 
	PHASECYCLE $
	PARTPART $
	VACLNDUSE $
	LOWNUMBER $
	HIGHNUMBER $
	STREETNAME	$
	STREETCODE	$
	QDRNTNAME	$
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
	PCHILDCODE	$
	ABTLOTCODE	$
	SALEPRICE 
	c_SALEDATE $
	ACCEPTCODE $
	SALETYPE $
	c_DEEDDATE $
	ASSESSMENT	 									
	ANNUALTAX	 
	DUEDATE1	 
	AMTDUE1	 
	DUEDATE2	 
	AMTDUE2	 
	DUEDATE3	 
	AMTDUE3	 
	TOTDUEAMT	 
	TOTCOLAMT	 
	TOTBALAMT	 
	c_EXTRACTDAT $
	DEEDSTATUS $
	CAPCURR	$
	CAPPROP $
	REASONCD	$ 		
	TXSALEDESC	$
	CLASS3	
	CLASS3EX	$
	CY1YEAR $
	CY1TXSALE	$
	CY1TAX	 
	CY1PEN	 
	CY1INT	 
	CY1FEE	 
	CY1TOTDUE	
	CY1COLL 	
	CY1BAL	 
	CY1CR  
	CY2YEAR $
	CY2TXSALE	$
	CY2TAX	 
	CY2PEN	 
	CY2INT	 
	CY2FEE	 
	CY2TOTDUE	
	CY2COLL 	
	CY2BAL	 
	CY2CR  
	PY1YEAR $
	PY1TXSALE	$
	PY1TAX	 
	PY1PEN	 
	PY1INT	 
	PY1FEE	 
	PY1TOTDUE	
	PY1COLL 	
	PY1BAL	 
	PY1CR  
	PY2YEAR $
	PY2TXSALE	$
	PY2TAX	 
	PY2PEN	 
	PY2INT	 
	PY2FEE	 
	PY2TOTDUE	
	PY2COLL 	
	PY2BAL	 
	PY2CR  
	PY3YEAR $
	PY3TXSALE	$
	PY3TAX	 
	PY3PEN	 
	PY3INT	 
	PY3FEE	 
	PY3TOTDUE	
	PY3COLL 	
	PY3BAL	 
	PY3CR  
	PY4YEAR $
	PY4TXSALE	$
	PY4TAX	 
	PY4PEN	 
	PY4INT	 
	PY4FEE	 
	PY4TOTDUE	
	PY4COLL 	
	PY4BAL	 
	PY4CR  
	PY5YEAR $
	PY5TXSALE	$
	PY5TAX	 
	PY5PEN	 
	PY5INT	 
	PY5FEE	 
	PY5TOTDUE	
	PY5COLL 	
	PY5BAL	 
	PY5CR  
	PY6YEAR $
	PY6TXSALE	$
	PY6TAX	 
	PY6PEN	 
	PY6INT	 
	PY6FEE	 
	PY6TOTDUE	
	PY6COLL 	
	PY6BAL	 
	PY6CR  
	PY7YEAR $
	PY7TXSALE	$
	PY7TAX	 
	PY7PEN	 
	PY7INT	 
	PY7FEE	 
	PY7TOTDUE	
	PY7COLL 	
	PY7BAL	 
	PY7CR  
	PY8YEAR $
	PY8TXSALE	$
	PY8TAX	 
	PY8PEN	 
	PY8INT	 
	PY8FEE	 
	PY8TOTDUE	
	PY8COLL 	
	PY8BAL	 
	PY8CR  
	PY9YEAR $
	PY9TXSALE	$
	PY9TAX	 
	PY9PEN	 
	PY9INT	 
	PY9FEE	 
	PY9TOTDUE	
	PY9COLL 	
	PY9BAL	 
	PY9CR  
	PY10YEAR $
	PY10TXSALE	$
	PY10TAX	 
	PY10PEN	 
	PY10INT	 
	PY10FEE	 
	PY10TOTDUE	
	PY10COLL 	
	PY10BAL	 
	PY10CR  
	LASTPAYDT $
	OWNNAME2 $
	
;

	SALEDATE = input( substr( c_SALEDATE, 1, 10 ), yymmdd10. );
	DEEDDATE = input( substr( c_DEEDDATE, 1, 10 ), yymmdd10. );
	EXTRACTDAT = input( substr( c_EXTRACTDAT, 1, 10 ), yymmdd10. );

	usecode = put(in_usecode,z3.);
  
  format SALEDATE yymmdd10.;
	format	 DEEDDATE yymmdd10.;
	format	 EXTRACTDAT yymmdd10.;

drop c_SALEDATE c_DEEDDATE c_EXTRACTDAT in_usecode;

run;

proc sort data = realprop.ITS_Public_Extract; by ssl; run;
%File_info( data=RealProp.ITS_Public_Extract )


/** Read ITSPE Facts File **/

filename fimport "&filepath.&factsfile." lrecl=2000;

data realprop.ITSPE_Facts;

  infile FIMPORT delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;

  	informat OBJECTID best32. ;
	informat SSL $20. ;
	informat ASSESSOR_NAME $30. ;
	informat LAND_USE_CODE best32.;
	informat LAND_USE_DESCRIPTION $39.;
	informat LANDAREA best32.;
	informat PROPERTY_ADDRESS $39.;
	informat OTR_NEIGHBORHOOD_CODE best32.;
	informat OTR_NEIGHBORHOOD_NAME $32.;
	informat OWNER_NAME_PRIMARY $60.;
	informat CAREOF_NAME $30.;
	informat OWNER_ADDRESS_LINE1 $30.;
	informat OWNER_ADDRESS_LINE2 $30.;
	informat OWNER_ADDRESS_CITYSTZIP $40.;
	informat APPRAISED_VALUE_BASEYEAR_LAND best32.;
	informat APPRAISED_VALUE_BASEYEAR_BLDG best32.;
	informat APPRAISED_VALUE_PRIOR_LAND best32.;
	informat APPRAISED_VALUE_PRIOR_IMPR best32.;
	informat APPRAISED_VALUE_PRIOR_TOTAL best32.;
	informat APPRAISED_VALUE_CURRENT_LAND best32.;
	informat APPRAISED_VALUE_CURRENT_IMPR best32.;
	informat APPRAISED_VALUE_CURRENT_TOTAL best32.;
	informat PHASEIN_VALUE_CURRENT_LAND best32.;
	informat PHASEIN_VALUE_CURRENT_BLDG best32.;
	informat VACANT_USE $3.;
	informat HOMESTEAD_DESCRIPTION $16.;
	informat TAX_TYPE_DESCRIPTION $50.;
	informat TAXRATE best32.;
	informat MIXED_USE $1.;
	informat OWNER_OCCUPIED_COOP_UNITS best32.;
	informat LAST_SALE_PRICE best32.;
	informat c_LAST_SALE_DATE $32.;
	informat c_DEED_DATE $32.;
	informat CURRENT_ASSESSMENT_CAP best32.;
	informat PROPOSED_ASSESSMENT_CAP best32.;
	informat OWNER_NAME_SECONDARY $60.;
	informat ADDRESS_ID $358.;
	informat c_LASTMODIFIEDDATE $32.;


	input
	OBJECTID
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
	APPRAISED_VALUE_BASEYEAR_LAND
	APPRAISED_VALUE_BASEYEAR_BLDG
	APPRAISED_VALUE_PRIOR_LAND 
	APPRAISED_VALUE_PRIOR_IMPR 
	APPRAISED_VALUE_PRIOR_TOTAL 
	APPRAISED_VALUE_CURRENT_LAND
	APPRAISED_VALUE_CURRENT_IMPR
	APPRAISED_VALUE_CURRENT_TOTAL
	PHASEIN_VALUE_CURRENT_LAND
	PHASEIN_VALUE_CURRENT_BLDG
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
;

	LAST_SALE_DATE = input( substr( c_LAST_SALE_DATE, 1, 10 ), yymmdd10. );
	DEED_DATE = input( substr( c_DEED_DATE, 1, 10 ), yymmdd10. );
	LASTMODIFIEDDATE = input( substr( c_LASTMODIFIEDDATE, 1, 10 ), yymmdd10. );
  
  format LAST_SALE_DATE yymmdd10.;
	format	 DEED_DATE yymmdd10.;
	format	 LASTMODIFIEDDATE yymmdd10.;

	drop c_LAST_SALE_DATE c_DEED_DATE c_LASTMODIFIEDDATE
		 objectid landarea taxrate;

run;

proc sort data = realprop.ITSPE_Facts; by ssl; run;
%File_info( data=RealProp.ITSPE_Facts )



/** Read ITSPE Sales File **/

filename fimport "&filepath.&Salesfile." lrecl=2000;

data realprop.Itspe_property_sales;

  infile FIMPORT delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;

  	informat OBJECTID best32. ;
	informat SSL $20. ;
	informat LAND_USE_C best32.;
	informat LAND_USE_D $39.;
	informat LANDAREA best32.;
	informat PROPERTY_A $39.;
	informat OWNER_NAME $30.;
	informat APPRAISED_ best32.;
	informat APPRAISED1 best32.;
	informat APPRAISE_1 best32.;
	informat APPRAISE_2 best32.;
	informat APPRAISE_3 best32.;
	informat APPRAISE_4 best32.;
	informat APPRAISE_5 best32.;
	informat APPRAISE_6 best32.;
	informat PHASEIN_VA best32.;
	informat PHASEIN__1 best32.;
	informat VACANT_USE $3.;
	informat HOMESTEAD_ best32.;
	informat HOMESTEAD1 $16.;
	informat TAX_TYPE_D $50.;
	informat TAXRATE best32.;
	informat MIXED_USE $1.;
	informat OWNER_OCCU best32.;
	informat LAST_SALE_ best32.;
	informat c_LAST_SALE1 $32.;
	informat c_DEED_DATE $32.;
	informat CURRENT_AS best32.;
	informat PROPOSED_A best32.;
	informat OWNER_NA_1 $30.;
	informat ADDRESS_ID $358.;
	informat c_LASTMODIFI $32.;

	input
	OBJECTID
	SSL $
	LAND_USE_C
	LAND_USE_D $
	LANDAREA
	PROPERTY_A $
	OWNER_NAME $
	APPRAISED_
	APPRAISED1
	APPRAISE_1
	APPRAISE_2
	APPRAISE_3
	APPRAISE_4
	APPRAISE_5
	APPRAISE_6
	PHASEIN_VA
	PHASEIN__1
	VACANT_USE $ 
	HOMESTEAD_
	HOMESTEAD1 $ 
	TAX_TYPE_D $
	TAXRATE
	MIXED_USE $
	OWNER_OCCU
	LAST_SALE_
	c_LAST_SALE1
	c_DEED_DATE
	CURRENT_AS
	PROPOSED_A
	OWNER_NA_1 $ 
	ADDRESS_ID $ 
	c_LASTMODIFI
;

	LAST_SALE1 = input( substr( c_LAST_SALE1, 1, 10 ), yymmdd10. );
	DEED_DATE = input( substr( c_DEED_DATE, 1, 10 ), yymmdd10. );
	LASTMODIFI = input( substr( c_LASTMODIFI, 1, 10 ), yymmdd10. );
  
  format LAST_SALE1 mmddyy10.;
	format	 DEED_DATE mmddyy10.;
	format	 LASTMODIFI mmddyy10.;

drop c_LAST_SALE1 c_DEED_DATE c_LASTMODIFI
	 objectid landarea taxrate vacant_use mixed_use address_id deed_date;

run;

proc sort data = realprop.Itspe_property_sales; by ssl; run;
%File_info( data=realprop.Itspe_property_sales )



/* End of Program */
