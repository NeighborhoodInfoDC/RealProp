/**************************************************************************
 Program:  Update_all_sale_transactions.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/06/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to update sales transactions file with
 latest Ownerpt update.

 Modifications:
  12/31/13 PAT  Updated for new SAS1 server.
**************************************************************************/

%macro Update_all_sale_transactions( update_file=, prev_sale=, outds=, cleanup=Y );

  %let cleanup = %upcase( &cleanup );

  %** For debugging **;
  %let global_where = (1);

** Create update transaction files **;

data 
  /*_Update_dump (keep=&id_vars &update_vars &no_update_vars &clean_vars &prev_vars)*/
  _Update_new_obs (keep=&id_vars &update_vars &no_update_vars)
  _Update_refresh_date (keep=&id_vars &update_date_vars)
  _Update_refresh_other (keep=&id_vars &update_other_vars);

  set 
    &prev_sale (in=Exist rename=(ownerpt_extractdat_last=ownerpt_extractdat))
    &update_file
  ;
  by ssl /*ownerpt_extractdat*/;

  where &global_where;

  ** Create ownername_full var. **;

  %Ownername_full()

  length ownername_full_ret $150 acceptcode_ret $2;
  retain ownerpt_extractdat_first_ret ownerpt_extractdat_ret ownername_full_ret acceptcode_ret saledate_ret saleprice_ret;
  retain sale_num_ret;

  if first.ssl then do;

    if not( Exist ) then do;
      ownerpt_extractdat_first = ownerpt_extractdat;
      Sale_num = 1;
      new = 1;
    end; 

    output _Update_new_obs;

    ownerpt_extractdat_first_ret = ownerpt_extractdat_first;
    ownerpt_extractdat_ret = ownerpt_extractdat;
    ownername_full_ret = ownername_full; 
    acceptcode_ret = acceptcode;
    saledate_ret = saledate;
    saleprice_ret = saleprice;
    sale_num_ret = sale_num;

  end;

  else if not Exist then do;

    if missing( sale_num ) then sale_num = sale_num_ret;
    if missing ( ownerpt_extractdat_first ) then ownerpt_extractdat_first = ownerpt_extractdat_first_ret;

      **** New transaction? ****;

      ** Determine if owner name changed **;
      ** NB: Earlier ownerpt files had only one ownername field, so only compare first owner **; 

      if ownerpt_extractdat_ret < &Ownerpt_2nd_owner_extractdat then do;
        Owner_changed = ( scan( ownername_full_ret, 1, '+' ) ~= scan( ownername_full, 1, '+' ) );
      end;
      else do;
        Owner_changed = ( ownername_full_ret ~= ownername_full );
      end;

      *FORMAT saledate_ret ownerpt_extractdat_first ownerpt_extractdat ownerpt_extractdat_ret saledate MMDDYY8.;
      *PUTLOG '>>>' '>>>' SSL= SALE_NUM= ownerpt_extractdat_ret= ownerpt_extractdat= ownername_full_ret= ownername_full=
             Owner_changed= ;

      *PUTLOG '>>>' '>>>' ssl= sale_num= ownername_full_ret= ownername_full= saledate_ret= saledate= saleprice_ret= saleprice=
          ownerpt_extractdat_first= ownerpt_extractdat= acceptcode_ret= acceptcode= Owner_changed=;

      if ( ( Owner_changed and saledate_ret < saledate and saleprice_ret ~= saleprice ) and 
           ( ownerpt_extractdat_first < saledate or acceptcode_ret ~= acceptcode or not( missing( saledate_ret ) ) ) ) or 
         ( 0 < saledate_ret < saledate and ownerpt_extractdat_first < saledate and 
           ( Owner_changed or ( saleprice_ret ~= saleprice and saleprice > 0 ) or acceptcode_ret ~= acceptcode ) )
       then do;

        if not missing( saledate ) then do;

        ** New transaction **;

        *PUTLOG 'NEW TRANSACTION!' /;

        ownerpt_extractdat_first = ownerpt_extractdat;
        ownerpt_extractdat_ret = ownerpt_extractdat;
        ownername_full_ret = ownername_full;
        acceptcode_ret = acceptcode; 
        saledate_ret = saledate;
        saleprice_ret = saleprice;
        new = 1;
        sale_num + 1;
        output _Update_new_obs;

        end;
  
      end;
      else do;
        ** Not a new transaction **;
        *PUTLOG 'NO' @;
        if not( missing( saledate ) ) and 
           ( saledate <= ownerpt_extractdat_first or 
             ( ownerpt_extractdat_first = .x and saleprice > 0 ) ) then do;
          *PUTLOG ' - UPDATE RECORD' @;
          output _Update_refresh_date;
        end;
        output _Update_refresh_other;
        *PUTLOG ;
      end;

  end;

  else do;

    output _Update_new_obs;

  end;

  ownerpt_extractdat_first_ret = ownerpt_extractdat_first;
  ownerpt_extractdat_ret = ownerpt_extractdat;
  ownername_full_ret = ownername_full;
  acceptcode_ret = acceptcode; 
  sale_num_ret = sale_num;

  if not( missing( saledate ) ) then do;
    saledate_ret = saledate;
    saleprice_ret = saleprice;
  end;
  
  *keep new ownername_full ownername_full_prev sale_num ownerpt_extractdat_first &keep_vars;
  rename ownerpt_extractdat=ownerpt_extractdat_last;

  label
    ownerpt_extractdat_first = "Extract date of Ownerpt update where sale first appeared"
    ownerpt_extractdat = "Extract date of Ownerpt update where sale last appeared";    

  format ownerpt_extractdat_first mmddyy10.;

  /***output _Update_dump;***/

run;

data _Update_refresh_date;

  set _Update_refresh_date;
  by ssl sale_num;

  if last.sale_num;

run;

data _Update_refresh_other;

  set _Update_refresh_other;
  by ssl sale_num;

  if last.sale_num;

run;

data _Update_final;

  merge _Update_new_obs _Update_refresh_date _Update_refresh_other;
  by ssl sale_num;

run;

** Remove duplicate dates **;

proc sort data=_Update_final;
  by ssl saledate sale_num;

data &outds (keep=&id_vars &update_vars &no_update_vars);

  set _Update_final (drop=sale_num);
  by ssl saledate;

  retain sale_num;

  if first.ssl then sale_num = 0;

  if last.saledate then do;
    sale_num = sale_num + 1; 
    output;
  end;

  label sale_num = "Sequential number of sale (for SSL)";  

run;

%if &cleanup = Y %then %do;

  ** Cleanup temporary files **;

  proc datasets nolist library=work memtype=(data);
    delete _Update_:;
  quit;

%end;

%mend Update_all_sale_transactions;

