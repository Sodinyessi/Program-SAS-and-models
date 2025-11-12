*CD4 pourcentage;
data perct;
set immuno.labpat;
if cd4_U = 2 then output;
run;
*Supprimer valeur abbérentes;
proc univariate data = perct;
var cd4_v;
run;

data perct ;set perct;
if cd4_v > 60 then delete;
run;

	*numéros de mesure;
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

	*Isoler patients qui n'ont pas de M0 et voir s'ils ont CD4_art;
data test;set perct;
by UID;
if first.UID then output;
run;
proc freq data = test;
table mes_CD4;
run;
data patients_perct_1;set test;
if mes_CD4 ne "0_M0" then output;
run;
data patients_perct_2;set test;
if mes_CD4 = "0_M0" then output;
run;
*Supprimer patients parmi ceux qui n'ont pas de M0 ceux qui n'ont pas de cd4_art;
data patients_perct_1; set patients_perct_1;
if cd4p_art <0 then delete;
run;
*Ajouter une ligne pour M0 et cd4_v = cd4p_art et cd4_d = art_sd;
DATA test;
SET patients_perct_1 patients_perct_1;
run;
proc sort data= test;
by UID;
run;
data test_1; set test;
by UID;
if first.UID = 1 then mes_CD4 = "0_M0";
run;
data test_1; set test_1;
if mes_CD4 = "0_M0" then cd4_v = cd4p_art;
run;
data test_1; set test_1;
if mes_CD4 = "0_M0" then cd4_d = art_sd;
run;

*Isoler la première ligne;
data test_1;set test_1;
if mes_cd4 = "0_M0" then output;
run;
*Concaténation avec les autres patients;
data test_2; set test_1 patients_perct_2;
run;


*Isoler les numéros de patients;
data test_pat;set test_2;
keep UID;
run;

*Créer table CD4 avec que ceux qui ont une mesure M0 au moins;
proc sort data = perct;
by UID;
run;
proc sort data = test_pat;
by UID;
run;
data perct_1; 
merge test_pat (in = c) perct;
by UID;
if c;
run;
*Ajouter les M0 crée pour les 40 patients qui avant des cd4_art et pas de trace dans lab_cd4;
data perct_2;
set perct_1 test_1;
run;
*Sélectionner les patients qui ont au moins deux mesures;

proc sql;
	create table perct_3
	as
	SELECT *,  COUNT(MES_CD4)as nbre_cd4 
	FROM perct_2
	GROUP BY UID;
quit;

data perct_4;set perct_3;
if nbre_cd4 < 2 then delete;
run;
proc sort data = perct_4;
by UID CD4_d;
run;
*Description;

data patients_perct;set perct_4;
by UID;
if first.UID then output;
run;

proc freq data = patients_perct;
table mes_CD4;
run;

*AGE;
data patients_perct; set patients_perct;
age = (art_sd - birth_d) / 365.25;
run;
proc freq data = patients_perct;
table center*country;
run;
proc means data = patients_perct median Q1 Q3;
var age;
run;
proc means data = patients_perct median Q1 Q3;
class center;
var age;
run;
data patients_perct; set patients_perct;
if age <2 then cl_age = 1;
if age>=2 and age<3 then cl_age = 2;
if age>=3 and age<5 then cl_age = 3;
if age>=5 and age<10 then cl_age = 4;
if age>=10 then cl_age = 5;
run;
proc freq data = patients_perct;
table cl_age;
run;

*GENDER;
proc freq data = patients_perct;
table gender;
run;

*WHO clinical stage;
data patients_perct; set patients_perct;
if stage_WHO_ART = 9 then stage_WHO_ART = 99;
run;
proc freq data = patients_perct;
table stage_WHO_ART;
run;

*HB count; ;
proc univariate data = patients_perct;
var Hb_ART;
run;
proc univariate data = patients_perct;
where Hb_ART < 8;
var Hb_ART;
run;

*Baseline CD4_abs;
proc means data = patients_perct median Q1 Q3;
var cd4_v;
run;
proc means data = patients_perct median Q1 Q3;
class center;
var cd4_v;
run;

*WHO classif (according to WHO);
data patients_perct; set patients_perct;
if (age < 1 and cd4_v < 25) then cd4_cl = 3;
if ((age >= 1 and age < 2) and cd4_v <20) then cd4_cl = 3;
if ((age >= 2 and age <5) and cd4_v < 15) then cd4_cl = 3;
if (age >=5 and cd4_v < 15) then cd4_cl = 3;

