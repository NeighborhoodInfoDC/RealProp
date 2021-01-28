/**************************************************************************
 Program:  Read_itspe_files.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Eleanor Noble
 Created:  05/11/2020
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)

 Description:  Read ITS Public Extract, ITSPE Facts, and ITSPE Sales


 Modifications: 10-3-16 Update with new data -RP
                                02-03-17 Update with Q4-2016 data -RP
                                09-27-17 Updste with new data -IM
                                03-20-18 Update with new data -NS
 Modifications: 10-3-16 Update with Q2-2016 data -RP
                                12-8-16 Update with Q3-2016 data -RP
                                5-25-18 Update with Q1-2018 data -RP
                                5-25-18 Update with Q2-2018 data -WO
                                5-11-2020 Update with new data - EN
                                1-7-2021 update with new data -AH

**************************************************************************/

%include "\\sas1\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp );

** Note revisions **;
%let revisions = Updated through 2021-01;

/* Path to raw data csv files and names */

%let filepath = &_dcdata_r_path\RealProp\Raw\2021-01\;

%let PEfile = Integrated_Tax_System_Public_Extract.csv;
%let FactsFile = Integrated_Tax_System_Public_Extract_Facts.csv;
%let SalesFile = Integrated_Tax_System_Public_Extract_Property_Sales.csv;

/** Read ITS Public Extract File **/

filename fimport "&filepath.&pefile." lrecl=2000;

