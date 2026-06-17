/**************************************************************************
 jenner-check bundle: Ownername_full (RealProp/Macros/Ownername_full.sas)

 %Ownername_full() is an autocall macro that builds a combined owner-name
 variable from the parcel ownership file's `ownername` and `ownname2`
 fields: it upcases both, replaces '+' with '&', collapses blanks, and joins
 the two names with " + " when a second owner is present. This bundle
 inlines the macro exactly as written upstream and calls it in a DATA step
 over a small mock ownership extract that exercises each branch (single
 owner, two owners, and a name containing '+').
**************************************************************************/

%macro Ownername_full( var=Ownername_full, Ownname2_exists=Y );

  %let Ownname2_exists = %upcase( &Ownname2_exists );

  %let ownername = left( compbl( upcase( translate( ownername, '&', '+' ) ) ) );
  %let ownname2 = left( compbl( upcase( translate( ownname2, '&', '+' ) ) ) );

  length &var $ 150;

  %if &Ownname2_exists = Y %then %do;
    if ownname2 = '' then &var = &ownername;
    else &var = trim( &ownername ) || ' + ' || &ownname2;
  %end;
  %else %do;
    &var = &ownername;
  %end;

  label &var = "Name(s) of property owners";

%mend Ownername_full;

/* Mock ownership extract (the real pipeline reads the DC ownerpt file).
   Pipe-delimited so multi-word names stay intact; ownname2 is blank for
   single-owner parcels. */
data ownerpt;
  length ssl $ 12 ownername $ 60 ownname2 $ 60;
  infile datalines dsd dlm='|';
  input ssl $ ownername $ ownname2 $;
  datalines;
0001-0001|smith  john|smith  mary
0002-0014|dc government|
0010-0100|lee  david + lin  ann|
0044-0007|columbia heights llc|jones  robert
0055-0033|nguyen  thanh|
;
run;

/* Combine names with both branches exercised (Ownname2_exists=Y). */
data ownerpt_named;
  set ownerpt;
  %Ownername_full()
run;

proc print data=ownerpt_named label noobs;
  var ssl ownername ownname2 Ownername_full;
  title "Combined owner names built with RealProp %Ownername_full";
run;
