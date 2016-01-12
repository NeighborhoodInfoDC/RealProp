/**************************************************************************
 Program:  Create_Sales_master_forecl.sas
 Library:  Realprop
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey
 Created:  02/04/11
 Version:  SAS 9.2
 Environment:  Remote Windows session (SAS1)
 
 Description:  Create sales transaction history file with foreclosure records.

 Modifications: 03/03/11 LH Added Dataset label.
 		11/15/11 LH Added end_date for dataset label.
 		08/27/12 LH Added 2010 & 2012 geographies.
		02/26/14 LH Updated for SAS1. 
**************************************************************************/

/** Macro Create_sales_master_forecl - Start Definition **/

%macro Create_sales_master_forecl(RegExpFile=, start_dt=,end_dt=,finalize=N, end_date=, revisions=New file. );
	%let data       = sales_master;
	%let MaxExp     = 1000;

	/*%syslput MaxExp=&MaxExp;
	%syslput data=&data;
	
	%syslput start_dt=&start_dt;
	%syslput end_dt=&end_dt;
        %syslput end_date=&end_date;*/

%let finalize = %upcase( &finalize ); 

	  %if &finalize = Y %then %do;
	    %note_mput( macro=Create_sales_master_forecl, msg=Finalize=&finalize - realprop.sales_master_forecl will be replaced. );
	    %let out = realpr_r.sales_master_forecl;
	    %let out_nolib = sales_master_forecl;
	  %end;
	  %else %do;
	    %warn_mput( macro=Create_sales_master_forecl, msg=Finalize=&finalize - realprop.sales_master_forecl will NOT be replaced. );
	    %let out = sales_master_forecl;
	    %let out_nolib = sales_master_forecl;
		
	  %end;

	  %syslput out=&out;
	  %syslput out_nolib=&out_nolib;
	  %syslput finalize=&finalize;
	  %syslput revisions=&revisions;



options SORTPGM=SAS MSGLEVEL=I;

** Read in regular expressions **;

filename xlsfile dde "excel|&_dcdata_r_path\RealProp\Prog\[&RegExpFile]Sheet1!r2c1:r&MaxExp.c2" lrecl=256 notab;

data RegExp (compress=no);
  length OwnerCat_re $ 3 RegExp $ 1000;
  infile xlsfile missover dsd dlm='09'x;
  input OwnerCat_re RegExp;
  OwnerCat_re = put( 1 * OwnerCat_re, z3. );
  if RegExp = '' then stop;
  put OwnerCat_re= RegExp=;
