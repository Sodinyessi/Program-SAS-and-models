options obs=100; /* cap input rows for the captured run */

/* Mock stand-in for the patients_perct patient-level table (one row per
   child, built earlier in percert.sas by merging immuno.patients with the
   selected CD4 measurements). birth_d/art_sd are SAS date values (days);
   cd4_v here is the baseline CD4% used by the WHO age/CD4 banding logic. */
data patients_perct;
  format birth_d art_sd date9.;
  input UID $ birth_d :date9. art_sd :date9. center $ country $ gender $ stage_WHO_ART Hb_ART cd4_v;
  datalines;
P01 04JAN2018 02JAN2020 Bamako Mali M 2 10.5 18
P02 15MAR2017 10FEB2020 Bamako Mali F 3 9.2 22
P03 22JUL2019 01AUG2020 Abidjan CoteIvoire M 1 11.8 33
P04 09SEP2015 12DEC2019 Abidjan CoteIvoire F 4 7.5 12
P05 30NOV2020 05JAN2021 Dakar Senegal M 2 10.1 27
P06 18FEB2014 20MAR2020 Dakar Senegal F 9 8.8 19
P07 25MAY2019 01JUN2020 Bamako Mali M 1 12.4 40
P08 11OCT2016 15NOV2020 Abidjan CoteIvoire F 2 9.9 16
;
run;
