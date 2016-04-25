/**************************************************************************
 Program:  Create_new_ownerpt.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  4/1/16
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Combine ITS Public Extract files from opendata.dc.gov:
				1) Its_public_extract
				2) itspe_facts
			    3) itspe_property_sales

 Modifications:
 Output dataset: ownerpt_yyyy_mm
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )

** Date for ownerpt **;
%let ownerptdt = 2016_04;


/* Sort input datasets */
proc sort data = realprop.Its_public_extract out = Its_public_extract_in; by ssl; run;
proc sort data = realprop.Itspe_facts out = Itspe_facts_in ; by ssl; run;
proc sort data = realprop.Itspe_property_sales out = Itspe_property_sales_in; by ssl; run;


/* Merge ITS files */
data itspe_all;
	merge Its_public_extract_in Itspe_facts_in Itspe_property_sales_in;
	by ssl;

	%let filedate = extractdat;

	%Acceptcode_old()

	%let format=
      deed_date ownerpt_extractdat saledate mmddyy10.
      Proptype $proptyp.
      Usecode $Usecode.
      Hstdcode $homestd.
      MIXEDUSE del_code part_part yesno.
      Class_Type_3d Mix1class_3d Mix2class_3d $class3d.
      Mix1txtype Mix2txtype $taxtype.
      Acceptcode_old $accept.
      acceptcode $accptnw.
      Saletype $Saletyp. saletype_new $sltypnw. 
      nbhd $nbhd.;

    ** UI Record number **;
    
	RecordNo = _n_;
    label RecordNo = 'Record number (UI created)';

    ** Date missing values **;
    
    if saledate <= '01jan1900'd or saledate > &filedate then do;
      if saleprice in ( 0, . ) then do;
        saledate = .n;
        saleprice = .n;
      end;
      else do;
        %warn_put( macro=Create_new_ownerpt, 
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
	del_code = ndelcode; 
    
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
	part_part = npartpart;
    
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
  
    
      ** NBHDNAME **;
      
      length Nbhdname $ 30;
      
      Nbhdname = put( nbhd, $nbhd. );
    

	/* Variables from old ownerpt */
	ownerpt_extractdat = extractdat;
	no_units = coopunits;

  
 
	/* Fix capasscur and capasspro */
	capasscur = input( capcurr, best32. );
	capasspro = input( capprop, best32. );

  
	%ui_proptype

	format ownerpt_extractdat saledate mmddyy10.;
	
	length class_type_3d mix1class_3d mix2class_3d $ 3;

	class_type_3d = put(classtype,z3.);
	mix1class_3d = put(mix1class,z3.);
	mix2class_3d = put(mix2class,z3.);


	/* ITS files don't have X/Y coords, but need these variables for parcel_base and parcel_geo */
	x_coord = .;
	y_coord = .;



	/* Final renames to make consistent with old ownerpt*/
	rename appraised_value_prior_land = old_land
		   appraised_value_prior_impr = old_impr
		   appraised_value_prior_total = old_total
		   appraised_value_current_land = new_land
		   appraised_value_current_impr = new_impr
		   appraised_value_current_total = new_total
		   hstdcode = hstd_code
		   taxrate = tax_rate
		   owner_occupied_coop_units = no_ownocct
		   annualtax = amttax
		   reasoncd = reasoncode
		   acceptcode = acceptcode_new
		   class3ex_num = class3ex
		   subnbhd = sub_nbhd
		   acceptcode_old = acceptcode
		   asrname=asr_name
		   assessment= assess_val
		   CITYSTZIP = address3
;


	drop appraised_value_baseyear_bldg appraised_value_baseyear_land
	 	 assessor_name careof_name deeddate delcode
	 	 land_use_c land_use_d landarea_num last_sale_date lastmodifieddate
		 newimpr newland newtotal oldimpr oldland oldtotal objectid_1
		 ownocct phasebuild_num phaseland_num 
		 coopunits capcurr capprop classtype mixed_use
;


	format &format ;


run;


data realprop.ownerpt_&ownerptdt.;
	set itspe_all
	(drop = mixeduse saletype);

	rename nmixeduse=mixeduse;
	saletype = saletype_old;

	format saletype $SALETYP.;

	
	/* Label ownerpt */
	%include "&_dcdata_r_path\RealProp\Prog\Updates\Label_ownerpt.sas";

run;



%Dup_check(
  data=RealProp.ownerpt_&ownerptdt.,
  by=ssl,
  id=premiseadd,
  out=_dup_check,
  listdups=Y,
  count=dup_check_count
)



%File_info( data=realprop.ownerpt_&ownerptdt., printobs=5,
  freqvars=acceptcode acceptcode_new class3 class3ex del_code hstd_code 
           ownerpt_extractdat mix1class_3d mix2class_3d mix1txtype mix2txtype
           nbhd part_part pchildcode proptype qdrntname saletype_new sub_nbhd usecode vaclnduse
           ui_proptype
 )

run;


/* End of Program */
