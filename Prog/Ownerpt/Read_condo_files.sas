/**************************************************************************
 Program:  Read_condo_files.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/16/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read condo test download files.

 Modifications:
**************************************************************************/

/**%include "L:\SAS\Inc\StdLocal.sas";**/
%include "C:\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )

/** Macro Read - Start Definition **/

%macro Read( file );

  filename fimport "C:\DCData\Libraries\RealProp\Raw\Test 01-08-16\&file..csv" lrecl=2000;

  proc import out=RealProp.&file.
      datafile=fimport
      dbms=csv replace;
    datarow=2;
    getnames=yes;
    guessingrows=1000;

  run;

  filename fimport clear;

  %File_info( data=RealProp.&file. )

  run;

%mend Read;

/** End Macro Definition **/

%Read( Condo_Approval_Lots )


filename fimport "C:\DCData\Libraries\RealProp\Raw\Test 01-08-16\Condo_Relate_Table.csv" lrecl=2000;

data RealProp.Condo_Relate_Table;

  infile FIMPORT delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;

     informat OBJECTID best32. ;
     informat SSL $20. ;
     informat REGIME $32. ;
     informat COMPLEX best32. ;
     informat NAME $33. ;
     informat REC_LOT best32. ;
     informat UNDER_REC best32. ;
     informat TAX_LOT best32. ;
     informat UNDER_TAX best32. ;
     informat CONDO_BK best32. ;
     informat CONDO_PG best32. ;
     informat REC_LOT2 $14. ;
     informat SQUARE best32. ;
     informat SUFFIX $1. ;
     informat LOT best32. ;
     informat MAT_SSL $20. ;
     informat ACT_LOT best32. ;
     informat REGIME_ID best32. ;
     informat UNITNUM $5. ;
     informat ADDRESS_ID best32. ;
     informat DOC_DATE yymmdd10. ;
     informat O_LOTS $1. ;
     informat BK_PG $6. ;
     informat UNUM_OWN $7. ;
     informat UID_ best32. ;
     informat MARUNITNUM $5. ;
     informat AIR_LOT $1. ;
     informat UNDER_AIR best32. ;
     informat ASSESSMENT best32. ;
     informat OLDTOTAL best32. ;
     informat NEWTOTAL best32. ;
     informat OWNERNAME $56. ;
     informat OWNNAME2 $47. ;
     informat CAREOFNAME $39. ;
     informat ADDRESS1 $35. ;
     informat ADDRESS2 $1. ;
     informat CITYSTZIP $35. ;
     informat LANDAREA best32. ;
     informat HSTDCODE best32. ;
     informat CY1YEAR $15. ;
     informat CAPCURR best32. ;
     informat PHASELAND best32. ;
     informat PHASEBUILD best32. ;
     informat CAPPROP best32. ;
     informat NEWLAND best32. ;
     informat NEWIMPR best32. ;
     informat SALEPRICE best32. ;
     informat _c_SALEDATE $32. ;
     
   input
               OBJECTID
               SSL $
               REGIME $
               COMPLEX
               NAME $
               REC_LOT
               UNDER_REC
               TAX_LOT
               UNDER_TAX
               CONDO_BK
               CONDO_PG
               REC_LOT2 $
               SQUARE
               SUFFIX $
               LOT
               MAT_SSL $
               ACT_LOT
               REGIME_ID
               UNITNUM $
               ADDRESS_ID
               DOC_DATE
               O_LOTS $
               BK_PG $
               UNUM_OWN $
               UID_
               MARUNITNUM $
               AIR_LOT $
               UNDER_AIR
               ASSESSMENT
               OLDTOTAL
               NEWTOTAL
               OWNERNAME $
               OWNNAME2 $
               CAREOFNAME $
               ADDRESS1 $
               ADDRESS2 $
               CITYSTZIP $
               LANDAREA
               HSTDCODE
               CY1YEAR $
               CAPCURR
               PHASELAND
               PHASEBUILD
               CAPPROP
               NEWLAND
               NEWIMPR
               SALEPRICE
               _c_SALEDATE $
   ;
  
  Saledate = input( substr( _c_saledate, 1, 10 ), yymmdd10. );
  
  format saledate mmddyy10.;
  
  drop _c_: ;
   
  run;
     
  filename fimport clear;

  %File_info( data=RealProp.Condo_Relate_Table )

  run;


