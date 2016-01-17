/**************************************************************************
 Program:  Read_itspe_files.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  01/16/16
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Read ITSPE test download files.

 Modifications:
**************************************************************************/

/**%include "L:\SAS\Inc\StdLocal.sas";**/
%include "C:\DCData\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( RealProp )

/** Macro Read - Start Definition **/

%macro Read( file );

  filename fimport "C:\DCData\Libraries\RealProp\Raw\Test 01-08-16\&file..csv" lrecl=2000;

  proc import out=RealProp.&file.
      datafile=fimport
      dbms=csv replace;
    datarow=2;
    getnames=yes;
    guessingrows=1000;

  run;

  filename fimport clear;

  %File_info( data=RealProp.&file. )

  run;

%mend Read;

/** End Macro Definition **/

%Read( ITSPE_Facts )

%Read( ITSPE_Facts_2 )

%Read( ITSPE_Facts )

%Read( ITSPE_PROPERTY_SALES )

%Read( ITSPE_VACANT_PROPERTY )



