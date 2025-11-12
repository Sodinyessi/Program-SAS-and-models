/
**************************************************************************************************************************************
*
*								REPONSE IMMUNOLOGIQUE AU TRAITEMENT - MERGER4	
*
**************************************************************************************************************************************
/;

libname immuno 'P:\CD4_IEDEA\MERGER 4_OCTOBRE_12';

proc contents data = immuno.inf_treated;run;

*Table initiale: Inf_treated (toutes les variables), inftreated (variables sélectionnées) et lab_cd4;
/* critères d'inclusions:
	- agés < 15 ans à l'inclusion
	- diagnostique confirmé
	- ART-naifs à la mise sous ART
	- Au moins deux mesures de CD4 dont une à la mise sous ART;
*/

*Au moins une mesure à la mise sous ART;
	* Ajouter cd4_art et cd4_p_art dans la table inftreated;
data cd4;set immuno.inf_treated;
keep UID cd4_art cd4p_art inc_d;
run;
proc sql;
	create table immuno.patients as
	select *
	from immuno.inftreated right join cd4 
	on cd4.UID = inftreated.UID;

	* select *
	* from immuno.inftreated, cd4 
	* where cd4.UID = inftreated.UID;
quit;
* Variables CD4 à l'inclusions: cd4_art (absolu) et cd4p_art;
data immuno.patients;
set immuno.patients;
if cd4_art > 0 or cd4p_art > 0 then output;
run;
*Suppression des doublons;
proc sort data = immuno.patients out = immuno.patients nodupkey;
by UID;
run;
* Extraction des numéros de patients;
data pat_id;
set immuno.patients;
keep UID;
run;

* Isoler les patients inclus dans la table Lab_cd4;
proc sql;
	create table lab as
	select *
	from immuno.lab_cd4 right join pat_id
	on lab_cd4.UID = pat_id.UID;
quit;

*la table lab comprend les données CD4 pour tous les patients avec au moins une mesure de CD4;

*Merge des deux tables;
proc sort data = lab;
by UID CD4_D;
run;
proc sort data = immuno.patients;
by UID;
run;
proc sql;
	create table immuno.labpat as
	select *
	from immuno.patients left join lab
	on  patients.UID = lab.UID ;
quit;
*la table immuno.labpat comprend les dommées patients + CD4 pour tous les patients avec au moins une mesure de CD4;
proc sql;
	select COUNT (DISTINCT UID) 
	FROM immuno.labpat;
quit;

*Temps entre chaque mesure;
data immuno.labpat;
set immuno.labpat;
rename mise_ss_ART = art_sd;
run;
data immuno.labpat;
set immuno.labpat;
mes_delai = (cd4_d - art_sd)/30;
run;
*Suppression des mesures > 3 mois avant ART;
data immuno.labpat_1;
set immuno.labpat;
if mes_delai < -3 then delete;
run;
proc sql;
	select COUNT (DISTINCT UID) 
	FROM immuno.labpat_1;
quit;
*La table labpat contient toutes les données pour enfants avec au moins une mesure après ART, abs et %;




					********************************** CD4 absolus ******************************************

/;

	*CD4 absolus; * Attention à partir de ceux qui ont une mesure pre-art. Penser à changer la table de départ et mettre immuno.labpat ; 
data abs;
set immuno.labpat_1;
if cd4_U = 1 then output;
run;
*Supprimer valeur abbérentes;
data abs ;set abs;
if cd4_v > 3000 then delete;
run;
proc univariate data = abs;var mes_delai;run;
proc sql;
	select COUNT (DISTINCT UID) 
	FROM abs;
quit;
	*numéros de mesure;
data abs ;set abs;
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

data abs; set abs; * recoder pour que M0 soit le premier;
if mes_CD4 = "001_M-24" then delai_CD4 = abs(-24-mes_delai);
if mes_CD4 = "002_M-18" then delai_CD4 = abs(-18-mes_delai);
if mes_CD4 = "003_M-12" then delai_CD4 = abs(-12-mes_delai);
if mes_CD4 = "004_M-6" then delai_CD4 = abs(-6-mes_delai);
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

proc sort data = abs;
by UID mes_CD4 delai_CD4;
run;
data abs; set abs;
by UID mes_CD4;
if first.mes_CD4 = 1 then output;
run;

	*Isoler patients qui n'ont pas de M0 et voir s'ils ont CD4_art;
data test;set abs;
by UID;
if first.UID then output;
run;
proc freq data = test;
table mes_CD4;
run;
data patients_abs_1;set test;
if mes_CD4 ne "0_M0" then output;
run;
data patients_abs_2;set test;
if mes_CD4 = "0_M0" then output;
run;

*Supprimer patients parmi ceux qui n'ont pas de M0 ceux qui n'ont pas de cd4_art;
data patients_abs_1; set patients_abs_1;
if cd4_art <0 then delete;
run;
*Ajouter une ligne pour M0 et cd4_v = cd4_art et cd4_d = art_sd;
DATA test;
SET patients_abs_1 patients_abs_1;
run;
proc sort data= test;
by UID;
run;
data test_1; set test;
by UID;
if first.UID = 1 then mes_CD4 = "0_M0";
run;
data test_1; set test_1;
if mes_CD4 = "0_M0" then cd4_v = cd4_art;
run;
data test_1; set test_1;
if mes_CD4 = "0_M0" then cd4_d = art_sd;
run;

*Isoler la première ligne;
data test_1;set test_1;
if mes_cd4 = "0_M0" then output;
run;
*Concaténation avec les autres patients;
data test_2; set test_1 patients_abs_2;
run;
*Isoler les numéros de patients;
data test_pat;set test_2;
keep UID;
run;

*Créer table CD4 avec que ceux qui ont une mesure M0 au moins;
proc sort data = abs;
by UID;
run;
proc sort data = test_pat;
by UID;
run;
data abs_1; 
merge test_pat (in = c) abs;
by UID;
if c;
run;
*Ajouter les M0 crée pour les 50 patients qui avant des cd4_art et pas de trace dans lab_cd4;
data abs_2;
set abs_1 test_1;
run;
proc sql;
	select COUNT (DISTINCT UID) 
	FROM abs_2;
quit;

*Sélectionner les patients qui ont au moins deux mesures;

proc sql;
	create table abs_3
	as
	SELECT *,  COUNT(MES_CD4)as nbre_cd4 
	FROM abs_2
	GROUP BY UID;
quit;

data abs_4;set abs_3;
if nbre_cd4 < 2 then delete;
run;
proc sort data = abs_4;
by UID CD4_d;
run;
proc sql;
	select COUNT (DISTINCT UID) 
	FROM abs_4;
quit;

proc sql;
select COUNT (CD4_V) as nbre
from abs_4
group by mes_cd4;
quit;
run;


	*Description;

data patients_abs;set abs_4;
by UID;
if first.UID then output;
run;
proc freq data = patients_abs;
table mes_CD4;
run;
*Création d'un ID par patient;
data patients_abs; set patients_abs;
id = _N_;
run;

*AGE;
data patients_abs; set patients_abs;
age = (art_sd - birth_d) / 365.25;
age_m = age*12;
run;
proc freq data = patients_abs;
table center*country;
run;
proc means data = patients_abs median Q1 Q3;
var age;
run;
proc means data = patients_abs median Q1 Q3;
class center;
var age;
run;
data patients_abs; set patients_abs;
if age <2 then cl_age = 1;
if age>=2 and age<3 then cl_age = 2;
if age>=3 and age<4 then cl_age = 3;
if age>=4 and age<5 then cl_age = 4;
if age>=5 then cl_age = 5;
run;
proc freq data = patients_abs;
table cl_age ;
run;


*GENDER;
proc freq data = patients_abs;
table gender*cl_age;
run;

*WHO clinical stage;
data patients_abs; set patients_abs;
if stage_WHO_ART = 9 then stage_WHO_ART = 99;
run;
proc freq data = patients_abs;
table stage_WHO_ART*cl_age / chisq;
run;

*HB count; *(399 missing values);
proc means data = patients_abs median Q1 Q3;
class cl_age;
var Hb_ART;
run;
proc means data = patients_abs;
where Hb_ART < 8;
class cl_age;
var Hb_ART;
run;


*Baseline CD4_abs;
proc means data = patients_abs median Q1 Q3;
var cd4_v;
run;
proc means data = patients_abs median Q1 Q3;
class center;
var cd4_v;
run;

*WHO classif (according to paper by Dunn);
data patients_abs; set patients_abs;

if age <1 and cd4_v < 1500 then cd4_cl = 3; 
if (age >= 1 and age < 3) and cd4_v <750 then cd4_cl = 3; 
if (age >= 3 and age < 5) and cd4_v <350 then cd4_cl = 3;
if age >=5 and cd4_v < 200 then cd4_cl = 3;


if age <1 and (cd4_v >= 1500  and cd4_v < 2000) then cd4_cl = 2; 
if (age >= 1 and age < 3) and (cd4_v >= 750  and cd4_v < 1000) then cd4_cl = 2; 
if (age >= 3 and age < 5) and (cd4_v >= 350  and cd4_v < 500) then cd4_cl = 2;
if age >=5 and (cd4_v >= 200 and cd4_v < 350) then cd4_cl = 2;

if age <1 and cd4_v >= 2000 then cd4_cl = 1; 
if (age >= 1 and age < 3) and cd4_v >= 1000 then cd4_cl = 1; 
if (age >= 3 and age < 5) and cd4_v >=500 then cd4_cl = 1;
if age >=5 and cd4_v >= 350 then cd4_cl = 1;


run;

proc freq data = patients_abs;
table cd4_cl*cl_age;
run;
proc means data = patients_abs median Q1 Q3 min max;
class cl_age;
var cd4_v;
run;
proc means data = patients_abs median Q1 Q3;
where mes_CD4 = "0_M0";
class cd4_cl;
var cd4_v;
run;

*Export de la table patients_abs en format txt pour calcul du zscore;
*Import de la table zscore.xls (AnthroPlus):

*WAZ & HAZ;

proc univariate data = immuno.zscores;
var WAZ;
run;
proc univariate data = immuno.zscores;
var HAZ;
run;
data zscores;set immuno.zscores;
if WAZ < -2 then U_weight = "yes"; else U_weight = "no";
if WAZ = . then U_weight = "unknown";
if HAZ < -2 then stunt = "yes"; else stunt = "no";
if HAZ = . then stunt = "unknown";
run;
proc freq data = zscores;
table U_weight stunt;
run;
data zscores_1; set zscores;
keep id U_weight stunt WAZ HAZ;
run;

