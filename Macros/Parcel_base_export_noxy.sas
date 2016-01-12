/**************************************************************************
 Program:  Parcel_base_export_noxy.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/03/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to export parcels not listed in
 Parcel_geo to mapping file for assigning geographies.

 Modifications:
  02/12/07 PAT  Created SAS 9 version with no DBMS/Engines support.
                SAS data set must be converted to DBF with DBMS/Copy.
  12/19/13 PAT  Updated for new SAS1 server.
**************************************************************************/

/** Macro Parcel_base_export_noxy - Start Definition **/

%macro Parcel_base_export_noxy( update_file= );

  %if %Dataset_exists( Pb_nogeo_&update_file._xy, quiet=N ) %then %do;
  
    options noxwait;
  
    x "md &_dcdata_r_path\RealProp\Maps\&update_file";

    libname xfile "&_dcdata_r_path\RealProp\Maps\&update_file";

    data xfile.Pb_nogeo_&update_file._xy (compress=no);
      set Pb_nogeo_&update_file._xy;
    run;

    /******
    libname dbmsdbf dbdbf "D:\DCData\Libraries\RealProp\Maps\&update_file" ver=4 width=12 dec=2
      update=Pb_nogeo_&update_file._xy;

    data dbmsdbf.update;
      set Pb_nogeo_&update_file._xy;
    run;
    ******/
    
  %end;

%mend Parcel_base_export_noxy;

/** End Macro Definition **/

