/**************************************************************************
 Program:  Parcel_base_who_owns.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/25/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Autocall macro to create Parcel_base_who_owns data set.

 Modifications:
**************************************************************************/

%macro Parcel_base_who_owns( 
  RegExpFile=, 
  MaxExp=3000,  /** NOTE: This number should be larger than the number of rows in the above file **/
  Diagnostic_file=&_dcdata_default_path\RealProp\Prog\Updates\Parcel_base_who_owns_diagnostic.xls,
  inlib=RealProp,
  data=Parcel_base,
  outlib=RealProp,
  Finalize=Y, 
  Revisions= 
  );

  %local parcel_base_file_dtmf dtm dtmf;
  
  %if %length( &RegExpFile ) = 0 %then %do;
    %Err_mput( macro=Parcel_base_who_owns, msg=Must provide a regular expression file in RegExpFile=. )
    %goto Exit_macro;
  %end;

  ** Create default revisions= label **;
  
  %if %length( &revisions ) = 0 %then %do;
  
    proc sql noprint;
      select modate into :parcel_base_file_dtmf separated by ' '
      from dictionary.tables where libname="%upcase(&inlib)" and memname = "%upcase(&data)";
    quit;

    %let dtm = %sysfunc( inputn( &parcel_base_file_dtmf, anydtdtm. ) );
    %let dtmf = %sysfunc( putn( %sysfunc( datepart( &dtm ) ), worddatx12. ) ),%sysfunc( putn( %sysfunc( timepart( &dtm ) ), timeampm8. ) );
    %let revisions = Updated with Parcel_base (&dtmf).;
  
  %end;
  
  %put Revisions = &revisions;
  
  ** Read in regular expressions **;

  filename xlsfile "&RegExpFile" lrecl=2500;

  data RegExp (compress=no);
    length OwnerCat_re $ 3 RegExp $ 2000;
    infile xlsfile missover dsd firstobs=2;
    input OwnerCat_re RegExp;
    OwnerCat_re = put( 1 * OwnerCat_re, z3. );
    if RegExp = '' then stop;
    put OwnerCat_re= RegExp=;
  run;

  ** Add owner-occupied sale flag to Parcel records **;

  %create_own_occ( inlib=&inlib, inds=&data, outds=parcel_base_ownocc );

  ** Match regular expressions against owner data file **;

  data Parcel_base_who_owns (label="DC real property parcels - property owner types");

     set parcel_base_ownOcc;
              
     %ownername_full()

     length Ownercat OwnerCat1-OwnerCat&MaxExp $ 3;
     retain OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp num_rexp;
     array a_OwnerCat{*} $ OwnerCat1-OwnerCat&MaxExp;
     array a_re{*}     re1-re&MaxExp;

     ** Load & parse regular expressions **;
    if _n_ = 1 then do;
      i = 1;
     do until ( eof );
        set RegExp end=eof;
        a_OwnerCat{i} = OwnerCat_re;
        a_re{i} = prxparse( regexp );
        if missing( a_re{i} ) then do;
          putlog "Error" regexp=;
          stop;
        end;
        i = i + 1;
      end;

       num_rexp = i - 1;
       
    end;

    i = 1;
    match = 0;

   do while ( i <= num_rexp and not match );
      if prxmatch( a_re{i}, upcase( ownername_full ) ) then do;
        OwnerCat = a_OwnerCat{i};
        match = 1;
      end;

      i = i + 1;

    end;
    
    ** Assign codes for special cases **;
    
      if ownername_full ~= '' then do;
    
        ** Owner-occupied Single Family, Condo, and multifamily rental **;
    
        if ui_proptype='10' and OwnerCat in ( '', '030' ) and owner_occ_sale then Ownercat= '010';
    
         if ui_proptype in ( '11', '13' ) and OwnerCat in ( '', '030' ) and owner_occ_sale then Ownercat= '020';
    
        ** Cooperatives are owner-occupied (OwnerCat=20), unless special owner **;
        ** NOTE: PROBABLY NEED TO CHANGE THIS, MAYBE CREATE A SEPARATE OWNER CATEGORY FOR COOPS **;
    
        else if ui_proptype = '12' and OwnerCat in ( '', '030', '110' ) then do;
          OwnerCat = '020';
        end;
    
        else if OwnerCat in ( '', '030' ) then do;
          OwnerCat = '030';
        end;
    
    end;

    ** Separate corporate (110) into for profit & nonprofit by tax status **;
    
    if OwnerCat = '110' then do;
      if mix1txtype = 'TX' then OwnerCat = '115';
      else OwnerCat = '111';
    end;
    
    ownername_full = propcase( ownername_full );
    
    drop i match num_rexp regexp OwnerCat_re OwnerCat1-OwnerCat&MaxExp re1-re&MaxExp;
    
    label OwnerCat = 'Property owner type';
    
    format OwnerCat $owncat.;
    
    keep ssl premiseadd premiseadd_std premiseadd_m hstd_code OwnerCat 
         Ownername_full owneraddress owneraddress_std owneraddress_m address3 
         ui_proptype in_last_ownerpt Owner_occ_sale mix1txtype mix2txtype;

  run;


  **** Diagnostics ****;

  proc sort data=Parcel_base_who_owns (where=(Ownercat not in ( '010', '020', '030' )))
    out=Parcel_base_who_owns_diagnostic;
    by OwnerCat;
  run;

  ods listing close;
  ods tagsets.excelxp file="&diagnostic_file" style=Minimal options(sheet_interval='Bygroup' );

  proc freq data=Parcel_base_who_owns_diagnostic;
    by OwnerCat;
    tables Ownername_full / missing;
  run;

  ods tagsets.excelxp close;
  ods listing;
  
  %if %mparam_is_yes( &finalize ) %then %do;
  
    **** Finalize data set ****;
    
    %Finalize_data_set( 
    /** Finalize data set parameters **/
    data=Parcel_base_who_owns,
    out=Parcel_base_who_owns,
    outlib=&outlib,
    label="DC real property parcels - property owner types",
    sortby=ssl,
    /** Metadata parameters **/
    restrictions=None,
    revisions=%str(&revisions),
    /** File info parameters **/
    printobs=5,
    freqvars=OwnerCat Owner_occ_sale
    );
    
  %end;

  %Exit_macro:

%mend Parcel_base_who_owns;