proc sort data = patients_abs;
by id;
run;
proc sort data = zscores_1;
by id;
run;
data patients_abs;
merge patients_abs (in=x) zscores_1;
if x;
run;
proc freq data = patients_abs;
table U_weight*cl_age stunt*cl_age;
run;
proc means data = patients_abs median Q1 Q3;
where (U_weight = "yes" or U_weight = "no");
class cl_age;
var WAZ ;
run;
proc freq data = patients_abs ;
table U_weight*cl_age / chisq;
run;
proc means data = patients_abs median Q1 Q3;
where (stunt = "yes" or stunt= "no");
class cl_age;
var HAZ ;
run;
proc freq data = patients_abs ;
table stunt*cl_age / chisq;
run;
*CTX;
proc freq data = patients_abs;
table CTX_ART*cl_age / chisq;
run;
*ART regimen;
data patients_abs;
set patients_abs;
if regime_art >2 then regime_art = 3;
run;
proc freq data = patients_abs;
table regime_art*cl_age / chisq;
run;

*FU_time;
data patients_abs; set patients_abs;
FU_time = (last_contact - art_sd)/30;
run;
proc univariate data = patients_abs;
var FU_time;
run;
proc sql;
	SELECT  SUM(FU_time) 
FROM patients_abs;
quit;
proc sql;
	SELECT cl_age, SUM(FU_time) 
FROM patients_abs
	GROUP BY cl_age;
quit;
proc sql;
	SELECT cd4_cl, SUM(FU_time) 
FROM patients_abs
	GROUP BY cd4_cl;
quit;

*Type de traitement;
proc freq data = patients_abs;
table type_ttt*regime_ART;
run;

*Outcome;
proc freq data = patients_abs;
table outcome;
run;
data patients_abs;set patients_abs;
if FU_time > 24 then outcome_24 = 3; else outcome_24 = outcome;
run;
proc freq data = patients_abs;
table outcome_24*cl_age;
run;
proc univariate data = patients_abs;
var FU_time;
run;
*Differences between outcome and CD4 by age;
proc freq data = patients_abs;
table cd4_cl*cl_age / chisq;
run;
proc freq data = patients_abs;
table outcome_24*cl_age / chisq;
run;

*Time to ART initiation;

data patients_abs; set patients_abs;
ART_time = (art_sd - inc_d)/30;
run;
data patients_abs; set patients_abs;
if ART_time =< 0 then ART_time = .;
run;
proc univariate data = patients_abs;
var ART_time;run;

*Characteristiques des patients exclus;

proc sql;
create table exclus as
select *
FROM immuno.inf_treated
WHERE NOT EXISTS(
SELECT patients_abs.UID
FROM patients_abs
WHERE patients_abs.UID=inf_treated.UID);
quit;
run;

data exclus; set exclus;
if age <2 then cl_age = 1;
if age>=2 and age<3 then cl_age = 2;
if age>=3 and age<4 then cl_age = 3;
if age>=4 and age<5 then cl_age = 4;
if age>=5 then cl_age = 5;
run;
proc freq data = exclus;
table cl_age;run;
proc freq data = exclus;
table gender;run;

data exclus; set exclus;
if stage_WHO_ART = 9 then stage_WHO_ART = 99;
run;
proc freq data = exclus;
table WHO_ART*cl_age / chisq;
run;

*Distribution of median CD4 by time since ART initiation;
*Création de la table avec toutes les caractéristiques patients + mesures répétées;
*Table avec mesures seulement;
data abs_5; set abs_4;
keep UID cd4_d cd4_v mes_cd4;
run;
proc sort data = abs_5;
by UID;
run;
proc sort data = patients_abs;
by UID;
run;
data abs_finale;
merge  patients_abs (in=x) abs_5;
by UID;
if x;
run;


proc means data = abs_finale median Q1 Q3;
class mes_CD4 cl_age;
var cd4_v;
run;
data abs_finale;set abs_finale;
if mes_CD4 = "0_M0" then mvisit = 0;
if mes_CD4 = "1_M6" then mvisit = 6;
if mes_CD4 = "2_M12" then mvisit = 12;
if mes_CD4 = "3_M18" then mvisit = 18;
if mes_CD4 = "4_M24" then mvisit = 24;
if mes_CD4 = "5_M30" then mvisit = 30;
if mes_CD4 = "6_M36" then mvisit = 36;
if mes_CD4 = "7_M42" then mvisit = 42;
if mes_CD4 = "8_M48" then mvisit = 48;
if mes_CD4 = "9_M54" then mvisit = 54;
if mes_CD4 = "99_M60" then mvisit = 60;
run;


*Export sous R;



*Descriptions sur 24 mois;
data abs_finale_24; set abs_finale;
if mvisit <= 24 then output;
run;

proc means data = abs_finale_24 median Q1 Q3;
class  mvisit;
var cd4_v;
run;
proc means data = abs_finale_24 median Q1 Q3;
class  cd4_cl mvisit;
var cd4_v;
run;
proc means data = abs_finale_24 median Q1 Q3;
class  regime_ART mvisit;
var cd4_v;
run;
proc means data = abs_finale_24 median Q1 Q3;
class gender mvisit;
var cd4_v;
run;




*Modèle linéaire mixte;
*Création de la variable D_CD4;

data abs_finale_24; set abs_finale_24;
D_CD4 = (cd4_v - Cd4_art);
time = ((cd4_d -art_sd) / 365.25)*12; * temps en mois;
if mvisit = 0 then time = 0;
run;
 

*Création de la variable time et time2;
data abs_finale_24; set abs_finale_24;
if time < 6 then do; T1=time;T2=0;end;
if time >=6 then do; T1=6;T2=time-6;end;
run;

proc univariate data = abs_finale_24;
var T1 T2;
run;

*Nombre médian de mesures en 24 mois;
proc sql;
	create table abs_finale_24_1
	as
	SELECT *,  COUNT(MES_CD4)as nbre_cd4 
	FROM abs_finale_24
	GROUP BY UID;
quit;
proc sort data = abs_finale_24_1; by UID;run;
data test;set abs_finale_24_1;
by UID;
if first.UID =1then output;
run;
proc means data = test median Q1 Q3;
var nbre_cd4; run; 


*Analyses univariées;
proc mixed data = abs_finale_24 method = ml noclprint covtest;
class UID ;
model D_CD4 = T1 T2 / noint s cl ddfm=bw outpred = p;;
random  T1 T2/sub=UID type = UN;
estimate "gain CD4 M12 < 2 ans"  T1 12 T2 12  /cl;
run;
proc mixed data = abs_finale_24 method = ml noclprint covtest;
class UID cl_age;
model D_CD4 = T1 T2 cl_age*T1 cl_age*T2 / noint s cl ddfm=bw outpred = p;;
random  T1 T2/sub=UID type = UN;
*Gain à 6 mois;
estimate "gain CD4 M6 < 2 ans"  T1 6 T2 0 cl_age*T1 6 0 0 0 0 cl_age*T2 0 0 0 0 0/cl ;
estimate "gain CD4 M6 3 ans"  T1 6 T2 0 cl_age*T1 0 6 0 0 0 cl_age*T2 0 0 0 0 0 /cl;
estimate "gain CD4 M6 4-5 ans"  T1 6 T2 0 cl_age*T1 0 0 6 0 0 cl_age*T2 0 0 0 0 0 /cl;
estimate "gain CD4 M6 6-10 ans"  T1 6 T2 0 cl_age*T1 0 0 0 6 0 cl_age*T2 0 0 0 0 0/cl;  
estimate "gain CD4 M6 11-15 ans"  T1 6 T2 0 cl_age*T1  0 0 0 0 6 cl_age*T2  0 0 0 0 0/cl;
*Gain à 12 mois;
estimate "gain CD4 M24 < 2 ans"  T1 6 T2 6 cl_age*T1 6 0 0 0 0 cl_age*T2 6 0 0 0 0/cl ;
estimate "gain CD4 M24 3 ans"  T1 6 T2 6 cl_age*T1 0 6 0 0 0 cl_age*T2 0 6 0 0 0 /cl;
estimate "gain CD4 M24 4-5 ans"  T1 6 T2 6 cl_age*T1 0 0 6 0 0 cl_age*T2 0 0 6 0 0 /cl;
estimate "gain CD4 M24 6-10 ans"  T1 6 T2 6 cl_age*T1 0 0 0 6 0 cl_age*T2 0 0 0 6 0/cl;  
estimate "gain CD4 M24 11-15 ans"  T1 6 T2 6 cl_age*T1  0 0 0 0 6 cl_age*T2  0 0 0 0 6/cl;

*Gain à 24 mois;
estimate "gain CD4 M24 < 2 ans"  T1 6 T2 18 cl_age*T1 6 0 0 0 0 cl_age*T2 18 0 0 0 0/cl ;
estimate "gain CD4 M24 3 ans"  T1 6 T2 18 cl_age*T1 0 6 0 0 0 cl_age*T2 0 18 0 0 0 /cl;
estimate "gain CD4 M24 4-5 ans"  T1 6 T2 18 cl_age*T1 0 0 6 0 0 cl_age*T2 0 0 18 0 0 /cl;
estimate "gain CD4 M24 6-10 ans"  T1 6 T2 18 cl_age*T1 0 0 0 6 0 cl_age*T2 0 0 0 18 0/cl;  
estimate "gain CD4 M24 11-15 ans"  T1 6 T2 18 cl_age*T1  0 0 0 0 6 cl_age*T2  0 0 0 0 18/cl;

