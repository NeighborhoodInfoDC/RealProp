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
    '140' = "State of Maryland"
    '141' = "Montgomery County"
    '142' = "Prince George's County"
    '143' = "Charles County"
    '144' = "Frederick County"
    '145' = "City of Gaithersburg"
    '146' = "City of Rockville"
    '147' = "City of Takoma Park"
    '150' = "Commonwealth of Virginia"
    '151' = "Arlington County"
    '152' = "Fairfax County"
    '153' = "City of Alexandria"
    '154' = "City of Fairfax"
    '155' = "City of Falls Church"
    '156' = "Loudoun County"
    '157' = "Prince William County"
    '158' = "City of Manassas"
    '159' = "City of Manassas Park"
  ;
	
run;

proc catalog catalog=RealProp.Formats;
  modify owncat (desc="Real property owner categories") / entrytype=formatc;
  contents;
quit;

run;
