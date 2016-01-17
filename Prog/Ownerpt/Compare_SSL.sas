/**************************************************************************
 Program:  Compare_ssl.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/16/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Compare Ownerpt source files.

 Modifications:
**************************************************************************/

/**%include "L:\SAS\Inc\StdLocal.sas";**/
%include "C:\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )


/** Macro Compare_ssl - Start Definition **/

%macro Compare_ssl( file_list );

  %local i file invar;

  %let i = 1;
  %let file = %scan( &file_list, &i, %str( ) );

  %do %until ( &file = );

      proc sort data=RealProp.&file out=&file;
      by ssl;
    run;

    %let i = %eval( &i + 1 );
    %let file = %scan( &file_list, &i, %str( ) );

  %end;
  
  data RealProp.Compare_ssl;

    merge 
    
    %let i = 1;
    %let file = %scan( &file_list, &i, %str( ) );

    %do %until ( &file = );
    
        %if %length( _in_&file ) > 32 %then
          %let invar = %substr( _in_&file, 1, 32 );
        %else 
          %let invar = _in_&file;

        &file (keep=ssl in=&invar)

      %let i = %eval( &i + 1 );
      %let file = %scan( &file_list, &i, %str( ) );

    %end;
    
      ;
      by ssl;
      
    %let i = 1;
    %let file = %scan( &file_list, &i, %str( ) );

    %do %until ( &file = );

        %if %length( _in_&file ) > 32 %then
          %let invar = %substr( _in_&file, 1, 32 );
        %else 
          %let invar = _in_&file;

        &file=&invar;

      %let i = %eval( &i + 1 );
      %let file = %scan( &file_list, &i, %str( ) );

    %end;
          
    run;
   

%mend Compare_ssl;

/** End Macro Definition **/

%let file_list = ownerpt_2014_01 
    itspe_facts itspe_facts_2 itspe_property_sales itspe_vacant_property 
    owner_polygons_common_ownership 
    property_sale_points 
    Condo_Approval_Lots /*Condo_Relate_Table*/;
    
%let file_list = 
    ownerpt_2014_01 
    itspe_facts 
    itspe_property_sales 
    owner_polygons_common_ownership 
    property_sale_points
    Condo_Approval_Lots 
  ;

*options obs=0;
*options mprint symbolgen mlogic;


%Compare_ssl( &file_list )

%File_info( data=RealProp.Compare_ssl )

proc freq data=RealProp.Compare_ssl;
  tables %ListChangeDelim( &file_list, new_delim=* )
  /nocum nopercent list;
  format &file_list dyesno.;
run;
