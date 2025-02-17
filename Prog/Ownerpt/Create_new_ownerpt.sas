/**************************************************************************
 Program:  Create_new_ownerpt.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  5/11/2020
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)

 Description:  Combine ITS Public Extract files from opendata.dc.gov:
                1) Its_public_extract
                2) itspe_facts
                3) Cama_property_sales

 Modifications: 06/24/22 - In 2022 DC Open Data replaced the replaced ITSPE property sales file 
						with Tax System Property Sales (CAMA). New new CAMA sales file is different
						because it does not include information about the owner or the property
						itself. It is also different because it is a historic file with multiple 
						sales per property (and therefore duplicate SSLs). 
 Output dataset: ownerpt_yyyy_mm
		
**************************************************************************/

%include "\\sas1\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )

** Date for ownerpt **;

%let ownerptdt = 2024_05;


/* Sort input ITSPE datasets */
proc sort data = realprop.Its_public_extract out = Its_public_extract_in; by ssl; run;
proc sort data = realprop.Itspe_facts out = Itspe_facts_in ; by ssl; run;


/* Setup CAMA sales file to keep the most recent sale per SSL */
proc sort data = realprop.Cama_property_sales out = Cama_property_sales; by ssl sale_date; run;

data Cama_property_sales_nd; 
	set Cama_property_sales; 
	by ssl sale_date; 
	if last.ssl;
run;


/* Merge ITS and CAMA files */
data itspe_all;
	merge Its_public_extract_in Itspe_facts_in Cama_property_sales_nd;
    by ssl;

    %let filedate = extractdat;

	saletype = upcase(saletype);
	acceptcode = upcase(acceptcode);

	** Re-code acceptcode **;
	%let dyr = %substr(&ownerptdt,1,4);
    %Acceptcode_old(datayear=&dyr.)

	** Re-code proptype **;
	%Proptype_old;

    %let format=
      deed_date ownerpt_extractdat saledate mmddyy10.
      Proptype Proptype_old $proptyp.
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

    select ( upcase(saletype) );
      when ( 'IMPROVED' )
        saletype_new = 'I';
      when ( 'VACANT' )
        saletype_new = 'V';
      when ( '' )
        saletype_new = '';
      otherwise do;
        %warn_put( msg='SALETYPE value unknown: ' saletype )
      end;
    end;

    if acceptcode in: ( 'MULTI' ) then do;
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

	** Fix usecode **;
	if usecode in ("  ."," .",".") then usecode = "";

	** Fix QDRNTNAME **;
	if QDRNTNAME in ("0") then QDRNTNAME = "";

    ** Recode ACCEPTCODE **;

    length acceptcode_old $ 2;

    select (  upcase(acceptcode) );
      when ( 'BUYER = SELLER' ) acceptcode_old = '03';
      when ( 'FORECLOSURE' ) acceptcode_old = '05';
      when ( 'GOVERNMENT PURCHASE' ) acceptcode_old = '06';
      when ( 'LAND SALE' ) acceptcode_old = '09';
      when ( 'MULTI-MARKET SALE' ) acceptcode_old = '98';
      when ( 'MULTI-UNASSESSED' ) acceptcode_old = '02';
      when ( 'MULTI-BUYER = SELLER' ) acceptcode_old = '03';
      when ( 'MULTI-UNUSUAL' ) acceptcode_old = '04';
      when ( 'MULTI-FORECLOSURE' ) acceptcode_old = '05';
      when ( 'MULTI-GOVT PURCHASE' ) acceptcode_old = '06';
      when ( 'MULTI-SPECULATIVE' ) acceptcode_old = '07';
      when ( 'MULTI-MISC' ) acceptcode_old = '08';
      when ( 'MULTI-LAND SALE' ) acceptcode_old = '09';
      when ( 'MARKET SALE' ) acceptcode_old = '01';
      when ( 'MISCELLANEOUS' ) acceptcode_old = '08';
      when ( 'SPECULATIVE' ) acceptcode_old = '07';
      when ( 'TAX DEED' ) acceptcode_old = '98';
      when ( 'UNASSESSED' ) acceptcode_old = '02';
      when ( 'UNUSUAL' ) acceptcode_old = '04';
      when ( '' ) acceptcode_old = '';
      otherwise do;
        %warn_put( msg='ACCEPTCODE value unknown: ' recordno= ssl= acceptcode= )
      end;
    end;

	** Recode ACCEPTCODE_NEW **;

	select (  upcase(acceptcode) );
      when ( 'BUYER = SELLER' ) acceptcode = 'BUYER=SELLER';
      when ( 'FORECLOSURE' ) acceptcode = 'FORECLOSURE';
      when ( 'GOVERNMENT PURCHASE' ) acceptcode = 'GOVT PURCHASE';
      when ( 'LAND SALE' ) acceptcode = 'LANDSALE';
      when ( 'MULTI-MARKET SALE' ) acceptcode = 'M1 MULTI-VERIFIED SALE';
      when ( 'MULTI-UNASSESSED' ) acceptcode = 'M2 MULTI-UNASSESSED';
      when ( 'MULTI-BUYER = SELLER' ) acceptcode = 'M3 MULTI-BUYER-SELLER';
      when ( 'MULTI-UNUSUAL' ) acceptcode = 'M4 MULTI-UNUSUAL';
      when ( 'MULTI-FORECLOSURE' ) acceptcode = 'M5 MULTI-FORECLOSURE';
      when ( 'MULTI-GOVT PURCHASE' ) acceptcode = 'M6 MULTI-GOVT PURCHASE';
      when ( 'MULTI-SPECULATIVE' ) acceptcode = 'M7 MULTI-SPECULATIVE';
      when ( 'MULTI-MISC' ) acceptcode = 'M8 MULTI-MISC';
      when ( 'MULTI-LAND SALE' ) acceptcode = 'M9 MULTI-LAND SALE';
      when ( 'MARKET SALE' ) acceptcode = 'MARKET';
      when ( 'MISCELLANEOUS' ) acceptcode = 'MISC';
      when ( 'SPECULATIVE' ) acceptcode = 'SPECULATIVE';
      when ( 'TAX DEED' ) acceptcode = 'TAX DEED';
      when ( 'UNASSESSED' ) acceptcode = 'UNASSESSED';
      when ( 'UNUSUAL' ) acceptcode = 'UNUSUAL';
      when ( '' ) acceptcode = '';
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
                   appraised_value_current_bldg = new_impr
                   appraised_value_current_total = new_total
                   hstdcode = hstd_code
                   taxrate = tax_rate
                   owner_occupied_coop_units = no_ownocct
                   annualtax = amttax
                   reasoncd = reasoncode
                   acceptcode = acceptcode_new
                   subnbhd = sub_nbhd
                   acceptcode_old = acceptcode
                   asrname=asr_name
                   assessment= assess_val
                   CITYSTZIP = address3
				   Proptype_old = Proptype
