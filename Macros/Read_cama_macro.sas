/**************************************************************************
 Program:  Read_CAMAResPt_macro.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   B. Losoya
 Created:  3/4/2014
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Autocall macro for reading and processing CAMAResPt
 files (real property parcels) obtained from OCTO. (Adapted read ownerpt macro)

 Modifications: 04/15/14 LH - Removed unneeded code from ownerpt macro. Added camatype to macro. /

**************************************************************************/

/** Macro Read_CAMA_macro - Start Definition **/

%macro Read_CAMA_macro( 
  inpath= &_dcdata_r_path\RealProp\Raw,    /* Location of input file */
  infile= CAMAResPt,                             /* Name of input file */
  intype=dbf,                                  /* Type of input file (dbf, mdb) */
  intable=,                                    /* Input table (Access files only) */
  camatype=, 								/*Type of CAMA (ResPt, CondoPt, CommPt)*/
  outfilesuf=,                                 /* Suffix for output data set (used only if 2+ extracts in same month) */
  filemonth=,                                  /* Month of file extract (number) */
  fileyear=, 									/* Year of file extract (4-digits) */
  filedate=,									/* Full date of file extract (mmDDyyyy)*/
  obs=1000000000,                              /* Maximum obs. to process */
  corrections=,                                /* Corrections to be applied to this file */
  prev_file=,                                  /* Previous data set for building comparison (optional) */
  format=                                      /* Additional formats to be applied */
    saledate mmddyy10.  Usecode $Usecode.
    ,
  freqvars= bldg_num usecode cama_proptype 
    
  );
  
  %let mname=Read_CAMA_macro;
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
  
  ** Convert file from DBF or MDB format **;
  
  %if &intype = DBF %then %do;
    libname inf dbdbf "&inpath" ver=4 CAMA&camatype=&infile;
    %let dsname = CAMA&camatype;
  %end;
  %else %if &intype = MDB %then %do;
    %if &intable = %then %do;
      %err_mput( macro=&mname, msg=For Access database must provide a value for INTABLE= parameter. )
      %goto exit;
    %end;
    libname inf dbaccess "&inpath\&infile..mdb" CAMA&camatype="&intable";
    %let dsname = CAMA&camatype;
  %end;
  %else %if &intype = SAS7BDAT %then %do;
    libname inf "&inpath";
    %let dsname = &infile;
  %end;
  %else %do;
    %err_mput( macro=&mname, msg=Invalid value &INTYPE for INTYPE= parameter (must be DBF or MDB). )
    %goto exit;
  %end;
  
  /**%let filedate = &_max_SALEDATE; WHAT DOES NEED TO BE?
  %let filedate_fmt = &_max_SALEDATE_fmt;**/
  %let outfile = CAMA&camatype._&fileyear._%sysfunc( putn( &filemonth, z2. ) )&outfilesuf;
  
  %note_mput( macro=&mname, msg=Output data set is &outfile.. )
  
  /**%syslput outfile = &outfile;**/
  /**%syslput filedate = &filedate;**/
  /**%syslput filedate_fmt = &filedate_fmt;**/


    ** Convert to SAS data set **;
  
  data CAMA_readin;
  
    length SSL $ 17;
  
    set inf.&dsname (obs=&obs);
    
    if SALEDATE < '01jan1980'd then SALEDATE = .;

    
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

  run;

 ** Create final CAMAResPt extract file **;

 
  %note_mput( macro=&mname, msg=)

  data &outfile (label="DC CAMA &camatype update file, extract date &filemonth.-&fileyear.");

    set CAMA_readin ;
       
    format _all_ ;
    informat _all_ ;
    
    format &format ;

    ** Date missing values **;
    
    if saledate <= '01jan1900'd or saledate > &filedate then do;
      if price in ( 0, . ) then do;
        saledate = .n;
       price = .n;
      end;
      else do;
        %warn_put( macro=&mname, 
                   msg="Invalid sale date (will be set to .U): " / RecordNo= ssl= saledate= 
                       "SALEDATE(unformatted)=" saledate best16. " " price= );
        saledate = .u;
      end;
    end;
    
 
    ** Sale price missing values **;
    
    if price in ( ., 0 ) then do;
      if saledate = .n then price = .n;
      else if price = . then price = .u;
    end;
    
  
    ** Modified UI property type code **;
    
	  length cama_proptype $ 2;
	  
	  cama_proptype = put( usecode, $useuipt. );
	  
	  label cama_proptype = 'CAMA (UI-based) property type code';
	  
	  format cama_proptype $uiprtyp.;
	  



    ** Data set labels **;
    
    /**%include "[DCDATA.REALPROP.PROG]Label_CAMA.sas";**/
    %include "&_dcdata_r_path\RealProp\Prog\Updates\Label_CAMA&camatype..sas";

  run;
    
  ** Sort by parcel number **;

  /**%pop_option( compress )**/

  proc sort data=&outfile out=RealPr_r.&outfile;
    by ssl;
    
  run;
  

  
  ** File descriptive info **;
  
  **rsubmit;
	options spool;
  %File_info(data=RealPr_r.&outfile, 
    freqvars=&freqvars
  )
	options spool;

  
  
  %** Comparison of parcels with previous file **;
  
  /*%if &prev_file ~= %then %do;
  
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
  
    %note_mput( macro=&mname, msg=Previous CAMAResPt file not specified (PREV_FILE=). )
    %note_mput( macro=&mname, msg=Comparison with previous CAMAResPt will not be performed. )
 
  %end;*/
  
  %exit:
  
  %note_mput( macro=&mname, msg=Macro exiting. )

%mend Read_CAMA_macro;

/** End Macro Definition **/

