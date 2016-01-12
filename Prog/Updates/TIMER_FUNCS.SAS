/** Macro Start_timer - Start Definition **/

%macro Start_timer( num=0, label=, quiet=N );

  %global _timer_start_time&num _timer_end_time&num _timer_label&num;

  %if &label ~=  %then %let _timer_label&num = / &label;
  %else %let _timer_label&num = ;

  %let _timer_start_time&num = %sysfunc( datetime() );
  
  %if %upcase( &quiet ) = N %then %do;
    %note_mput( macro=Start_timer, msg=Timer &num started: %sysfunc( putn( &&&_timer_start_time&num, datetime20.2 ) ) &&&_timer_label&num )
  %end;

%mend Start_timer;

/** End Macro Definition **/

/** Macro Check_timer - Start Definition **/

%macro Check_timer( num=0, quiet=N );

  %let _timer_end_time&num = %sysfunc( datetime() );
  %let elapsed = %sysevalf( &&&_timer_end_time&num - &&&_timer_start_time&num );

  %if %upcase( &quiet ) = N %then %do;
    %note_mput( macro=Check_timer, msg=Timer &num check: %sysfunc( putn( &&&_timer_end_time&num, datetime20.2 ) ) &&&_timer_label&num )
    %note_mput( macro=Check_timer, msg=Elapsed time: %sysfunc( putn( &elapsed, time12.2 ) ) &&&_timer_label&num )
  %end;

%mend Check_timer;

/** End Macro Definition **/