data ITS_Public_Extract;

  infile FIMPORT delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;

        informat ABTLOTCODE     $4.;
        informat ACCEPTCODE $30.;
        informat ADDRESS1 $30.;
        informat ADDRESS2 $30.;
        informat AMTDUE1        best32.;
        informat AMTDUE2        best32.;
        informat AMTDUE3        best32.;
        informat ANNUALTAX      best32.;
        informat ARN $1.;
        informat ASRNAME $1.;
        informat ASSESSMENT     best32.;
        informat BIDBALANCE     best32.;
        informat BIDCOLLECTED     best32.;
        informat BIDNAME $30.;
        informat BIDTOTALDUE     best32.;
        informat CAPCURR        $13.;
        informat CAPPROP $10.;
        informat CAREOFNAME $40.;
        informat CITYSTZIP $40.;
        informat CLASSTYPE best32.;
        informat COOPUNITS best32.;
        informat CY1BAL best32.;
        informat CY1COLL best32.;
        informat CY1CR best32.;
        informat CY1FEE best32.;
        informat CY1INT best32.;
        informat CY1PEN best32.;
        informat CY1TAX best32.;
        informat CY1TOTDUE      best32.;
        informat CY1TXSALE      $10.;
        informat CY1YEAR $16.;
        informat CY2BAL best32.;
        informat CY2COLL best32.;
        informat CY2CR best32.;
        informat CY2FEE best32.;
        informat CY2INT best32.;
        informat CY2PEN best32.;
        informat CY2TAX best32.;
        informat CY2TOTDUE      best32.;
        informat CY2TXSALE      $10.;
        informat CY2YEAR $16.;
        informat c_DEEDDATE $32.;
        informat DELCODE $1.;
        informat DUEDATE1       best32.;
        informat DUEDATE2       best32.;
        informat DUEDATE3       best32.;
        informat c_EXTRACTDAT       $32.;
        informat HSTDCODE $1.;
        informat INST_NO       best32.;
        informat INTERNALID       best32.;
        informat LANDAREA best32.;
        informat LASTPAYDT $10.;
        informat LOT $4.;
        informat LOWNUMBER $4.;
        informat MIX1BLDPCT     best32.;
        informat MIX1BLDVAL best32.;
        informat MIX1CLASS best32.;
        informat MIX1LNDPCT best32.;
        informat MIX1LNDVAL     best32.;
        informat MIX1RATE best32.;
        informat MIX1TXTYPE $2.;
        informat MIX2BLDPCT     best32.;
        informat MIX2BLDVAL best32.;
        informat MIX2CLASS best32.;
        informat MIX2LNDPCT best32.;
        informat MIX2LNDVAL     best32.;
        informat MIX2RATE best32.;
        informat MIX2TXTYPE $2.;
        informat MIXEDUSE $1.;
        informat MORTGAGECO best32.;
        informat NBHD $3.;
        informat NBHDNAME $30.;
        informat NEWIMPR $9.;
        informat NEWLAND $9.;
        informat NEWTOTAL $9.;
        informat OBJECTID best32. ;
        informat OLDIMPR $9.;
        informat OLDLAND $9.;
        informat OLDTOTAL $9.;
        informat OWNERNAME $60.;
        informat OWNNAME2 $30.;
        informat OWNOCCT $3.;
        informat PACEBALANCE best32.;
        informat PACECOLLECTED best32.;
        informat PACETOTALDUE best32.;
        informat PARTPART $1.;
        informat PCHILDCODE     $1.;
        informat PHASEBUILD best32.;
        informat PHASELAND best32.;
        informat PIPARENTLOT $12.;
        informat PREMISEADD $45.;
        informat PRESSL $45.;
        informat PRMS_WARD best32.;
        informat PROPTYPE $1.;
        informat PY10BAL        best32.;
        informat PY10COLL best32.;
        informat PY10CR best32.;
        informat PY10FEE        best32.;
        informat PY10INT        best32.;
        informat PY10PEN        best32.;
        informat PY10TAX        best32.;
        informat PY10TOTDUE     best32.;
        informat PY10TXSALE     $10.;
        informat PY10YEAR $16.;
        informat PY1BAL best32.;
        informat PY1COLL best32.;
        informat PY1CR best32.;
        informat PY1FEE best32.;
        informat PY1INT best32.;
        informat PY1PEN best32.;
        informat PY1TAX best32.;
        informat PY1TOTDUE      best32.;
        informat PY1TXSALE      $10.;
        informat PY1YEAR $16.;
        informat PY2BAL best32.;
        informat PY2COLL best32.;
        informat PY2CR best32.;
        informat PY2FEE best32.;
        informat PY2INT best32.;
        informat PY2PEN best32.;
        informat PY2TAX best32.;
        informat PY2TOTDUE      best32.;
        informat PY2TXSALE      $10.;
        informat PY2YEAR $16.;
        informat PY3BAL best32.;
        informat PY3COLL best32.;
        informat PY3CR best32.;
        informat PY3FEE best32.;
        informat PY3INT best32.;
        informat PY3PEN best32.;
        informat PY3TAX best32.;
        informat PY3TOTDUE      best32.;
        informat PY3TXSALE      $10.;
        informat PY3YEAR $16.;
        informat PY4BAL best32.;
        informat PY4COLL best32.;
        informat PY4CR best32.;
        informat PY4FEE best32.;
        informat PY4INT best32.;
        informat PY4PEN best32.;
        informat PY4TAX best32.;
        informat PY4TOTDUE      best32.;
        informat PY4TXSALE      $10.;
        informat PY4YEAR $16.;
        informat PY5BAL best32.;
        informat PY5COLL best32.;
        informat PY5CR best32.;
        informat PY5FEE best32.;
        informat PY5INT best32.;
        informat PY5PEN best32.;
        informat PY5TAX best32.;
        informat PY5TOTDUE      best32.;
        informat PY5TXSALE      $10.;
        informat PY5YEAR $16.;
        informat PY6BAL best32.;
        informat PY6COLL best32.;
        informat PY6CR best32.;
        informat PY6FEE best32.;
        informat PY6INT best32.;
        informat PY6PEN best32.;
        informat PY6TAX best32.;
        informat PY6TOTDUE      best32.;
        informat PY6TXSALE      $10.;
        informat PY6YEAR $16.;
        informat PY7BAL best32.;
        informat PY7COLL best32.;
        informat PY7CR best32.;
        informat PY7FEE best32.;
        informat PY7INT best32.;
        informat PY7PEN best32.;
        informat PY7TAX best32.;
        informat PY7TOTDUE      best32.;
        informat PY7TXSALE      $10.;
        informat PY7YEAR $16.;
        informat PY8BAL best32.;
        informat PY8COLL best32.;
        informat PY8CR best32.;
        informat PY8FEE best32.;
        informat PY8INT best32.;
        informat PY8PEN best32.;
        informat PY8TAX best32.;
        informat PY8TOTDUE      best32.;
        informat PY8TXSALE      $10.;
        informat PY8YEAR $16.;
        informat PY9BAL best32.;
        informat PY9COLL best32.;
        informat PY9CR best32.;
        informat PY9FEE best32.;
        informat PY9INT best32.;
        informat PY9PEN best32.;
        informat PY9TAX best32.;
        informat PY9TOTDUE      best32.;
        informat PY9TXSALE      $10.;
        informat PY9YEAR $16.;
        informat QDRNTNAME      $2.;
        informat REASONCD       $1.;
        informat c_SALEDATE       $32.;
        informat SALEPRICE best32.;
        informat SALETYPE $20.;
        informat SEWSBALANCE best32.;
        informat SEWSCOLLECTED best32.;
        informat SEWSTOTALDUE best32.;
        informat SQUARE $4.;
        informat SSL $17. ;
        informat STREETNAME     $30. ;
        informat SUBNBHD $1.;
        informat SUFFIX $4.;
        informat SWWSADBALANCE best32.;
        informat SWWSADCOLLECTED best32.;
        informat SWWSADTOTALDUE best32.;
        informat TAXRATE best32.;
        informat TOTBALAMT      best32.;
        informat TOTCOLAMT      best32.;
        informat TOTDUEAMT      best32.;
        informat TRIGROUP $1.;
        informat UNITNUMBER $10. ;
        informat in_usecode best32.;
        informat VACLNDUSE $1.;

        input
        ABTLOTCODE     $
        ACCEPTCODE $
        ADDRESS1 $
        ADDRESS2 $
        AMTDUE1       
        AMTDUE2        
        AMTDUE3        
        ANNUALTAX      
        ARN $
        ASRNAME $
        ASSESSMENT     
        BIDBALANCE     
        BIDCOLLECTED     
        BIDNAME $
        BIDTOTALDUE     
        CAPCURR        $
        CAPPROP $
        CAREOFNAME $
        CITYSTZIP $
        CLASSTYPE 
        COOPUNITS 
        CY1BAL 
        CY1COLL 
        CY1CR 
        CY1FEE 
        CY1INT 
        CY1PEN 
        CY1TAX 
        CY1TOTDUE      
        CY1TXSALE      $
        CY1YEAR $
        CY2BAL 
        CY2COLL 
        CY2CR 
        CY2FEE 
        CY2INT 
        CY2PEN 
        CY2TAX 
        CY2TOTDUE      
        CY2TXSALE      $
        CY2YEAR $
        c_DEEDDATE $
        DELCODE $
        DUEDATE1       
        DUEDATE2       
        DUEDATE3       
        c_EXTRACTDAT     $
        HSTDCODE $
        INST_NO       
        INTERNALID       
        LANDAREA 
        LASTPAYDT $
        LOT $
        LOWNUMBER $
        MIX1BLDPCT     
        MIX1BLDVAL 
        MIX1CLASS 
        MIX1LNDPCT 
        MIX1LNDVAL     
        MIX1RATE 
        MIX1TXTYPE $
        MIX2BLDPCT     
        MIX2BLDVAL 
        MIX2CLASS 
        MIX2LNDPCT 
        MIX2LNDVAL     
        MIX2RATE 
        MIX2TXTYPE $
        MIXEDUSE $
        MORTGAGECO 
        NBHD $
        NBHDNAME $
        NEWIMPR $
        NEWLAND $
        NEWTOTAL $
        OBJECTID  
        OLDIMPR $
        OLDLAND $
        OLDTOTAL $
        OWNERNAME $
        OWNNAME2 $
        OWNOCCT $
        PACEBALANCE 
        PACECOLLECTED 
        PACETOTALDUE 
        PARTPART $
        PCHILDCODE     $
        PHASEBUILD 
        PHASELAND 
        PIPARENTLOT $
        PREMISEADD $
        PRESSL $
        PRMS_WARD 
        PROPTYPE $
        PY10BAL        
        PY10COLL 
        PY10CR 
        PY10FEE        
        PY10INT        
        PY10PEN        
        PY10TAX        
        PY10TOTDUE     
        PY10TXSALE     $
        PY10YEAR $
        PY1BAL 
        PY1COLL 
        PY1CR 
        PY1FEE 
        PY1INT 
        PY1PEN 
        PY1TAX 
        PY1TOTDUE      
        PY1TXSALE      $
        PY1YEAR $
        PY2BAL 
        PY2COLL 
        PY2CR 
        PY2FEE 
        PY2INT 
        PY2PEN 
        PY2TAX 
        PY2TOTDUE      
        PY2TXSALE      $
        PY2YEAR $
        PY3BAL 
        PY3COLL 
        PY3CR 
        PY3FEE 
        PY3INT 
        PY3PEN 
        PY3TAX 
        PY3TOTDUE      
        PY3TXSALE      $
        PY3YEAR $
        PY4BAL 
        PY4COLL 
        PY4CR 
        PY4FEE 
        PY4INT 
        PY4PEN 
        PY4TAX 
        PY4TOTDUE      
        PY4TXSALE      $
        PY4YEAR $
        PY5BAL 
        PY5COLL 
        PY5CR 
        PY5FEE 
        PY5INT 
        PY5PEN 
        PY5TAX 
        PY5TOTDUE      
        PY5TXSALE      $
        PY5YEAR $
        PY6BAL 
        PY6COLL 
        PY6CR 
        PY6FEE 
        PY6INT 
        PY6PEN 
        PY6TAX 
        PY6TOTDUE      
        PY6TXSALE      $
        PY6YEAR $
        PY7BAL 
        PY7COLL 
        PY7CR 
        PY7FEE 
        PY7INT 
        PY7PEN 
        PY7TAX 
        PY7TOTDUE      
        PY7TXSALE      $
        PY7YEAR $
        PY8BAL 
        PY8COLL 
        PY8CR 
        PY8FEE 
        PY8INT 
        PY8PEN 
        PY8TAX 
        PY8TOTDUE      
        PY8TXSALE      $
        PY8YEAR $
        PY9BAL 
        PY9COLL 
        PY9CR 
        PY9FEE 
        PY9INT 
        PY9PEN 
        PY9TAX 
        PY9TOTDUE      
        PY9TXSALE      $
        PY9YEAR $
        QDRNTNAME      $
        REASONCD       $
        c_SALEDATE       $
        SALEPRICE 
        SALETYPE $
        SEWSBALANCE 
        SEWSCOLLECTED 
        SEWSTOTALDUE 
        SQUARE $
        SSL $ 
        STREETNAME     $ 
        SUBNBHD $
        SUFFIX $
        SWWSADBALANCE 
        SWWSADCOLLECTED 
        SWWSADTOTALDUE 
        TAXRATE 
        TOTBALAMT      
        TOTCOLAMT      
        TOTDUEAMT      
        TRIGROUP $
        UNITNUMBER $ 
        in_usecode
        VACLNDUSE $
		;

        SALEDATE = input( substr( c_SALEDATE, 1, 10 ), yymmdd10. );
        DEEDDATE = input( substr( c_DEEDDATE, 1, 10 ), yymmdd10. );
        EXTRACTDAT = input( substr( c_EXTRACTDAT, 1, 10 ), yymmdd10. );

        usecode = put(in_usecode,z3.);

  		format SALEDATE yymmdd10.;
        format   DEEDDATE yymmdd10.;
        format   EXTRACTDAT yymmdd10.;

