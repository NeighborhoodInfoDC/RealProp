/**************************************************************************
 Program:  Read_CAMA_2018_05.sas
 Library:  RealProp
 Project:  Urban-Greater DC
 Author:   L. Hendey
 Created:  
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read latest CAMA files.

 Modifications: 
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )


%let filedate=2018-05; 

/*Read in raw cama files*/
%Read_cama; 

/*merge files and figure out how to deal with duplicates*/ 

data Cama;
set realpr_r.Camacommpt_2013_08 (in=a) realpr_r.Camacondopt_2013_08 (in=b) camarespt (in=c);

if a then cama="CommPt";
if b then cama="CondoPt";
if c then cama="ResPt";

length bldg_id $3. ssl_bldg_id $25;
bldg_id=bldg_num;
ssl_bldg_id=ssl||"-"||bldg_id;

label Cama="Origin File for CAMA data"
	  bldg_id="Character version of Building Number"
	  ssl_bldg_id="Unique SSL and Building ID (UI Created)";

run;

proc sort data=work.camacommpt_2013_08;
by ssl bldg_num;
run;

run;

%dup_check( 
    data=Cama, 
    by=ssl_bldg_id, 
    id=premiseadd unitnumber cama,
    printnumdups=N,
    out=_dup_check_out
  )
  run;

  title2;
  
  ** Count duplicate parcels **;
  
  proc sql noprint;
    create table _dup_check_out_count (compress=no) as
    select count(*) as count
    from _dup_check_out;
    quit;
  run;
  
  data _null_;
    set _dup_check_out_count;
    if count > 0 then do;
      %err_put( msg=count "duplicate parcels were found in final output data set" )
      %err_put( msg="A list of duplicate parcels has been printed to the SAS output." )
    end;
  run;

