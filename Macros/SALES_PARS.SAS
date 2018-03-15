/**************************************************************************
 Program:  Sales_pars.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/25/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to create standard macro variables for
 processing real property sales data.

 Modifications:
  04/06/09 PAT Dropped vars: arn asr_name tax_rate phasebuild trigroup
               phasecycle phaseland mix1bldpct mix1bldval mix1lndpct
               mix1lndval mix1rate mix1txtype mix2bldpct mix2bldval 
               mix2lndpct mix2lndval mix2rate mix2txtype mixeduse.
               Added vars: Acceptcode_new Saletype_new.
  04/09/09 PAT Added back vars: mix1bldpct mix1bldval mix1lndpct
               mix1lndval mix1rate mix1txtype mix2bldpct mix2bldval
               mix2lndpct mix2lndval mix2rate mix2txtype mixeduse.
  08/16/12 RAG Added new 2010 and 2012 geography vars: 
  12/31/13 PAT Updated for new SAS1 server.
  03/30/14 PAT Added voterpre2012 to list of geography vars. 
  03/16/17 RP Added bridge park to list of geography vars.
**************************************************************************/

/** Macro Sales_pars - Start Definition **/

%macro Sales_pars(  );

  %global 
    id_vars geo_vars_cat geo_vars_xy geo_vars 
    update_date_vars update_fixed_vars update_other_vars update_vars no_update_vars 
    clean_vars owner_occ_sale_vars prev_vars prev_vars_w_suffix
    Ownerpt_2nd_owner_extractdat;

%** Date when ownerpt extacts included 2nd owner field (OWNNAME2) **;

%let Ownerpt_2nd_owner_extractdat = '24mar2005'd;

%** Obs. identification vars **;

%let id_vars = ssl sale_num;

%** Geography variables **;

%let geo_vars_cat = 
  anc2002 casey_nbr2003 casey_ta2003 city cluster2000 cluster2017
  cluster_tr2000 eor geo2000 psa2004 ward2002 zip
  geo2010 psa2012 ward2012 anc2012 voterpre2012 bridgepk;

%let geo_vars_xy = x_coord y_coord geoblk2000 geoblk2010;

%let geo_vars = &geo_vars_cat &geo_vars_xy;

%** These variables are updated with new sales records **;

%let update_date_vars = saledate saleprice;

%let update_fixed_vars = 
  landarea no_units premiseadd;

%let update_other_vars =
  abtlotcode acceptcode acceptcode_new address1 address2
  address3 careofname
  deed_date 
  hstd_code inst_no 
  mortgageco no_ownocct 
  ownername
  ownerpt_extractdat_last ownname2 ownername_full 
  part_part pchildcode proptype 
  reasoncode
  saletype saletype_new
  ui_proptype unitnumber usecode;

%let update_vars = &update_date_vars &update_fixed_vars &update_other_vars;

%** These variables are NOT updated once the initial sales record is saved to Sales_master **;

%let no_update_vars =
  assess_val basebuild baseland new_impr new_land new_total 
  vaclnduse ownerpt_extractdat_first
  mix1bldpct mix1bldval mix1lndpct
  mix1lndval mix1rate mix1txtype mix2bldpct mix2bldval
  mix2lndpct mix2lndval mix2rate mix2txtype mixeduse
;

%** Vars created as part of the cleaning process **;

%let clean_vars =
  market_sale area_excluded price_excluded ratio_excluded ratio clean_sale;

%** Owner-occupied sales flag **;  

%let owner_occ_sale_vars =
  owner_occ_sale;

%** Data retained from previous sales **;  

%***let prev_vars = 
  address1_prev address2_prev address3_prev careofname_prev 
  acceptcode_prev hstd_code_prev 
  ownername_prev ownname2_prev ownername_full_prev 
  saledate_prev saleprice_prev;

%let prev_vars = 
  saledate saleprice ownername_full saletype saletype_new acceptcode acceptcode_new hstd_code 
  address1 address2 address3 careofname owner_occ_sale;

%let prev_vars_w_suffix = %ListChangeDelim( &prev_vars, old_delim=%str( ), new_delim=%str( ), suffix=_prev, quiet=y );

%***let keep_vars = &no_update_vars &update_vars;

/* Dropped:
highnumber lownumber old_impr old_land old_total ownerpt_recordno 
lot nbhd nbhdname qdrntname square streetcode streetname sub_nbhd 
suffix ustreetname
arn asr_name 
tax_rate 
  phasebuild phasecycle phaseland 
trigroup 
*/

%****************************************************************************;
%*********** Subsetting variable and value definitions **********************;
%****************************************************************************;

