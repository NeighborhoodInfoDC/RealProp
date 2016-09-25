/**************************************************************************
 Program:  Parcel_base_who_owns.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/12/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create ownership categories for real property parcels.
 
 NOTE: Workbook 
 "L:\Libraries\RealProp\Prog\Updates\Owner type codes & reg expr 09-28-11.xls"
 must be open in Excel before submitting this program.
 
 Runtime: Approximately 5 minutes.

 Modifications:
  10/12/14 PAT Updated for SAS1 server.
               Updated regular expressions to 09-28-11.
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )
%DCData_lib( MAR )


%Parcel_base_who_owns( 
  RegExpFile = Owner type codes & reg expr 09-28-11.txt
)