*Différence de gain;
estimate "gain CD4 M6 <2 vs >5"  cl_age*T1  -6 6 0 0 0  cl_age*T2 0 0 0 0 0 / cl;
estimate "gain CD4 M6 2 vs >5"  cl_age*T1  -6 0 6 0 0 cl_age*T2 0 0 0 0 0 / cl;
estimate "gain CD4 M6 3 vs >5"  cl_age*T1  -6 0 0 6 0  cl_age*T2 0 0 0 0 0 / cl;
estimate "gain CD4 M6 4 vs >5"  cl_age*T1  -6 0 0 0 6 cl_age*T2 0 0 0 0 0 / cl;
estimate "gain CD4 M12 <2 vs >5"  cl_age*T1 -6 6 0 0 0 cl_age*T2 -6 6 0 0 0 / cl;
estimate "gain CD4 M12 2 vs >5"  cl_age*T1  -6 0 6 0 0 cl_age*T2 -6 0 6 0 0/ cl;
estimate "gain CD4 M12 3 vs >5"  cl_age*T1  -6 0 0 6 0 cl_age*T2 -6 0 0 6 0 / cl;
estimate "gain CD4 M12 4 vs >5"  cl_age*T1  -6 0 0 0 6  cl_age*T2 -6 0 0 0 6/ cl;
estimate "gain CD4 M24 <2 vs >5"  cl_age*T1 -6 6 0 0 0 cl_age*T2 -18 18 0 0 0 / cl;
estimate "gain CD4 M24 2 vs >5"  cl_age*T1 -6 0 6 0 0 cl_age*T2 -18 0 18 0 0/ cl;
estimate "gain CD4 M24 3 vs >5"  cl_age*T1 -6 0 0 6 0 cl_age*T2 -18 0 0 18 0/ cl;
estimate "gain CD4 M24 4 vs >5"  cl_age*T1 -6 0 0 0 6 cl_age*T2 -18 0 0 0 18/ cl;
run;
proc mixed data = abs_finale_24 method = ml noclprint covtest;
class UID cd4_cl;
model D_CD4 = T1 T2 cd4_cl*T1 cd4_cl*T2 / noint s cl ddfm=bw outpred = p;
random  T1 T2/sub=UID type = UN;
*Gain à 6 mois;
estimate "gain CD4 M6 no signs"  T1 6 T2 0 cd4_cl*T1 6 0 0 cd4_cl*T2 0 0 0/cl ;
estimate "gain CD4 M6 mod"  T1 6 T2 0 cd4_cl*T1 0 6 0 cd4_cl*T2 0 0 0 /cl;
estimate "gain CD4 M6 severe"  T1 6 T2 0 cd4_cl*T1 0 0 6 cd4_cl*T2 0 0 0/cl;
*Gain à 12 mois;
estimate "gain CD4 M12 no signs"  T1 6 T2 6 cd4_cl*T1 6 0 0 cd4_cl*T2 6 0 0/cl ;
estimate "gain CD4 M12 mod"  T1 6 T2 6 cd4_cl*T1 0 6 0 cd4_cl*T2 0 6 0 /cl;
estimate "gain CD4 M12 severe"  T1 6 T2 6 cd4_cl*T1 0 0 6 cd4_cl*T2 0 0 6/cl;
*Gain à 24 mois;
estimate "gain CD4 M24 no signs"  T1 6 T2 18 cd4_cl*T1 6 0 0 cd4_cl*T2 18 0 0/cl ;
estimate "gain CD4 M24 mod"  T1 6 T2 18 cd4_cl*T1 0 6 0 cd4_cl*T2 0 18 0 /cl ;
estimate "gain CD4 M24 severe"  T1 6 T2 18 cd4_cl*T1 0 0 6 cd4_cl*T2 0 0 18 /cl;
*Différence de gain;
estimate "gain CD4 M6 no vs mod" cd4_cl*T1 -6 6 0 cd4_cl*T2 0 0 0 / cl;
estimate "gain CD4 M6 no vs sev" cd4_cl*T1 -6 0 6 cd4_cl*T2 0 0 0 / cl;
estimate "gain CD4 M12 no vs mod" cd4_cl*T1 -6 6 0 cd4_cl*T2 -6 6 0 / cl;
estimate "gain CD4 M12 no vs sev" cd4_cl*T1 -6 0 6 cd4_cl*T2 -6 0 6 / cl;
estimate "gain CD4 M24 no vs mod" cd4_cl*T1 -6 6 0 cd4_cl*T2 -18 18 0 / cl;
estimate "gain CD4 M24 no vs sev" cd4_cl*T1 -6 0 6 cd4_cl*T2 -18 0 18 / cl;
run;


proc mixed data = abs_finale_24 method = ml noclprint covtest;
class UID gender;
model D_CD4 = T1 T2 gender*T1 gender*T2 / noint s cl ddfm=bw outpred = p;
random intercept T1 T2/sub=UID type = UN;
*Gain à 6 mois;
estimate "gain CD4 M6 boys"  T1 6 T2 0 gender*T1 6 0 /cl;
estimate "gain CD4 M6 girls"  T1 6 T2 0 gender*T1 0 6  /cl;
*Gain à 12 mois;
estimate "gain CD4 M12 boys"  T1 6 T2 6 gender*T1 6 0  gender*T2 6 0  /cl;
estimate "gain CD4 M12 girls"  T1 6 T2 6 gender*T1 0 6 gender*T2 0 6 /cl;
*Gain à 24 mois;
estimate "gain CD4 M24 boys"  T1 6 T2 18 gender*T1 6 0  gender*T2 18 0  /cl;
estimate "gain CD4 M24 girls"  T1 6 T2 18 gender*T1 0 6 gender*T2 0 18 /cl;
run;


proc mixed data = abs_finale_24 method = ml noclprint covtest;
class UID regime_ART;
model D_CD4 = T1 T2 regime_ART*T1 regime_ART*T2 / noint s cl ddfm=bw outpred = p;
random intercept T1 T2/sub=UID type = UN;
*Gain à 6 mois;
estimate "gain CD4 M12 NNRTI"  T1 6 T2 0 regime_ART*T1 6 0 0/cl ;
estimate "gain CD4 M12 PI"  T1 6 T2 0 regime_ART*T1 0 6 0/cl  ;
*Gain à 12 mois;
estimate "gain CD4 M24 NNRTI"  T1 6 T2 6 regime_ART*T1 6 0 0  regime_ART*T2 6 0 0 /cl ;
estimate "gain CD4 M24 PI"  T1 6 T2 6 regime_ART*T1 0 6 0 regime_ART*T2 0 6 0 /cl ;
*Gain à 24 mois;
estimate "gain CD4 M24 NNRTI"  T1 6 T2 18 regime_ART*T1 6 0 0 regime_ART*T2 18 0 0/cl ;
estimate "gain CD4 M24 PI"  T1 6 T2 18 regime_ART*T1 0 6  0regime_ART*T2 0 18 0/cl ;
run;

*Analyse multivariée;

*model plein en fonction de l'age, des CD4, du sexe et du traitement;
proc mixed data = abs_finale_24 method=ml noclprint covtest;
class UID cl_age cd4_cl Gender regime_ART;
model D_CD4 =  T1 T2  cl_age*T1  cl_age*T2 cd4_cl*T1 cd4_cl*T2 GENDER*T1 GENDER*T2 regime_ART*T1 regime_ART*T2 / noint s cl ddfm=bw outpred = p;
random   T1 T2/sub=UID type = UN;

*Gain à 6 mois;
estimate "gain CD4 M6 < 2 ans"  T1 6 T2 0 cl_age*T1 6 0 0 0 0   cd4_cl*T1 6 0 0 GENDER*T1 6 0 regime_ART*T1 6 0 0 /cl ;
*estimate "gain CD4 M6  2 ans"  T1 6 T2 0 cl_age*T1 0 6 0 0 0  cd4_cl*T1 6 0 0  GENDER*T1 6 0 regime_ART*T1 6 0 0 / cl;
*estimate "gain CD4 M6 3 ans"  T1 6 T2 0 cl_age*T1 0 0 6 0 0  cd4_cl*T1 6 0 0  GENDER*T1 6 0 regime_ART*T1 6 0 0 / cl;
*estimate "gain CD4 M6 4 ans"  T1 6 T2 0 cl_age*T1 0 0 0 6 0  cd4_cl*T1 6 0 0  GENDER*T1 6 0 regime_ART*T1 6 0 0 / cl;
*estimate "gain CD4 M6 >5 ans"  T1 6 T2 0 cl_age*T1 0 0 0 0 6  cd4_cl*T1 6 0 0  GENDER*T1 6 0 regime_ART*T1 6 0 0 / cl;

estimate "gain CD4 M6 no isp"  T1 6 T2 0 cd4_cl*T1 6 0 0  cl_age*T1 6 0 0 0 0 GENDER*T1 6 0 regime_ART*T1 6 0 0 / cl;
*estimate "gain CD4 M6 mod isp"  T1 6 T2 0 cd4_cl*T1 0 6 0 cl_age*T1  0 0 0 0 6 GENDER*T1 6 0 regime_ART*T1 6 0 0 / cl;
*estimate "gain CD4 M6 sev isp"  T1 6 T2 0 cd4_cl*T1 0 0 6  cl_age*T1  0 0 0 0 6 GENDER*T1 6 0 regime_ART*T1 6 0 0 / cl;

estimate "gain CD4 M6 M"  T1 6 T2 0 GENDER*T1 6 0  cd4_cl*T1 6 0 0  cl_age*T1 6 0 0 0 0  regime_ART*T1 6 0 0 / cl;
*estimate "gain CD4 M6 F"  T1 6 T2 0 GENDER*T1 0 6   cd4_cl*T1 6 0 0  cl_age*T1  0 0 0 0 6  regime_ART*T1 6 0 0 / cl;

estimate "gain CD4 M6 2NRTI+1NNRTI"  T1 6 T2 0 regime_ART*T1  6 0 0 GENDER*T1 6 0  cd4_cl*T1 6 0 0 cl_age*T1 6 0 0 0 0/ cl;
*estimate "gain CD4 M6 2NRTI+1IP"  T1 6 T2 0 regime_ART*T1  0 6 0 GENDER*T1 6 0  cd4_cl*T1 6 0 0  cl_age*T1  0 0 0 0 6 /cl;


*Gain à 12 mois;
estimate "gain CD4 M12 < 2 ans"  T1 6 T2 6 cl_age*T1 6 0 0 0 0 cl_age*T2 6 0 0 0 0 
cd4_cl*T1 6 0 0 cd4_cl*T2 6 0 0 GENDER*T1 6 0 GENDER*T2 6 0 regime_ART*T1  6 0 0 regime_ART*T2  6 0 0/ cl;
*estimate "gain CD4 M12  2 ans"  T1 6 T2 6 cl_age*T1 0 6 0 0 0 cl_age*T2 0 6 0 0 0  
cd4_cl*T1 6 0 0 cd4_cl*T2 6 0 0 GENDER*T1 6 0 GENDER*T2 6 0 regime_ART*T1  6 0 0 regime_ART*T2  6 0 0 /cl;
*estimate "gain CD4 M12 3 ans"  T1 6 T2 6 cl_age*T1 0 0 6 0 0  cl_age*T2 0 0 6 0 0  
cd4_cl*T1 6 0 0 cd4_cl*T2 6 0 0 GENDER*T1 6 0 GENDER*T2 6 0 regime_ART*T1  6 0 0 regime_ART*T2  6 0 0 / cl;
*estimate "gain CD4 M12 4 ans"  T1 6 T2 6 cl_age*T1 0 0 0 6 0  cl_age*T2 0 0 0 6 0  
cd4_cl*T1 6 0 0 cd4_cl*T2 6 0 0 GENDER*T1 6 0 GENDER*T2 6 0 regime_ART*T1  6 0 0 regime_ART*T2  6 0 0 / cl;
*estimate "gain CD4 M12 >5 ans"  T1 6 T2 6 cl_age*T1 0 0 0 0 6  cl_age*T2 0 0 0 0 6
cd4_cl*T1 6 0 0 cd4_cl*T2 6 0 0 GENDER*T1 6 0 GENDER*T2 6 0 regime_ART*T1  6 0 0 regime_ART*T2  6 0 0/ cl;

