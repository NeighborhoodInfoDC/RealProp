/**************************************************************************
 Program:  Corrections_2014_01.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/28/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Make corrections to 1/25/2014 OwnerPt update to
 Parcel_base data set and Parcel_base, Parcel_geo, Sales_master, and
 Sales_res_clean metadata.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp, local=n )
%DCData_lib( Metadata, local=n )

/** Macro Delete_last_revision - Start Definition **/

%macro Delete_last_revision( 
  library=,      /** Library name **/
  filename=,     /** Data set name **/
  before=,        /** SAS date value: If specified, 
                     delete all revision entries BEFORE this date. **/
  after=         /** SAS date value: If specified, 
                     delete all revision entries AFTER this date. **/
);

%let library = %upcase( &library );
%let filename = %upcase( &filename );

%put _local_;

options obs=max;

proc print data=Metadata.Meta_history noobs;
  where library = "&library" and filename = "&filename";
  by library filename;
  var FileUpdated FileRevisions;
  title2 "Meta_history - BEFORE deletion";
  
run;

data Metadata.Meta_history;

  set Metadata.Meta_history;
  by library filename descending FileUpdated;

  if library = %upcase( "&library" ) and filename = %upcase( "&filename" ) and 
      %if &before ~= and &after ~= %then %do;
        ( &before > datepart( FileUpdated ) > &after ) /** Delete all revisions before and after specified dates **/
      %end;
      %else %if &before ~= %then %do;
        ( &before > datepart( FileUpdated ) ) /** Delete all revisions before specified date **/
      %end;
      %else %if &after ~= %then %do;
        ( datepart( FileUpdated ) > &after ) /** Delete all revisions after specified date **/
      %end;
      %else %do;
        first.filename /** Delete last revision only **/
      %end;
    then do;
      %note_put( msg="Deleting observation from Meta_history: "      
                      _n_= library= filename= FileUpdated= FileRevisions= )
      delete;
  end;

run;

proc print data=Metadata.Meta_history noobs;
  where library = "&library" and filename = "&filename";
  by library filename;
  var FileUpdated FileRevisions;
  title2 "Meta_history - AFTER deletion";
  
run;

%mend Delete_last_revision;

/** End Macro Definition **/


** Delete last revision from Parcel_base metadata **;

%Delete_last_revision( library=RealProp, filename=Parcel_base, after='01jun2014'd )

** Revise labels in Parcel_base data set **;

proc datasets library=RealProp memtype=(data) nolist;
  modify Parcel_base;
    label 
      in_last_ownerpt = "Parcel was in most recent Ownerpt update [Ownerpt_2014_01]"
      new_ownerpt_parcel = "New parcel as of most recent Ownerpt update [Ownerpt_2014_01]";
  run;
  contents data=Parcel_base;
  run;
quit;

** Reregister Parcel_base **;

%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=Parcel_base,
  creator=rpitingolo,
  creator_process=Parcel_base_Ownerpt_2014_01.sas,
  restrictions=None,
  revisions=%str(Updated with Ownerpt_2014_01.)
)

** Reregister Parcel_geo **;

%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=Parcel_geo,
  creator=rpitingolo,
  creator_process=Parcel_geo_Ownerpt_2014_01.sas,
  restrictions=None,
  revisions=%str(Updated with Ownerpt_2014_01.)
)

** Reregister Sales_master **;

%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=Sales_master,
  creator=rpitingolo,
  creator_process=Update_sales_2014_01.sas,
  restrictions=None,
  revisions=%str(Updated with Realpr_r.ownerpt_2014_01.)
)

** Reregister Sales_res_clean **;

%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=Sales_res_clean,
  creator=rpitingolo,
  creator_process=Update_sales_2014_01.sas,
  restrictions=None,
  revisions=%str(Updated with Realpr_r.ownerpt_2014_01.)
)

run;
