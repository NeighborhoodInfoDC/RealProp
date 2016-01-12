/**************************************************************************
 Program:  Parcel_base_who_owns.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/12/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create ownership categories for real property parcels.
 
 NOTE: Workbook 
 "L:\Libraries\RealProp\Prog\Updates\Owner type codes & reg expr 09-28-11.xls"
 must be open in Excel before submitting this program.
 
 Runtime: Approximately 5 minutes.

 Modifications:
  10/12/14 PAT Updated for SAS1 server.
               Updated regular expressions to 09-28-11.
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp, local=n )

%let RegExpFile = Owner type codes & reg expr 09-28-11.xls;

%let MaxExp     = 2000;  /** NOTE: This number should be larger than the number of rows in the above spreadsheet **/

** Read in regular expressions **;

filename xlsfile dde "excel|&_dcdata_r_path\RealProp\Prog\[&RegExpFile]Sheet1!r2c1:r&MaxExp.c2" lrecl=256 notab;

data RegExp (compress=no);
  length OwnerCat_re $ 3 RegExp $ 2000;
  infile xlsfile missover dsd dlm='09'x;
  input OwnerCat_re RegExp;
  OwnerCat_re = put( 1 * OwnerCat_re, z3. );
  if RegExp = '' then stop;
  put OwnerCat_re= RegExp=;
run;

** Add owner-occupied sale flag to Parcel records **;

%create_own_occ( inlib=realprop, inds=parcel_base, outds=parcel_base_ownOcc );

** Match regular expressions against owner data file **;

data Realprop.Parcel_base_who_owns;

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
  
  keep ssl premiseadd premiseadd_std OwnerCat Ownername_full owneraddress owneraddress_std address3 ui_proptype in_last_ownerpt Owner_occ_sale mix1txtype mix2txtype;

run;

%File_info( data=Realprop.Parcel_base_who_owns, freqvars=OwnerCat )

run;


**** Diagnostics ****;

proc print data=Realprop.Parcel_base_who_owns (obs=100);
  where OwnerCat = '';
  by OwnerCat;
run;

proc sort data=Realprop.Parcel_base_who_owns (where=(Ownercat not in ( '010', '020', '030', '' )))
  out=Parcel_base_who_owns_diagnostic;
  by OwnerCat;
run;

ods listing close;
ods tagsets.excelxp file="L:\Libraries\RealProp\Prog\Updates\Parcel_base_who_owns_diagnostic.xls" style=Minimal options(sheet_interval='Bygroup' );

proc freq data=Parcel_base_who_owns_diagnostic;
  by OwnerCat;
  tables Ownername_full / missing;
run;

ods tagsets.excelxp close;
ods listing;

