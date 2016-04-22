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

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )


*options obs=1000 ;

proc sort data = RealProp.owner_polygons_common_ownership out = owner_polygons_common_ownership_; by ssl; run;
proc sort data = Realprop.Condo_approval_lots out = Condo_approval_lots_; by ssl; run;
proc sort data = Realprop.Condo_relate_table out = Condo_relate_table_; by ssl; run;



/* Fix char/num issues */
data Condo_approval_lots_in;
	set Condo_approval_lots_;
	%macro makechar (var,l);
	fix_&var.=put(&var.,&l.);
	drop &var.;
	rename fix_&var.=&var.;
	%mend makechar;
	%makechar (gis_id,8.);
	%makechar (square,32.);
	%makechar (lot,10.);
	%makechar (ssl,18.);
run;


/* Fix char/num issues */
data Condo_relate_table_in;
	set Condo_relate_table_;

	%macro makechar (var,l);
	fix_&var.=put(&var.,&l.);
	drop &var.;
	rename fix_&var.=&var.;
	%mend makechar;
	%makechar (square,32.);
	%makechar (lot,10.);
	%makechar (address_id,10.);
	%makechar (assessment,10.);
	%makechar (oldtotal,9.);
	%makechar (newtotal,10.);
	%makechar (landarea,8.);
	%makechar (hstdcode,1.);
	%makechar (capcurr,13.);
	%makechar (phaseland,9.);
	%makechar (phasebuild,9.);
	%makechar (capprop,10.);
	%makechar (newland,9.);
	%makechar (newimpr,9.);
	%makechar (saleprice,11.);
	%makechar (saledate,10.);
	%makechar (ssl,18.);


run;



/*Combine condo files with owner_polygons_common_ownership */
data ply_condos;

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
  ssl $ 18;


  merge 
		owner_polygons_common_ownership_
	 	Condo_approval_lots_in
	  	Condo_relate_table_in;
  by ssl;
  /*
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

  ;*/

  keep
	acceptcode
	account_id
	act_lot
	arn
	complex
	computed_a
	computed_area_sf
	condo_bk
	condo_book
	condo_book_num
	condo_page
	condo_page_num
	condo_pg
	condo_regi
	condo_regime_num
	condolot
	conv_tol_1
	conv_tol_2
	conv_toler
	conv_tolerance_resolution
	conv_tolerance_type
	conv_tolerance_value
	dcgiscondolotplyarea
	dcgiscondolotplylen
	deeds
	delcode
	hstdcode
	is_rear_of
	is_theoret
	landarea
	marunitnum
	no_units
	o_lots
	proptype
	record_are
	record_area_sf
	recordatio
	recordation_dt
	recordlots
	recordlotsplyid
	regime
	regime_id
	res
	reservatio
	saletype_new
	shapearea
	shapelen
	squareplyi
	squareplyid
	uid_
	under_air
	under_rec
	under_tax
	underlies_
	underlies_condo



	  ;

run;






proc sort data = realprop.itspe_m nodupkey; by ssl; run;
proc sort data = ply_condos; by ssl; run;

data RealProp.OwnerPly_OwnerPt;
	merge realprop.itspe_m ply_condos;
	by ssl;
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