estimate "gain CD4 M12 no isp"  T1 6 T2 6 cd4_cl*T1 6 0 0  cd4_cl*T2 6 0 0  
cl_age*T1 6 0 0 0 0 cl_age*T2 6 0 0 0 0  GENDER*T1 6 0 GENDER*T2 6 0 regime_ART*T1  6 0 0 regime_ART*T2  6 0 0 / cl;
*estimate "gain CD4 M12 mod isp"  T1 6 T2 6 cd4_cl*T1 0 6 0 cd4_cl*T2 0 6 0 
cl_age*T1 0 0 0 0 6 cl_age*T2 0 0 0 0 6   GENDER*T1 6 0 GENDER*T2 6 0 regime_ART*T1  6 0 0 regime_ART*T2  6 0 0 / cl;
*estimate "gain CD4 M12 sev isp"  T1 6 T2 6 cd4_cl*T1 0 0 6  cd4_cl*T2 0 0 6
cl_age*T1 0 0 0 0 6 cl_age*T2 0 0 0 0 6  GENDER*T1 6 0 GENDER*T2 6 0 regime_ART*T1  6 0 0 regime_ART*T2  6 0 0 / cl;

estimate "gain CD4 M12 M" T1 6 T2 6 GENDER*T1 6 0  GENDER*T2 6 0 
cd4_cl*T1 6 0 0 cd4_cl*T2 6 0 0 cl_age*T1 6 0 0 0 0 cl_age*T2 6 0 0 0 0  regime_ART*T1  6 0 0 regime_ART*T2 6 0 0 / cl;
*estimate "gain CD4 M12 F"  T1 6 T2 6 GENDER*T1 0 6 GENDER*T2 0 6
cd4_cl*T1 6 0 0 cd4_cl*T2 6 0 0 cl_age*T1 0 0 0 0 6 cl_age*T2 0 0 0 0 6  regime_ART*T1  6 0 0 regime_ART*T2  6 0 0 / cl;


estimate "gain CD4 M12 2NRTI+1NNRTI"  T1 6 T2 6 regime_ART*T1  6 0 0 regime_ART*T2 6 0 0
GENDER*T1 6 0 GENDER*T2 6 0 cd4_cl*T1 6 0 0 cd4_cl*T2 6 0 0 cl_age*T1 6 0 0 0 0 cl_age*T2 6 0 0 0 0 / cl;
*estimate "gain CD4 M12 2NRTI+1IP"  T1 6 T2 6 regime_ART*T1 0 6 0 regime_ART*T2 0 6 0   GENDER*T1 12 0  GENDER*T2 6 0
GENDER*T1 6 0 GENDER*T2 6 0 cd4_cl*T1 6 0 0 cd4_cl*T2 6 0 0 cl_age*T1 0 0 0 0 6 cl_age*T2 0 0 0 0 6   / cl;
 
*Gain à 24 mois;
estimate "gain CD4 M24 < 2 ans"  T1 6 T2 18 cl_age*T1 6 0 0 0 0 cl_age*T2 18 0 0 0 0 
cd4_cl*T1 6 0 0 cd4_cl*T2 18 0 0 GENDER*T1 6 0 GENDER*T2 18 0 regime_ART*T1  6 0 0 regime_ART*T2  18 0 0/ cl;
*estimate "gain CD4 M24  2 ans"  T1 6 T2 18 cl_age*T1 0 6 0 0 0 cl_age*T2 0 18 0 0 0  
cd4_cl*T1 6 0 0 cd4_cl*T2 18 0 0 GENDER*T1 6 0 GENDER*T2 18 0 regime_ART*T1 6 0 0 regime_ART*T2  18 0 0/ cl;
*estimate "gain CD4 M24 3 ans"  T1 6 T2 18 cl_age*T1 0 0 6 0 0  cl_age*T2 0 0 18 0 0  
cd4_cl*T1 6 0 0 cd4_cl*T2 18 0 0 GENDER*T1 6 0 GENDER*T2 18 0 regime_ART*T1  6 0 0 regime_ART*T2  18 0 0/ cl;
*estimate "gain CD4 M24 4 ans"  T1 6 T2 18 cl_age*T1 0 0 0 6 0  cl_age*T2 0 0 0 18 0  
cd4_cl*T1 6 0 0 cd4_cl*T2 18 0 0 GENDER*T1 6 0 GENDER*T2 18 0 regime_ART*T1  6 0 0 regime_ART*T2  18 0 0/ cl;
*estimate "gain CD4 M24 >5 ans"  T1 6 T2 18 cl_age*T1 0 0 0 0 6 cl_age*T2 0 0 0 0 18
cd4_cl*T1 6 0 0 cd4_cl*T2 18 0 0 GENDER*T1 6 0 GENDER*T2 18 0 regime_ART*T1  6 0 0 regime_ART*T2  18 0 0/ cl;

estimate "gain CD4 M24 no isp"  T1 6 T2 18 cd4_cl*T1 6 0 0  cd4_cl*T2 18 0 0  
cl_age*T1 6 0 0 0 0 cl_age*T2 18 0 0 0 0   GENDER*T1 6 0 GENDER*T2 18 0 regime_ART*T1  6 0 0 regime_ART*T2  18 0 0 / cl;
*estimate "gain CD4 M24 mod isp"  T1 6 T2 18 cd4_cl*T1 0 6 0 cd4_cl*T2 0 18 0 
cl_age*T1 0 0 0 0 6 cl_age*T2 0 0 0 0 18  GENDER*T1 6 0 GENDER*T2 18 0 regime_ART*T1  6 0 0 regime_ART*T2  18 0 0 / cl;
*estimate "gain CD4 M24 sev isp"  T1 6 T2 18 cd4_cl*T1 0 0 6  cd4_cl*T2 0 0 18
cl_age*T1 0 0 0 0 6 cl_age*T2 0 0 0 0 18  GENDER*T1 6 0 GENDER*T2 18 0 regime_ART*T1  6 0 0 regime_ART*T2  18 0 0 / cl;

estimate "gain CD4 M24 M" T1 6 T2 18 GENDER*T1 6 0  GENDER*T2 18 0 
cd4_cl*T1 6 0 0 cd4_cl*T2 18 0 0 cl_age*T1 6 0 0 0 0 cl_age*T2 18 0 0 0 0  regime_ART*T1  6 0 0 regime_ART*T2 18 0 0 / cl;
*estimate "gain CD4 M24 F"  T1 6 T2 18 GENDER*T1 0 6 GENDER*T2 0 18
cd4_cl*T1 6 0 0 cd4_cl*T2 18 0 0 cl_age*T1 0 0 0 0 6 cl_age*T2 0 0 0 0 18 regime_ART*T1  6 0 0 regime_ART*T2 18 0 0 / cl;


estimate "gain CD4 M24 2NRTI+1NNRTI"  T1 6 T2 18 regime_ART*T1  6 0 0 regime_ART*T2 18 0 0
GENDER*T1 6 0 GENDER*T2 18 0 cd4_cl*T1 6 0 0 cd4_cl*T2 18 0 0 cl_age*T1 6 0 0 0 0 cl_age*T2 18 0 0 0 0 / cl;
*estimate "gain CD4 M24 2NRTI+1IP"  T1 6 T2 18 regime_ART*T1 0 6 0 regime_ART*T2 0 18 0   GENDER*T1 12 0  GENDER*T2 18 0
GENDER*T1 6 0 GENDER*T2 18 0 cd4_cl*T1 6 0 0 cd4_cl*T2 18 0 0 cl_age*T1 0 0 0 0 6 cl_age*T2 0 0 0 0 18 / cl;



*Différence de gain à 6 mois;
estimate "gain CD4 M6 <2 vs >5"  cl_age*T1  -6 6 0 0 0  cl_age*T2 0 0 0 0 0 / cl;
estimate "gain CD4 M6 2 vs >5"  cl_age*T1  -6 0 6 0 0 cl_age*T2 0 0 0 0 0 / cl;
estimate "gain CD4 M6 3 vs >5"  cl_age*T1  -6 0 0 6 0  cl_age*T2 0 0 0 0 0 / cl;
estimate "gain CD4 M6 4 vs >5"  cl_age*T1  -6 0 0 0 6 cl_age*T2 0 0 0 0 0 / cl;

estimate "gain CD4 M6 mod isp vs non isp" cd4_cl*T1 -6 6 0 cd4_cl*T2 0 0 0 / cl;
estimate "gain CD4 M6 sev isp vs non isp" cd4_cl*T1 -6 0 6 cd4_cl*T2 0 0 0 /cl;

estimate "gain CD4 M6 F vs M" GENDER*T1 -6 6 GENDER*T2 0 0 /cl;

estimate "gain CD4 M6 IP vs NNRTI" regime_ART*T1 -6 6 0 regime_ART*T2 0 0 0 /cl;

*Différence de gain à M12;
estimate "gain CD4 M12 <2 vs >5"  cl_age*T1 -6 6 0 0 0 cl_age*T2 -6 6 0 0 0 / cl;
estimate "gain CD4 M12 2 vs >5"  cl_age*T1  -6 0 6 0 0 cl_age*T2 -6 0 6 0 0/ cl;
estimate "gain CD4 M12 3 vs >5"  cl_age*T1  -6 0 0 6 0 cl_age*T2 -6 0 0 6 0 / cl;
estimate "gain CD4 M12 4 vs >5"  cl_age*T1  -6 0 0 0 6  cl_age*T2 -6 0 0 0 6/ cl;

estimate "gain CD4 M12 mod isp vs non isp" cd4_cl*T1 -6 6 0 cd4_cl*T2 -6 6 0 / cl;
estimate "gain CD4 M12 sev isp vs non isp" cd4_cl*T1 -6 0 6 cd4_cl*T2 -6 0 6 /cl;

estimate "gain CD4 M12 F vs M" GENDER*T1 -6 6 GENDER*T2 -6 6 /cl;

estimate "gain M12 IP vs NNRTI" regime_ART*T1 -6 6 0 regime_ART*T2 -6 6 0 /cl;


*Différence de gain à M24;
estimate "gain CD4 M24 <2 vs >5"  cl_age*T1 -6 6 0 0 0 cl_age*T2 -18 18 0 0 0 / cl;
estimate "gain CD4 M24 2 vs >5"  cl_age*T1 -6 0 6 0 0 cl_age*T2 -18 0 18 0 0/ cl;
estimate "gain CD4 M24 3 vs >5"  cl_age*T1 -6 0 0 6 0 cl_age*T2 -18 0 0 18 0/ cl;
estimate "gain CD4 M24 4 vs >5"  cl_age*T1 -6 0 0 0 6 cl_age*T2 -18 0 0 0 18/ cl;

