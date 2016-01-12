/**************************************************************************
 Program:  Read_CAMACondoPt_macro.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   B. Losoya
 Created:  3/4/2014
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Autocall macro for reading and processing CAMACondoPt
 files (real property parcels) obtained from OCTO.

 Modifications:

**************************************************************************/

/** Macro Read_CAMACondoPt_macro - Start Definition **/

%macro Read_CAMACondoPt_macro( 
  inpath= &_dcdata_r_path\RealProp\Raw,    /* Location of input file */
  infile= CAMACondoPt,                             /* Name of input file */
  intype=dbf,                                  /* Type of input file (dbf, mdb) */
  intable=,                                    /* Input table (Access files only) */
  outfilesuf=,                                 /* Suffix for output data set (used only if 2+ extracts in same month) */
  filemonth=,                                  /* Month of file extract (number) */
  fileyear=,                                   /* Year of file extract (4-digits) */
  obs=1000000000,                              /* Maximum obs. to process */
  corrections=,                                /* Corrections to be applied to this file */
  del_dup_recs=,                               /* List of record nos. for obs. to delete */
  prev_file=,                                  /* Previous data set for parcel comparison (optional) */
  format=                                      /* Additional formats to be applied */
    deed_date CAMACondoPt_SALEDATE saledate mmddyy10.
    Usecode $Usecode.
    
    Saletype $Saletyp.,
  freqvars=
    CAMACondoPt_SALEDATE qdrntname 
    saletype usecode 
    

  );
  
  %let mname=Read_CAMACondoPt_macro;
  /**%syslput mname = &mname;**/
  /**%syslput prev_file = &prev_file;**/
    
  %note_mput( macro=&mname, msg=Macro starting. )
  
  %let intype = %upcase( &intype );
  
  %** Date constant values **;
  
  %fdate( mvar=D01JAN2002, date='01jan2002'd, fmt=20.0, quiet=y )
  %fdate( mvar=D01JAN2003, date='01jan2003'd, fmt=20.0, quiet=y )
  %fdate( mvar=D01FEB2004, date='01feb2004'd, fmt=20.0, quiet=y )
  %fdate( mvar=D01JAN2005, date='01jan2005'd, fmt=20.0, quiet=y )
  %fdate( mvar=D24MAR2005, date='24mar2005'd, fmt=20.0, quiet=y )
  %fdate( mvar=D31MAR2013, date='31mar2013'd, fmt=20.0, quiet=y )
  
  %** Create comma-separated variable list of record nos. to delete **;

  %let del_dup_recs_csv = %ListChangeDelim( &del_dup_recs, quiet=y );
  /**%syslput del_dup_recs_csv = &del_dup_recs_csv;**/

  ** Convert file from DBF or MDB format **;
  
  %if &intype = DBF %then %do;
    libname inf dbdbf "&inpath" ver=4 CAMACondoPt=&infile;
    %let dsname = CAMACondoPt;
  %end;
  %else %if &intype = MDB %then %do;
    %if &intable = %then %do;
      %err_mput( macro=&mname, msg=For Access database must provide a value for INTABLE= parameter. )
      %goto exit;
    %end;
    libname inf dbaccess "&inpath\&infile..mdb" CAMACondoPt="&intable";
    %let dsname = CAMACondoPt;
  %end;
  %else %if &intype = SAS7BDAT %then %do;
    libname inf "&inpath";
    %let dsname = &infile;
  %end;
  %else %do;
    %err_mput( macro=&mname, msg=Invalid value &INTYPE for INTYPE= parameter (must be DBF or MDB). )
    %goto exit;
  %end;
  
  ** Get file extraction date **;
  
  proc sql noprint;
    select min(SALEDATE), max(SALEDATE)
      into :_min_SALEDATE, :_max_SALEDATE
    from inf.&dsname (obs=1000)
    where SALEDATE > '01jan2001'd;
    quit;
  run;
  
  /**%syslput _min_SALEDATE=&_min_SALEDATE;**/
  /**%syslput _max_SALEDATE=&_max_SALEDATE;**/

  data _null_;
    call symput("_min_SALEDATE_fmt",left(put(&_min_SALEDATE,mmddyy10.)));
    call symput("_max_SALEDATE_fmt",left(put(&_max_SALEDATE,mmddyy10.)));
  run;
  
  %put _min_SALEDATE=&_min_SALEDATE_fmt;
  %put _max_SALEDATE=&_max_SALEDATE_fmt;
  
  %if &_min_SALEDATE ~= &_max_SALEDATE or &_max_SALEDATE = . %then %do;
    %warn_mput( macro=&mname, msg=File extraction dates (SALEDATE) are not consistent: &_min_SALEDATE_fmt to &_max_SALEDATE_fmt )
    %warn_mput( macro=&mname, msg=&_max_SALEDATE_fmt will be used as the file extraction date. )
  %end;
  
  %let filemonth = %sysfunc( month( &_max_SALEDATE ) );
  %let fileyear = %sysfunc( year( &_max_SALEDATE ) );
  %let filedate = &_max_SALEDATE;
  %let filedate_fmt = &_max_SALEDATE_fmt;
  %let outfile = CAMACondoPt_&fileyear._%sysfunc( putn( &filemonth, z2. ) )&outfilesuf;
  
  %note_mput( macro=&mname, msg=Output data set is &outfile.. )
  
  /**%syslput outfile = &outfile;**/
  /**%syslput filedate = &filedate;**/
  /**%syslput filedate_fmt = &filedate_fmt;**/

  %** List of ID vars for duplicate parcel check **;
  
  %if ( &D01JAN2002 <= &filedate and &filedate < &D01JAN2003 ) or &D01FEB2004 <= &filedate %then 
    %let dup_ids = recordno premiseadd unitnumber x_coord y_coord;
  %else 
    %let dup_ids = recordno premiseadd unitnumber saledate;

  /**%syslput dup_ids = &dup_ids;**/   
  
  %** Formats and frequency var list for files before 1/1/02 **;
  
  %if &filedate < &D01JAN2002 %then %do;

    %note_mput( macro=&mname, msg=Using formats and frequency var list for files before 1/1/02 )
  
    %let format=
      deed_date CAMACondoPt_SALEDATE saledate mmddyy10.
      
      Usecode $Usecode.
      
      Saletype $Saletyp.;
      
    %let freqvars=
      CAMACondoPt_SALEDATE qdrntname del_code
      saletype usecode 
      zoning
      
      ;
 
  %end;
  
  %** Formats and frequency var list for files between 1/1/02 and 1/1/05 **;
  
  %if &D01JAN2002 <= &filedate < &D01JAN2005 %then %do;

    %note_mput( macro=&mname, msg=Using formats and frequency var list for files before 1/1/05 )
  
    %let format=
      deed_date CAMACondoPt_SALEDATE saledate mmddyy10.
      
      Usecode $Usecode.
      
      Saletype $Saletyp.;
      
    %let freqvars=
      CAMACondoPt_SALEDATE qdrntname 
      saletype usecode 
      
      ;
 
  %end;
 
  %** Formats and frequency var list for files between 3/24/05 and 3/30/13 **;
  
  %if &D31MAR2013 > &filedate >= &D24MAR2005 %then %do;
  
    %note_mput( macro=&mname, msg=Using formats and frequency var list for files on or after 3/24/05 )
  
    %let format=
      deed_date CAMACondoPt_SALEDATE saledate lastpaydt mmddyy10.
      Usecode $Usecode.
      ;
      
    %let freqvars=
      CAMACondoPt_SALEDATE QDRNTNAME 
      saletype_new usecode 
      ;
  
  %end;
  
  %** Formats and frequency var list for files on or after 3/31/13 **;
  
  %if &filedate >= &D31MAR2013 %then %do;
  
    %note_mput( macro=&mname, msg=Using formats and frequency var list for files on or after 3/31/13 )
  
    %let format=
      deed_date CAMACondoPt_SALEDATE saledate lastpaydt mmddyy10.
      
      Usecode $Usecode.
      
      Saletype $Saletyp. saletype_new $sltypnw. 
     ;
      
    %let freqvars=
      CAMACondoPt_SALEDATE QDRNTNAME
      saletype saletype_new usecode 
      
      ;
  
  %end;
  
  %** Copy format & freqvar parameters to Alpha **;
  
  /**%syslput format = &format;**/
  /**%syslput freqvars = &freqvars;**/
  
  run;

  %** List user-defined macro variables in remote session **;

  **rsubmit;
  
  %global dup_check_count;
  
  %put --- REMOTE MACRO VARS ---;
  %put _user_;
  
  run;
  
  **endrsubmit;
  
  ** Convert to SAS data set **;
  
  data CAMACondoPt;
  
    length SSL $ 17;
  
    set inf.&dsname (obs=&obs);
    
    if SALEDATE < '01jan1980'd then SALEDATE = .;

    %if not( ( &D01JAN2002 <= &filedate and &filedate < &D01JAN2003 ) or &D01FEB2004 <= &filedate ) %then %do;
      ssl = op_ssl;
      drop op_ssl;
    %end;
    
    ssl = left( upcase( ssl ) );
    
    attrib _all_ label=' ';
    format _all_ ;
    informat _all_ ;
    
    format saledate mmddyy10.;
  
    ** Record number **;
    
    RecordNo = _n_;
    
    label RecordNo = 'Record number (UI created)';
    
    ** CORRECTIONS FOR THIS EXTRACT ONLY! **;
    
    &corrections
    
    ** Correct ACCEPTCODE value **;
    
    if acceptcode = '1' then acceptcode = '01';
    
    
  
    ** Reformat files on or after 3/24/05 to correspond to earlier file format **;
  
    

    ***** NOTE:
    ***** NEED TO FIX RENAMING OF TAX VARIABLES AS YEARS CHANGE 
    ***** LOOK AT PY?YEAR VARIABLES TO GET YEARS FOR NEW VARIABLES 
    *****;

    rename 
      acceptcode = acceptcode_new
     
    ; 

    drop 
     
  
  run;

  /**************
  ** Upload to Alpha **;
  
  **rsubmit;
  
  %push_option( compress )
  
  options compress=no;
  
  proc upload status=no
    data=CAMACondoPt 
    out=CAMACondoPt;
    
  run;
  
  **endrsubmit;
  *****************/

  ** Display remote macro variables **;
  
  **rsubmit;
  
  
  **endrsubmit;
  
  ** Check for duplicates **;
  
  **rsubmit;
  
  title2 'Duplicate observations in input data';
  
  %dup_check( 
    data=CAMACondoPt, 
    by=ssl, 
    id=&dup_ids,
    count=,
    printnumdups=N,
    out=_dup_check_in
  )

  title2;
  
  run;
  
  ** Print list of duplicate record nos. in LOG **;

  data _null_;

    set _dup_check_in end=eof;
    by ssl;
    
    length line $ 84;
    
    line = repeat( '-', 84 );
    
    if _n_ = 1 then 
      put // line //
        "Duplicate RecordNo's: " @;
    
    if not first.ssl then put RecordNo @;
    
    if eof then 
      put /// line ///;
    
  run;

  proc datasets library=work memtype=(data) nolist nowarn;
    delete _dup_check_in;
  quit;
    
  run;

  **endrsubmit;

  %if &del_dup_recs_csv ~= %then %do;
      
    ** Delete records for duplicate parcels **;
    
    **rsubmit;
    
    data CAMACondoPt;
    
      set CAMACondoPt;
      
      if RecordNo in ( &del_dup_recs_csv ) then delete;
          
    run;
    
    **endrsubmit;

  %end;
  
  /*********************
  ** Copy data set labels include file to Alpha **;
  
  **rsubmit;
  
  proc upload status=no
    infile = "d:\dcdata\libraries\realprop\prog\Label_ownerpt.sas"
    outfile = "[DCDATA.REALPROP.PROG]Label_ownerpt.sas";
  run;
  
  ** Purge older file versions **;
  
  /**x "purge [dcdata.realprop.prog]Label_ownerpt.sas";**/
  
  run;

  **endrsubmit;
  ***************************/
  
  ** Create final CAMACondoPt extract file **;

  **rsubmit;
  
  %note_mput( macro=&mname, msg=)

  data &outfile (label="DC real property parcels update file, extract date &filedate_fmt");

    set CAMACondoPt (drop=SALEDATE);

    retain CAMACondoPt_SALEDATE &filedate;
    
    format _all_ ;
    informat _all_ ;
    
    format &format ;

    ** Date missing values **;
    
    if saledate <= '01jan1900'd or saledate > &filedate then do;
      if saleprice in ( 0, . ) then do;
        saledate = .n;
        saleprice = .n;
      end;
      else do;
        %warn_put( macro=&mname, 
                   msg="Invalid sale date (will be set to .U): " / RecordNo= ssl= saledate= 
                       "SALEDATE(unformatted)=" saledate best16. " " saleprice= );
        saledate = .u;
      end;
    end;
    
    ** NB:  Many deed dates are missing, so no sense in printing them to the log **;
    
    if deed_date <= '01jan1800'd or deed_date > &filedate 
      then do;
        deed_date = .u;
      end;
    
    ** Sale price missing values **;
    
    if saleprice in ( ., 0 ) then do;
      if saledate = .n then saleprice = .n;
      else if saleprice = . then saleprice = .u;
    end;
    
    
    ** Recode SALETYPE "00" to blank **;
    
    if saletype = "00" then saletype = "";
    
    ** Recode QDRNTNAME **;
    
    if qdrntname = "__" then qdrntname = "";
    
    ** UI property type code **;
    
    **%Ui_proptype**;

    ** Data set labels **;
    
    /**%include "[DCDATA.REALPROP.PROG]Label_CAMA.sas";**/
    %include "&_dcdata_r_path\RealProp\Prog\Updates\Label_CAMAcondo.sas";

  run;
    
  ** Sort by parcel number **;

  /**%pop_option( compress )**/

  proc sort data=&outfile out=RealPr_r.&outfile;
    by ssl;
    
  run;
  
  /*************
  ** Purge older file versions **;
  
  /**x "purge [dcdata.realprop.data]&outfile..*";**/
  
  run;
  ******************/

  ** Check for duplicates **;
  /*
  title2 "Duplicate parcels in final data set (RealProp.&outfile)";
  title3 "**** DUPLICATE PARCELS SHOULD BE REMOVED USING THE DEL_DUP_RECS= MACRO PARAMETER ****";
  
  %dup_check( 
    data=RealPr_r.&outfile, 
    by=ssl, 
    id=&dup_ids,
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
      %err_put( macro=&mname, msg=count "duplicate parcels were found in final output data set RealPr_r.&outfile." )
      %err_put( macro=&mname, msg="Duplicate parcels should be removed using the DEL_DUP_RECS= parameter." )
      %err_put( macro=&mname, msg="A list of duplicate parcels has been printed to the SAS output." )
    end;
  run;

  proc datasets library=work memtype=(data) nolist nowarn;
    delete _dup_check_: ;
  quit;
    
  run;
*/
  **endrsubmit;
  
  ** File descriptive info **;
  
  **rsubmit;
	options spool;
  %File_info( 
    data=RealPr_r.&outfile, 
    freqvars=&freqvars
  )
	options spool;
  proc freq data=RealPr_r.&outfile tables deed_date saledate / missing;
    format deed_date year. saledate yyq.;
	
  run;
  
  data RealPr_r.camacondopt;
	keep 	AC	AYB	BATHRM	BEDRM	BLDG_NUM	CNDTN	CNDTN_D	EXE_CODE	EXTWALL	EXTWALL_D	
			EYB	FIREPLACES	GBA	GRADE	GRADE_D	HEAT	HEAT_D	HF_BATHRM	INTWALL	INTWALL_D	
			KITCHENS	LANDAREA	LIVING	NUM_UNITS	OWNERNAME	OWNNAME2	PREMISEADD	
			PRICE	QUALIFIED	ROOF	ROOF_D	ROOMS	SALE_NUM	SALEDATE	SSL	STORIES	
			STRUCT	STRUCT_D	STYLE	STYLE_D	UNITNUMBER	USECODE	X_COORD	Y_COORD	YR_RMDL SECT_NUM Struct_Cl STRUCT_CL_ WALL_HGT;
	set RealPr_r.&outfile;
	Condo = 1;
  run;
  **endrsubmit;
  
  %** Comparison of parcels with previous file **;
  
  %if &prev_file ~= %then %do;
  
    **rsubmit;
  
    ** Comparison with previous extract file **;
      
    data _comp (compress=no);

      merge
        RealPr_r.&prev_file (keep=ssl ui_proptype in=_in_base)
        RealPr_r.&outfile (keep=ssl ui_proptype in=_in_comp);

      by ssl;

      in_base = _in_base;
      in_comp = _in_comp;

      **if ( in_base or in_comp ) and not( in_base and in_comp );
      
      old_parcels = 0;
      new_parcels = 0;
      
      if in_base and not in_comp then old_parcels = 1;
      if in_comp and not in_base then new_parcels = 1;
      
      chg_parcels = new_parcels - old_parcels;
      
      if ui_proptype = '' then ui_proptype = '99';

    run;
    
    proc format;
      value $uiprtsh
        '10' = 'Single-fam.'
        '11' = 'Condo'
        '12' = 'Coop'
        '13', '19' = 'Rental/ other'
        '20', '21', '22', '23', '24', '29' = 'Commercial'
        '30', '40' = 'Other'
        '50', '51' = 'Vacant'
        '99' = 'Unknown';
    
    proc tabulate data=_comp missing format=comma10.0;
      var in_base in_comp old_parcels new_parcels chg_parcels;
      class ui_proptype;
      table 
        in_base in_comp old_parcels new_parcels chg_parcels,
        sum=' ' * ( all='Total' ui_proptype=' ' ) /rts=54 condense;
      label
        in_base = "Total parcels in &prev_file"
        in_comp = "Total parcels in &outfile"
        old_parcels = "Parcels from &prev_file not in &outfile"
        new_parcels = "New parcels added in &outfile"
        chg_parcels = "Change in number of parcels";
      format ui_proptype $uiprtsh.;
      title2;
      title3 "Comparison of &outfile with &prev_file";
      
    run;
    
    title2;
    
    proc datasets library=work memtype=(data) nolist nowarn;
      delete _comp;
    quit;

    run;
    
    **endrsubmit;

  %end;
  %else %do;
  
    %note_mput( macro=&mname, msg=Previous CAMACondoPt file not specified (PREV_FILE=). )
    %note_mput( macro=&mname, msg=Comparison with previous CAMACondoPt will not be performed. )
 
  %end;
  
  %exit:
  
  %note_mput( macro=&mname, msg=Macro exiting. )

%mend Read_CAMACondoPt_macro;

/** End Macro Definition **/

