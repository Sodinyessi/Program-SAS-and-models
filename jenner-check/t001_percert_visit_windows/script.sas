/* Adapted from percert.sas (Sodinyessi/Program-SAS-and-models), lines 1-55.
   Original reads `immuno.labpat`, built earlier in immuno.sas from a
   LIBNAME pointing at a local clinical data drive (P:\CD4_IEDEA\...).
   Here the same shape is supplied inline (mock stand-in for immuno.labpat,
   below) so the visit-window recoding and nearest-measurement selection
   logic run unmodified against sample rows. Several patients get two rows
   in the same visit window to exercise the nearest-measurement tie-break. */

data labpat;
  input UID $ cd4_U cd4_v mes_delai;
  datalines;
P01 2 34.5 -1
P01 2 33.0 1.5
P01 2 29.0 5.5
P01 2 26.5 10.0
P02 2 41.0 -2.0
P02 2 38.0 4.0
P02 2 36.5 8.0
P02 2 30.0 20.0
P03 2 22.0 -0.5
P03 2 21.0 2.0
P03 2 19.5 12.0
P04 2 55.0 0.0
P04 2 61.5 3.0
P04 2 48.0 7.0
P05 2 27.5 -1.5
P05 2 28.0 6.5
P05 2 25.0 13.5
P06 2 33.0 -2.5
P06 2 31.5 4.5
P06 1 950 -2.5
P06 1 1010 4.5
;
run;

*CD4 pourcentage;
data perct;
set labpat;
if cd4_U = 2 then output;
run;

*Supprimer valeur abberantes;
proc univariate data = perct;
var cd4_v;
run;

data perct ;set perct;
if cd4_v > 60 then delete;
run;

	*numeros de mesure;
data perct ;set perct;
by UID;
format mes_CD4 $16.;
if mes_delai >=-3 and mes_delai < 3 then mes_CD4 = "0_M0";
if mes_delai >= 3 and mes_delai < 9 then mes_CD4 = "1_M6";
if mes_delai >= 9 and mes_delai < 15 then mes_CD4 = "2_M12";
if mes_delai >= 15 and mes_delai < 21 then mes_CD4 = "3_M18";
if mes_delai >= 21 and mes_delai < 27 then mes_CD4 = "4_M24";
if mes_delai >= 27 and mes_delai <33 then mes_CD4 = "5_M30";
if mes_delai >= 33 and mes_delai < 39 then mes_CD4 = "6_M36";
if mes_delai >= 39 and mes_delai < 45 then mes_CD4 = "7_M42";
if mes_delai >= 45 and mes_delai < 51 then mes_CD4 = "8_M48";
if mes_delai >= 51 and mes_delai <57 then mes_CD4 = "9_M54";
if mes_delai >=57 and mes_delai < 63 then mes_CD4 = "99_M60";
if mes_delai >=63 then delete;
run;

	*si plusieurs mesures pour un intevalle, prendre celle qui se rapproche le plus;

data perct; set perct;
if mes_CD4 = "0_M0" then delai_CD4 = abs(0-mes_delai);
if mes_CD4 = "1_M6" then delai_CD4 = abs(6-mes_delai);
if mes_CD4 = "2_M12" then delai_CD4 = abs(12-mes_delai);
if mes_CD4 = "3_M18" then delai_CD4 = abs(18-mes_delai);
if mes_CD4 = "4_M24" then delai_CD4 = abs(24-mes_delai);
if mes_CD4 = "5_M30" then delai_CD4 = abs(30-mes_delai);
if mes_CD4 = "6_M36" then delai_CD4 = abs(36-mes_delai);
if mes_CD4 = "7_M42" then delai_CD4 = abs(42-mes_delai);
if mes_CD4 = "8_M48" then delai_CD4 = abs(48-mes_delai);
if mes_CD4 = "9_M54" then delai_CD4 = abs(54-mes_delai);
if mes_CD4 = "99_M60" then delai_CD4 = abs(60-mes_delai);
run;

proc sort data = perct;
by UID mes_CD4 delai_CD4;
run;
data perct; set perct;
by UID mes_CD4;
if first.mes_CD4 = 1 then output;
run;

proc print data = perct;
title "perct: one nearest CD4% measurement per patient per visit window";
run;

proc freq data = perct;
table mes_CD4;
title "Distribution of assigned visit windows";
run;
