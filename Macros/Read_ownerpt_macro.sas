/**************************************************************************
 Program:  Read_ownerpt_macro.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/08/05
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Autocall macro for reading and processing ownerpt
 files (real property parcels) obtained from OCTO.

 Modifications:
  04/06/05  Added USTREETNAME variable.  Recode HIGHNUMBER "0000" to "".
  04/07/05  Automatic extraction date.  Recode LOWNUMBER "0000" to "".
  04/14/05  Recode PROPTYPE, MIXEDUSE, DEL_CODE, PART_PART
            to match previous coding scheme.
            Renamed Class_Type_3d, Mix1class_3d, Mix2class_3d because
            of new 3-digit coding scheme.
            Drop EOR field.
            Added FORMAT= option.
  04/22/05  Added/corrected labels.
  04/27/05  Added corrections for BAY LN & MONTEREY LN.
  06/24/05  Incorporated reformatting of files 03/24/05 and later.
            Renamed CY* and PY* vars to old names.
            Created SALETYPE variable compatible with previous coding.  
            Renamed new SALETYPE to SALETYPE_NEW.
            Now processes file remotely on Alpha.
  06/27/05 PAT  Reports duplicate SSL numbers (%dup_check macro).
                Duplicate SSLs no longer automatically deleted 
                (should be done with CORRECTIONS=).
  06/28/05 PAT  Duplicate parcel records now deleted through CORRECTIONS=
                parameter.
                Purges older versions of data set.
  08/25/05 PAT  Freq table of saledate now formatted yyq. (year & qtr)
  03/14/05 PAT  Modified to read earlier Access files.
  03/23/06 PAT  Lots of modifications
  03/28/06 PAT  For files 03/2005 and after: reformatted var. ACCEPTCODE
                and renamed var. PRMSWARD.
                Correction for ACCEPTCODE = '1' -> '01'.
  01/23/07 PAT  Added support for input data being in SAS format (SAS7BDAT).
  06/18/07 PAT  Note if PREV_FILE= not specified.
  12/08/08 PAT  Added ACCEPTCODE='M7 MULTI-SPECULATIVE' recode to '07'.
  11/02/09 PAT  Added MIXEDUSE='S' (Class 2 split tax rate) recode to 'Y'.
                Added MIXEDUSE_NEW var. to retain original values.
  10/24/13 PAT  Corrections for Ownerpt files 3/31/13 or later:
                Remove references to missing vars inst_no, mortgageco, 
                eor, prmsward.
                Create nbhdname variable from nbhd.
                Add $nbhd. format to nbhd var.
  12/18/13 PAT  Adapted to SAS1 server. 
**************************************************************************/

/** Macro Read_ownerpt_macro - Start Definition **/

