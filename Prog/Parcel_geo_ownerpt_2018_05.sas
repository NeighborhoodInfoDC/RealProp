
/**************************************************************************
 Program:  Parcel_geo_ownerpt_2018_05.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  5-29-18
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description:  Update Parcel_geo with new parcels from Ownerpt.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )
%DCData_lib( MAR );


/** Update two parameters below **/

%let update_date = 2018_05;
%let revisions = Updated through 2018-05;


/** Don't need to edit this code **/

%let update_file = Ownerpt_&update_date.;

%Parcel_geo_update_new( update_file=&update_file, finalize=&finalize, keep_vars =
    ssl anc2002 anc2012 casey_nbr2003 casey_ta2003 city cjrtractbl cluster2000
	cluster_tr2000 eor geo2000 geo2010 geobg2000 geobg2010 geoblk2000 geoblk2010
	geoid10 psa2004 psa2012 ssl voterpre2012 ward2002 ward2012 x_coord y_coord zip
	cluster2017 stantoncommons bridgepk
);


/** Run Duplicate Check before Finalizing **/
%Dup_check(
  data=parcel_geo_&update_file.,
  by=ssl,
  id=SSL,
  out=_dup_check,
  listdups=Y,
  count=dup_check_count
)
