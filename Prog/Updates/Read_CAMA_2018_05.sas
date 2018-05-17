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


%let date=2018-05; 

%Read_cama; 


  /** Input file information **/
  inpath=&_dcdata_r_path\RealProp\Raw\2014-03,
  infile=CAMARespt,
  intype=sas7bdat,								
  camatype=Respt,								/*Type of CAMA (ResPt, CondoPt, CommPt)*/
  outfilesuf=,
  filemonth=03,                                  /* Month of file extract (number) */
  fileyear=2014,								 /* Year of file extract (4-digits) */
  filedate='10mar2014'd,									/* Full date of file extract (mmDDyyyy)*/
  /** Name of previous ownerpt data set 
  prev_file=CAMARespt_xxxx_zz,**/
  
  /** List data corrections here **/
  corrections=
	saleyear=year(saledate);
	if saleyear > 2014 then saledate=saledate-36524.2;
	label saleyear="Sale Year Variable to Correct Sale Date";) *Check next -file many dates like 2098 instead of 1998); 


%Read_cama_macro( 

  /** Input file information **/
  inpath=&_dcdata_r_path\RealProp\Raw\2013-10,
  infile=CAMACommpt,
  intype=sas7bdat,
   camatype=CommPt,								/*Type of CAMA (ResPt, CondoPt, CommPt)*/
  outfilesuf=,
  filemonth=08,                                  /* Month of file extract (number) */
  fileyear=2013,								 /* Year of file extract (4-digits) */
  filedate='13aug2013'd,									/* Full date of file extract (mmDDyyyy)*/
  /** Name of previous ownerpt data set 
  prev_file=CAMACommpt_xxxx_zz,**/
      
  /** List data corrections here **/
  corrections=
      
)


%Read_cama_macro( 

  /** Input file information **/
  inpath=&_dcdata_r_path\RealProp\Raw\2013-10,
  infile=CAMACondopt,
 	intype=sas7bdat,
   camatype=CondoPt,								/*Type of CAMA (ResPt, CondoPt, CommPt)*/
  outfilesuf=,
  filemonth=08,                                  /* Month of file extract (number) */
  fileyear=2013,								 /* Year of file extract (4-digits) */
  filedate='13aug2013'd,									/* Full date of file extract (mmDDyyyy)*/
  /** Name of previous ownerpt data set 
  prev_file=CAMACondopt_xxxx_zz,**/
    
  
  /** List data corrections here **/
  corrections=
      
);
data camarespt (drop=old_units);
set realpr_r.Camarespt_2014_03 (rename=(num_units=old_units));
length num_units 3.;

num_units=old_units;
label num_units="Number of Units";

run;
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

