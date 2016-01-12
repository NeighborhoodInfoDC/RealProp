/**************************************************************************
 Program:  Square_geo.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  03/27/08
 Version:  SAS 9.1
 Environment:  Local Windows session (desktop)
 
 Description:  Create crosswalk between real property squares and DC
 geographies (for use in adding geography to foreclosure notices).
 Register with metadata.
 
 NB: File has no numeric vars, so metadata process has errors. They can
     be ignored.

 Modifications:
  12/18/08 PAT  Updated with Ownerpt_2008_11.
                Added inactive squares.
  07/31/12 RAG  Updated to include 2010 and 2012 geographies.
  01/14/14 PAT  Updated for new SAS1 server.
  03/28/14 PAT  Added voterpre2012 to geo vars. 
  03/29/14 PAT  Corrected problem with libraries defaulting to local. 
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Realprop )


** Start submitting commands to remote server **;

/**rsubmit;**/

%let revisions = Added var voterpre2012 to data set.;

%let geos = anc2002 casey_nbr2003 casey_ta2003 city cluster2000 cluster_tr2000
            cjrtractbl eor psa2004 ward2002 zip geo2000 geoblk2000
			anc2012 psa2012 ward2012 geo2010 geoblk2010 voterpre2012;

data A (compress=no);

  merge Realpr_r.parcel_geo (in=in1)
    Realpr_r.parcel_base (keep=ssl in_last_ownerpt landarea);
  by ssl;

  where ssl not =: "PAR";

  *if in1 and in_last_ownerpt;
  if in1 and not( missing( /*ward2002*/ ward2012 ) );

  length square $ 8;

  square = scan( ssl, 1 );

  label square = "Property square/suffix";

run;

proc summary data=A nway;
  var landarea;
  by square;
  class in_last_ownerpt &geos;
  output out=square sum=;

proc sort data=square;
  by square descending in_last_ownerpt descending landarea;

data Realpr_r.Square_geo (label="DC real property squares - geographic identifiers" sortedby=square);

  set square (drop=_type_ _freq_ landarea);
  by square;

  if first.square;

run;

%File_info( data=Realpr_r.Square_geo, stats=, freqvars=ward2002 cluster_tr2000 geo2000 ward2012 geo2010 voterpre2012)

** Register metadata **;

%Dc_update_meta_file(
  ds_lib=RealProp,
  ds_name=Square_geo,
  creator_process=Square_geo.sas,
  restrictions=None,
  revisions=%str(&revisions)
)

run;

/**endrsubmit;**/

** End submitting commands to remote server **;

/**signoff;**/

