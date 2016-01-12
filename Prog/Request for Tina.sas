**get vars for tina/helen;

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp ) 

*Residential CAMA file - summarize to get building count per parcel;
proc sort data=realpr_r.camarespt_2014_03 out=camarespt_2014_03;
by ssl ;
proc summary data=camarespt_2014_03;
by ssl; 
output out=num_bldgs_camarespt ;
run;
proc freq data=num_bldgs_camarespt;
tables _freq_;
run;

*Condo CAMA file (no multiple buildings per parcel); 
proc sort data=realpr_r.camacondopt_2013_08 out=camacondopt_2013_08;
by ssl ;
*Prep Commm CAMA file;
data commpt;

set realpr_r.camacommpt_2013_08;
keep ssl bldg_num gba NUM_UNITS ayb eyb;

*delete records that are in both CAMA CommPt and CAMA ResPT (keeping in ResPT);
if ssl in ("0132    0249" "0242    0824" "0277    0800" "0333    0801" "0333    0804" "0335    0810" "0396    0032" "0396    0033" "0843    0018" "0886    0042" "0906    0826"
"0916    0020" "0920    0057" "1033    0100" "1045    0846" "1077    0114" "1087    0082" "2520    0806" "2578    0026" "2676    0823" "2995    0073" "3092    0018" "3093    0034"
"3094    0082" "3094    0083" "3094    0084" "3123    0039" "3509    0076" "3816    0005" "3935    0026" "4044    0043" "4059    0029" "4147    0041" "4446    0014" "5997    0039"
) then delete; 

run;
	*delete duplicate observations for ssl & building number;
	proc sort data=commpt nodups;
	by ssl bldg_num;
	run;
	*summarize to get totals and min/max;
	proc summary data=commpt;
	by ssl;
	var gba num_units ayb eyb;
	output out=commpt_sum sum=sum_gba sum_units min=min_gba min_num_units  min_ayb min_eyb max=max_gba max_num_units max_ayb max_eyb ;
	run;
*Merge ResPT and Summarize ResPT;
data camarespt_bldg_1_record (where=(bldg_num=1 or num_bldgs=1) drop=SALEDATE SALE_NUM USECODE cama_proptype LANDAREA PREMISEADD UNITNUMBER OWNERNAME OWNNAME2  X_COORD  Y_COORD) ;
merge camarespt_2014_03 num_bldgs_camarespt (keep=ssl _freq_ rename=(_freq_=num_bldgs)) ;
by ssl; 

label num_bldgs="Number of Buildings on Parcel (see CAMA for detail)";
run;
*Merge all 3 CAMA files;
data cama_res_condo_comm;
set camarespt_bldg_1_record camacondopt_2013_08 (in=b drop=SALEDATE SALE_NUM USECODE cama_proptype LANDAREA PREMISEADD UNITNUMBER OWNERNAME OWNNAME2  X_COORD  Y_COORD)
	commpt_sum (in=c drop=_type_ rename=(_freq_=num_bldgs));

label  num_bldgs="Number of Buildings on Parcel" 
													  sum_gba="Total Gross Building Area" 
													  sum_units="Total Number of Units (all Buildings)" 
													  min_gba="Smallest Gross Building Area"
													  max_gba="Largest Gross Building Area"	
													  min_num_units ="Smallest Number of Units in a building"
													  max_num_units="Largest Number of Units in a building"
													  min_ayb="Earliest Actual Year Built"
													  max_ayb="Latest Actual Year Built"
													  min_eyb="Earliest Estimated Year Built"
													  max_eyb="Latest Actual Year Built";
if b then num_bldgs=.n;

run;
*check for dups = should be zero;
proc sort data=cama_res_condo_comm nodups;
by ssl;
run; 

*merge CAMA on to sales_master_forecl; 
proc sql ;
create table test_master_cama as
(select master.*, cama.*
from realpr_r.sales_master_forecl as  master left join cama_res_condo_comm as cama
on master.ssl=cama.ssl
)
;
*merge on block group ids;
proc sql ;
create table realpr_l.sales_master_cama_041614 as
(select master.*, geo.geobg2010, geo.geobg2000
from test_master_cama as  master left join realpr_r.parcel_geo as geo
on master.ssl=geo.ssl
)
;


quit;

