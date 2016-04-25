
%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp );
%DCData_lib( MAR );


data old_parcel_geo;
	set realprop.parcel_geo;
	inpg = 1;
run;

proc sort data = old_parcel_geo; by ssl; run;


data Parcel_base_ownerpt_2016_04_all;
	set Parcel_base_ownerpt_2016_04;
run;

proc sort data = Parcel_base_ownerpt_2016_04_all; by ssl; run;


data mergegeo;
	merge Parcel_base_ownerpt_2016_04_all (in=a) old_parcel_geo;
	by ssl;
	if a;
run;


data PB_ownerpt_2016_04_retain;
	set mergegeo (where=(inpg=1));
run;

data PB_ownerpt_2016_04_needgeo;
		set mergegeo (where=(inpg^=1));
		
		/** Recode address to get rid of unit numbers **/
		newadd = LOWNUMBER || " " || ustreetname || QDRNTNAME;
run;


/** Use MAR geocoder to get missing geographies **/
%DC_mar_geocode(
  data = PB_ownerpt_2016_04_needgeo,
  staddr = newadd,
  out = PB_ownerpt_2016_04_geo
);



 data PB_ownerpt_2016_04_newgeo;
  	set PB_ownerpt_2016_04_geo 
		(drop= _matched_ _notes_ _score_  address_id end_apt
		m_addr m_city m_obs m_state m_zip newadd newadd_std x y )

	Pb_ownerpt_2016_04_retain (in=b);

	length City $ 1;
    city = "1";
    label city = "Washington, D.C.";

	if b then mar_matched = 0;
		else mar_matched = 1;
	label mar_matched = "Matched to Geography by MAR Geocoder";

	if b then GeoRec = 1 ;
		else if _status_ = "Found" then GeoRec = 1;
		else GeoRec = 0;
	Label GeoRec = "Geography Available for Record";


	 ** Tract-based neighborhood clusters **;
    
    %Block00_to_cluster_tr00()
    
    ** Casey target area neighborhoods **;
    
    %Tr00_to_cta03()
    %Tr00_to_cnb03()
    
    ** East of the river **;
    
    %Tr00_to_eor()

	 ** Voting precincts 2012 **;
    
    %Block10_to_vp12()

	format geo2000 $geo00a. anc2002 $anc02a. psa2004 $psa04a. ward2002 $ward02a.
     	   geo2010 $geo10a. anc2012 $anc12a. psa2012 $psa12a. ward2012 $ward12a./*Added 2012 vars 07/06/12 RAG*/
		   zip $zipa. cluster2000 $clus00a. city $city.;
    
    label
      CJRTRACTBL = "OCTO tract/block ID"
      Ssl = "Property Identification Number (Square/Suffix/Lot)"
    ;

	drop inpg _status_;
run;
