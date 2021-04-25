/**************************************************************************
 Program:  Format_$owncat.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/12/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create $owncat format for real property owner categories.

 Modifications:
**************************************************************************/

%include "\\sas1\DCdata\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp, local=n )

proc format library=RealProp;
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
    '140' = 'State of Maryland'
    '141' = 'Montgomery County, MD'
    '142' = "Prince George's County, MD"
    '145' = 'Gaithersburg city, MD'
    '146' = 'Rockville city, MD'
    '147' = 'Takoma Park city, MD'
    '151' = 'Arlington County, VA'
    '152' = 'Fairfax County, VA'
    '154' = 'Fairfax city, VA'
    '155' = 'Falls Church city'
    '156' = 'Park Authority Northern VA'
  ;
	
run;

proc catalog catalog=RealProp.Formats;
  modify owncat (desc="Real property owner categories") / entrytype=formatc;
  contents;
quit;

run;
