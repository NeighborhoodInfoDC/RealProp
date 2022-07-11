/**************************************************************************
 Program:  Parcel_geo_ownerpt_2022_06.sas
 Library:  RealProp
 Project:  Urban-Greater DC
 Author:   Rob Pitingolo
 Created:  6/28/22
 Version:  SAS 9.4
 Environment:  Windows
 
 Description:  Update Parcel_geo with new parcels from Ownerpt.

 Modifications:
**************************************************************************/

%include "\\SAS1\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )
%DCData_lib( MAR );

/** Update two parameters below **/

%let update_date = 2022_06;
%let revisions = Updated through 2022-06;

/** Don't need to edit this code **/

%Parcel_geo_update_mar(update_date = &update_date.,
	geo_vars = ssl x_coord y_coord
    Address_id anc2002 anc2012 city cluster2000 cluster2017
	cluster_tr2000 eor geo2000 geo2010 geo2020 geobg2020 geoblk2020
	psa2004 psa2012 psa2019 voterpre2012 ward2002 ward2012 ward2022 zip,
	revisions = &revisions.
);

/** Run Duplicate Check before Finalizing **/
%Dup_check(
  data=Parcel_geo_update,
  by=ssl,
  id=SSL,
  out=_dup_check,
  listdups=Y,
  count=dup_check_count
)
