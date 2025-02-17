/**************************************************************************
 Program:  Read_CAMA_2025_02.sas
 Library:  RealProp
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  5/12/23
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 GitHub issue:  174

 
 Description:  Read latest CAMA files. To update this code, update the %let
			   belows for the new dates. Run the program and review the 
			   dup_check output and update the deduplicate parameter
			   below. Any buildings that are straight duplicates within
			   the same cama file source do not need to be coded separately.

 Reads data from these CSV files, downloaded from opendata.dc.gov, that must be
 saved in \\sas1\DCDATA\Libraries\Realprop\Raw\yyyy-mm
 
   Computer_Assisted_Mass_Appraisal__Commercial.csv
   Computer_Assisted_Mass_Appraisal__Condominium.csv
   Computer_Assisted_Mass_Appraisal__Residential.csv

 Modifications: 1/12/2019 LH Removed Delete old metadata code. Update Condo file that was updated in 12-2018.
   5/12/23 PT Updated macro for new file formats (no Objectid).
 
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )


%let filedate=2025-02; 
%let update_file = 2025_02;
%let revisions=Updates - new CAMA as of 02-2025.;

/*Read in raw cama files*/
%Read_cama_2023(filedate=&filedate., update_file=&update_file., revisions=&revisions., 


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

