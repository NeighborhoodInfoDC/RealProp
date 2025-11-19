/**************************************************************************
 Program:  Create_own_occ.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/26/08
 Version:  SAS 9.1
 
 Description:  Autocall macro to create Owner_occ_sale variable.
 Sale is owner occupied if tax billing address matches property address,
 OR homestead exemption flag indicates an owner-occupied property.

 Note:  Input data set must include these variables: 
 address1, address2, address3, ui_proptype, premiseadd, hstd_code.

 Modifications:
  12/02/08 PAT No longer uses SSL and SALEDATE as merge vars. Creates
               temporary ID var instead. Output data set no longer
               sorted by SSL and SALEDATE.
  03/30/09 PAT Added .N=Not applicable for non-applicable property types.
  02/22/10 PAT Removed ssl saledate sale_num from keep= option.
  04/26/10 PAT Added QUIET= option to suppress warning messages from 
               %DC_geocode.
  12/31/13 PAT  Updated for new SAS1 server.
**************************************************************************/

%macro create_own_occ(
  inds=,  /** input data set name **/
  outds=,  /** output data set name **/
  inlib=work, /** input library **/
  outlib=work,  /** output library **/
  cleanup=y, /** Cleanup temporary files (Y/N) **/
  quiet=y  /** Suppress %DC_geocode() warning messages (Y/N) **/
);

  %local APPLICABLE_UI_PROPTYPE_CODES HSTD_OWN_OCC_CODES UNIT_LBL dsid rc premiseadd_lbl owneraddress_lbl;

  %let APPLICABLE_UI_PROPTYPE_CODES = '10', '11', '13';
  %let HSTD_OWN_OCC_CODES = '1', '5', 'A';
  %let UNIT_LBL = 'UNIT';

  %** Get labels for address variables **;

  %let dsid=%sysfunc(open(&inlib..&inds,i));
  %if &dsid %then %do;
      %let premiseadd_lbl=%qsysfunc(varlabel(&dsid,%sysfunc(varnum(&dsid,premiseadd))));
      %let rc=%sysfunc(close(&dsid));
  %end;
  %else %do;
    %err_mput( macro=Create_own_occ, msg=The input data set %upcase(&inlib..&inds) does not exist or could not be opened. )
    %goto exit;
  %end;
  
  %let premiseadd_lbl = Full property address;
  %let owneraddress_lbl = Property owner tax billing address;
  
	** Add unique ID for remerging data **;

	data 
	  _&inds
   	  _sales_owner_dc (keep=_create_own_occ_id /*ssl saledate sale_num*/ ui_proptype premiseadd_str owneraddress);

	  set &inlib..&inds;

	  _create_own_occ_id = _n_;
	  
	  ** Create Premiseadd_str by removing "WASHINGTON DC ..." from PREMISEADD **;
	  
	  length Premiseadd_str $ 80;
	  
	  Premiseadd_str = prxchange( 's/washington dc.*//i', 1, premiseadd );

	  length owneraddress $ 40;

	  if address2 = '' then owneraddress = address1;
	  else owneraddress = address2;
	  
	  label owneraddress = "&owneraddress_lbl";

	  ** Standardize addresses of DC owners for matching **;
	  ** DC-based owners of single-fam, condo, and rental properties 
          ** Skip address matching if homestead exemption flag indicates owner occupied;
	  
	  if ui_proptype in ( &APPLICABLE_UI_PROPTYPE_CODES ) and indexw( address3, 'DC' ) and
                not( hstd_code in ( &HSTD_OWN_OCC_CODES ) ) then output _sales_owner_dc;

	  output _&inds;
	  
	  label
	    Premiseadd = "&premiseadd_lbl"
	    Premiseadd_str = "Property street address";

	run;
	

	%DC_mar_geocode(
	  data=_sales_owner_dc,
	  out=_premise_geo,
	  staddr=Premiseadd_str,
	  id=_create_own_occ_id ,
	  ds_label=,
	  keep_geo=,
	  geo_match=Y,
	  block_match=N,
	  listunmatched=N,
          quiet=&quiet
	)

	%DC_mar_geocode(
	  data=_sales_owner_dc,
	  out=_owneraddress_geo,
	  staddr=owneraddress,
	  id=_create_own_occ_id ,
	  ds_label=,
	  keep_geo=,
	  geo_match=Y,
	  block_match=N,
	  listunmatched=N,
          quiet=&quiet
	)

	run;

	** Merge standardized addresses & create owner-occ. sale flag **;

	data &outlib..&outds;
	
	  merge
	    _&inds
	    _premise_geo 
	      (keep=_create_own_occ_id Premiseadd_str_std m_addr _matched_
	       rename=(m_addr=premiseadd_str_m _matched_=_matched_premiseadd_str))
	    _owneraddress_geo 
	      (keep=_create_own_occ_id owneraddress_std m_addr _matched_ in=inDC
	       rename=(m_addr=owneraddress_m _matched_=_matched_owneraddress));
	  by  _create_own_occ_id;

	  length Owner_occ_sale 3;

        if ui_proptype in ( &APPLICABLE_UI_PROPTYPE_CODES ) then do;

	    if hstd_code in ( &HSTD_OWN_OCC_CODES ) then do;
	      owner_occ_sale = 1; /** Own-occ.: homestead deduction **/
	    end;
          else do;
	      if Premiseadd_str ~= "" and owneraddress ~= "" then do;
              if inDC then do;
	          if Premiseadd_str_std ~= "" and owneraddress_std ~= "" then do;
	            if ( indexw( upcase( Premiseadd_str_std ), &UNIT_LBL ) and indexw( upcase( owneraddress_std ), &UNIT_LBL ) )
	               or indexw( upcase( Premiseadd_str_std ), '1/2' ) or indexw( upcase( owneraddress_std ), '1/2' )
	               or upcase( _matched_Premiseadd_str ) ~= 'STREET' or upcase( _matched_owneraddress ) ~= 'STREET' then do;
	              /** If both addresses contain apartment numbers, either address contains 1/2, 
	                  or both geo matched addresses not to street, use _std addresses **/
                    if Premiseadd_str_std = owneraddress_std then 
  	                owner_occ_sale = 1; /** Own-occ.: addresses match **/
  	              else
  	                owner_occ_sale = 0; /** In DC, but different address **/
  	            end;
  	            else do;
  	              /** Otherwise, use geo matched addresses **/
  	              if Premiseadd_str_m = owneraddress_m then 
  	                owner_occ_sale = 1; /** Own-occ.: addresses match **/
  	              else 
  	                owner_occ_sale = 0; /** In DC, but different address **/
  	            end;
                end;
	          else owner_occ_sale = .u;  /** Status unknown: missing addresses **/
	        end;
	        else owner_occ_sale = 0;  /** Out of state owner **/
            end;
            else owner_occ_sale = .u;  /** Status unknown: missing addresses **/
          end;

	  end;
        else do;
          owner_occ_sale = .n;  /** Not applicable **/
        end;

	  format owner_occ_sale yesno.;

	  label
	    owner_occ_sale = 'Owner-occupied sale'
	    Premiseadd_str_m = "Property street address (geo matched by %nrstr(%DC_mar_geocode))"
	    owneraddress_m = "&owneraddress_lbl (geo matched by %nrstr(%DC_mar_geocode))"
	    ;

	  drop _create_own_occ_id;

	run;

  %exit:

  %if %mparam_is_yes( &cleanup ) %then %do;

    ** Cleanup temporary files **;

    proc datasets nolist library=work memtype=(data);
      delete _&inds _sales_owner_dc _premise_geo _owneraddress_geo;
    quit;

  %end;

%mend create_own_occ;

