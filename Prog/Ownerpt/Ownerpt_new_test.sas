/**************************************************************************
 Program:  Ownerpt_new_test.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/18/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Test creation of Ownerpt file from new VPM data sets.

 Modifications:
**************************************************************************/

/**%include "L:\SAS\Inc\StdLocal.sas";**/
%include "C:\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )


*options obs=1000;

data RealProp.OwnerPly_OwnerPt;

  length class3ex_num 3 del_code landarea_num 8 lottype $ 1 
  mix1bldval_num mix1lndval_num mix2bldval_num mix2lndval_num 6
  new_impr new_land new_total old_impr old_land old_total 6
  no_units 4
  part_part 8
  phasebuild_num phaseland_num 6
  premiseadd $ 44
  saledate_num saleprice_num 8 
  saletype_new $ 1
  square $ 4
  ssl $ 17

;

  set RealProp.owner_polygons_common_ownership;
  
  %Acceptcode_old()
  
  class3ex_num = input( class3ex, best32. );

  select ( upcase( delcode ) );
    when ( 'Y' )
      del_code = 1;
    when ( 'N' )
      del_code = 0;
    otherwise
      del_code = .u;
  end;

  ownerpt_extractdat = input( scan(upcase(extractdat), 1, 'T' ), yymmdd10. );
  
  landarea_num = input( landarea, best32. );
  
  lottype = put( lot_type, 1. );
  
  mix1bldval_num = input( mix1bldval, best32. );
  mix1lndval_num = input( mix1lndval, best32. );
  mix2bldval_num = input( mix2bldval, best32. );
  mix2lndval_num = input( mix2lndval, best32. );
  
  new_impr = input( newimpr, best32. );
  new_land = input( newland, best32. );
  new_total = input( newtotal, best32. );
  
  old_impr = input( oldimpr, best32. );
  old_land = input( oldland, best32. );
  old_total = input( oldtotal, best32. );
  
  no_units = input( coopunits, best32. );

  select ( upcase( partpart ) );
    when ( 'Y' )
      part_part = 1;
    when ( 'N' )
      part_part = 0;
    otherwise
      part_part = .u;
  end;
  
  phasebuild_num = input( phasebuild, best32. );
  phaseland_num = input( phaseland, best32. );
  
  saledate_num = input( scan( upcase( saledate ), 1, 'T' ), yymmdd10. );
  saleprice_num = input( saleprice, best32. );
  
  saletype_new = left( upcase( saletype ) );
  
  %ui_proptype

  format ownerpt_extractdat saledate_num mmddyy10.;
  
  rename 
    acceptcode = acceptcode_new
    acceptcode_old = acceptcode
    annualtax = amttax
    class3ex_num = class3ex
    hstdcode = hstd_code
    instno = inst_no
    landarea_num = landarea
    mix1bldval_num = mix1bldval
    mix1class = mix1class_3d 
    mix2class = mix2class_3d
    mix1lndval_num = mix1lndval
    mix2bldval_num = mix2bldval
    mix2lndval_num = mix2lndval
    mixeduse = mixeduse_new
    phasebuild_num = phasebuild
    phaseland_num = phaseland
    saledate_num = saledate
    saleprice_num = saleprice
          subnbhd = sub_nbhd
      taxrate = tax_rate

  ;
  
  keep 
  ssl premiseadd
  abtlotcode
acceptcode
acceptcode_old
address1
address2
annualtax
arn
careofname
class3
class3ex_num
cy1cr
cy2cr
del_code
ownerpt_extractdat 
hstdcode
instno
landarea_num
lottype
highnumber lownumber

mix1bldpct
mix1bldval_num
mix1class
mix1lndpct
mix1lndval_num
mix1rate
mix1txtype
mix2bldpct
mix2bldval_num
mix2class
mix2lndpct
mix2lndval_num
mix2rate
mix2txtype

mixeduse
mortgageco
nbhd
new_impr new_land new_total
old_impr old_land old_total
no_units
ownername
ownname2
part_part
pchildcode
phasebuild_num
phaseland_num
prmsward
proptype
qdrntname
saledate_num
saleprice_num
saletype_new
streetcode
streetname
subnbhd
suffix
taxrate 
unitnumber
usecode
vaclnduse

ui_proptype

/** NEW VARS **/
condo_regi
condolot
cy1: 
cy2:
py:

;
  

run;

proc sort data=RealProp.OwnerPly_OwnerPt;
  by ssl;
  
%Dup_check(
  data=RealProp.OwnerPly_OwnerPt,
  by=ssl,
  id=premiseadd,
  out=_dup_check,
  listdups=Y,
  count=dup_check_count
)

%File_info( data=RealProp.OwnerPly_OwnerPt, printobs=5,
  freqvars=acceptcode acceptcode_new class3 class3ex condolot del_code hstd_code 
           ownerpt_extractdat lottype mix1class_3d mix2class_3d mix1txtype mix2txtype
           nbhd part_part pchildcode proptype qdrntname saletype_new sub_nbhd usecode vaclnduse
           ui_proptype





 )

%Compare_file_struct( 
  lib=RealProp, 
  file_list=
    ownerpt_2014_01 OwnerPly_OwnerPt
  )


proc compare base=RealProp.ownerpt_2014_01 compare=RealProp.OwnerPly_OwnerPt maxprint=(40,32000);
  id ssl;
run;

