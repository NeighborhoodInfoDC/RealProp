/**************************************************************************
 Program:  Parcel_geo_ownerpt_2018_09.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   W. Oliver
 Created:  
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Update Parcel_geo with new parcels from Ownerpt.

 Modifications:
  07/27/14 PAT  Added local=n parameter to %DCData_lib() to prevent 
                creation of local library reference. 
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp)
%DCData_lib( MAR)


/** Update two parameters below **/

%let update_date = 2018_09;
%let revisions = Updated through 2018-09;


/** Don't need to edit this code **/


%Parcel_geo_update_new(keep_vars =
    ssl anc2002 anc2012 casey_nbr2003 casey_ta2003 city cjrtractbl cluster2000
	cluster_tr2000 eor geo2000 geo2010 geobg2000 geobg2010 geoblk2000 geoblk2010
	geoid10 psa2004 psa2012 ssl voterpre2012 ward2002 ward2012 x_coord y_coord zip
	cluster2017 stantoncommons bridgepk
);


/** Run Duplicate Check before Finalizing **/
%Dup_check(
  data=parcel_geo_ownerpt_&update_date.,
  by=ssl,
  id=SSL,
  out=_dup_check,
  listdups=Y,
  count=dup_check_count
)