;


        drop assessor_name careof_name deeddate delcode
                 last_sale_date lastmodifieddate
                 newimpr newland newtotal oldimpr oldland oldtotal ownocct
                 coopunits capcurr capprop classtype mixed_use proptype
;


        format &format ;


run;


/* Create final dated ownerpt file */
data ownerpt_&ownerptdt.;
        set itspe_all
        (drop = mixeduse saletype);

        rename nmixeduse=mixeduse;
        saletype = saletype_old;

        format saletype $SALETYP.;

        /* Label ownerpt */
        %include "&_dcdata_default_path\RealProp\Prog\Updates\Label_ownerpt.sas";

run;


%Dup_check(
  data=ownerpt_&ownerptdt.,
  by=ssl,
  id=premiseadd,
  out=_dup_check,
  listdups=Y,
  count=dup_check_count
)

%Finalize_data_set(
  /** Finalize data set parameters **/
  data=ownerpt_&ownerptdt.,
  out=ownerpt_&ownerptdt.,
  outlib=realprop,
  label="Recreated Ownerpt File from ITS and CAMA Data",
  sortby=ssl,
  /** Metadata parameters **/
  restrictions=None,
  revisions=%str(New Ownerpt as of &ownerptdt.),
  /** File info parameters **/
  printobs=5,
  freqvars=acceptcode acceptcode_new del_code hstd_code
           ownerpt_extractdat mix1class_3d mix2class_3d mix1txtype mix2txtype
           nbhd part_part pchildcode proptype qdrntname saletype_new sub_nbhd usecode vaclnduse
           ui_proptype
);




/* End of Program */
