/**************************************************************************
 Program:  Addr_parse_floor.sas
 Library:  RealProp
 Project:  DC Data Warehouse
 Author:   P. Tatian
 Created:  03/01/05
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro used by %Address_parse() macro to
 process floor specifications.

 Modifications:
  02/03/14 PAT  Updated for new SAS1 server.
**************************************************************************/

%macro Addr_parse_floor(num);
	 if i_&num.fl = 1 then
	  do;
		 _ap_temp_ad = substr(_ap_temp_ad, indexc(_ap_temp_ad," ")+1);
		 **f_flr = 1;
	  end;
	 else if i_&num.fl > 1 then
	  do;
		 _ap_temp_ad = trim(left( substr(_ap_temp_ad, 1, i_&num.fl-1) )); **first part of address (w/o fl);
		 **f_flr = 2;
	  end;
%mend Addr_parse_floor;

