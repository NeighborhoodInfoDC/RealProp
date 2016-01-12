/**************************************************************************
 Program:  set_where.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/25/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to set selection criteria for
 Sales_master and Sales_res_clean data sets. 

 Note: Macro %Sale_pars() must be executed before this macro.

 Modifications:
   06/11/07 PT  Adjusted so WHERE= is no longer part of returned 
                whereCode value.
                Renamed Recordno to Ownerpt_recordno.
   07/11/07 PT  Additional modifications.  Now supports creating 
                final data sets that are registered with metadata system.
   03/25/09 PT  Created separate autocall macro file. 
                Removed %include of dcsales_pars.sas.
  02/03/14 PAT  Updated for new SAS1 server.
**************************************************************************/

%macro set_where(
  which=    /** Data set to be created: SALES or MASTER **/
);

  %let which = %upcase( &which );

  %global whereCode;

        %if %upcase(&which) = SALES %then %do;
                %if &use_accept_code=YES %then %do;
                        %let accept= (&accept_code);
                %end;
                %if &use_saleprice=YES %then %do;
                        %let sale_p=  (&salePrice_code);
                %end;
                %if &use_saleType=YES %then %do;
                        %let sale_t=  (&saleType_code);
                %end;
                %if &use_propType=YES %then %do;
                        %let ui_prop=  (&propType_code);
                %end;
                %if &use_salesdate=YES %then %do;
                        %let sale_d=  (&saledate_code);
                %end;
                
                %let whereCode= ( (1) ;

                %if &use_accept_code=YES %then %do;
			%let whereCode=&whereCode and &accept;
                %end;
                %if &use_saleprice=YES %then %do;
 			%let whereCode=&whereCode and &sale_p;
                %end;
                %if &use_saleType=YES %then %do;
 			%let whereCode=&whereCode and &sale_t;
                %end;
                %if &use_propType=YES %then %do;
 			%let whereCode=&whereCode and &propType_code;
                %end;
                %if &use_salesdate=YES %then %do;
 			%let whereCode=&whereCode and &saledate_code;
                %end;
		%let whereCode=&wherecode.);
		%put &wherecode;

        %end;
        %else %do;
           %let whereCode=;
        %end;

	%Note_mput( macro=Set_where, msg=whereCode=&whereCode )

%mend set_where;

