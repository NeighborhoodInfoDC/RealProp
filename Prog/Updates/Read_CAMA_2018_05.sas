/**************************************************************************
 Program:  Read_CAMA_2018_05.sas
 Library:  RealProp
 Project:  Urban-Greater DC
 Author:   L. Hendey
 Created:  
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read latest CAMA files.

 Modifications: 
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )


%let filedate=2018-05; 
%let update_file = _2018_05;

/*Read in raw cama files*/
%Read_cama(filedate=&filedate., update_file=&update_file.); 

/*merge files and figure out how to deal with duplicates*/ 

	data Cama;
	set CAMA_commpt (in=a) CAMA_condopt (in=b) CAMA_respt (in=c);

	if a then cama="CommPt";
	if b then cama="CondoPt";
	if c then cama="ResPt";

	label Cama="Origin file for CAMA data"
	;

	drop objectid;
		 

	run;
	

	%dup_check( 
	    data=Cama, 
	    by=ssl bldg_num, 
	    id=cama usecode Struct_d STRUCT_CL_D price saledate,
	    printnumdups=N,
	    out=_dup_check_out
	  )
	  run;

	  title2;
  
  /***review output to see changes** - MAY NEED TO ADJUST CODE BELOW**/

	data cama2;
		set cama;

	  *deal with duplicates between COMM PT and Res PT;

	*remove respt observation;

		if bldg_num=1 and CAMA="ResPt" then do; 
		 	if ssl in("0100    0905" "0100    0906")  then delete; *CBS broadcasting building 2020-2030 M ST NW; 
	 		if ssl in("0100    7003" "0100    7004" "0100    7005" "0100    7006" "0100    7007" "0100    7008" "0100    7009" "0100    7010" "0100    7011"
				"0100    7012" "0100    7013" "0100    7014" "0100    7015") then delete; *CBS broadcasting building 2020-2030 M ST NW; 
			if ssl in ("1035    0123" "1035    0124" "1035    0125" ) then delete; *East Capitol - currently marked as religious owned by Lincoln Park United Methodist; 
			if  ssl in ("1043    0869" "1043    0870"  ) then delete; *currently use is industrial misc and commerical garage; 
				if ssl ="2624    0815" then delete; *looks like the property was renovated and now should be in COMMpt; 
			if ssl="3702    0808" then delete; *usecode is educational -owned by USA in Brookland; 
			if ssl="2950    0816" then delete; *usecode is medical; *likely walter reed? *most of square 2950 is owned by DC or US/Army on Georgia Ave NW; 
			if ssl="0394    0879" then delete; *usecode is special use; *likely owned by DC; 
		end;

		run;

*delete straight dups for 	"2359    0837" 		"2745A   0074";
			 
		proc sort data=cama2 out=cama3 nodupkey EQUALS;
		by ssl bldg_num;

		run;
		

	%Finalize_data_set( 
	  data=cama3,
	  out=cama_building,
	  outlib=realprop,
	  label="Computer Assisted Mass Appraisal (CAMA) Property Characteristics - Building Level file",
	  sortby=ssl bldg_num,
	  revisions=New file. Data downloaded from opendata.dc.gov in 5-2018.,
	  freqvars=cama usecode bldg_num
	)

	
	  ** Saved dated copy of base file **;

	  %Finalize_data_set( 
	  /** Finalize data set parameters **/
	  data=cama3,
	  out=cama_building_&update_file,
	  outlib=realprop,
	  label="Computer Assisted Mass Appraisal (CAMA) Property Characteristics - Building Level file, &update_file",
	  sortby=ssl bldg_num,
	  /** Metadata parameters **/
	  revisions=%str(&revisions),
	  /** File info parameters **/
	  printobs=5,
	  freqvars=cama usecode bldg_num
	  );


*create parcel-level file;

	*get number of buildings on a parcel; 
	proc summary data=cama3;
	by ssl;
	id cama EXTRACTDAT ;
	output out=cama_sum;
	run;
	
	*select out only first observation by ssl  - most should be bldg #1; 
	proc sort data=cama3 out=cama_bldg1 nodupkey equals;
	by ssl;
	run;
	data cama4;

	merge cama_bldg1 cama_sum (rename=(_freq_=num_bldg) drop= EXTRACTDAT cama _type_);
	by ssl;

	if num_bldg > 1 then multi_bldg=1; else multi_bldg=0; 

	label num_bldg="Number of buildings on parcel"
		  multi_bldg="Parcel has more than one building";	
		;

	run;


	%Finalize_data_set( 
	  data=cama4,
	  out=cama_parcel,
	  outlib=realprop,
	  label="Computer Assisted Mass Appraisal (CAMA) - Parcel file Bldg 1 Characteristics",
	  sortby=ssl,
	  revisions=New file. Data downloaded from opendata.dc.gov in 5-2018.,
	  freqvars=cama usecode num_bldg multi_bldg
	)

	  ** Saved dated copy of base file **;

	  %Finalize_data_set( 
	  /** Finalize data set parameters **/
	  data=cama3,
	  out=cama_parcel_&update_file,
	  outlib=realprop,
	  label="Computer Assisted Mass Appraisal (CAMA) - Parcel file Bldg 1 Characteristics, &update_file",
	  sortby=ssl,
	  /** Metadata parameters **/
	  revisions=%str(&revisions),
	  /** File info parameters **/
	  printobs=5,
	  freqvars=cama usecode num_bldg multi_bldg
	  );