estimate "gain CD4 M24 mod isp vs non isp" cd4_cl*T1 -6 6 0 cd4_cl*T2 -18 18 0 / cl;
estimate "gain CD4 M24 sev isp vs non isp" cd4_cl*T1 -6 0 6 cd4_cl*T2 -18 0 18 /cl;

estimate "gain CD4 M24 F vs M" GENDER*T1 -6 6 GENDER*T2 -18 18 /cl;

estimate "gain M24 IP vs NNRTI" regime_ART*T1 -6 6 0 regime_ART*T2 -18 18 0 /cl;

run;

proc univariate data = p;
var Resid;
histogram Resid/normal;
run;

*Détermination des pvalue;
*Modèle plein;
proc mixed data = abs_finale_24 method=ml noclprint covtest;
class UID cl_age cd4_cl Gender regime_ART;
model D_CD4 =  T1 T2  cl_age*T1  cl_age*T2 cd4_cl*T1 cd4_cl*T2 GENDER*T1 GENDER*T2 regime_ART*T1 regime_ART*T2 / noint s cl ddfm=bw outpred = p;
random   T1 T2/sub=UID type = UN;
run;
*Modèle sans âge;
proc mixed data = abs_finale_24 method=ml noclprint covtest;
class UID cl_age cd4_cl Gender regime_ART;
model D_CD4 =  T1 T2  cl_age*T1  cl_age*T2 cd4_cl*T1 cd4_cl*T2 GENDER*T1 GENDER*T2  / noint s cl ddfm=bw outpred = p;
random   T1 T2/sub=UID type = UN;
run;



*Analyse de sensibilité;
*Créer table avec uniquement les patients vivants;
data abs_finale_24_sens; set abs_finale_24;
if outcome_24 = 3 then output;
run;
data test; set abs_finale_24_sens;
by UID;
if first.UID then output;run;

proc mixed data = abs_finale_24_sens method=ml noclprint covtest;
class UID cl_age cd4_cl Gender regime_ART;
model D_CD4 =  T1 T2  cl_age*T1  cl_age*T2 cd4_cl*T1 cd4_cl*T2 GENDER*T1 GENDER*T2 regime_ART*T1 regime_ART*T2 / noint s cl ddfm=bw outpred = p;
random   T1 T2/sub=UID type = UN;

estimate "gain CD4 M12 < 2 ans"  T1 12 T2 0 cl_age*T1 12 0 0 0 0   cd4_cl*T1 12 0 0 GENDER*T1 12 0 regime_ART*T1 12 0 0 /cl ;
estimate "gain CD4 M12  2-3 ans"  T1 12 T2 0 cl_age*T1 0 12 0 0 0  cd4_cl*T1 12 0 0  GENDER*T1 12 0 regime_ART*T1 12 0 0 / cl;
estimate "gain CD4 M12 3-5 ans"  T1 12 T2 0 cl_age*T1 0 0 12 0 0  cd4_cl*T1 12 0 0  GENDER*T1 12 0 regime_ART*T1 12 0 0 / cl;
estimate "gain CD4 M12 5-10 ans"  T1 12 T2 0 cl_age*T1 0 0 0 12 0  cd4_cl*T1 12 0 0  GENDER*T1 12 0 regime_ART*T1 12 0 0 / cl;
estimate "gain CD4 M12 10-15 ans"  T1 12 T2 0 cl_age*T1 0 0 0 0 12  cd4_cl*T1 12 0 0  GENDER*T1 12 0 regime_ART*T1 12 0 0 / cl;
estimate "gain CD4 M24 < 2 ans"  T1 12 T2 12 cl_age*T1 12 0 0 0 0 cl_age*T2 12 0 0 0 0 
cd4_cl*T1 12 0 0 cd4_cl*T2 12 0 0 GENDER*T1 12 0 GENDER*T2 12 0 regime_ART*T1  12 0 0 regime_ART*T2  12 0 0/ cl;
estimate "gain CD4 M24  2-3 ans"  T1 12 T2 12 cl_age*T1 0 12 0 0 0 cl_age*T2 0 12 0 0 0  
cd4_cl*T1 12 0 0 cd4_cl*T2 12 0 0 GENDER*T1 12 0 GENDER*T2 12 0 regime_ART*T1  12 0 0 regime_ART*T2  12 0 0 /cl;
estimate "gain CD4 M24 3-5 ans"  T1 12 T2 12 cl_age*T1 0 0 12 0 0  cl_age*T2 0 0 12 0 0  
cd4_cl*T1 12 0 0 cd4_cl*T2 12 0 0 GENDER*T1 12 0 GENDER*T2 12 0 regime_ART*T1  12 0 0 regime_ART*T2  12 0 0 / cl;
estimate "gain CD4 M24 5-10 ans"  T1 12 T2 12 cl_age*T1 0 0 0 12 0  cl_age*T2 0 0 0 12 0  
cd4_cl*T1 12 0 0 cd4_cl*T2 12 0 0 GENDER*T1 12 0 GENDER*T2 12 0 regime_ART*T1  12 0 0 regime_ART*T2  12 0 0 / cl;
estimate "gain CD4 M24 10-15 ans"  T1 12 T2 12 cl_age*T1 0 0 0 0 12  cl_age*T2 0 0 0 0 12 
cd4_cl*T1 12 0 0 cd4_cl*T2 12 0 0 GENDER*T1 12 0 GENDER*T2 12 0 regime_ART*T1  12 0 0 regime_ART*T2  12 0 0/ cl;
run;

**Modèle linéaire mixte sur 5 ans;
*Création de la variable D_CD4;

data abs_finale; set abs_finale;
D_CD4 = (cd4_v - Cd4_art);
FU_time = (FU_time)*12;
run; 

*Création de la variable FU_time et FU_time2;
data abs_finale; set abs_finale;
if FU_time< 12 then do; T1=FU_time;T2=0;end;
if FU_time >=12 then do; T1=12;T2=FU_time-12;end;
run;

*model plein en fonction de l'age, des CD4, du sexe et du traitement;

proc mixed data = abs_finale method = ml noclprint covtest;
class UID cl_age;
model D_CD4 = T1 T2 cl_age*T1 cl_age*T2 / noint s cl ddfm=bw outpred = p;;
random  T1 T2/sub=UID type = UN;
run;
*Gain à 12 mois;
estimate "gain CD4 M12 < 2 ans"  T1 12 T2 0 cl_age*T1 12 0 0 0 0 /cl;
estimate "gain CD4 M12 3 ans"  T1 12 T2 0 cl_age*T1 0 12 0 0 0 /cl ;
estimate "gain CD4 M12 4-5 ans"  T1 12 T2 0 cl_age*T1 0 0 12 0 0 /cl ;
estimate "gain CD4 M12 6-10 ans"  T1 12 T2 0 cl_age*T1 0 0 0 12 0/cl;  
estimate "gain CD4 M12 11-15 ans"  T1 12 T2 0 cl_age*T1  0 0 0 0 12/cl;
*Gain à 24 mois;
estimate "gain CD4 M24 < 2 ans"  T1 12 T2 12 cl_age*T1 12 0 0 0 0 cl_age*T2 12 0 0 0 0/cl ;
estimate "gain CD4 M24 3 ans"  T1 12 T2 12 cl_age*T1 0 12 0 0 0 cl_age*T2 0 12 0 0 0 /cl;
estimate "gain CD4 M24 4-5 ans"  T1 12 T2 12 cl_age*T1 0 0 12 0 0 cl_age*T2 0 0 12 0 0 /cl;
estimate "gain CD4 M24 6-10 ans"  T1 12 T2 12 cl_age*T1 0 0 0 12 0 cl_age*T2 0 0 0 12 0/cl;  
estimate "gain CD4 M24 11-15 ans"  T1 12 T2 12 cl_age*T1  0 0 0 0 12 cl_age*T2  0 0 0 0 12/cl;
run;

proc mixed data = abs_finale method = ml noclprint covtest;
class UID cd4_cl;
model D_CD4 = T1 T2 cd4_cl*T1 cd4_cl*T2 / noint s cl ddfm=bw outpred = p;
random intercept T1 T2/sub=UID type = UN;
*Gain à 12 mois;
estimate "gain CD4 M12 no signs"  T1 12 T2 0 cd4_cl*T1 12 0 0/cl ;
estimate "gain CD4 M12 mod"  T1 12 T2 0 cd4_cl*T1 0 12 0  /cl;
estimate "gain CD4 M12 severe"  T1 12 T2 0 cd4_cl*T1 0 0 12 /cl;
*Gain à 24 mois;
estimate "gain CD4 M24 no signs"  T1 12 T2 12 cd4_cl*T1 12 0 0 cd4_cl*T2 12 0 0/cl ;
estimate "gain CD4 M24 mod"  T1 12 T2 12 cd4_cl*T1 0 12 0 cd4_cl*T2 0 12 0 /cl ;
estimate "gain CD4 M24 severe"  T1 12 T2 12 cd4_cl*T1 0 0 12 cd4_cl*T2 0 0 12 /cl;
run;

proc mixed data = abs_finale method = ml noclprint covtest;
class UID gender;
model D_CD4 = T1 T2 gender*T1 gender*T2 / noint s cl ddfm=bw outpred = p;
random intercept T1 T2/sub=UID type = UN;
*Gain à 12 mois;
estimate "gain CD4 M12 boys"  T1 12 T2 0 gender*T1 12 0 /cl;
estimate "gain CD4 M12 girls"  T1 12 T2 0 gender*T1 0 12 0  /cl;
*Gain à 24 mois;
estimate "gain CD4 M24 boys"  T1 12 T2 12 gender*T1 12 0  gender*T2 12 0  /cl;
estimate "gain CD4 M24 girls"  T1 12 T2 12 gender*T1 0 12 gender*T2 0 12 /cl;
run;


proc mixed data = abs_finale_24 method = ml noclprint covtest;
class UID regime_ART;
model D_CD4 = T1 T2 regime_ART*T1 regime_ART*T2 / noint s cl ddfm=bw outpred = p;
random intercept T1 T2/sub=UID type = UN;
*Gain à 12 mois;
estimate "gain CD4 M12 NNRTI"  T1 12 T2 0 regime_ART*T1 12 0/cl ;
estimate "gain CD4 M12 PI"  T1 12 T2 0 regime_ART*T1 0 12 0/cl  ;
*Gain à 24 mois;
estimate "gain CD4 M24 NNRTI"  T1 12 T2 12 regime_ART*T1 12 0  regime_ART*T2 12 0 /cl ;
estimate "gain CD4 M24 PI"  T1 12 T2 12 regime_ART*T1 0 12 regime_ART*T2 0 12/cl ;
run;


