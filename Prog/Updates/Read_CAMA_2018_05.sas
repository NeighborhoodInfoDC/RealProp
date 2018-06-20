/**************************************************************************
 Program:  Read_CAMA_2018_05.sas
 Library:  RealProp
 Project:  Urban-Greater DC
 Author:   L. Hendey
 Created:  6/15/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read latest CAMA files. To update this code, update the %let
			   belows for the new dates. Run the program and review the 
			   dup_check output and update the deduplicate parameter
			   below. Any buildings that are straight duplicates within
			   the same cama file source do not need to be coded separately.

 Modifications: 
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )


%let filedate=2018-05; 
%let update_file = 2018_05;
%let revisions=New file. Data downloaded from opendata.dc.gov in 5-2018.;

/*Read in raw cama files*/
%Read_cama(filedate=&filedate., update_file=&update_file., revisions=&revisions., 


	deduplicate=
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

); 

/*this code should be deleted the next time the program is run - LH 6/20/18*/
%Delete_metadata_file(  
         ds_lib=realprop,
         ds_name=cama_building__2018_05,
         meta_lib=_metadat,
         meta_pre=meta
  )
  
%Delete_metadata_file(  
         ds_lib=realprop,
         ds_name=CAMA_PARCEL__2018_05,
         meta_lib=_metadat,
         meta_pre=meta
  )  