if (age < 1 and (cd4_v >= 25 and cd4_v < 35)) then cd4_cl = 2;
if ((age >= 1 and age < 2) and (cd4_v >= 20 and cd4_v < 30)) then cd4_cl = 2;
if ((age >= 2 and age < 5) and (cd4_v >= 15 and cd4_v < 25)) then cd4_cl = 2;
if (age >= 5 and (cd4_v >= 15 and cd4_v <20)) then cd4_cl = 2;

if (age < 1 and cd4_v >=35) then cd4_cl = 1;
if ((age >= 1 and age < 2) and cd4_v >= 30) then cd4_cl =1 ;
if ((age >= 2 and age < 5) and cd4_v >= 25) then cd4_cl =1 ;
if (age >=5 and cd4_v >= 20) then cd4_cl = 1;

run;
proc freq data = patients_perct;
table cd4_cl;
run;
proc means data = patients_perct median Q1 Q3;
where mes_CD4 = "0_M0";
class cd4_cl;
var cd4_v;
run;

*ART regimen;
data patients_perct;
set patients_perct;
if regime_art>2 then regime_art = 3;
run;
proc freq data = patients_perct;
table regime_art;
run;

*Outcome;
proc freq data = patients_perct;
table outcome*cd4_cl;
run;

*FU_time;
data patients_perct; set patients_perct;
FU_time = (last_contact - art_sd)/365.25;
run;
proc univariate data = patients_perct;
var FU_time;
run;
proc sql;
	SELECT  SUM(FU_time) 
FROM patients_perct;
quit;
proc sql;
	SELECT cl_age, SUM(FU_time) 
FROM patients_perct
	GROUP BY cl_age;
quit;
proc sql;
	SELECT cd4_cl, SUM(FU_time) 
FROM patients_perct
	GROUP BY cd4_cl;
quit;



*Distribution of median CD4 by time since ART initiation;
proc sort data = patients_perct;
by UID;
run;
data perct_5; set perct_4;
keep UID cd4_d cd4_v mes_CD4;
run;
proc sort data = perct_5;
by UID;
run;

 data perct_finale;
 merge patients_perct (in=c)perct_5;
 by UID;
 if c;
 run;


proc sort data = perct_finale;
by UID mes_CD4;
run;

proc means data = perct_finale median Q1 Q3;
class mes_CD4;
var cd4_v;
run;
data perct_finale;set perct_finale;
if mes_CD4 = "0_M0" then mvist = 0;
if mes_CD4 = "1_M6" then mvist = 6;
if mes_CD4 = "2_M12" then mvist = 12;
if mes_CD4 = "3_M18" then mvist = 18;
if mes_CD4 = "4_M24" then mvist = 24;
if mes_CD4 = "5_M30" then mvist = 30;
if mes_CD4 = "6_M36" then mvist = 36;
if mes_CD4 = "7_M42" then mvist = 42;
if mes_CD4 = "8_M48" then mvist = 48;
if mes_CD4 = "9_M54" then mvist = 54;
if mes_CD4 = "99_M60" then mvist = 60;
run;
*Suivi à 24 mois;
data perct_finale_24; set perct_finale;
if FU_time >= 2 then FU_time_24 = 2; else FU_time_24 = FU_time;
run;
data perct_finale_24; set perct_finale_24;
if FU_time> 2 and outcome <3 then outcome_24 = 3; else outcome_24 = outcome;
run;
data perct_finale_24; set perct_finale_24;
if mvist>24 then delete;
run;

data perct_finale_24_1;set perct_finale_24;
by UID;
if first.UID = 1 then output;
run;
proc freq data = perct_finale_24_1;
table outcome_24;
run;
proc means data = perct_finale_24_1 median Q1 Q3;
var FU_time_24;
run;
proc sql;
	SELECT  SUM(FU_time_24) 
FROM perct_finale_24_1;
quit;

*Export sous R;

*Création de la variable D_CD4;

data perct_finale_24; set perct_finale_24;
D_CD4 = (cd4_v - Cd4p_art);
FU_time_24 = (FU_time_24)*12;
run; 

*Création de la variable FU_time et FU_time2;
data perct_finale_24; set perct_finale_24;
if FU_time_24 < 12 then do; T1=FU_time_24;T2=0;end;
if FU_time_24 >=12 then do; T1=12;T2=FU_time_24-12;end;
run;
*Analyse multivariée;

*model plein en fonction de l'age, des CD4, du sexe et du traitement;
proc mixed data = perct_finale_24 method=ml noclprint covtest;
class UID cl_age cd4_cl Gender regime_ART ;
model D_CD4 =  T1 T2  cl_age*T1  cl_age*T2 cd4_cl*T1 cd4_cl*T2 GENDER*T1 GENDER*T2 regime_ART*T1 regime_ART*T2 / noint s cl ddfm=bw outpred = p;
random  T1 T2/sub=UID type = VC;