drop c_SALEDATE c_DEEDDATE c_EXTRACTDAT in_usecode;

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

        informat OBJECTID best32. ;
        informat SSL $17. ;
        informat ASSESSOR_NAME $30. ;
        informat LAND_USE_CODE best32.;
        informat LAND_USE_DESCRIPTION $39.;
        informat LANDAREA best32.;
        informat PROPERTY_ADDRESS $39.;
        informat OTR_NEIGHBORHOOD_CODE best32.;
        informat OTR_NEIGHBORHOOD_NAME $32.;
        informat OWNER_NAME_PRIMARY $60.;
        informat CAREOF_NAME $40.;
        informat OWNER_ADDRESS_LINE1 $30.;
        informat OWNER_ADDRESS_LINE2 $30.;
        informat OWNER_ADDRESS_CITYSTZIP $40.;
        informat APPRAISED_VALUE_PRIOR_LAND best32.;
        informat APPRAISED_VALUE_PRIOR_IMPR best32.;
        informat APPRAISED_VALUE_PRIOR_TOTAL best32.;
        informat APPRAISED_VALUE_CURRENT_LAND best32.;
        informat APPRAISED_VALUE_CURRENT_TOTAL best32.;
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
		informat APPRAISED_VALUE_PROPOSED_LAND best32.;
		informat APPRAISED_VALUE_PROPOSED_IMPR best32.;
		informat APPRAISED_VALUE_PROPOSED_TOTAL best32.;
		informat APPRAISED_VALUE_CURRENT_IMPR best32.;



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
        APPRAISED_VALUE_PRIOR_LAND 
        APPRAISED_VALUE_PRIOR_IMPR 
        APPRAISED_VALUE_PRIOR_TOTAL 
        APPRAISED_VALUE_CURRENT_LAND 
        APPRAISED_VALUE_CURRENT_TOTAL 
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
		APPRAISED_VALUE_PROPOSED_LAND 
		APPRAISED_VALUE_PROPOSED_IMPR 
		APPRAISED_VALUE_PROPOSED_TOTAL 
		APPRAISED_VALUE_CURRENT_IMPR 
