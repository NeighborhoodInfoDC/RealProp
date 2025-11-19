/**************************************************************************
 Program:  Parcel_base_who_owns.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/12/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create ownership categories for real property parcels.
 
 Runtime: Approximately 5 minutes.

 Modifications:
  10/12/14 PAT Updated for SAS1 server.
               Updated regular expressions to 09-28-11.
  10/7/16 RP Update for Sept-2016 parcel base
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )
%DCData_lib( MAR )


** NOTE: Revisions= parameter should be blank when doing a regular Parcel_base update **;

%Parcel_base_who_owns(
  RegExpFile=&_dcdata_default_path\RealProp\Prog\Updates\Owner type codes reg expr.txt,
  Revisions=%str(Fix issue with new Premiseadd values.)  
  )