*Gain à 12 mois;
estimate "gain CD4 M12 < 2 ans"  T1 12 T2 0 cl_age*T1 12 0 0 0 0   cd4_cl*T1 12 0 0 GENDER*T1 12 0 regime_ART*T1 12 0 0 / cl;
estimate "gain CD4 M12  3 ans"  T1 12 T2 0 cl_age*T1 0 12 0 0 0  cd4_cl*T1 12 0 0  GENDER*T1 12 0 regime_ART*T1 12 0 0 / cl;
estimate "gain CD4 M12 4-5 ans"  T1 12 T2 0 cl_age*T1 0 0 12 0 0  cd4_cl*T1 12 0 0  GENDER*T1 12 0 regime_ART*T1 12 0 0 / cl;
estimate "gain CD4 M12 5-10 ans"  T1 12 T2 0 cl_age*T1 0 0 0 12 0  cd4_cl*T1 12 0 0  GENDER*T1 12 0 regime_ART*T1 12 0 0/ cl;
estimate "gain CD4 M12 11-15 ans"  T1 12 T2 0 cl_age*T1 0 0 0 0 12  cd4_cl*T1 12 0 0  GENDER*T1 12 0 regime_ART*T1 12 0 0/ cl;

estimate "gain CD4 M12 no isp"  T1 12 T2 0 cd4_cl*T1 12 0 0  cl_age*T1 12 0 0 0 0  GENDER*T1 12 0 regime_ART*T1 12 0 0 / cl;
estimate "gain CD4 M12 mod isp"  T1 12 T2 0 cd4_cl*T1 0 12 0 cl_age*T1 12 0 0 0 0  GENDER*T1 12 0 regime_ART*T1 12 0 0 / cl;
estimate "gain CD4 M12 sev isp"  T1 12 T2 0 cd4_cl*T1 0 0 12  cl_age*T1 12 0 0 0 0 GENDER*T1 12 0 regime_ART*T1 12 0 0 / cl;

estimate "gain CD4 M12 M"  T1 12 T2 0 GENDER*T1 12 0  cd4_cl*T1 12 0 0  cl_age*T1 12 0 0 0 0  regime_ART*T1 12 0 0/ cl;
estimate "gain CD4 M12 F"  T1 12 T2 0 GENDER*T1 0 12   cd4_cl*T1 12 0 0  cl_age*T1 12 0 0 0 0  regime_ART*T1 12 0 0/ cl;

estimate "gain CD4 M12 2NRTI+1NNRTI"  T1 12 T2 0 regime_ART*T1  12 0 0 GENDER*T1 12 0  cd4_cl*T1 12 0 0  cl_age*T1 12 0 0 0 0 / cl;
estimate "gain CD4 M12 2NRTI+1IP"  T1 12 T2 0 regime_ART*T1  0 12 0 GENDER*T1 12 0  cd4_cl*T1 12 0 0  cl_age*T1 12 0 0 0 0  / cl;

*Différence de gain à 12 mois;
estimate "gain CD4 M12 3 vs <2"  cl_age*T1 -12 12 0 0 0 cl_age*T2 0 0 0 0 0 / cl;
estimate "gain CD4 M12 4-5 vs <2"  cl_age*T1 -12 0 12 0 0 cl_age*T2 0 0 0 0 0 / cl;
estimate "gain CD4 M12 6-10 vs <2"  cl_age*T1 -12 0 0 12 0 cl_age*T2 0 0 0 0 0 / cl;
estimate "gain CD4 M12 10-15 vs <2"  cl_age*T1 -12 0 0 0 12 cl_age*T2 0 0 0 0 0 / cl;