run;
		** Start submitting commands to remote server **;

		/** Upload regular expressions **;

		rsubmit ;

		proc upload status=no
		  data=RegExp 
		  out=RegExp (compress=no);

		run;*/

		data Who_owns;

	            set realpr_r.&data; 
	            
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

		/* Download final file **;

		proc download status=no
		  data=Who_owns 
		  out=Who_owns (label="Who owns the neighborhood analysis file, source &data");

		run;
		*/

		**Recode owner names - to adjust for bank spellings**;
		data step1;
			set who_owns; 

		%lender_history(ownername_full,ownername_fullR);

		if ownername_fullR=" " then ownername_fullR=ownername_full;

	
		run;
			
		proc sort data=rod_r.foreclosures_history out=foreclosures_history; 
			by ssl order;
	    data foreclosures1;
		  set foreclosures_history ;
				
			sale_num=.;
			
			daystonextsale=next_sale_date - outcome_date;

			if outcome_code2 in (1 10) then sale_num=prev_sale_num; *in foreclosure or in default;
				if outcome_code2 in (2 3 4 5 6 7 8 9 11 12) then sale_num=post_sale_num;
				*sold - foreclosure or not, avoided or canceled shoudl now have post sale num=prev sale num;
			if sale_num=. and next_sale_num =1 then sale_num=.n;
			if ownerpt_extractdat_last=. and sale_num= . then sale_num=.n;

			*majority of the following records are notices in the 90s;	
			if sale_num=. and next_sale_num >=2 and outcome_date < '01jan2000'd then sale_num =.n;
			if sale_num=. and next_sale_num=. then sale_num =.n;
			if sale_num=. and prev_sale_num=. and post_Sale_num=. then sale_num=.n;
			
			if outcome_code2 in (1 10) and sale_num in (1.5 2.5 3.5 4.5 5.5 6.5 7.5)
				then do; post_sale_date=prev_sale_date;
				post_sale_price=prev_sale_price;
				post_sale_accept=prev_sale_accept;
				post_sale_owner=prev_sale_owner;
				post_sale_ownerR=prev_sale_ownerR;
				post_sale_hstd=prev_sale_hstd;
				post_sale_ownocc=prev_sale_ownocc;
				post_sale_owncat=prev_sale_owncat;
				post_sale_aval=prev_sale_aval;
				post_sale_units=prev_sale_units;
				post_sale_ownocct=prev_sale_ownocct;
				post_sale_prp=prev_sale_prp;
				post_sale_stype=prev_sale_stype;
				end;
			
		run;
		
		proc freq data=foreclosures1;
		tables sale_num/missprint;
		run;
		proc freq data=foreclosures1;
		tables record_type; where sale_num=.;
		run;
		proc print data=foreclosures1;
		where outcome_code2 in(1 10) and sale_num=.n;
		var ssl filingdate_r sale_num record_type outcome_code2 prev_sale_date prev_sale_num post_sale_date;
		run;
		/*test code;
		proc print data=foreclosures1;
		where sale_num=. and ownerpt_extractdat_last ne . ;
		var ssl outcome_code num_notice outcome_code2 filingdate_r prev_sale_num post_sale_num next_sale_num next_sale_date daystonextsale record_type;
		run;*/
		

		data foreclosures2;
			set foreclosures1 ;
		
			 ssl_lag=lag (ssl);
	    	    order_lag=lag(order);

			 prev_record_sale_num=lag(sale_num);
			 
			 if order=1 then prev_record_sale_num=.;

		 run;
		 proc sort data=foreclosures2 out=foreclosures2sort;
			by descending ssl descending order;
		 run;

		data foreclosures3;
    		set foreclosures2sort;

				next_record_sale_num=lag(sale_num);
		run;
		proc sort data=foreclosures3 out=foreclosures3sort;
		by ssl order;
		run;

		%macro step4;
		data foreclosures4;
		 set foreclosures3sort (where=(sale_num not in (. .n))) ;
		   by ssl;

			retain num_fc_episode episode_reo
			episode1_mediate episode1_mstart episode1_default episode1_dstart episode1_notices episode1_start episode1_end episode1_cancel episode1_outcome episode1_outcome2 episode1_tdeed
			episode2_mediate episode2_mstart episode2_default episode2_dstart episode2_notices episode2_start episode2_end episode2_cancel episode2_outcome episode2_outcome2 episode2_tdeed
			episode3_mediate episode3_mstart episode3_default episode3_dstart episode3_notices episode3_start episode3_end episode3_cancel episode3_outcome episode3_outcome2 episode3_tdeed
			episode4_mediate episode4_mstart episode4_default episode4_dstart episode4_notices episode4_start episode4_end episode4_cancel episode4_outcome episode4_outcome2 episode4_tdeed
			episode5_mediate episode5_mstart episode5_default episode5_dstart episode5_notices episode5_start episode5_end episode5_cancel episode5_outcome episode5_outcome2 episode5_tdeed
			; 

			format episode1_mstart episode1_dstart episode1_start episode1_end episode2_mstart  episode2_dstart episode2_start episode2_end 
					episode3_mstart episode3_dstart episode3_start episode3_end episode4_mstart episode4_dstart episode4_start episode4_end
					episode5_mstart episode5_dstart episode5_start episode5_end  MMDDYY10.
					episode1_outcome episode2_outcome episode3_outcome episode4_outcome episode5_outcome outcome.
					episode1_outcome2 episode2_outcome2 episode3_outcome2 episode4_outcome2 episode5_outcome2 outcomII.;
		*create end points;
		end=1;
		if sale_num=next_record_sale_num then end=.;
		if sale_num=.n then end=.;
		if last.ssl and sale_num ne .n then end=1;
				
		if first.ssl then do;

		num_fc_episode=0; episode1_mediate=0; episode1_mstart=.; episode1_default=0; episode1_dstart=.; episode1_notices=0; episode1_start=.; episode1_end=.; episode1_cancel=0; episode_reo=.;
		episode1_outcome=.; episode1_outcome2=.; episode1_tdeed=0;
		episode2_mediate=0; episode2_mstart=.; episode2_default=0; episode2_dstart=.; episode2_notices=0; episode2_start=.; episode2_end=.; episode2_cancel=0; episode2_outcome=.; episode2_outcome2=.; episode2_tdeed=0;
		episode3_mediate=0; episode3_mstart=.; episode3_default=0; episode3_dstart=.; episode3_notices=0; episode3_start=.; episode3_end=.; episode3_cancel=0; episode3_outcome=.; episode3_outcome2=.; episode3_tdeed=0;
		episode4_mediate=0; episode4_mstart=.; episode4_default=0; episode4_dstart=.; episode4_notices=0; episode4_start=.; episode4_end=.; episode4_cancel=0; episode4_outcome=.; episode4_outcome2=.; episode4_tdeed=0;
		episode5_mediate=0; episode5_mstart=.; episode5_default=0; episode5_dstart=.; episode5_notices=0; episode5_start=.; episode5_end=.; episode5_cancel=0; episode5_outcome=.; episode5_outcome2=.; episode5_tdeed=0;
		end;
		
		if sale_num ne .n then num_fc_episode=num_fc_episode + 1;
		if post_sale_reo=1 then episode_reo=1; 
		%do i=1 %to 5;

			if num_fc_episode=&i. then do;
				episode&i._default=num_default;
				episode&i._mediate=num_mediate;
				episode&i._mstart=firstmediate_date;
				episode&i._dstart=firstdefault_date;
				episode&i._notices=num_notice;
				episode&i._start=firstnotice_date;
				episode&i._end=outcome_date;
				episode&i._cancel=num_cancel;
				episode&i._outcome=outcome_code;
				episode&i._outcome2=outcome_code2;
				episode&i._tdeed=num_tdeed;
			end;
		%end;

		if end=1 then do; output;
		
		num_fc_episode=0; episode1_mediate=0; episode1_mstart=.; episode1_default=0; episode1_dstart=.; episode1_notices=0; episode1_start=.; episode1_end=.; episode1_cancel=0; episode_reo=.;
		episode1_outcome=.; episode1_outcome2=.; episode1_tdeed=0;
		episode2_mediate=0; episode2_mstart=.; episode2_default=0; episode2_dstart=.; episode2_notices=0; episode2_start=.; episode2_end=.; episode2_cancel=0; episode2_outcome=.; episode2_outcome2=.; episode2_tdeed=0;
		episode3_mediate=0; episode3_mstart=.; episode3_default=0; episode3_dstart=.; episode3_notices=0; episode3_start=.; episode3_end=.; episode3_cancel=0; episode3_outcome=.; episode3_outcome2=.; episode3_tdeed=0;
		episode4_mediate=0; episode4_mstart=.; episode4_default=0; episode4_dstart=.; episode4_notices=0; episode4_start=.; episode4_end=.; episode4_cancel=0; episode4_outcome=.; episode4_outcome2=.; episode4_tdeed=0;
		episode5_mediate=0; episode5_mstart=.; episode5_default=0; episode5_dstart=.; episode5_notices=0; episode5_start=.; episode5_end=.; episode5_cancel=0; episode5_outcome=.; episode5_outcome2=.; episode5_tdeed=0;
		end;
		run;
		%mend step4;
		%step4;

		proc freq data=foreclosures4;
		tables num_fc_episode episode_reo episode1_default episode1_mediate sale_num;
		run;
		
	
		**Merge with foreclosures_history file; 
		proc sort data=foreclosures4;
		by ssl sale_num;
		proc sort data=step1;
		by ssl sale_num;
		data step2; 
		merge step1 foreclosures4 (where=(sale_num in (1 2 3 4 5 6 7 8 9 10 11))
						  keep=ssl sale_num  
							firsttdeed_date firsttdeed_grantee firsttdeed_granteeR firsttdeed_grantor firsttdeed_owncat
							lasttdeed_date lasttdeed_grantee lasttdeed_granteeR lasttdeed_grantor lasttdeed_owncat 
							 lasttdeed_multiplelots	lastnotice_grantee lastnotice_grantor lastnotice_grantorR lastnotice_grantor_owncat
							firstnotice_date lastnotice_date firstdefault_date lastdefault_date firstmediate_date lastmediate_date
							lastdefault_grantor lastdefault_grantee
								  outcome_date outcome_code outcome_code2 episode_reo num_fc_episode
		episode1_mediate episode1_mstart episode1_default episode1_dstart episode1_notices episode1_start episode1_end episode1_cancel episode1_outcome episode1_outcome2 episode1_tdeed
			episode2_mediate episode2_mstart episode2_default episode2_dstart episode2_notices episode2_start episode2_end episode2_cancel episode2_outcome episode2_outcome2 episode2_tdeed
			episode3_mediate episode3_mstart episode3_default episode3_dstart episode3_notices episode3_start episode3_end episode3_cancel episode3_outcome episode3_outcome2 episode3_tdeed
			episode4_mediate episode4_mstart episode4_default episode4_dstart episode4_notices episode4_start episode4_end episode4_cancel episode4_outcome episode4_outcome2 episode4_tdeed
			episode5_mediate episode5_mstart episode5_default episode5_dstart episode5_notices episode5_start episode5_end episode5_cancel episode5_outcome episode5_outcome2 episode5_tdeed
			);
		by ssl sale_num;

		run;
		
		data foreclosures5 ;
			set foreclosures4 (where=(sale_num in (1.5 2.5 3.5 4.5 5.5 6.5 7.5 8.5 ))
						  keep=ssl sale_num  
							firsttdeed_date firsttdeed_grantee firsttdeed_granteeR firsttdeed_grantor firsttdeed_owncat firsttdeed_multiplelots
							lasttdeed_date lasttdeed_grantee lasttdeed_granteeR lasttdeed_grantor lasttdeed_owncat lasttdeed_multiplelots
							lastnotice_grantee lastnotice_grantor lastnotice_grantorR lastnotice_grantor_owncat
							firstnotice_date lastnotice_date firstdefault_date lastdefault_date firstmediate_date lastmediate_date
							lastdefault_grantor lastdefault_grantee
								  outcome_date outcome_code outcome_code2  episode_reo num_fc_episode 
				episode1_mediate episode1_mstart episode1_default episode1_dstart episode1_notices episode1_start episode1_end episode1_cancel episode1_outcome episode1_outcome2 episode1_tdeed
			episode2_mediate episode2_mstart episode2_default episode2_dstart episode2_notices episode2_start episode2_end episode2_cancel episode2_outcome episode2_outcome2 episode2_tdeed
			episode3_mediate episode3_mstart episode3_default episode3_dstart episode3_notices episode3_start episode3_end episode3_cancel episode3_outcome episode3_outcome2 episode3_tdeed
			episode4_mediate episode4_mstart episode4_default episode4_dstart episode4_notices episode4_start episode4_end episode4_cancel episode4_outcome episode4_outcome2 episode4_tdeed
			episode5_mediate episode5_mstart episode5_default episode5_dstart episode5_notices episode5_start episode5_end episode5_cancel episode5_outcome episode5_outcome2 episode5_tdeed
			post_sale_date post_sale_price post_sale_accept post_sale_owner  post_sale_hstd  post_sale_ownocc post_sale_owncat 
			post_sale_aval post_sale_units  post_sale_ownocct  post_sale_prp post_sale_stype post_sale_ownerR  
			USECODE ownerpt_extractdat_last GeoBlk2000 geo2000 ward2002 Psa2004 Anc2002 zip Cluster2000 casey_nbr2003 
			casey_ta2003 city cluster_tr2000 eor x_coord y_coord  GeoBlk2010 geo2010 ward2012 Psa2012 Anc2012
rename=(post_sale_date=saledate post_sale_price=saleprice post_sale_accept=acceptcode post_sale_owner=ownername_full
			post_sale_hstd=hstd_code  post_sale_ownocc=owner_occ_sale post_sale_owncat=ownercat 
			post_sale_aval=assess_val post_sale_units=no_units  post_sale_ownocct=no_ownocct  post_sale_prp=ui_proptype
			post_sale_stype=saletype post_sale_ownerR=ownername_fullR));

			
		run;
		
		data step3 (drop= i); 
		set step2 foreclosures5 (in=a);

		by ssl sale_num ;
		
			drop MIX1TXTYPE MIX1RATE MIX1LNDPCT MIX1LNDVAL MIX1BLDPCT MIX1BLDVAL MIX2TXTYPE MIX2RATE MIX2LNDPCT 
			MIX2LNDVAL MIX2BLDPCT  BASELAND BASEBUILD new_land new_impr MIX2BLDVAL

			PCHILDCODE ABTLOTCODE inst_no MORTGAGECO reasoncode proptype part_part acceptcode_prev
			saletype_prev  saleprice_prev saledate_prev careofname_prev address1_prev address2_prev address3_prev
			hstd_code_prev acceptcode_new_prev saletype_new_prev ownername_full_prev owner_occ_sale_prev
			;


		sale_from_fc=.;

		if a then sale_from_fc=1;

		**create collapsed outcome code to calculate sale type;
		outcome_sale_code=.;
		array outcome {5} episode1_outcome episode2_outcome episode3_outcome episode4_outcome episode5_outcome;
			do i=1 to 5 until (outcome_sale_code ne .);
			 if outcome_sale_code = . and outcome{i}=2 then outcome_sale_code=2; *foreclosure sale;
			  if outcome_sale_code = . and outcome{i}=3 then outcome_sale_code=3; *distressed sale;
				 if outcome_sale_code = . and outcome{i} in (4 5 6 8 9) then outcome_sale_code=4; *avoided;
				   if outcome_sale_code = . and outcome{i} in(1 7) then outcome_sale_code =1; *in foreclosure or default;
				    if outcome_sale_code = . and outcome{i} in (. .n) then outcome_sale_code=0;
			end;
		run;
	
		
		proc freq data=step3;
		tables outcome_sale_code;
		run;

		proc sort data=step3;	
		by ssl sale_num;

		data &out. (label="Property sales master file, foreclosure records appended through &end_date., DC" drop=ssl_lag prev_sale_reo prev_UNITNUMBER prev_PREMISEADD 
					sortedby=ssl sale_num) ;
			set step3;

		prev_sale_reo=.;
		ssl_lag=lag(ssl);

		prev_sale_reo=lag(episode_reo); 
		prev_PREMISEADD=lag(PREMISEADD);
		prev_UNITNUMBER=lag(UNITNUMBER);
		if ssl~=ssl_lag then prev_sale_reo=.; 
		if ssl=ssl_lag and sale_from_fc=1 then do; PREMISEADD=prev_PREMISEADD; UNITNUMBER=prev_UNITNUMBER;
		end;

		sale_code=.;
		*put in the (episode_reo=1 or prev_sale_reo=1) as temp fix - should fix fhistory when 2 trustees deeds in a row bank still owner;

		if sale_from_fc=. and outcome_sale_code=2 & (episode_reo=1) then sale_code=1; *Trustees Deed (matching sale) and REO;
		if sale_from_fc=. and outcome_sale_code=2 & prev_sale_reo=1 and ownercat in ('040' '050' '120' '130') then sale_code=1; 
		else if sale_from_fc=. and outcome_sale_code=2 & episode_reo=. then sale_code=2; *Trustees Deed (matching sale) and No REO;
		else if sale_from_fc=1 and outcome_sale_code=2 & episode_reo=1 then sale_code=3; *Trustees Deed (no matching sale) and REO;
		else if sale_from_fc=1 and outcome_sale_code=2 & prev_sale_reo=1 and ownercat in ('040' '050' '120' '130') then sale_code=3; *Trustees Deed (no matching sale) and REO;
		else if sale_from_fc=1 and outcome_sale_code=2 & episode_reo=. then sale_code=4; *Trustees Deed (no matching sale) and No REO;
		else if outcome_sale_code=3 & episode_reo=1 then sale_code=5; *Distressed Sale & REO;
		else if outcome_sale_code=3 & prev_sale_reo=1 and ownercat in ('040' '050' '120' '130') then sale_code=5; *Distressed Sale & REO;
		else if outcome_sale_code=3 & episode_reo=. then sale_code=6; *Distressed Sale (not REO);
		else if prev_sale_reo=1 and outcome_sale_code=0 and ownercat not in('040' '050' '120' '130')
														then sale_code=9; *REO exit;
		else if prev_sale_reo=1 and outcome_sale_code=0 and ownercat in('040' '050' '120' '130')
														then sale_code=10; *REO Transfer;
		else if outcome_sale_code=0 and acceptcode='03' then sale_code=11; *buyer=seller;
		else if num_fc_episode ge 1 and outcome_sale_code=4 and (market_sale=1 or acceptcode ="01")
												then sale_code=7; *Market Sale (more than a year after last Fc or NOD notice);
		else if num_fc_episode ge 1 and outcome_sale_code=4 and saleprice not in (. 0) then sale_code=7;

		else if outcome_sale_code in (1 0) and (market_sale=1 or acceptcode ="01") 
														then sale_code=8; *Market Sale - no previous fc/default episode;
		else if outcome_sale_code in (1 0) and saleprice not in (. 0) then sale_code=8; 

		else if outcome_code in (1 7 . .n) and (market_sale~=1 and acceptcode~="01") then sale_code=12; *Other;
		else if outcome_code in (4 5 6 8 9) and (market_sale~=1 and acceptcode~="01") then sale_code=12; *Other;


		sale_code_sht=.; 

		if sale_code in (7 8) then sale_code_sht=1;
		if sale_code in (1 3 5) then sale_code_sht=2;
		if sale_code in (2 4) then sale_code_sht=3;
		if sale_code in (6) then sale_code_sht=4;
		if sale_code in (9) then sale_code_sht=5;
		if sale_code in (12 10) then sale_code_sht=6; *other non market - including reo transfers;
		if sale_code=11 then sale_code_sht=.; *buyer=seller not included;
		
		format outcome_code outcome. outcome_code2 outcomII. sale_code salecod. sale_code_sht salesht.;
		label sale_code="Type of Sale"
			  sale_code_sht="Type of Sale - Collapsed"
			  sale_from_fc="Sale Transaction only found in Foreclosure Data"
			  outcome_code="Last episode foreclosure outcome code"
			  outcome_code2="Last episode detailed foreclosure outcome code"
			  outcome_sale_code="Collapsed foreclosure episode outcome code"
			  outcome_date="Last episode foreclosure outcome date"
			  episode_reo="Prior owners foreclosure episodes resulted in REO"
			  num_fc_episode="Number of foreclosure episodes - current owner"
			  ownername_fullR="Name(s) of property owners- Recoded"
			 episode1_notices="Episode 1: number of foreclosure notices"
			episode1_start="Episode 1: start date (notice of foreclosure)"
			episode1_end="Episode 1: end date"
			episode1_cancel="Episode 1: number of cancellation notices"
			episode1_outcome="Episode 1: foreclosure outcome code"
			episode1_outcome2="Episode 1: detailed foreclosure outcome code"
			episode1_tdeed="Episode 1: number of notices of trustees deed sale"
			episode1_default="Episode 1: number of notices of default"
			episode1_dstart="Episode 1: default start date"
			episode1_mediate="Episode 1: number of mediation certificates"
			episode1_mstart="Episode 1: mediation certficate date"
    		 episode2_notices="Episode 2: number of foreclosure notices"
			episode2_start="Episode 2: start date (notice of foreclosure)"
			episode2_end="Episode 2: end date"
			episode2_cancel="Episode 2: number of cancellation notices"
			episode2_outcome="Episode 2: foreclosure outcome code"
			episode2_outcome2="Episode 2: detailed foreclosure outcome code"
			episode2_tdeed="Episode 2: number of notices of trustees deed sale"
			episode2_default="Episode 2: number of notices of default"
			episode2_dstart="Episode 2: default start date"
			episode2_mediate="Episode 2: number of mediation certificates"
			episode2_mstart="Episode 2: mediation certficate date"
			 episode3_notices="Episode 3: number of foreclosure notices"
			episode3_start="Episode 3: start date (notice of foreclosure)"
			episode3_end="Episode 3: end date"
			episode3_cancel="Episode 3: number of cancellation notices"
			episode3_outcome="Episode 3: foreclosure outcome code"
			episode3_outcome2="Episode 3: detailed foreclosure outcome code"
			episode3_tdeed="Episode 3: number of notices of trustees deed sale"
			episode3_default="Episode 3: number of notices of default"
			episode3_dstart="Episode 3: default start date"
			episode3_mediate="Episode 3: number of mediation certificates"
			episode3_mstart="Episode 3: mediation certficate date"
			 episode4_notices="Episode 4: number of foreclosure notices"
			episode4_start="Episode 4: start date (notice of foreclosure)"
			episode4_end="Episode 4: end date"
			episode4_cancel="Episode 4: number of cancellation notices"
			episode4_outcome="Episode 4: foreclosure outcome code"
			episode4_outcome2="Episode 4: detailed foreclosure outcome code"
			episode4_tdeed="Episode 4: number of notices of trustees deed sale"
			episode4_default="Episode 4: number of notices of default"
			episode4_dstart="Episode 4: default start date"
			episode4_mediate="Episode 4: number of mediation certificates"
			episode4_mstart="Episode 4: mediation certficate date"
			episode5_notices="Episode 5: number of foreclosure notices"
			episode5_start="Episode 5: start date (notice of foreclosure)"
			episode5_end="Episode 5: end date"
			episode5_cancel="Episode 5: number of cancellation notices"
			episode5_outcome="Episode 5: foreclosure outcome code"
			episode5_outcome2="Episode 5: detailed foreclosure outcome code"
			episode5_tdeed="Episode 5: number of notices of trustees deed sale"
			episode5_default="Episode 5: number of notices of default"
			episode5_dstart="Episode 5: default start date"
			episode5_mediate="Episode 5: number of mediation certificates"
			episode5_mstart="Episode 5: mediation certficate date"
			firsttdeed_date="First trustees deed sale date from last fc episode"
			firsttdeed_grantee="First trustees deed sale grantee from last fc episode"
		    firsttdeed_granteeR="First trustees deed sale grantee recoded from last fc episode"
			firsttdeed_grantor="First trustees deed sale grantor from last fc episode"
			firsttdeed_owncat="First trustees deed sale grantee owner type from last fc episode"
			firsttdeed_multiplelots="First trustees deed sale multiple lots from last fc episode"
			lasttdeed_date="Last trustees deed sale date from last fc episode"
			lasttdeed_grantee="Last trustees deed sale grantee from last fc episode"
			lasttdeed_granteeR="Last trustees deed sale grantee recoded from last fc episode"
			lasttdeed_grantor="Last trustees deed sale grantor from last fc episode"
			lasttdeed_owncat="Last trustees deed sale grantee owner type from last fc episode"
			lasttdeed_multiplelots="Last trustees deed sale multiple lots from last fc episode"
			lastnotice_grantee="Last notice grantee from last fc episode"  
			lastnotice_grantor="Last notice grantor from last fc episode" 
			lastnotice_grantorR="Last notice grantor recoded from last fc episode"  
			lastnotice_grantor_owncat="Last notice grantor owner type from last fc episode" 
			firstnotice_date="First notice date from last fc episode" 
			lastnotice_date="Last notice date from last fc episode"  
			firstdefault_date="First default date from last fc episode"
			lastdefault_date="Last default date from last fc episode"
			firstmediate_date="First mediation certficate date from last fc episode"
			lastmediate_date="Last mediation certficate date from last fc episode"
			lastdefault_grantee="Last default grantee from last fc episode"
			lastdefault_grantor="Last default grantor from last fc episode" 
;
			
		run;

		/*checking data****
			proc print data=step4 (obs=100);
		where sale_code=12;
		var ssl sale_num saleprice acceptcode outcome_code post_sale_reo prev_sale_reo market_sale;
		run;
		*/
		/*x "purge [DCDATA.REALPROP.DATA]&out_nolib.*";*/

		%File_info( data=&out., printobs=5, freqvars=sale_code sale_code_sht );

		/*%if &finalize= N %then %do;

			proc download data=&out_nolib. out=realprop.&out_nolib._test;
			run;

		%end;*/

		  %if &finalize = Y %then %do;
		  
		    ** Register metadata **;
		    
		    %Dc_update_meta_file(
		      ds_lib=REALPROP,
		      ds_name=&out_nolib,
		      creator_process=Sales_master_forecl.sas,
		      restrictions=None,
		      revisions=%str(&revisions)
		    );
		    
		    run;

		
		    
		  %end;

	/*endrsubmit;
	
	** End submitting commands to remote server **;*/



%mend Create_sales_master_forecl;

/** End Macro Definition **/

