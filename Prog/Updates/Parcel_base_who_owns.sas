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

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )
%DCData_lib( MAR )


proc format library=work;
  value $OwnCat
    '010' = 'Single-family owner-occupied'
    '020' = 'Multifamily owner-occupied'
    '030' = 'Other individuals'
    '040' = 'DC government'
    '045' = 'DC Housing Authority'
    '050' = 'US government'
    '060' = 'Foreign governments'
    '070' = 'Quasi-public entities'
    '080' = 'Community development corporations/organizations'
    '090' = 'Private universities, colleges, schools'
    '100' = 'Churches, synagogues, religious'
    '110' = 'Corporations, partnership, LLCs, LLPs, associations'
    '111' = 'Nontaxable corporations, partnerships, associations'
    '115' = 'Taxable corporations, partnerships, associations'
    '120' = 'Government-Sponsored Enterprise'
    '130' = 'Banks, Lending, Mortgage and Servicing Companies'
  ;
	
run;

data Parcel_base;

  set RealProp.Parcel_base (obs=1000);
  
run;


** NOTE: Leave Revisions= parameter blank when just doing a regular update **;

%Parcel_base_who_owns(
  inlib=realprop,
  data=Parcel_base,
  RegExpFile=&_dcdata_default_path\RealProp\Prog\Updates\Owner type codes reg expr.txt,
  Revisions= 
  )

