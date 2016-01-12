/**************************************************************************
 Program:  Sales_master_forecl.sas
 Library:  Realprop
 Project:  NeighborhoodInfo DC
 Author:   L. Hendey
 Created:  01/07/11
 Version:  SAS 9.2
 Environment:  Remote Windows session (SAS1)
 
 Description:  Create sales transaction history file with foreclosure records.

 Modifications: 02/06/11 LH New File.
 		03/03/11 LH Updated with Sales through 01/04/11 and Forecl through 12/31/10.
 		10/14/11 LH Updates ui_proptype, sales through 6/01/11, Forecl through 03/31/11.
 		11/15/11 LH Updates Sales through 09/29/11, Forecl through 06/30/11.
 		04/06/12 LH Updates Sales through 12/28/11, Forecl through 09/30/11.
 		08/27/12 LH Updates Sales through 05/12/12, Forecl through 03/31/12.
 		11/21/12 LH Updates Sales through 07/16/12, Forecl through 06/30/12.
 		04/25/12 LH Updates Sales through 12/31/12, Forecl through 12/31/12. Adds Defaults.
		02/26/14 LH Updates Sales through 08/13/13, Forecl through 06/30/13. Updates for SAS1. 
		08/12/14 LH Updates Sales through 12/27/13, Forecl through 12/31/13.
**************************************************************************/

%include "F:\DCData\SAS\Inc\StdRemote.sas";

** Define libraries **;
%DCData_lib( Rod )
%DCData_lib( RealProp )

/***Make sure to archive sales_master_forecl before finalizing***/

%Create_sales_master_forecl(
  finalize= Y,
  RegExpFile = Owner type codes & reg expr 09-28-11.xls,
  start_dt = '01jan1990'd,
  end_dt = '31dec013'd,
  end_date=12/31/13,
  revisions = %str(Updates Sales through 12/27/13, Forecl through 12/31/13.)
   )

run;