proc mixed data = abs_finale method=ml noclprint covtest PLOTS(MAXPOINTS=100000);
class UID cl_age cd4_cl Gender regime_ART ;
model D_CD4 =  T1 T2  cl_age*T1  cl_age*T2 cd4_cl*T1 cd4_cl*T2 GENDER*T1 GENDER*T2 regime_ART*T1 regime_ART*T2 / noint s cl ddfm=bw outpred = p ;
random  T1 T2/sub=UID type = UN;
*Différence de gain à 12 mois;
estimate "gain CD4 M12 3 vs <2"  cl_age*T1 -12 12 0 0 0 cl_age*T2 0 0 0 0 0 / cl;
estimate "gain CD4 M12 4-5 vs <2"  cl_age*T1 -12 0 12 0 0 cl_age*T2 0 0 0 0 0 / cl;
estimate "gain CD4 M12 6-10 vs <2"  cl_age*T1 -12 0 0 12 0 cl_age*T2 0 0 0 0 0 / cl;
estimate "gain CD4 M12 10-15 vs <2"  cl_age*T1 -12 0 0 0 12 cl_age*T2 0 0 0 0 0 / cl;

estimate "gain CD4 M12 mod vs nsp"  cd4_cl*T1 -12 12 0  cd4_cl*T2 0 0 0 / cl;
estimate "gain CD4 M12 sev vs nsp"  cd4_cl*T1 -12 0 12 cd4_cl*T2 0 0 0 / cl;

estimate "gain CD4 M12 F vs M"   GENDER*T1 -12 12  GENDER*T2 0 0 / cl;

estimate "gain CD4 M12 IP vs NNRTI" regime_ART*T1 -12 12 0 regime_ART*T2 0 0 0/cl;

*Différence de gain à 24 mois;
estimate "gain CD4 M24 3 vs <2"  cl_age*T1 -12 12 0 0 0 cl_age*T2 -12 12 0 0 0 / cl;
estimate "gain CD4 M24 4-5 vs <2"  cl_age*T1 -12 0 12 0 0 cl_age*T2 -12 0 12 0 0 / cl;
estimate "gain CD4 M24 6-10 vs <2"  cl_age*T1 -12 0 0 12 0 cl_age*T2 -12 0 0 12 0 / cl;
estimate "gain CD4 M24 10-15 vs <2"  cl_age*T1 -12 0 0 0 12 cl_age*T2 -12 0 0 0 12 / cl;

estimate "gain CD4 M24 mod vs nsp"  cd4_cl*T1 -12 12 0  cd4_cl*T2 -12 12 0 / cl;
estimate "gain CD4 M24 sev vs nsp"  cd4_cl*T1 -12 0 12 cd4_cl*T2 -12 0 12 / cl;

estimate "gain CD4 M24 F vs M"  GENDER*T1 -12 12 GENDER*T2 -12 12 / cl;

estimate "gain CD4 M24 IP vs NNRTI" regime_ART*T1 -12 12 0regime_ART*T2 -12 12 0/cl;

*Différence de gain à 36 mois;
estimate "gain CD4 M36 3 vs <2"  cl_age*T1 -12 12 0 0 0 cl_age*T2 -24 24 0 0 0 / cl;
estimate "gain CD4 M36 4-5 vs <2"  cl_age*T1 -12 0 12 0 0 cl_age*T2 -24 0 24 0 0 / cl;
estimate "gain CD4 M36 6-10 vs <2"  cl_age*T1 -12 0 0 12 0 cl_age*T2 -24 0 0 24 0 / cl;
estimate "gain CD4 M36 10-15 vs <2"  cl_age*T1 -12 0 0 0 12 cl_age*T2 -24 0 0 0 24 / cl;

estimate "gain CD4 M36 mod vs nsp"  cd4_cl*T1 -12 12 0  cd4_cl*T2 -24 24 0 / cl;
estimate "gain CD4 M36 sev vs nsp"  cd4_cl*T1 -12 0 12 cd4_cl*T2 -24 0 24 / cl;

estimate "gain CD4 M36 F vs M"  GENDER*T1 -12 12 GENDER*T2 -24 24 / cl;

estimate "gain CD4 M36 IP vs NNRTI"  regime_ART*T1 -12 12 0regime_ART*T2 -24 24 0/cl;

*Différence de gain à 60 mois;
estimate "gain CD4 M60 3 vs <2"  cl_age*T1 -12 12 0 0 0 cl_age*T2 -48 48 0 0 0 / cl;
estimate "gain CD4 M60 4-5 vs <2"  cl_age*T1 -12 0 12 0 0 cl_age*T2 -48 0 48 0 0 / cl;
estimate "gain CD4 M60 6-10 vs <2"  cl_age*T1 -12 0 0 12 0 cl_age*T2 -48 0 0 48 0 / cl;
estimate "gain CD4 M60 10-15 vs <2"  cl_age*T1 -12 0 0 0 12 cl_age*T2 -48 0 0 0 48 / cl;

estimate "gain CD4 M60 mod vs nsp"  cd4_cl*T1 -12 12 0  cd4_cl*T2 -48 48 0 / cl;
estimate "gain CD4 M60 sev vs nsp"  cd4_cl*T1 -12 0 12 cd4_cl*T2 -48 0 48 / cl;

estimate "gain CD4 M60 F vs M"  GENDER*T1 -12 12 GENDER*T2 -48 48 / cl;

estimate "gain CD4 M60 IP vs NNRTI"  regime_ART*T1 -12 12 0regime_ART*T2 -48 48 0/cl;


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



*Gain à 36 mois;
estimate "gain CD4 M36 < 2 ans"  T1 12 T2 24 cl_age*T1 12 0 0 0 0 cl_age*T2 24 0 0 0 0 
cd4_cl*T1 12 0 0 cd4_cl*T2 24 0 0 GENDER*T1 12 0 GENDER*T2 24 0 regime_ART*T1  12 0 0 regime_ART*T2  24 0 0 / cl;
estimate "gain CD4 M36  3 ans"  T1 12 T2 24 cl_age*T1 0 12 0 0 0 cl_age*T2 0 24 0 0 0  
cd4_cl*T1 12 0 0 cd4_cl*T2 24 0 0 GENDER*T1 12 0 GENDER*T2 24 0 regime_ART*T1  12 0 0 regime_ART*T2  24 0 0 / cl;
estimate "gain CD4 M36 4-5 ans"  T1 12 T2 24 cl_age*T1 0 0 12 0 0  cl_age*T2 0 0 24 0 0  
cd4_cl*T1 12 0 0 cd4_cl*T2 24 0 0 GENDER*T1 12 0 GENDER*T2 24 0 regime_ART*T1  12 0 0 regime_ART*T2  24 0 0 / cl;
estimate "gain CD4 M36 6-10 ans"  T1 12 T2 24 cl_age*T1 0 0 0 12 0  cl_age*T2 0 0 0 24 0  
cd4_cl*T1 12 0 0 cd4_cl*T2 24 0 0 GENDER*T1 12 0 GENDER*T2 24 0 regime_ART*T1  12 0 0 regime_ART*T2  24 0 0 / cl;
estimate "gain CD4 M36 11-15 ans"  T1 12 T2 24 cl_age*T1 0 0 0 0 12  cl_age*T2 0 0 0 0 24
cd4_cl*T1 12 0 0 cd4_cl*T2 24 0 0 GENDER*T1 12 0 GENDER*T2 24 0 regime_ART*T1  12 0 0 regime_ART*T2  24 0 0 / cl;

estimate "gain CD4 M36 no isp"  T1 12 T2 24 cd4_cl*T1 12 0 0  cd4_cl*T2 24 0 0  
cl_age*T1 12 0 0 0 0 cl_age*T2 24 0 0 0 0  GENDER*T1 12 0 GENDER*T2 24 0 regime_ART*T1  12 0 0 regime_ART*T2  24 0 0 / cl;
estimate "gain CD4 M36 mod isp"  T1 12 T2 24 cd4_cl*T1 0 12 0 cd4_cl*T2 0 24 0 
cl_age*T1 12 0 0 0 0 cl_age*T2 24 0 0 0 0  GENDER*T1 12 0 GENDER*T2 24 0 regime_ART*T1  12 0 0 regime_ART*T2  24 0 0 / cl;
estimate "gain CD4 M36 sev isp"  T1 12 T2 24 cd4_cl*T1 0 0 12  cd4_cl*T2 0 0 24
cl_age*T1 12 0 0 0 0 cl_age*T2 24 0 0 0 0  GENDER*T1 12 0 GENDER*T2 24 0 regime_ART*T1  12 0 0 regime_ART*T2  24 0 0 / cl;

estimate "gain CD4 M36 M" T1 12 T2 24 GENDER*T1 12 0  GENDER*T2 24 0 
cd4_cl*T1 12 0 0 cd4_cl*T2 24 0 0 cl_age*T1 12 0 0 0 0 cl_age*T2 24 0 0 0 0 regime_ART*T1  12 0 0 regime_ART*T2  24 0 0 / cl;
estimate "gain CD4 M36 F"  T1 12 T2 24 GENDER*T1 0 12 GENDER*T2 24 0
cd4_cl*T1 12 0 0 cd4_cl*T2 24 0 0 cl_age*T1 12 0 0 0 0 cl_age*T2 24 0 0 0 0 regime_ART*T1  12 0 0 regime_ART*T2  24 0 0 / cl;


estimate "gain CD4 M36 2NRTI+1NNRTI"  T1 12 T2 24 regime_ART*T1  12 0 0 regime_ART*T2 24 0 0
GENDER*T1 12 0 GENDER*T2 24 0 cd4_cl*T1 12 0 0 cd4_cl*T2 24 0 0 cl_age*T1 12 0 0 0 0 cl_age*T2 24 0 0 0 0 / cl;
estimate "gain CD4 M36 2NRTI+1IP"  T1 12 T2 24 regime_ART*T1 0 12 0 regime_ART*T2 0 24 0   
GENDER*T1 12 0  GENDER*T2 24 0 cd4_cl*T1 12 0 0 cd4_cl*T2 24 0 0 cl_age*T1 12 0 0 0 0 cl_age*T2 24 0 0 0 0 / cl;



