


%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp );
%DCData_lib( mar );


data z2;
	set Itspe_facts;
	rename objectid=objectid2
			landarea = landarea2
			taxrate = taxrate2
			vacant_use=vacant_use2
			mixed_use=mixed_use2
			address_id=address_id2
			deed_date=deed_date2;;
run;

data z3;
	set Itspe_property_sales;
	rename objectid=objectid3
			landarea = landarea3
			taxrate = taxrate3
			vacant_use=vacant_use3
			mixed_use=mixed_use3
			address_id=address_id3
			deed_date=deed_date3;
run;

data geoin ;
	set Parcel_base_ownerpt_2016_04;
	newadd = LOWNUMBER || " " || ustreetname || QDRNTNAME;
run;




%DC_mar_geocode(
  data = geoin,
  staddr = newadd,
  out = geotest
);

data geotest2;
	if _STATUS_ ^= "FOUND" then _STATUS_ = "NOT FOUND";
run;


proc sort data = geotest; by _score_; run;

proc freq data = geotest2;
	tables _STATUS_;
run;
