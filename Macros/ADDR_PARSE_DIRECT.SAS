/**************************************************************************
 Program:  Addr_parse_direct.sas
 Library:  RealProp
 Project:  DC Data Warehouse
 Author:   P. Tatian
 Created:  03/01/05
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro used by %Address_parse() macro to
 abbreviate directions if not a part of another word and not followed
 by AVE, RD, etc.

 Modifications:
  02/03/14 PAT  Updated for new SAS1 server.
**************************************************************************/

%macro Addr_parse_direct(d,len,wrd,abbr);

 if &d._index ^=0 then
  do;
     if indexc(substr(_ap_temp_ad,&d._index+&len.,1),"ABCDEFGHIJKLMNOPQRSTUVWXYZ")=0
     	and indexc(substr(_ap_temp_ad,&d._index-1,1),"ABCDEFGHIJKLMNOPQRSTUVWXYZ")=0 then
      do;
         if substr(_ap_temp_ad,&d._index+&len.+1,3)^="AVE" and
            substr(_ap_temp_ad,&d._index+&len.+1,2) not in ("RD","ST","DR","LN") then
          do;
             _ap_temp_ad=tranwrd(_ap_temp_ad, "&wrd.", " &abbr. ");
             **f_dir&d.= 1;
          end;
      end;
  end;

%mend Addr_parse_direct;