*Gain à 24 mois;
estimate "gain CD4 M24 < 2 ans"  T1 12 T2 12 cl_age*T1 12 0 0 0 0 cl_age*T2 12 0 0 0 0 
cd4_cl*T1 12 0 0 cd4_cl*T2 12 0 0 GENDER*T1 12 0 GENDER*T2 12 0 regime_ART*T1  12 0 0 regime_ART*T2  12 0 0 / cl;
estimate "gain CD4 M24  3 ans"  T1 12 T2 12 cl_age*T1 0 12 0 0 0 cl_age*T2 0 12 0 0 0  
cd4_cl*T1 12 0 0 cd4_cl*T2 12 0 0 GENDER*T1 12 0 GENDER*T2 12 0 regime_ART*T1  12 0 0 regime_ART*T2  12 0 0 / cl;
estimate "gain CD4 M24 4-5 ans"  T1 12 T2 12 cl_age*T1 0 0 12 0 0  cl_age*T2 0 0 12 0 0  
cd4_cl*T1 12 0 0 cd4_cl*T2 12 0 0 GENDER*T1 12 0 GENDER*T2 12 0 regime_ART*T1  12 0 0 regime_ART*T2  12 0 0 / cl;
estimate "gain CD4 M24 6-10 ans"  T1 12 T2 12 cl_age*T1 0 0 0 12 0  cl_age*T2 0 0 0 12 0  
cd4_cl*T1 12 0 0 cd4_cl*T2 12 0 0 GENDER*T1 12 0 GENDER*T2 12 0 regime_ART*T1  12 0 0 regime_ART*T2  12 0 0 / cl;
estimate "gain CD4 M24 11-15 ans"  T1 12 T2 12 cl_age*T1 0 0 0 0 12  cl_age*T2 0 0 0 0 12 
cd4_cl*T1 12 0 0 cd4_cl*T2 12 0 0 GENDER*T1 12 0 GENDER*T2 12 0 regime_ART*T1  12 0 0 regime_ART*T2  12 0 0 / cl;

estimate "gain CD4 M24 no isp"  T1 12 T2 12 cd4_cl*T1 12 0 0  cd4_cl*T2 12 0 0  
cl_age*T1 12 0 0 0 0 cl_age*T2 12 0 0 0 0  GENDER*T1 12 0 GENDER*T2 12 0 regime_ART*T1  12 0 0 regime_ART*T2  12 0 0 / cl;
estimate "gain CD4 M24 mod isp"  T1 12 T2 12 cd4_cl*T1 0 12 0 cd4_cl*T2 0 12 0 
cl_age*T1 12 0 0 0 0 cl_age*T2 12 0 0 0 0  GENDER*T1 12 0 GENDER*T2 12 0 regime_ART*T1  12 0 0 regime_ART*T2  12 0 0 / cl;
estimate "gain CD4 M24 sev isp"  T1 12 T2 12 cd4_cl*T1 0 0 12  cd4_cl*T2 0 0 12
cl_age*T1 12 0 0 0 0 cl_age*T2 12 0 0 0 0  GENDER*T1 12 0 GENDER*T2 12 0 regime_ART*T1  12 0 0 regime_ART*T2  12 0 0 / cl;

estimate "gain CD4 M24 M" T1 12 T2 12 GENDER*T1 12 0  GENDER*T2 12 0 
cd4_cl*T1 12 0 0 cd4_cl*T2 12 0 0 cl_age*T1 12 0 0 0 0 cl_age*T2 12 0 0 0 0 regime_ART*T1  12 0 0 regime_ART*T2  12 0 0 / cl;
estimate "gain CD4 M24 F"  T1 12 T2 12 GENDER*T1 0 12 GENDER*T2 12 0
cd4_cl*T1 12 0 0 cd4_cl*T2 12 0 0 cl_age*T1 12 0 0 0 0 cl_age*T2 12 0 0 0 0 regime_ART*T1  12 0 0 regime_ART*T2  12 0 0 / cl;


estimate "gain CD4 M24 2NRTI+1NNRTI"  T1 12 T2 12 regime_ART*T1  12 0 0 regime_ART*T2 12 0 0
GENDER*T1 12 0 GENDER*T2 12 0 cd4_cl*T1 12 0 0 cd4_cl*T2 12 0 0 cl_age*T1 12 0 0 0 0 cl_age*T2 12 0 0 0 0 / cl;
estimate "gain CD4 M24 2NRTI+1IP"  T1 12 T2 12 regime_ART*T1 0 12 0 regime_ART*T2 0 12 0   GENDER*T1 12 0  GENDER*T2 12 0
GENDER*T1 12 0 GENDER*T2 12 0 cd4_cl*T1 12 0 0 cd4_cl*T2 12 0 0 cl_age*T1 12 0 0 0 0 cl_age*T2 12 0 0 0 0 / cl;

*Différence de gain à M24;
estimate "gain CD4 M24 3 vs <2"  cl_age*T1 -12 12 0 0 0 cl_age*T2 -12 12 0 0 0 / cl;
estimate "gain CD4 M24 4-5 vs <2"  cl_age*T1 -12 0 12 0 0 cl_age*T2 -12 0 12 0 0 / cl;
estimate "gain CD4 M24 6-10 vs <2"  cl_age*T1 -12 0 0 12 0 cl_age*T2 -12 0 0 12 0 / cl;
estimate "gain CD4 M24 10-15 vs <2"  cl_age*T1 -12 0 0 0 12 cl_age*T2 -12 0 0 0 12 / cl;
run;
