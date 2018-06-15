/**************************************************************************
 Program:  Read_CAMA_2018_05.sas
 Library:  RealProp
 Project:  Urban-Greater DC
 Author:   L. Hendey
 Created:  
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Read latest CAMA files.

 Modifications: 
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )


%let filedate=2018-05; 
%let update_file = _2018_05;
%let revisions=New file. Data downloaded from opendata.dc.gov in 5-2018.;

/*Read in raw cama files*/
%Read_cama(filedate=&filedate., update_file=&update_file., revisions=&revisions.); 