;

        LAST_SALE_DATE = input( substr( c_LAST_SALE_DATE, 1, 10 ), yymmdd10. );
        DEED_DATE = input( substr( c_DEED_DATE, 1, 10 ), yymmdd10. );
        LASTMODIFIEDDATE = input( substr( c_LASTMODIFIEDDATE, 1, 10 ), yymmdd10. );

  format LAST_SALE_DATE yymmdd10.;
        format   DEED_DATE yymmdd10.;
        format   LASTMODIFIEDDATE yymmdd10.;

        drop c_LAST_SALE_DATE c_DEED_DATE c_LASTMODIFIEDDATE
                 objectid landarea taxrate;

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


/** Read ITSPE Sales File **/

filename fimport "&filepath.&Salesfile." lrecl=2000;

data Itspe_property_sales;

  infile FIMPORT delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;

        informat OBJECTID best32. ;
        informat SSL $17. ;
        informat LAND_USE_C best32.;
        informat LAND_USE_D $39.;
        informat LANDAREA best32.;
        informat PROPERTY_A $39.;
        informat OWNER_NAME $30.;
		informat APPRAISED_VALUE_PRIOR_LAND best32.;
		informat APPRAISED_VALUE_PRIOR_IMPR best32.;
		informat APPRAISED_VALUE_PRIOR_TOTAL best32.;
		informat APPRAISED_VALUE_CURRENT_LAND best32.;
		informat APPRAISED_VALUE_CURRENT_TOTAL best32.;
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
		informat APPRAISED_VALUE_PROPOSED_LAND best32.;
		informat APPRAISED_VALUE_PROPOSED_IMPR best32.;
		informat APPRAISED_VALUE_PROPOSED_TOTAL best32.;
		informat APPRAISED_VALUE_CURRENT_BLDG best32.;


        input
        OBJECTID 
        SSL $
        LAND_USE_C 
        LAND_USE_D $
        LANDAREA 
        PROPERTY_A $
        OWNER_NAME $
		APPRAISED_VALUE_PRIOR_LAND 
		APPRAISED_VALUE_PRIOR_IMPR 
		APPRAISED_VALUE_PRIOR_TOTAL 
		APPRAISED_VALUE_CURRENT_LAND 
		APPRAISED_VALUE_CURRENT_TOTAL 
        VACANT_USE $
		HOMESTEAD_ 
        HOMESTEAD1 $
        TAX_TYPE_D $
        TAXRATE 
        MIXED_USE $
        OWNER_OCCU 
        LAST_SALE_ 
        c_LAST_SALE1 $
        c_DEED_DATE $
        CURRENT_AS 
        PROPOSED_A 
        OWNER_NA_1 $
        ADDRESS_ID $
        c_LASTMODIFI $
		APPRAISED_VALUE_PROPOSED_LAND 
		APPRAISED_VALUE_PROPOSED_IMPR 
		APPRAISED_VALUE_PROPOSED_TOTAL 
		APPRAISED_VALUE_CURRENT_BLDG 
;

        LAST_SALE1 = input( substr( c_LAST_SALE1, 1, 10 ), yymmdd10. );
        DEED_DATE = input( substr( c_DEED_DATE, 1, 10 ), yymmdd10. );
        LASTMODIFI = input( substr( c_LASTMODIFI, 1, 10 ), yymmdd10. );

  format LAST_SALE1 mmddyy10.;
        format   DEED_DATE mmddyy10.;
        format   LASTMODIFI mmddyy10.;

drop c_LAST_SALE1 c_DEED_DATE c_LASTMODIFI
         objectid landarea taxrate vacant_use mixed_use address_id deed_date;

run;

%Finalize_data_set(
  /** Finalize data set parameters **/
  data=Itspe_property_sales,
  out=Itspe_property_sales,
  outlib=realprop,
  label="ITS Property Sales File from DC Open Data",
  sortby=ssl,
  /** Metadata parameters **/
  restrictions=None,
  revisions=%str(&revisions),
  /** File info parameters **/
  printobs=5
);




/* End of Program */