*Gain à 60 mois;
estimate "gain CD4 M60 < 2 ans"  T1 12 T2 48 cl_age*T1 12 0 0 0 0 cl_age*T2 48 0 0 0 0 
cd4_cl*T1 12 0 0 cd4_cl*T2 48 0 0 GENDER*T1 12 0 GENDER*T2 48 0 regime_ART*T1  12 0 0 regime_ART*T2  48 0 0 / cl;
estimate "gain CD4 M60  3 ans"  T1 12 T2 48 cl_age*T1 0 12 0 0 0 cl_age*T2 0 48 0 0 0  
cd4_cl*T1 12 0 0 cd4_cl*T2 48 0 0 GENDER*T1 12 0 GENDER*T2 48 0 regime_ART*T1  12 0 0 regime_ART*T2  48 0 0 / cl;
estimate "gain CD4 M60 4-5 ans"  T1 12 T2 48 cl_age*T1 0 0 12 0 0  cl_age*T2 0 0 48 0 0  
cd4_cl*T1 12 0 0 cd4_cl*T2 48 0 0 GENDER*T1 12 0 GENDER*T2 48 0 regime_ART*T1  12 0 0 regime_ART*T2  48 0 0 / cl;
estimate "gain CD4 M60 6-10 ans"  T1 12 T2 48 cl_age*T1 0 0 0 12 0  cl_age*T2 0 0 0 48 0  
cd4_cl*T1 12 0 0 cd4_cl*T2 48 0 0 GENDER*T1 12 0 GENDER*T2 48 0 regime_ART*T1  12 0 0 regime_ART*T2 48 0 0 / cl;
estimate "gain CD4 M60 11-15 ans"  T1 12 T2 48 cl_age*T1 0 0 0 0 12  cl_age*T2 0 0 0 0 48
cd4_cl*T1 12 0 0 cd4_cl*T2 48 0 0 GENDER*T1 12 0 GENDER*T2 48 0 regime_ART*T1  12 0 0 regime_ART*T2  48 0 0 / cl;

estimate "gain CD4 M60 no isp"  T1 12 T2 48 cd4_cl*T1 12 0 0  cd4_cl*T2 48 0 0  
cl_age*T1 12 0 0 0 0 cl_age*T2 48 0 0 0 0  GENDER*T1 12 0 GENDER*T2 48 0 regime_ART*T1  12 0 0 regime_ART*T2  48 0 0 / cl;
estimate "gain CD4 M60 mod isp"  T1 12 T2 48 cd4_cl*T1 0 12 0 cd4_cl*T2 0 48 0 
cl_age*T1 12 0 0 0 0 cl_age*T2 48 0 0 0 0  GENDER*T1 12 0 GENDER*T2 48 0 regime_ART*T1  12 0 0 regime_ART*T2  48 0 0 / cl;
estimate "gain CD4 M60 sev isp"  T1 12 T2 48 cd4_cl*T1 0 0 12  cd4_cl*T2 0 0 48
cl_age*T1 12 0 0 0 0 cl_age*T2 48 0 0 0 0  GENDER*T1 12 0 GENDER*T2 48 0 regime_ART*T1  12 0 0 regime_ART*T2  48 0 0 / cl;

estimate "gain CD4 M60 M" T1 12 T2 48 GENDER*T1 12 0  GENDER*T2 48 0 
cd4_cl*T1 12 0 0 cd4_cl*T2 48 0 0 cl_age*T1 12 0 0 0 0 cl_age*T2 48 0 0 0 0 regime_ART*T1  12 0 0 regime_ART*T2  48 0 0 / cl;
estimate "gain CD4 M60 F"  T1 12 T2 48 GENDER*T1 0 12 GENDER*T2 48 0
cd4_cl*T1 12 0 0 cd4_cl*T2 48 0 0 cl_age*T1 12 0 0 0 0 cl_age*T2 48 0 0 0 0 regime_ART*T1  12 0 0 regime_ART*T2  48 0 0 / cl;


estimate "gain CD4 M60 2NRTI+1NNRTI"  T1 12 T2 48 regime_ART*T1  12 0 0 regime_ART*T2 48 0 0
GENDER*T1 12 0 GENDER*T2 48 0 cd4_cl*T1 12 0 0 cd4_cl*T2 48 0 0 cl_age*T1 12 0 0 0 0 cl_age*T2 48 0 0 0 0 / cl;
estimate "gain CD4 M60 2NRTI+1IP"  T1 12 T2 48 regime_ART*T1 0 12 0 regime_ART*T2 0 48 0   
GENDER*T1 12 0  GENDER*T2 48 0 cd4_cl*T1 12 0 0 cd4_cl*T2 48 0 0 cl_age*T1 12 0 0 0 0 cl_age*T2 48 0 0 0 0 / cl;

run;

/

					********************************** RATTRAPAGE DE IMMUNITE NORMALE *********************
/;
* A partie de abs_finale_24;

*Sélectionner les enfants en immunodépression sévère dès la mise sous ART:;

data rattrapage; set abs_finale_24;
if cd4_cl >1 then output;
run;
proc freq data = rattrapage;
table cd4_cl;
run;
*Vérif du nombre de patients : 922;
proc sql;
select count(distinct UID) from rattrapage
quit; run;

*Trier les patients par dates et déterminer l'évènement "rattraper une croissance normale";
proc sort data = rattrapage;
by UID mvisit;
run;
*Age à la visite;
data rattrapage; set rattrapage;
age_visit = (cd4_d - birth_d) / 365.25;
run;
proc means data = rattrapage;
var age_visit;
run;
*Classe de CD4 à la visite;
data rattrapage; set rattrapage;

if age_visit <1 and cd4_v < 1500 then cd4_cl_visit = 3; 
if (age_visit  >= 1 and age_visit  < 3) and cd4_v <750 then cd4_cl_visit = 3; 
if (age_visit  >= 3 and age_visit  < 5) and cd4_v <500 then cd4_cl_visit = 3;
if age_visit  >=5 and cd4_v < 200 then cd4_cl_visit = 3;

if age_visit <1 and (cd4_v >=1500 and cd4_v < 2000) then cd4_cl = 2;
if (age_visit  >= 1 and age_visit  < 3) and (cd4_v >= 750  and cd4_v < 1000) then cd4_cl_visit = 2; 
if (age_visit  >= 3 and age_visit < 5) and (cd4_v >= 350 and cd4_v < 500) then cd4_cl_visit = 2;
if age_visit  >=5 and (cd4_v >= 200 and cd4_v < 350) then cd4_cl_visit = 2;

if age_visit  <1 and cd4_v > 2000 then cd4_cl_visit = 1; 
if (age_visit  >= 1 and age_visit  < 3) and cd4_v >= 1000 then cd4_cl_visit = 1; 
if (age_visit  >= 3 and age_visit  < 5) and cd4_v >=500 then cd4_cl_visit = 1;
if age_visit  >=5 and cd4_v >= 350 then cd4_cl_visit = 1;


run;

*Nombre d'enfants atteignant un rattrapage d'ici M24 : 625;
proc sql;
select count(distinct UID) from rattrapage
where cd4_cl_visit = 1;
quit; run;

*Codage du rattrapage;
data rattrapage; set rattrapage;
if cd4_cl_visit = 1 then rat = 1; else rat=2;
run;


*Table uniquement avec enfants qui ont fait un rattrapage;

data enf_rat; set rattrapage;
if  rat = 1 then output;
run;
proc sort data = enf_rat;
by UID mvisit;
run; 
data enf_rat; set enf_rat;
by UID mvisit;
if first.UID = 1 then output;
run;

*Table avec ceux qui n'ont pas rattrapé leur croissance;

proc sql;
	create table non_rat as
	select *
      from rattrapage
      where not exists (select *
            from enf_rat
            where enf_rat.UID = rattrapage.UID);
quit;
run;

*Nombre d'enfants dans non_rat;
proc sort data = non_rat;
by UID mvisit;run;
data non_rat; set non_rat;
by UID mvisit;
if last.UID = 1 then output;
run;


*Codage de event dans enf_rat;
data enf_rat;set enf_rat;
event = 1;
run;
*Codage de event dans non_rat;
data non_rat; set non_rat;
if outcome_24 = 1 then event = 2; * DC; 
if outcome_24 = 2 then event = 3;* pdv; 
if outcome_24 = 3 then event = 0; *suivi;
run;

*Concaténation des deux tables;
data rattrapage_finale; set enf_rat non_rat;
run;

*Les outcomes;
proc freq data = rattrapage_finale;
table event;
run;


*Modèle de Cox;

*Création de la variable time;
data rattrapage_finale; set rattrapage_finale;
time = (cd4_d - art_sd) / 30;
run;
proc univariate data = rattrapage_finale;
var time;
run;
*Supprimer données abbérantes;
data rattrapage_finale; set rattrapage_finale;
if time < = 0 then delete;
if event = 1 then rat_cd4 = 1; else rat_cd4 = 0;
if event = 2 then dc = 1; else dc = 0;
run;

*Recodage de l'évènement pour censure;
data rattrapage_finale; set rattrapage_finale;
if event =  1 then event_KM = 1 ;else event_KM = 0;
run;

*Codage de event_KM_12 and event_KM_24;

*Temps médian pour le rattrapge;
proc means data = rattrapage_finale median Q1 Q3;
var time;
run;
*Kaplan Meier;
*Recodage des classes d'age en 3;
data rattrapage_finale;set rattrapage_finale;
if cl_age = 1 then cl_age_2 = 1;
if cl_age >1 and cl_age < 5 then cl_age_2 = 2;
if cl_age = 5 then cl_age_2 = 3;
run;
proc lifetest data = rattrapage_finale plots = (s) graphics outsurv = p;
time time*event_KM(0);
strata cl_age_2;
run;

data p; set p;
var = 1 - survival;
vardown = 1 - SDF_UCL;
varup = 1 - SDF_LCL;
run;

goptions noborder htext = 3pct ;
axis1   label=( "Probability ") offset=(0,0) order=(0 to 1 by 0.2); 
axis2   label=( "Time since ART initiation (months)") offset=(0,0) order=(0 to 24 by 6);
proc gplot data = p;
plot var*time = cl_age_2/vaxis = axis1 haxis =axis2 legend = legend1;

symbol1 color = black line = 1 width = 2 interpol=steplj;
symbol2 color = green line=2 width = 2 interpol=steplj;
symbol3 color = red line = 3 width = 2 interpol=steplj;

legend1 position=(bottom center outside) label = ('Age at ART initiation') 
value = (tick =1 '<2 years' tick=2 '2-5  years' tick=3 '5+ years');
run;



*Analyses univariées;
proc phreg data = rattrapage_finale;
class cl_age_2 (ref = '1') / param = ref;
class regime_ART (ref = '1') / param = ref;
class CD4_cl (ref = '2') / param = ref;
model time*event_KM(0) = cl_age_2  CD4_cl  regime_ART gender /rl;
if (time > 12) then intert = 0;
else intert = cl_age_2;
run;


proc phreg data = rattrapage_finale;
model time*event_KM(0) = gender;
run;
proc phreg data = rattrapage_finale;
class cd4_cl (ref = '3') / param = ref;
model time*event_KM(0) = cd4_cl;
run;
*Export sous R;

*KM et Cox avec classes 2-5 ans;
data rattrapage_finale_2;
set rattrapage_finale;
if cl_age >1 and cl_age <5 then cl_age = 2.5;
run;
proc freq data = rattrapage_finale;
table cl_age;
run;
proc freq data = rattrapage_finale_2;
table cl_age;
run;
proc phreg data = rattrapage_finale_2;
class cl_age (ref = '1') / param = ref;
class regime_ART (ref = '1') / param = ref;
class CD4_cl (ref = '2') / param = ref;
model time*event_KM(0) = cl_age  CD4_cl  regime_ART gender/rl; *intert/rl;
*if (time > 12) then intert = 0;
*else intert = cl_age;
run;

