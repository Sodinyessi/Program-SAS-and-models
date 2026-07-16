options obs=100; /* cap input rows for the captured run */

/* Mock stand-in for abs_finale_24 (built earlier in immuno.sas from
   immuno.labpat): one row per CD4 measurement per patient, D_CD4 = CD4
   change from ART baseline, T1/T2 the piecewise-linear time split used
   throughout this repo's mixed models (T1 = time capped at 6 months,
   T2 = time beyond 6 months). Multiple visits per UID give PROC MIXED
   within-patient variation to fit the random slopes against. */
data abs_finale_24;
  input UID $ D_CD4 T1 T2;
  datalines;
P01 0    0  0
P01 120  6  0
P01 180  6  6
P01 210  6 12
P02 0    0  0
P02 90   6  0
P02 140  6  6
P02 160  6 12
P03 0    0  0
P03 150  6  0
P03 205  6  6
P03 260  6 12
P04 0    0  0
P04 60   6  0
P04 95   6  6
P04 110  6 12
P05 0    0  0
P05 100  6  0
P05 165  6  6
P05 190  6 12
P06 0    0  0
P06 80   6  0
P06 130  6  6
P06 155  6 12
;
run;