%global 
  wherecode use_ratio_limits use_price_limits use_area_limits 
  use_salesdate saledate_code use_accept_code accept_code
  use_saleType saleType_code use_saleprice saleprice_code 
  use_propType propType_code
  ratio_min ratio_max saleprice_min saleprice_max landarea_min landarea_max;

	%********************************************************************;
	%** Enter RATIO Percentile to use in selecting cases:              **;
	%**       Lower Bound must be 1,5,10,MIN or an actual number       **;
	%**       Upper Bound must be 90,95,99,MAX or an actual number     **;
	%**	 Default is lower=MIN and upper=MAX (i.e. all cases)      **;
	%** Note: The subsetting statement is found in the macro STEP3().  **;
	%**       The percentile macro is called: get_per()                **;
	%** 	 1,5,10,90,95,99 all refer to percentiles found in the    **;
	%**       data. A univariate is done on the file and these perc-   **;
	%**       tiles are dynamically generated. If the numbers you      **;
	%**       wish to use are not based on percentiles, use the        **;
	%**       actual number value for the lower and upper bounds.      **;
	%********************************************************************;
	%let use_ratio_limits=YES;
	%let r_lower_bound=1 ;    
	%let r_upper_bound=99;
	%let ratio_min = 0.1;
	%let ratio_max = 20;

	%********************************************************************;
	%** Enter SALESPRICE Percentile to use in selecting cases:         **;
	%**       Lower Bound must be 1,5,10,MIN or an actual number       **;
	%**       Upper Bound must be 90,95,99,MAX or an actual number     **;
	%**	 Default is lower=MIN and upper=MAX (i.e. all cases)      **;
	%** Note: The subsetting statement is found in the macro STEP3().  **;
	%**       The percentile macro is called: get_per()                **;
	%** 	 1,5,10,90,95,99 all refer to percentiles found in the    **;
	%**       data. A univariate is done on the file and these perc-   **;
	%**       tiles are dynamically generated. If the numbers you      **;
	%**       wish to use are not based on percentiles, use the        **;
	%**       actual number value for the lower and upper bounds.      **;
	%********************************************************************;
	%let use_price_limits=YES;
	%let s_lower_bound=1;    
	%let s_upper_bound=99;
	%let saleprice_min = 10000;
	%let saleprice_max = 10000000;

	%********************************************************************;
	%** Enter LANDAREA Percentile to use in selecting cases:           **;
	%**       Lower Bound must be 1,5,10,MIN or an actual number       **;
	%**       Upper Bound must be 90,95,99,MAX or an actual number     **;
	%**	 Default is lower=MIN and upper=MAX (i.e. all cases)      **;
	%** Note: The subsetting statement is found in the macro STEP3().  **;
	%**       The percentile macro is called: get_per()                **;
	%** 	 1,5,10,90,95,99 all refer to percentiles found in the    **;
	%**       data. A univariate is done on the file and these perc-   **;
	%**       tiles are dynamically generated. If the numbers you      **;
	%**       wish to use are not based on percentiles, use the        **;
	%**       actual number value for the lower and upper bounds.      **;
	%********************************************************************;
	%let use_area_limits=YES;
	%let a_lower_bound=1;    
	%let a_upper_bound=99;
	%let landarea_min = 20;
	%let landarea_max = 15000;

	%********************************************************************;
	%** Enter sales dates to use in selecting market sales             **;
	%**                                              		  **;
	%**                                                                **;
	%**	                         				  **;
	%********************************************************************;
	%let use_salesdate=YES;
	%let saledate_code=year( saledate ) >= 1995;    
	
	%********************************************************************;
	%** Enter Acceptance code to use in selecting market sales         **;
	%**                                              		  **;
	%**                                                                **;
	%**	                         				  **;
	%********************************************************************;
	%let use_accept_code=YES;
	%let accept_code=acceptcode in ('','00','01'); 
	
	%********************************************************************;
	%** Enter SaleType to use in selecting market sales                **;
	%**                                              		  **;
	%**                                                                **;
	%**	                         				  **;
	%********************************************************************;
	%let use_saleType=YES;
	%let saleType_code=saleType in ('','01'); 
	
	%********************************************************************;
	%** Enter SALEPRICE to use in selecting market sales               **;
	%**                                              		  **;
	%**                                                                **;
	%**	                         				  **;
	%** Note:Used in a where statement. Keep cases above this number.  **;
	%********************************************************************;
	%let use_saleprice=YES;
	%let saleprice_code=saleprice > 0;    


	%********************************************************************;
	%** Enter ui_proptype to use in selecting market sales             **;
	%**                                                     	   **;
	%**                                                                **;
	%**	                         				   **;
	%********************************************************************;
	%let use_propType=YES;
	%let propType_code=ui_proptype in ('10','11'); 


%****************************************************************************;
%*********** Other global variables                    **********************;
%****************************************************************************;

%global new_extract;


%mend Sales_pars;

/** End Macro Definition **/