/

					********************************** MESURES AVANT ART ***********************************

/;

*Identification des enfants avec des mesures CD4 avant ART;
*Reprendre la table de départ: immuno.labpat;
data before_art;
set immuno.labpat;
if mes_delai < -3 then output; 
run;
data before_art;
set before_art;
if cd4_U = 2 then delete; 
run;
data before_art;
set before_art;
if cd4_v > 3000 then delete; 
run;

*Numéroter les mesures;
	*numéros de mesure;
data before_art ;set before_art;
by UID;
format mes_CD4 $16.;
if mes_delai <-27 then delete;
if mes_delai >= -27 and mes_delai <-21 then mes_CD4 = "01_M-24";
if mes_delai >= - 21 and mes_delai < -15 then mes_CD4 = "02_M-18";
if mes_delai >= - 15 and mes_delai < -9 then mes_CD4 = "03_M-12";
if mes_delai >= - 9 and mes_delai < -3 then mes_CD4 = "04_M-6";
run;
*si plusieurs mesures pour un intevalle, prendre celle qui se rapproche le plus;

data before_art; set before_art; * recoder pour que M0 soit le premier;
if mes_CD4 = "01_M-24" then delai_CD4 = abs(-24-mes_delai);
if mes_CD4 = "02_M-18" then delai_CD4 = abs(-18-mes_delai);
if mes_CD4 = "03_M-12" then delai_CD4 = abs(-12-mes_delai);
if mes_CD4 = "04_M-6" then delai_CD4 = abs(-6-mes_delai);
run;

proc sort data = before_art;
by UID mes_CD4 delai_CD4;
run;
data before_art; set before_art;
by UID mes_CD4;
if first.mes_CD4 = 1 then output;
run;
*1513 mesures pre-ART;

data pre_ART_patients;set before_ART;
by UID;
if first.UID = 1 then output;
run;
*932 patients avec données pre-ART

*Merge avec la table des patients sous ART pour modéliser les CD4 depuis l'inclusion;

proc sql;
	create table inc_art as
	select *
      from before_art
      where exists (select *
            from abs
            where abs.UID = before_art.UID)
UNION
select *
      from abs
      where exists (select *
            from before_art
            where before_art.UID = abs.UID);
quit;
run;
data pre_ART_patients;set inc_ART;
by UID;
if first.UID = 1 then output;
run;
*931 enfants avec au moins deux données pre/post ART;

*Distribution of median CD4 by time since ART initiation;

proc means data = inc_art median Q1 Q3;
class mes_CD4;
var cd4_v;
run;
proc means data = inc_art;
class mes_CD4;
var cd4_v;
run;
data inc_art;set inc_art;
if mes_CD4 = "01_M-24" then mvisit = -24;
if mes_CD4 = "02_M-18" then mvisit = -18;
if mes_CD4 = "03_M-12" then mvisit = -12;
if mes_CD4 = "04_M-6" then mvisit = -6;
if mes_CD4 = "0_M0" then mvisit = 0;
if mes_CD4 = "1_M6" then mvisit = 6;
if mes_CD4 = "2_M12" then mvisit = 12;
if mes_CD4 = "3_M18" then mvisit = 18;
if mes_CD4 = "4_M24" then mvisit = 24;
if mes_CD4 = "5_M30" then mvisit = 30;
if mes_CD4 = "6_M36" then mvisit = 36;
if mes_CD4 = "7_M42" then mvisit = 42;
if mes_CD4 = "8_M48" then mvisit = 48;
if mes_CD4 = "9_M54" then mvisit = 54;
if mes_CD4 = "99_M60" then mvisit = 60;
run;
data inc_art;set inc_art;
age_inc = (inc_d - birth_d) / 365.25;
run;
data inc_art;set inc_art;
if age_inc < 2 then age_inc_cl = 1;
if age_inc >= 2 and age_inc <3 then age_inc_cl = 2;
if age_inc >=3 and age_inc < 4 then age_inc_cl = 3;
if age_inc >=4 and age_inc < 5 then age_inc_cl = 4;
if age_inc >=5 then age_inc_cl = 5;
run;

data inc_art;set inc_art;
if mes_CD4 > "4_M24" then delete;
run;
proc sort data = inc_art;
by UID mes_CD4;
run;
data inc_art_pat;set inc_art;
by UID;
if first.UID = 1 then output;
run;
proc means data = inc_art_pat median Q1 Q3;
var age_inc;
run;
data inc_art_pat; set inc_art_pat;

if age_inc < 1 and cd4_v < 1500 then cd4_cl = 3;
if (age_inc >= 1 and age_inc < 2) and cd4_v <750 then cd4_cl = 3;
if (age_inc >= 2 and age_inc <5) and cd4_v < 350 then cd4_cl = 3;
if age_inc >=5 and cd4_v < 200 then cd4_cl = 3;


if (age_inc >= 2 and age_inc <5) and (cd4_v >= 350 or cd4_v < 750) then cd4_cl = 2;
if age_inc >=5 and (cd4_v>= 200 and cd4_v < 350) then cd4_cl = 2;

if age_inc < 1 and cd4_v >=1500  then cd4_cl = 1;
if (age_inc >= 1 and age_inc < 2) and cd4_v >= 750 then cd4_cl =1 ;
if (age_inc >= 2 and age_inc <5) and cd4_v >= 750 then cd4_cl = 1;
if age_inc >=5 and cd4_v >= 350 then cd4_cl = 1;

run;
data inc_art_pat; set inc_art_pat;
cd4_inc = cd4_v;
run;

proc means data = inc_art_pat median Q1 Q3;
var cd4_v;run;
proc freq data = inc_art_pat;
table cd4_cl;
run;

data inc_art_pat; set inc_art_pat;
time_to_art = (art_sd - inc_d)/30;
run;
proc means data = inc_art_pat median Q1 Q3;
var time_to_art;
run;


*CD4 médian par temps;
*Export sous R pour courbe;


*Modèle multivariée;
*Merge des deux tables patients et toutes les mesures pour avoir les variables;
proc sort data = inc_art;
by UID;
run;
proc sort data = inc_art_pat;
by UID;
run;
data inc_art_finale;
merge inc_art_pat (in=x) inc_art;
by UID;
if x;
run;

data inc_art_finale; set inc_art_finale;

if age_inc < 1 and cd4_inc < 1500 then cd4_cl = 3;
if (age_inc >= 1 and age_inc < 2) and cd4_inc <750 then cd4_cl = 3;
if (age_inc >= 2 and age_inc <5) and cd4_inc < 350 then cd4_cl = 3;
if age_inc >=5 and cd4_v < 200 then cd4_inc = 3;


if (age_inc >= 2 and age_inc <5) and (cd4_inc >= 350 or cd4_inc < 750) then cd4_cl = 2;
if age_inc >=5 and (cd4_inc>= 200 and cd4_inc < 350) then cd4_cl = 2;

if age_inc < 1 and cd4_inc >=1500  then cd4_cl = 1;
if (age_inc >= 1 and age_inc < 2) and cd4_inc >= 750 then cd4_cl =1 ;
if (age_inc >= 2 and age_inc <5) and cd4_inc >= 750 then cd4_cl = 1;
if age_inc >=5 and cd4_inc >= 350 then cd4_cl = 1;

run;

*Création de la variable D_CD4;
data inc_art_finale; set inc_art_finale;
D_CD4 = (cd4_v - Cd4_inc);
run; 

*model plein en fonction de l'age, des CD4, du sexe et du traitement;
proc mixed data = inc_art_finale method=ml noclprint covtest;
class UID age_inc_cl cd4_cl Gender;
model D_CD4 =  time_to_art  age_inc_cl*time_to_art  cd4_cl*time_to_art GENDER*time_to_art / noint s cl ddfm=bw outpred = p;
random   time_to_art/sub=UID type = UN;
run;



proc gplot data = p;
plot Resid*Pred;
run;

proc univariate data = p;
var Resid;
histogram Resid/normal;
run;

















**************************************************************************************
***********************************************************************************************************************

*Comparatif avec enfants non inclus;
	* Récupération de leur ID patient
*ID des patients inclus;
data pat_id_inclus;set abs_finale;
keep UID;
run;
*ID de tous les patients;
data  pat_id_tous;set immuno.inftreated;
keep UID;
run;
*Selection que de ceux non inclus;
proc sql;
	create table pat_id_noninclus as
SELECT UID FROM  pat_id_tous except select UID From pat_id_inclus;quit;
run;
*Merge avec variables descriptives;
proc sort data = immuno.inf_treated;by UID;run;
proc sort data = pat_id_noninclus; by UID;run;
data pat_noninclus;
merge pat_id_noninclus (in=x) immuno.inftreated; by UID;
if x;
run;

*Création de la variable cl_age, recodage de la variable stage_WHO_ART et traitement;
data pat_noninclus;
set pat_noninclus;
rename mise_ss_ART = art_sd;
run;
data pat_noninclus; set pat_noninclus;
age = (art_sd - birth_d) / 365.25;
run;
data pat_noninclus; set pat_noninclus;
if age <2 then cl_age = 1;
if age>=2 and age<3 then cl_age = 2;
if age>=3 and age<4 then cl_age = 3;
if age>=4 and age<5 then cl_age = 4;
if age>=5 then cl_age = 5;
run;
data pat_noninclus; set pat_noninclus;
if stage_WHO_ART = 9 then stage_WHO_ART = 99;
run;
data pat_noninclus;set pat_noninclus;
if regime_art>2 then regime_art = 3;
run;
*Concaténation des deux tables (pat_noninclus et patients_abs;
data patients_abs;set patients_abs;
inclus = 1;
run;
data pat_noninclus; set pat_noninclus;
inclus=0;
run;
data patients;set patients_abs pat_noninclus;
run;

*Description;
proc means data = patients median Q1 Q3;class inclus;var age;run;



proc npar1way data = patients; var age; class inclus;run;
proc freq data = patients;table cl_age*inclus  / chisq;run;
proc freq data = patients;table gender*inclus center*inclus regime_art*inclus stage_WHO_art*inclus outcome*inclus / chisq;run;

data patients; set patients;
art_year = year(art_sd);
run;
data patients; set patients;
if art_year < 2006 then art_year_cl = 1;
if (art_year >=2006 and art_year < 2008) then art_year_cl = 2;
if (art_year >=2008 and art_year < 2010) then art_year_cl =3;
if art_year >=2010 then art_year_cl = 4;
run;
proc freq data = patients;
where inclus = 1;
table stage_WHO_art*cl_age/ chisq;
run;
