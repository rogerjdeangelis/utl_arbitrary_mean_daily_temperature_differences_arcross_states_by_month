Arbitrary mean daily temperature differences arcross states by month

see github
https://goo.gl/FaAdex
https://github.com/rogerjdeangelis/utl_arbitrary_mean_daily_temperature_differences_arcross_states_by_month

see
https://listserv.uga.edu/cgi-bin/wa?A2=SAS-L;d4df31.1802c

If you are just interested in the mean differences?

ALC is temperature
Time is month
GRP is state fips

I changed 46 to 4 for simplicity

Original spec
That is, I want 4 values of (mean group 1 - mean group2) and 46 values of (mean group 1 - mean group3)?

TWO SOLUTIONS

    1. Single proc report output dataset
    2. proc means, proc transpose and datastep

    3. Not shown: With proc corresp you can do it in two steps, proc corresp then datastep
    4. Can also do it with a single DOW loop (need sort order below but not flexible)

HAVE
====

 WORK.HAVE total obs=36

   TIME  GRP  REPS     ALC  |  RULE
                            |  For time 1 calculate mean grp1 - mean grp2
     1    1     1      186  |                       mean grp1 - mean grp3
     1    1     2      181  |
     1    1     3       -4  |  363/3 = 121
                            |
     1    2     1      192  |
     1    2     2      245  |
     1    2     3      139  |  576/3  = 192   g12= 121-192 = -71
                            |
     1    3     1      320  |
     1    3     2      299  |
     1    3     3      326  |  945/3  = 315   g13= 121 -315 = 194
                            |
     2    1     1       -5  |
     2    1     2      -74  |
     2    1     3      156  |
                            |
     2    2     1      170  |
     2    2     2      232  |
     2    2     3      259  |
                            |
     2    3     1      357  |
     2    3     2      365  |
     2    3     3      557  |
                            |
     3    1     1      -46  |
     3    1     2      126  |
     3    1     3       34  |
                            |
     3    2     1      293  |
     3    2     2      144  |
     3    2     3      104  |
                            |
     3    3     1      314  |
     3    3     2      339  |
     3    3     3      290  |
                            |
     4    1     1      141  |
     4    1     2       93  |
     4    1     3      -82  |
                            |
     4    2     1      278  |
     4    2     2      136  |
     4    2     3      209  |
                            |
     4    3     1      314  |
     4    3     2      291  |
     4    3     3      168  |


PROCESS  (both produce output datasets)
========================================

 1. Single proc report output dataset

   * as a by product you do get a nice report;
   proc report data=have nowd missing out=want
         (rename=(_c2_=g1 _c3_=g2 _c4_=g3));
   cols time (grp),(alc) g12 g13;
   define time / group;
   define grp / across;
   define alc / analysis mean;
   define g12 / computed;
   compute g12;g12=_c2_-_c3_;endcompute;
   compute g13;g13=_c2_-_c4_;endcompute;
   run;quit;

 2. proc means, proc transpose and datastep (advantage uclm and lclm)
    Proc report does not support uclm and lclm;

    proc means data = have;
    class time grp;
    var alc;
    output out = havAvg mean = mean uclm = upper lclm = lower;
    run;

    proc transpose data=havAvg prefix=avgGrp out=havXpo(drop=_:);
    id grp;
    var mean;
    by time;
    where _type_=3;
    run;

    data want;
       set havXpo;
       g12 = AVGGRP1  -  AVGGRP2 ;
       g13=  AVGGRP1  -  AVGGRP3 ;
    run;quit;


OUTPUT
======

 1. Single proc report output dataset

   WORK.WANT total obs=4

   TIME       G1         G2         G3         G12         G13

     1     121.000    192.000    315.000     -71.000    -194.000
     2      25.667    220.333    426.333    -194.667    -400.667
     3      38.000    180.333    314.333    -142.333    -276.333
     4      50.667    207.667    257.667    -157.000    -207.000

  2. proc means, proc transpose and datastep

   TIME    AVGGRP1    AVGGRP2    AVGGRP3       G12         G13

     1     121.000    192.000    315.000     -71.000    -194.000
     2      25.667    220.333    426.333    -194.667    -400.667
     3      38.000    180.333    314.333    -142.333    -276.333
     4      50.667    207.667    257.667    -157.000    -207.000

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data have;
  call streaminit(1234);
  do grp=1 to 3;
   do time=1 to 4;
     do reps=1 to 3;
      alc=int(100*rand('normal',grp,1));
      output;
     end;
    end;
  end;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __  ___
/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
\__ \ (_) | | |_| | |_| | (_) | | | \__ \
|___/\___/|_|\__,_|\__|_|\___/|_| |_|___/

;

see above
