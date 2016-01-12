/**************************************************************************
 Program:  Read_ownerpt_2012_01.sas
 Library:  RealProp
 Project:  NeighborhoodInfo DC
 Author:   
 Created:  
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read latest owner point file.

 Modifications: 
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp );

%Read_ownerpt_macro( 

  /** Input file information **/
  inpath=D:\DCData\Libraries\RealProp\Raw\2012-01,
  infile=OwnerPt,
  intype=sas7bdat,
  
  /** Name of previous ownerpt data set **/
  prev_file=Ownerpt_2011_10,
  
  /** List duplicate record numbers to delete here **/
  del_dup_recs=538
815
81123
82056
191179
193699
193700
193804
193871
193872
193873
193874
193975
193976
194078
194079
194080
194081
194082
194083
194121
194284
194285
194286
194287
194288
194801
194802
194803
194804
194805
194824
194825
194896
194897
194904
194905
194906
194907
194908
194909
194916
194917
194918
194919
194920
194921
194923
194924
194931
194932
194933
195000
195001
195002
195003
195004
195006
195007
195008
195009
195010
195011
195012
195099
195100
195101
195102
195104
195108
195114
195115
195219
195221
195228
195229
195258
195324
195325
195327
195328
195329
195348
195349
195440
195443
195455
195456
195463
195552
195569
195570
195571
195572
195573
195574
195575
195576
195586
195588
195589
195649
195684
195685
195686
195687
195688
195689
195690
195691
195692
195697
195702
195705
195707
195708
195743
195744
195754
195755
195756
195757
195758
195759
195760
195790
195793
195796
195798
195799
195800
195801
195802
195803
195806
195808
195854
195894
195895
195905
195906
195908
195909
195910
195911
195931
196004
196005
196006
196014
196030
196040
196114
196115
196116
196117
196145
196243
196244
196245
196254
196329
196332
196333
196334
196335
196336
196337
196338
196339
196340
196341
196353
196354
196400
196425
196426
196427
196428
196429
196430
196431
196432
196433
196434
196435
196436
196437

  ,
  
  /** List data corrections here **/
  corrections=
      
);

