/**************************************************************************
 Program:  Sales_summary.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/03/07
 Version:  SAS 9.1
 Environment:  Autocall macro

 Description: Autocall macro to produce summary of cleaned sales data.

 Modifications:
  02/03/14 PAT  Updated for new SAS1 server.
**************************************************************************/

%macro Sales_summary( data= );

proc tabulate data=&data format=comma10. noseps missing;
  class saledate ui_proptype;
  var saleprice;
  table 
    /** Rows **/
    saledate
    ,
    /** Columns **/
    ui_proptype=' ' * ( n='Number of sales' median='Median price' ) * saleprice=' '
  ;
  format saledate year4. ui_proptype $UIPRTYP.;
  title2 "Summary of Sales Data (File=&data)";
run;

proc tabulate data=&data format=comma10. noseps missing;
  class ownerpt_extractdat_last ui_proptype;
  table
    /** Rows **/
    all='TOTAL'
    ownerpt_extractdat_last=' ' 
    ,
    /** Columns **/
    n='Number of sales' * ( all='Total' ui_proptype=' ' )
    / box='By Date of Ownerpt Update File' rts=18
  ;
  format ui_proptype $UIPRTYP.;
  title2 "Summary of Sales Data by Ownerpt Extract Date (File=&data)";
run;

title2;
run;

%mend Sales_summary;
