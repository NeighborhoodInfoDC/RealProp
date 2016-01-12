/**************************************************************************
 Program:  Who_owns_Parcel_base_new.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/13/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Create ownership categories for real property parcels.
 
 This Excel workbook must be open before running program:
 D:\DCData\Libraries\RealProp\Prog\Owner type codes & reg expr 02-16-11.xls

 Modifications:
 12/15/10 PAT  Made corrections to matching code.
 09/04/14 MSW  Modified program for SAS1 Server
**************************************************************************/

**%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
**%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;
%DCData_lib( RealProp )
%let RegExpFile = Owner type codes & reg expr 09-18-11;
%let MaxExp     = 1000;
**%syslput MaxExp=&MaxExp;
**options SORTPGM=SAS MSGLEVEL=I;

** Read in regular expressions **;

**filename xlsfile dde "excel|&_dcdata_path\RealProp\Prog\[&RegExpFile]Sheet1!r2c1:r&MaxExp.c2" lrecl=256 notab;
filename txtfile "&_dcdata_path\realprop\Prog\&RegExpFile..txt";

data RegExp (compress=no);
  length OwnerCat_re $ 3 RegExp $ 1000;
  infile txtfile missover dsd dlm='09'x;
  input OwnerCat_re RegExp;
  OwnerCat_re = put( 1 * OwnerCat_re, z3. );
  if RegExp = '' then stop;
  put OwnerCat_re= RegExp=;
run;

** Upload regular expressions **;

**rsubmit;

**proc upload status=no
  data=RegExp 
  out=RegExp (compress=no);
**run;

** Add owner-occupied sale flag to Parcel records **;

%create_own_occ( inlib=realprop, inds=parcel_base, outds=parcel_base_ownOcc );

** Match regular expressions against owner data file **;

data Who_owns2;

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

run;

** Download final file **;

**proc download status=no
  data=Who_owns2 
  out=Who_owns2 (label="Who owns the neighborhood analysis file, source Parcel Base");
**run;

**endrsubmit;

data realprop.who_owns;
set who_owns2;
run;

