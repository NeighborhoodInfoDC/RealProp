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

%let filepath = &_dcdata_r_path\RealProp\Raw\2021-12\;

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
        informat DEEDSTATUS $1.;
        informat DELCODE $1.;
        informat DUEDATE1       best32.;
        informat DUEDATE2       best32.;
        informat DUEDATE3       best32.;
        informat EXTRACTDAT       best32.;
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
        informat SALEDATE       best32.;
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
        informat USECODE $4. ;
        informat VACLNDUSE $1.;

        input
        ABTLOTCODE     $;
        ACCEPTCODE $;
        ADDRESS1 $;
        informat ADDRESS2 $;
        informat AMTDUE1       ;
        informat AMTDUE2        ;
        informat AMTDUE3        ;
        informat ANNUALTAX      ;
        informat ARN $;
        informat ASRNAME $;
        informat ASSESSMENT     ;
        informat BIDBALANCE     ;
        informat BIDCOLLECTED     ;
        informat BIDNAME $;
        informat BIDTOTALDUE     ;
        informat CAPCURR        $;
        informat CAPPROP $;
        informat CAREOFNAME $;
        informat CITYSTZIP $;
        informat CLASSTYPE ;
        informat COOPUNITS ;
        informat CY1BAL ;
        informat CY1COLL ;
        informat CY1CR ;
        informat CY1FEE ;
        informat CY1INT ;
        informat CY1PEN ;
        informat CY1TAX ;
        informat CY1TOTDUE      ;
        informat CY1TXSALE      $;
        informat CY1YEAR $;
        informat CY2BAL ;
        informat CY2COLL ;
        informat CY2CR ;
        informat CY2FEE ;
        informat CY2INT ;
        informat CY2PEN ;
        informat CY2TAX ;
        informat CY2TOTDUE      ;
        informat CY2TXSALE      $;
        informat CY2YEAR $;
        informat DEEDSTATUS $;
        informat DELCODE $;
        informat DUEDATE1       ;
        informat DUEDATE2       ;
        informat DUEDATE3       ;
        informat EXTRACTDAT       ;
        informat HSTDCODE $;
        informat INST_NO       ;
        informat INTERNALID       ;
        informat LANDAREA ;
        informat LASTPAYDT $;
        informat LOT $;
        informat LOWNUMBER $;
        informat MIX1BLDPCT     ;
        informat MIX1BLDVAL ;
        informat MIX1CLASS ;
        informat MIX1LNDPCT ;
        informat MIX1LNDVAL     ;
        informat MIX1RATE ;
        informat MIX1TXTYPE $;
        informat MIX2BLDPCT     ;
        informat MIX2BLDVAL ;
        informat MIX2CLASS ;
        informat MIX2LNDPCT ;
        informat MIX2LNDVAL     ;
        informat MIX2RATE ;
        informat MIX2TXTYPE $;
        informat MIXEDUSE $;
        informat MORTGAGECO ;
        informat NBHD $;
        informat NBHDNAME $;
        informat NEWIMPR $;
        informat NEWLAND $;
        informat NEWTOTAL $;
        informat OBJECTID  ;
        informat OLDIMPR $;
        informat OLDLAND $;
        informat OLDTOTAL $;
        informat OWNERNAME $;
        informat OWNNAME2 $;
        informat OWNOCCT $;
        informat PACEBALANCE ;
        informat PACECOLLECTED ;
        informat PACETOTALDUE ;
        informat PARTPART $;
        informat PCHILDCODE     $;
        informat PHASEBUILD ;
        informat PHASELAND ;
        informat PIPARENTLOT $;
        informat PREMISEADD $;
        informat PRESSL $;
        informat PRMS_WARD ;
        informat PROPTYPE $;
        informat PY10BAL        ;
        informat PY10COLL ;
        informat PY10CR ;
        informat PY10FEE        ;
        informat PY10INT        ;
        informat PY10PEN        ;
        informat PY10TAX        ;
        informat PY10TOTDUE     ;
        informat PY10TXSALE     $;
        informat PY10YEAR $;
        informat PY1BAL ;
        informat PY1COLL ;
        informat PY1CR ;
        informat PY1FEE ;
        informat PY1INT ;
        informat PY1PEN ;
        informat PY1TAX ;
        informat PY1TOTDUE      ;
        informat PY1TXSALE      $;
        informat PY1YEAR $;
        informat PY2BAL ;
        informat PY2COLL ;
        informat PY2CR ;
        informat PY2FEE ;
        informat PY2INT ;
        informat PY2PEN ;
        informat PY2TAX ;
        informat PY2TOTDUE      ;
        informat PY2TXSALE      $;
        informat PY2YEAR $;
        informat PY3BAL ;
        informat PY3COLL ;
        informat PY3CR ;
        informat PY3FEE ;
        informat PY3INT ;
        informat PY3PEN ;
        informat PY3TAX ;
        informat PY3TOTDUE      ;
        informat PY3TXSALE      $;
        informat PY3YEAR $;
        informat PY4BAL ;
        informat PY4COLL ;
        informat PY4CR ;
        informat PY4FEE ;
        informat PY4INT ;
        informat PY4PEN ;
        informat PY4TAX ;
        informat PY4TOTDUE      ;
        informat PY4TXSALE      $;
        informat PY4YEAR $;
        informat PY5BAL ;
        informat PY5COLL ;
        informat PY5CR ;
        informat PY5FEE ;
        informat PY5INT ;
        informat PY5PEN ;
        informat PY5TAX ;
        informat PY5TOTDUE      ;
        informat PY5TXSALE      $;
        informat PY5YEAR $;
        informat PY6BAL ;
        informat PY6COLL ;
        informat PY6CR ;
        informat PY6FEE ;
        informat PY6INT ;
        informat PY6PEN ;
        informat PY6TAX ;
        informat PY6TOTDUE      ;
        informat PY6TXSALE      $;
        informat PY6YEAR $;
        informat PY7BAL ;
        informat PY7COLL ;
        informat PY7CR ;
        informat PY7FEE ;
        informat PY7INT ;
        informat PY7PEN ;
        informat PY7TAX ;
        informat PY7TOTDUE      ;
        informat PY7TXSALE      $;
        informat PY7YEAR $;
        informat PY8BAL ;
        informat PY8COLL ;
        informat PY8CR ;
        informat PY8FEE ;
        informat PY8INT ;
        informat PY8PEN ;
        informat PY8TAX ;
        informat PY8TOTDUE      ;
        informat PY8TXSALE      $;
        informat PY8YEAR $;
        informat PY9BAL ;
        informat PY9COLL ;
        informat PY9CR ;
        informat PY9FEE ;
        informat PY9INT ;
        informat PY9PEN ;
        informat PY9TAX ;
        informat PY9TOTDUE      ;
        informat PY9TXSALE      $;
        informat PY9YEAR $;
        informat QDRNTNAME      $;
        informat REASONCD       $;
        informat SALEDATE       ;
        informat SALEPRICE ;
        informat SALETYPE $;
        informat SEWSBALANCE ;
        informat SEWSCOLLECTED ;
        informat SEWSTOTALDUE ;
        informat SQUARE $;
        informat SSL $ ;
        informat STREETNAME     $ ;
        informat SUBNBHD $;
        informat SUFFIX $;
        informat SWWSADBALANCE ;
        informat SWWSADCOLLECTED ;
        informat SWWSADTOTALDUE ;
        informat TAXRATE ;
        informat TOTBALAMT      ;
        informat TOTCOLAMT      ;
        informat TOTDUEAMT      ;
        informat TRIGROUP $;
        informat UNITNUMBER $ ;
        informat USECODE $ ;
        informat VACLNDUSE $;

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
