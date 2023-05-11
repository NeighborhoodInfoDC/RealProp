/**************************************************************************
 Program:  Geo_vars.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/06/09
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to add geographic identifiers to 
 sales transaction file.

 Modifications:
  12/31/13 PAT  Updated for new SAS1 server.
  5/11/23 RP Changed Realprop to Realpr_r
**************************************************************************/

%macro Geo_vars( inds=, outds= );

** Add geographic vars & update fixed parcel characteristics **;

data &outds;

  merge 
    &inds (in=in1 drop=&update_fixed_vars)
    Realpr_r.Parcel_base (keep=ssl &update_fixed_vars)
    Realpr_r.Parcel_geo;
  by ssl;

  if in1;

run;

%mend Geo_vars;


