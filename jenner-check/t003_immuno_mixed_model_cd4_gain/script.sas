/* Adapted from immuno.sas (Sodinyessi/Program-SAS-and-models), lines 638-641.
   Original runs against abs_finale_24, built earlier in immuno.sas from
   immuno.labpat (a LIBNAME'd clinical drive). Here a small longitudinal
   CD4-gain table with the same columns (D_CD4, T1, T2, UID) is supplied
   inline so the piecewise-linear random-slopes mixed model -- the actual
   "modele lineaire mixte" this repo is named for -- fits unmodified. */

*Analyses univariees;
proc mixed data = abs_finale_24 method = ml noclprint covtest;
class UID ;
model D_CD4 = T1 T2 / noint s cl ddfm=bw outpred = p;
random  T1 T2/sub=UID type = UN;
estimate "gain CD4 M12 < 2 ans"  T1 12 T2 12  /cl;
run;
