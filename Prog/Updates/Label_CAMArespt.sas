************************************************************************
* Program:  Label_CAMArespt.sas
* Library:  RealProp
* Project:  DC Data Warehouse
* Author:   B. Losoya
* Created:  3/4/2014
* Version:  SAS 9.3
* Environment:  SAS Server
* 
* Description:  Label variables in CAMArespt files
* Note: Most lots have one building in the cama file, assigned BLDG_NUM of one in the table. 
	For parcels where multiple buildings exist, the primary building (such as the main residence) is assigned BLDG_NUM = 1. 
	The other buildings or structures have BLDG_NUM values in random sequential order.
	After the primary structure, there is no way to associate BLDG_NUM > 2 records with any particular structure on the lot."
* Modifications:
************************************************************************;

label
 
  Ssl = "Property Identification Number (Square/Suffix/Lot)"
  Usecode = "Property Use Codes"
  Landarea = "Square footage of property from the recorded deed"
  Premiseadd = "Property street address excluding city & zipcode"
  Unitnumber = "Unit number, typically associated with condominiums"
  Ownername = "Property owner's name"
  ownname2 = "2nd property owner's name"
  Price = "Most recent property sale price"
  x_coord = "Longitude of parcel center (MD State Plane Coord., NAD 1983 meters)"
  y_coord = "Latitude of parcel center (MD State Plane Coord., NAD 1983 meters)"
  	AC = "Air conditioning in residence"
	AYB = "The earliest time the main portion of the building was built. It is not affected by subsequent construction."
	BATHRM = "Number of bathrooms"
	BEDRM = "Number of bedrooms"
	BLDG_NUM = "Building Number" 
	CNDTN = "Condition code"
	CNDTN_D = "Condition description"
	EXE_CODE = "EXE_Code (blank for Comm)"
	EXTWALL = "Exterior wall code"
	EXTWALL_D = "Exterior wall description"
	EYB = "The calculated or apparent year, that an improvement was built that is most often more recent than actual year built."
	FIREPLACES = "Number of fireplaces"
	GBA = "Gross building area in square feet"
	GRADE = "Grade code"
	GRADE_D = "Grade Description"
	HEAT = "Heat type code"
	HEAT_D = "Heating type description"
	HF_BATHRM = "Number of half bathrooms"
	INTWALL = "Interior wall code"
	INTWALL_D = "Interior wall description"
	KITCHENS = "Number of kitchens"
	LIVING = "Livable square footage of a residence."
	NUM_UNITS = "Number of units"
	QUALIFIED = "Qualified"
	ROOF = "Roof type code"
	ROOF_D = "Roof type description"
	ROOMS = "Number of rooms"
	SALE_NUM = "Sale number (always 1 to get most recent sale)"
	SALEdate = "Date of Sale"
	STORIES = "Number of stories in primary dwelling"
	STRUCT = "Structure code"
	STRUCT_D = "Structure description"
	STYLE = "Style code"
	STYLE_D	= "Style description"
	YR_Rmdl = "Last year residence was remodeled"
	

	;

