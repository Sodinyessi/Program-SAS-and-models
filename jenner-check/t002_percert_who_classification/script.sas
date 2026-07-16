/* Adapted from percert.sas (Sodinyessi/Program-SAS-and-models), lines 150-231.
   Original runs against patients_perct, built earlier in the same script
   from immuno.labpat. Here a patient-level table with the same columns
   (age inputs, center, gender, WHO stage, CD4%) is supplied inline so the
   age banding, WHO immunological classification and the PROC FREQ/MEANS
   descriptive block run unmodified. */

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

*HB count;
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