%macro Read_ownerpt_macro( 
  inpath= &_dcdata_r_path\RealProp\Raw,    /* Location of input file */
  infile= Ownerpt,                             /* Name of input file */
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
    deed_date ownerpt_extractdat saledate mmddyy10.
    Proptype $proptyp.
    Usecode $Usecode.
    Hstd_code $homestd.
    MIXEDUSE del_code part_part yesno.
    Class_Type Mix1class Mix2class Mix3class Mix4class $class.
    Mix1txtype Mix2txtype Mix3txtype Mix4txtype $taxtype.
    Acceptcode $accept.
    Saletype $Saletyp.,
  freqvars=
    ownerpt_extractdat qdrntname del_code
    saletype ui_proptype proptype usecode 
    Acceptcode hstd_code 
    Reasoncode ASSESSCODE noticecode
    no_ownocct no_units pchildcode part_part 
    Class_Type MIXEDUSE Mix1class Mix2class Mix3class Mix4class
    Mix1txtype Mix2txtype Mix3txtype Mix4txtype 
    class3ex
    sub_nbhd 

  );
  
  %let mname=Read_ownerpt_macro;
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
    libname inf dbdbf "&inpath" ver=4 ownerpt=&infile;
    %let dsname = ownerpt;
  %end;
  %else %if &intype = MDB %then %do;
    %if &intable = %then %do;
      %err_mput( macro=&mname, msg=For Access database must provide a value for INTABLE= parameter. )
      %goto exit;
    %end;
    libname inf dbaccess "&inpath\&infile..mdb" ownerpt="&intable";
    %let dsname = ownerpt;
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
    select min(extractdat), max(extractdat)
      into :_min_extractdat, :_max_extractdat
    from inf.&dsname (obs=1000)
    where extractdat > '01jan2001'd;
    quit;
  run;
  
  /**%syslput _min_extractdat=&_min_extractdat;**/
  /**%syslput _max_extractdat=&_max_extractdat;**/

  data _null_;
    call symput("_min_extractdat_fmt",left(put(&_min_extractdat,mmddyy10.)));
    call symput("_max_extractdat_fmt",left(put(&_max_extractdat,mmddyy10.)));
  run;
  
  %put _min_extractdat=&_min_extractdat_fmt;
  %put _max_extractdat=&_max_extractdat_fmt;
  
  %if &_min_extractdat ~= &_max_extractdat or &_max_extractdat = . %then %do;
    %warn_mput( macro=&mname, msg=File extraction dates (EXTRACTDAT) are not consistent: &_min_extractdat_fmt to &_max_extractdat_fmt )
    %warn_mput( macro=&mname, msg=&_max_extractdat_fmt will be used as the file extraction date. )
  %end;
  
  %let filemonth = %sysfunc( month( &_max_extractdat ) );
  %let fileyear = %sysfunc( year( &_max_extractdat ) );
  %let filedate = &_max_extractdat;
  %let filedate_fmt = &_max_extractdat_fmt;
  %let outfile = Ownerpt_&fileyear._%sysfunc( putn( &filemonth, z2. ) )&outfilesuf;
  
  %note_mput( macro=&mname, msg=Output data set is &outfile.. )
  
  /**%syslput outfile = &outfile;**/
  /**%syslput filedate = &filedate;**/
  /**%syslput filedate_fmt = &filedate_fmt;**/

  %** List of ID vars for duplicate parcel check **;
  
  %if ( &D01JAN2002 <= &filedate and &filedate < &D01JAN2003 ) or &D01FEB2004 <= &filedate %then 
    %let dup_ids = recordno del_code premiseadd unitnumber x_coord y_coord assess_val saledate saleprice;
  %else 
    %let dup_ids = recordno del_code premiseadd unitnumber assess_val saledate saleprice;

  /**%syslput dup_ids = &dup_ids;**/   
  
  %** Formats and frequency var list for files before 1/1/02 **;
  
  %if &filedate < &D01JAN2002 %then %do;

    %note_mput( macro=&mname, msg=Using formats and frequency var list for files before 1/1/02 )
  
    %let format=
      deed_date ownerpt_extractdat saledate mmddyy10.
      Proptype $proptyp.
      Usecode $Usecode.
      Hstd_code $homestd.
      MIXEDUSE del_code part_part yesno.
      Class_Type Mix1class Mix2class Mix3class Mix4class $class.
      Mix1txtype Mix2txtype Mix3txtype Mix4txtype $taxtype.
      Acceptcode $accept.
      Saletype $Saletyp.;
      
    %let freqvars=
      ownerpt_extractdat qdrntname del_code
      saletype ui_proptype proptype usecode 
      zoning
      Acceptcode hstd_code 
      Reasoncode ASSESSCODE noticecode
      no_ownocct no_units pchildcode part_part 
      Class_Type MIXEDUSE Mix1class Mix2class Mix3class Mix4class
      Mix1txtype Mix2txtype Mix3txtype Mix4txtype 
      sub_nbhd;
 
  %end;
  
  %** Formats and frequency var list for files between 1/1/02 and 1/1/05 **;
  
  %if &D01JAN2002 <= &filedate < &D01JAN2005 %then %do;

    %note_mput( macro=&mname, msg=Using formats and frequency var list for files before 1/1/05 )
  
    %let format=
      deed_date ownerpt_extractdat saledate mmddyy10.
      Proptype $proptyp.
      Usecode $Usecode.
      Hstd_code $homestd.
      MIXEDUSE del_code part_part yesno.
      Class_Type Mix1class Mix2class Mix3class Mix4class $class.
      Mix1txtype Mix2txtype Mix3txtype Mix4txtype $taxtype.
      Acceptcode $accept.
      Saletype $Saletyp.;
      
    %let freqvars=
      ownerpt_extractdat qdrntname del_code
      saletype ui_proptype proptype usecode 
      Acceptcode hstd_code 
      Reasoncode ASSESSCODE noticecode
      no_ownocct no_units pchildcode part_part 
      Class_Type MIXEDUSE Mix1class Mix2class Mix3class Mix4class
      Mix1txtype Mix2txtype Mix3txtype Mix4txtype 
      sub_nbhd;
 
  %end;
 
  %** Formats and frequency var list for files between 3/24/05 and 3/30/13 **;
  
  %if &D31MAR2013 > &filedate >= &D24MAR2005 %then %do;
  
    %note_mput( macro=&mname, msg=Using formats and frequency var list for files on or after 3/24/05 )
  
    %let format=
      deed_date ownerpt_extractdat saledate lastpaydt mmddyy10.
      Proptype $proptyp.
      Usecode $Usecode.
      Hstd_code $homestd.
      MIXEDUSE del_code part_part yesno.
      class3 $yesno.
      Class_Type_3d Mix1class_3d Mix2class_3d $class3d.
      Mix1txtype Mix2txtype $taxtype.
      Acceptcode $accept.
      acceptcode_new $accptnw.
      Saletype $Saletyp. saletype_new $sltypnw. 
      nbhd $nbhd.;
      
    %let freqvars=
      ownerpt_extractdat QDRNTNAME del_code 
      saletype saletype_new ui_proptype proptype usecode 
      Acceptcode acceptcode_new hstd_code 
      Reasoncode /*ASSESSCODE noticecode*/
      no_ownocct no_units pchildcode part_part 
      Class_Type_3d MIXEDUSE Mix1class_3d Mix2class_3d /*Mix3class Mix4class*/
      Mix1txtype Mix2txtype /*Mix3txtype Mix4txtype*/ 
      class3 class3ex
      sub_nbhd prms_ward;
  
  %end;
  
  %** Formats and frequency var list for files on or after 3/31/13 **;
  
  %if &filedate >= &D31MAR2013 %then %do;
  
    %note_mput( macro=&mname, msg=Using formats and frequency var list for files on or after 3/31/13 )
  
    %let format=
      deed_date ownerpt_extractdat saledate lastpaydt mmddyy10.
      Proptype $proptyp.
      Usecode $Usecode.
      Hstd_code $homestd.
      MIXEDUSE del_code part_part yesno.
      class3 $yesno.
      Class_Type_3d Mix1class_3d Mix2class_3d $class3d.
      Mix1txtype Mix2txtype $taxtype.
      Acceptcode $accept.
      acceptcode_new $accptnw.
      Saletype $Saletyp. saletype_new $sltypnw. 
      nbhd $nbhd.;
      
    %let freqvars=
      ownerpt_extractdat QDRNTNAME del_code 
      saletype saletype_new ui_proptype proptype usecode 
      Acceptcode acceptcode_new hstd_code 
      Reasoncode /*ASSESSCODE noticecode*/
      no_ownocct no_units pchildcode part_part 
      Class_Type_3d MIXEDUSE Mix1class_3d Mix2class_3d /*Mix3class Mix4class*/
      Mix1txtype Mix2txtype /*Mix3txtype Mix4txtype*/ 
      class3 class3ex
      nbhd sub_nbhd;
  
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
  
  data Ownerpt;
  
    length SSL $ 17;
  
    set inf.&dsname (obs=&obs);
    
    if extractdat < '01jan1980'd then extractdat = .;

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
    
    %if &filedate >= &D24MAR2005 %then %do;
  
    ** Reformat files on or after 3/24/05 to correspond to earlier file format **;
  
    ** Recode MIXEDUSE **;
    
    select ( upcase( mixeduse ) );
      when ( "Y", "S" )
        nmixeduse = 1;
      when ( "N" )
        nmixeduse = 0;
      when ( "" )
        nmixeduse = .u;
      otherwise do;
        %warn_put( msg="MIXEDUSE value unknown:  " MIXEDUSE )
      end;
    end;        
    
    ** Recode DEL_CODE **;
    
    select ( upcase( delcode ) );
      when ( "Y" )
        ndelcode = 1;
      when ( "N" )
        ndelcode = 0;
      when ( "" )
        ndelcode = .u;
      otherwise do;
        %warn_put( msg="DELCODE value unknown:  " delcode )
      end;
    end;        
    
    ** Recode PARTPART **;
    
    select ( upcase( partpart ) );
      when ( "Y" )
        npartpart = 1;
      when ( "N" )
        npartpart = 0;
      when ( "" )
        npartpart = .u;
      otherwise do;
        %warn_put( msg="PARTPART value unknown:  " partpart )
      end;
    end;        
    
    ** Recode PROPTYPE **;
    
    length aproptype $ 1;
    
    select ( upcase( proptype ) );
      when ( "COMMERCIAL" )
        aproptype = "2";
      when ( "FLATS/CONVERSIONS" )
        aproptype = "4";
      when ( "GARAGE/UNIMPROVED LAND" )
        aproptype = "6";
      when ( "HOTELS/MOTELS" )
        aproptype = "5";
      when ( "RESIDENTIAL-MULTI FAMILY" )
        aproptype = "3";
      when ( "RESIDENTIAL-SINGLE FAMILY" )
        aproptype = "1";
      when ( "" )
        aproptype = "";
      otherwise do;
        %warn_put( msg="PROPTYPE value unknown:  " proptype )
      end;
    end;
    
    label aproptype = "Type of property";
    format aproptype $proptyp.;
    
    ** Recode SALETYPE **;
    
    length saletype_old $ 2 saletype_new $ 1;

    select ( saletype );
      when ( 'I - IMPROVED' )
        saletype_new = 'I';
      when ( 'V - VACANT' )
        saletype_new = 'V';
      when ( '' )
        saletype_new = '';
      otherwise do;
        %warn_put( msg='SALETYPE value unknown: ' saletype )
      end;
    end;

    if acceptcode in: ( 'M1', 'M2', 'M3', 'M4', 'M5', 'M6', 'M7', 'M8', 'M9' ) then do;
      saletype_old = '03';
    end;
    else do;
      select ( saletype_new );
        when ( 'I' )
          saletype_old = '01';
        when ( 'V' )
          saletype_old = '02';
        when ( '' )
          saletype_old = '';
        otherwise do;
          %warn_put( msg='SALETYPE_NEW value unknown: ' recordno= ssl= saletype= saletype_new= )
        end;
      end;
    end;
    
    ** Recode ACCEPTCODE **;
    
    length acceptcode_old $ 2;
    
    select ( acceptcode );
      when ( 'BUYER=SELLER' ) acceptcode_old = '03';
      when ( 'FORECLOSURE' ) acceptcode_old = '05';
      when ( 'GOVT PURCHASE' ) acceptcode_old = '06';
      when ( 'LANDSALE' ) acceptcode_old = '09';
      when ( 'M1 MULTI-VERIFIED SALE' ) acceptcode_old = '98';
      when ( 'M2 MULTI-UNASSESSED' ) acceptcode_old = '02';
      when ( 'M3 MULTI-BUYER-SELLER' ) acceptcode_old = '03';
      when ( 'M4 MULTI-UNUSUAL' ) acceptcode_old = '04';
      when ( 'M5 MULTI-FORECLOSURE' ) acceptcode_old = '05';
      when ( 'M6 MULTI-GOVT PURCHASE' ) acceptcode_old = '06';
      when ( 'M7 MULTI-SPECULATIVE' ) acceptcode_old = '07';
      when ( 'M8 MULTI-MISC' ) acceptcode_old = '08';
      when ( 'M9 MULTI-LAND SALE' ) acceptcode_old = '09';
      when ( 'MARKET' ) acceptcode_old = '01';
      when ( 'MISC' ) acceptcode_old = '08';
      when ( 'SPECULATIVE' ) acceptcode_old = '07';
      when ( 'TAX DEED' ) acceptcode_old = '98';
      when ( 'UNASSESSED' ) acceptcode_old = '02';
      when ( 'UNUSUAL' ) acceptcode_old = '04';
      when ( '' ) acceptcode_old = '';
      otherwise do;
        %warn_put( msg='ACCEPTCODE value unknown: ' recordno= ssl= acceptcode= )
      end;
    end;
    
    %if &filedate >= &D31MAR2013 %then %do;
    
      ** NBHDNAME **;
      
      length Nbhdname $ 30;
      
      Nbhdname = put( nbhd, $nbhd. );
      
    %end;

    ***** NOTE:
    ***** NEED TO FIX RENAMING OF TAX VARIABLES AS YEARS CHANGE 
    ***** LOOK AT PY?YEAR VARIABLES TO GET YEARS FOR NEW VARIABLES 
    *****;

    rename 
      acceptcode = acceptcode_new
      acceptcode_old = acceptcode
      annualtax = amttax
      ownocct = no_ownocct
      coopunits = no_units 
      oldtotal = old_total 
      oldimpr = old_impr
      oldland = old_land
      newtotal = new_total 
      newimpr = new_impr
      newland = new_land
      assessment = assess_val
      asrname = asr_name
      citystzip = address3
      reasoncd = reasoncode
      hstdcode = hstd_code
      classtype = class_type_3d
      mix1class = mix1class_3d 
      mix2class = mix2class_3d
      %if &filedate < &D31MAR2013 %then %do;
        prmsward = prms_ward
        instno = inst_no
      %end;
      taxrate = tax_rate
      deeddate = deed_date
      subnbhd = sub_nbhd
      ndelcode = del_code
      npartpart = part_part
      nmixeduse = mixeduse
      mixeduse = mixeduse_new
      aproptype = proptype
      saletype_old = saletype
      capcurr=capasscur
      capprop=capasspro
      py1year=desc_04
      py2year=desc_03
      py3year=desc_02
      py4year=desc_01
      py5year=desc_00
      py6year=desc_99
      py7year=desc_98
      py8year=desc_97
      py9year=desc_96
      py10year=desc_95x
      py1fee=totfee_04
      py2fee=totfee_03
      py3fee=totfee_02
      py4fee=totfee_01
      py5fee=totfee_00
      py6fee=totfee_99
      py7fee=totfee_98
      py8fee=totfee_97
      py9fee=totfee_96
      py10fee=totfee_95x
      py1bal=bal_04
      py2bal=bal_03
      py3bal=bal_02
      py4bal=bal_01
      py5bal=bal_00
      py6bal=bal_99
      py7bal=bal_98
      py8bal=bal_97
      py9bal=bal_96
      py10bal=bal_95x
      py1txsale=sflag_04
      py2txsale=sflag_03
      py3txsale=sflag_02
      py4txsale=sflag_01
      py5txsale=sflag_00
      py6txsale=sflag_99
      py7txsale=sflag_98
      py8txsale=sflag_97
      py9txsale=sflag_96
      py10txsale=sflag_95x
      py1tax=tax_04
      py2tax=tax_03
      py3tax=tax_02
      py4tax=tax_01
      py5tax=tax_00
      py6tax=tax_99
      py7tax=tax_98
      py8tax=tax_97
      py9tax=tax_96
      py10tax=tax_95x
      py1pen=pen_04
      py2pen=pen_03
      py3pen=pen_02
      py4pen=pen_01
      py5pen=pen_00
      py6pen=pen_99
      py7pen=pen_98
      py8pen=pen_97
      py9pen=pen_96
      py10pen=pen_95x
      py1int=int_04
      py2int=int_03
      py3int=int_02
      py4int=int_01
      py5int=int_00
      py6int=int_99
      py7int=int_98
      py8int=int_97
      py9int=int_96
      py10int=int_95x
      py1coll=coll_04
      py2coll=coll_03
      py3coll=coll_02
      py4coll=coll_01
      py5coll=coll_00
      py6coll=coll_99
      py7coll=coll_98
      py8coll=coll_97
      py9coll=coll_96
      py10coll=coll_95x
      py1totdue=totdue_04
      py2totdue=totdue_03
      py3totdue=totdue_02
      py4totdue=totdue_01
      py5totdue=totdue_00
      py6totdue=totdue_99
      py7totdue=totdue_98
      py8totdue=totdue_97
      py9totdue=totdue_96
      py10totdue=totdue_95x
      cy1bal=bal_05_1
      cy1coll=coll_05_1
      cy1fee=totfee_05_1
      cy1int=int_05_1
      cy1pen=pen_05_1
      cy1tax=tax_05_1
      cy1totdue=totdue_05_1
      cy1txsale=sflag_05_1
      cy1year=desc_05_1
      cy2bal=bal_05_2
      cy2coll=coll_05_2
      cy2fee=totfee_05_2
      cy2int=int_05_2
      cy2pen=pen_05_2
      cy2tax=tax_05_2
      cy2totdue=totdue_05_2
      cy2txsale=sflag_05_2
      cy2year=desc_05_2
    ; 

    drop 
      %if &filedate < &D31MAR2013 %then %do;
        eor 
      %end;
      proptype delcode partpart saletype;
    
  %end;
  
  run;

  /**************
  ** Upload to Alpha **;
  
  **rsubmit;
  
  %push_option( compress )
  
  options compress=no;
  
  proc upload status=no
    data=Ownerpt 
    out=Ownerpt;
    
  run;
  
  **endrsubmit;
  *****************/

  ** Display remote macro variables **;
  
  **rsubmit;
  
  run;
  
  **endrsubmit;
  
  ** Check for duplicates **;
  
  **rsubmit;
  
  title2 'Duplicate observations in input data';
  
  %dup_check( 
    data=Ownerpt, 
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
    
    data Ownerpt;
    
      set Ownerpt;
      
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
  
  ** Create final Ownerpt extract file **;

  **rsubmit;
  
  %note_mput( macro=&mname, msg=Ignore any uninitialized variable messages that may appear below. )

  data &outfile (label="DC real property parcels update file, extract date &filedate_fmt");

    set Ownerpt (drop=extractdat);

    retain OWNERPT_EXTRACTDAT &filedate;
    
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
    
    ** Cleaned street name **;
    
    length ustreetname $ 40;

    ustreetname = left( compbl( upcase( streetname ) ) );

    select ( ustreetname );
      when ( "MANSION COURT" )
        ustreetname = "MANSION CT";
      when ( "OXON RUN ROAD" )
        ustreetname = "OXON RUN RD";
      when ( "BAY LN" )
        ustreetname = "BAY LA";
      when ( "MONTEREY LN" )
        ustreetname = "MONTEREY LA";
      otherwise
        ;
    end;

    label ustreetname = "UI-cleaned street name";
    
    ** Recode LOWNUMBER, HIGHNUMBER = "0000" to "" **;
    
    if lownumber = "0000" then lownumber = "";
    if highnumber = "0000" then highnumber = "";
    
    ** Recode SALETYPE "00" to blank **;
    
    if saletype = "00" then saletype = "";
    
    ** Recode QDRNTNAME **;
    
    if qdrntname = "__" then qdrntname = "";
    
    ** UI property type code **;
    
    %Ui_proptype

    ** Data set labels **;
    
    /**%include "[DCDATA.REALPROP.PROG]Label_ownerpt.sas";**/
    %include "&_dcdata_r_path\RealProp\Prog\Updates\Label_ownerpt.sas";

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

  **endrsubmit;
  
  ** File descriptive info **;
  
  **rsubmit;

  %File_info( 
    data=RealPr_r.&outfile, 
    freqvars=&freqvars
  )

  proc freq data=RealPr_r.&outfile;
    tables deed_date saledate / missing;
    %if &filedate < &D31MAR2013 %then %do;
      tables nbhdname * nbhd / missing list;
    %end;
    format deed_date year. saledate yyq.;

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
  
    %note_mput( macro=&mname, msg=Previous Ownerpt file not specified (PREV_FILE=). )
    %note_mput( macro=&mname, msg=Comparison with previous Ownerpt will not be performed. )
 
  %end;
  
  %exit:
  
  %note_mput( macro=&mname, msg=Macro exiting. )

%mend Read_ownerpt_macro;

/** End Macro Definition **/

