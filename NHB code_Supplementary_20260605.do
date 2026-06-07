
********************************************************
*    Codes for Supplementary Information (Appendix)    *
********************************************************

clear 
set matsize 800

* We set the working directory here (location redacted for publication)

* Note by authors: We do not display the working directory or the original HIPE dataset file names to ensure data confidentiality. 
* Interested readers may contact the HPO directly (http://www.hpo.ie/) to request access to the HIPE microdata.



************************************************************************************
* Supplementary A: Regulation History of Private Practice in Ireland prior to 2014 *
************************************************************************************
* No Stata code is needed here. 


**************************************************************************
* Supplementary B: Trends of Hospital Beds and Occupancy Rate in Ireland *
**************************************************************************
* No Stata code is needed here. 



*********************************************************
* Supplementary C: The Analysis at the Aggregated Level *
*********************************************************


*============================================================*
* Codes for Supplementary Figure C1: 						 *
* The distribution of Monthly Public Admissions per Hospital *
*============================================================*
use base_dataset_2014, clear
keep if public == 1
gen n = 1
collapse (count) n, by(anon_hosp modate)

* Showing the distribution at the original level
gen admissions = n

twoway histogram admissions, bin(25) ///
title("Distribution of Monthly Public Admissions per Hospital") ///
xtitle("Monthly Admission Count") ytitle("The Original Level (Admission Number)") ///
graphregion(fcolor(white)) legend(off) /// 
|| kdensity admissions, bwidth(80)
graph export Fig_C1_pub_admissions.png, replace




*========================================================================*
* Codes for Supplementary Figure C2  								     *
* The Distribution of Monthly Public Admission per Hospital (log format) *
*========================================================================*
use base_dataset_2014, clear
keep if public == 1
gen n = 1
collapse (count) n, by(anon_hosp modate)

* Showing the distribution at the ln format
gen admissions = n
gen ln_admissions=ln(admissions)

twoway histogram ln_admissions, bin(25) ///
title("Distribution of Monthly Public Admissions per Hospital") ///
xtitle("Monthly Admission Count") ytitle("Logarithmic Format") ///
graphregion(fcolor(white)) legend(off) /// 
|| kdensity ln_admissions, bwidth(1) 
graph export Fig_C2_ln_pub_admissions.png, replace


*========================================================================*
* Codes for Supplementary Figure C3 									 *
* The Distribution of Monthly Public Admission per Hospital (IHS format) *
*========================================================================*
use base_dataset_2014, clear
keep if public == 1
gen n = 1
collapse (count) n, by(anon_hosp modate)

* Calculate Inverse Hyperbolic Sine (IHS):
gen admissions = n
gen ihs_admissions=asinh(admissions)

twoway histogram ihs_admissions, bin(25) ///
title("Distribution of Monthly Public Admissions per Hospital") ///
xtitle("Monthly Admission Count") ytitle("IHS Format") ///
graphregion(fcolor(white)) legend(off) /// 
|| kdensity ihs_admissions, bwidth(1) 
graph export Fig_C3_ihs_pub_admissions.png, replace



*=======================================================================*
* Supplementary Table C1 Panel A: The Number of Public Admissions       *
* (Hospital-department Level)									   		*
*=======================================================================*
set matsize 800
use base_dataset_2014, clear

* Generate dummy for MDCs
* Starting from the inpatient record analysis
foreach n of numlist 1/25 {
gen mdc_`n'=0
replace mdc_`n'=1 if mdc==`n'
  } 
  


* Collapse dataset to the nation-department level    

gen n = 1

* drop private admissions
drop if public==0

collapse (count) n (mean) sex hasmedcard partner agegroup old_diagcons exp_proc inter_exp_proc mdc_1 mdc_2 mdc_3 mdc_4 mdc_5 mdc_6 mdc_7 mdc_8 mdc_9 mdc_10 mdc_11 mdc_12 mdc_13 mdc_14 mdc_15 mdc_16 mdc_17 mdc_18 mdc_19 mdc_20 mdc_21 mdc_22 mdc_23 mdc_24 mdc_25, by(anon_hosp elective modate admyear)

gen POST=.
replace POST=1 if modate > ym(2013,12)
replace POST=0 if modate <= ym(2013,12)

gen inter=POST*elective

gen admissions = n
gen ln_admissions=ln(admissions)

* Calculate Inverse Hyperbolic Sine (IHS): 
gen ihs_admissions=asinh(admissions)

global controls "sex partner agegroup hasmedcard old_diagcons exp_proc inter_exp_proc"
global mdcs "mdc_1 mdc_2 mdc_3 mdc_4 mdc_5 mdc_6 mdc_7 mdc_8 mdc_9 mdc_10 mdc_11 mdc_12 mdc_13 mdc_14 mdc_15 mdc_16 mdc_17 mdc_18 mdc_19 mdc_20 mdc_21 mdc_22 mdc_23 mdc_24 mdc_25"

egen hosp_depar = group(anon_hosp elective)
egen hosp_year = group(anon_hosp admyear)


*============================================*
* Supplementary Table C1 Panel A: Column 1   *
*============================================*
eststo clear

eststo:reg admissions ///
sex agegroup partner /// 
$mdcs /// 
hasmedcard /// 
old_diagcons exp_proc inter_exp_proc /// 
i.hosp_year i.modate /// 
i.elective i.inter, cluster(hosp_depar)


*============================================*
* Supplementary Table C1 Panel A: Column 2   *
*============================================*
eststo:reg ln_admissions ///
sex agegroup partner /// 
$mdcs /// 
hasmedcard /// 
old_diagcons exp_proc inter_exp_proc /// 
i.hosp_year i.modate /// 
i.elective i.inter, cluster(hosp_depar)

*============================================*
* Supplementary Table C1 Panel A: Column 3   *
*============================================*
eststo:reg ihs_admissions ///
sex agegroup partner /// 
$mdcs /// 
hasmedcard /// 
old_diagcons exp_proc inter_exp_proc /// 
i.hosp_year i.modate /// 
i.elective i.inter, cluster(hosp_depar)

* Result Outputs for Table C1a
esttab using TableC1a.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Hospital-department Level: Number of Public Admissions")

esttab using TableC1a_ci.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Hospital-department Level: Number of Public Admissions")



*===================================================================*
* Supplementary Table C1 Panel B: The Number of Public Admissions   *
* (Nation-department Level)							               	*
*===================================================================*
eststo clear

* Again, we start with the inpatient record level data
use base_dataset_2014, clear

* Generate dummy for MDCs 
* Starting from the inpatient record analysis
foreach n of numlist 1/25 {
gen mdc_`n'=0
replace mdc_`n'=1 if mdc==`n'
  } 
  


* Collapse dataset to the nation-department level   

gen n = 1

* drop private admissions
drop if public==0

collapse (count) n (mean) sex agegroup partner hasmedcard old_diagcons exp_proc inter_exp_proc mdc_1 mdc_2 mdc_3 mdc_4 mdc_5 mdc_6 mdc_7 mdc_8 mdc_9 mdc_10 mdc_11 mdc_12 mdc_13 mdc_14 mdc_15 mdc_16 mdc_17 mdc_18 mdc_19 mdc_20 mdc_21 mdc_22 mdc_23 mdc_24 mdc_25, by(elective modate)

gen POST=.
replace POST=1 if modate > ym(2013,12)
replace POST=0 if modate <= ym(2013,12)

gen inter=POST*elective

gen admissions = n
gen ln_admissions=ln(admissions)

* Calculate Inverse Hyperbolic Sine (IHS): 
gen ihs_admissions=asinh(admissions)

global controls "sex partner agegroup hasmedcard old_diagcons exp_proc inter_exp_proc"
global mdcs "mdc_1 mdc_2 mdc_3 mdc_4 mdc_5 mdc_6 mdc_7 mdc_8 mdc_9 mdc_10 mdc_11 mdc_12 mdc_13 mdc_14 mdc_15 mdc_16 mdc_17 mdc_18 mdc_19 mdc_20 mdc_21 mdc_22 mdc_23 mdc_24 mdc_25"

*============================================*
* Supplementary Table C1 Panel B: Column 1   *
*============================================*
eststo:reg admissions $controls $mdcs i.elective i.modate i.inter, r

*============================================*
* Supplementary Table C1 Panel B: Column 2   *
*============================================*
eststo:reg ln_admissions $controls $mdcs i.elective i.modate i.inter, r

*============================================*
* Supplementary Table C1 Panel B: Column 3   *
*============================================*
eststo:reg ihs_admissions $controls $mdcs i.elective i.modate i.inter, r

* Result Outputs for Table C1b
esttab using TableC1b.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Nation-department Level: Number of Public Admissions")

esttab using TableC1b_ci.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Nation-department Level: Number of Public Admissions")




*************************************************************************
* Supplementary D1. Placebo Test with Falsification of Treatment Timing *
*************************************************************************

*====================================*
* Codes for Supplementary Table D1   *
*====================================*
eststo clear
use base_dataset_2014, clear

drop if admyear < 2009
drop if admyear > 2013

drop POST
drop inter
gen POST =0
gen inter = 0

sort modate
tostring modate, gen(modate_s)
encode modate_s, gen(modate_n)

foreach n of numlist 588/647 {
replace POST =0
replace inter =0
replace POST =1 if modate >= `n'
replace inter= POST*elective

eststo: reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.anon_hosp#i.admyear ///
i.elective i.inter , cluster(anon_hosp)
  } 
  
***Output data
esttab using TableD1.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Table D1: Placebo Test")

esttab using TableD1_ci.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Table D1: Placebo Test")



*******************************************************************************
* Supplementary D2. Placebo Test Based on the Policy Relevance of Specialties *
*******************************************************************************


*===================================*
* Supplementary Table D2, Column 1  *
*===================================*
eststo clear
use base_dataset_2014, clear

* We run regression for Radiotherapy (7500) & Radiology (2200) & Anaesthetics (8000)

eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter if specialty==7500 | specialty==2200 | specialty==8000, cluster(anon_hosp)



*===================================*
* Supplementary Table D2, Column 2  *
*===================================*

* We run regression EXCLUDING Radiotherapy (7500) & Radiology (2200) & Anaesthetics (8000)

preserve

drop if specialty==7500 
drop if specialty==2200 
drop if specialty==8000

eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)

restore
  
***Output data
esttab using TableD2.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Table D1: Placebo Test Based on the Policy Relevance of Specialties")

esttab using TableD2_ci.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Table D1: Placebo Test Based on the Policy Relevance of Specialties")



**************************************************************
* Supplementary E1. Different Settings of Control Variables  *
**************************************************************
eststo clear


*========================================*
* Supplementary Table E1, Column 1   	 *
* Only Control for age and sex           *
*========================================*
eststo:reg rawlos_winsor ///
i.sex i.agegroup ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)


*===============================================*
* Supplementary Table E1, Column 2  		    *
* Controls: age group, sex, marital status      *
*===============================================*
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)




*===============================================*
* Supplementary Table E1, Column 3    			*
* Additionally include disease type controls    *
*===============================================*
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter , cluster(anon_hosp)


*============================================*
* Supplementary Table E1, Column 4         	 *
* Additionally include patient type controls *
*============================================*
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard  ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter , cluster(anon_hosp)




*=================================================*
* Supplementary Table E1, Column 5				  *
* (Benchmark Regression)  						  *
* Additionally include consultants variables      *
*=================================================*
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter , cluster(anon_hosp)

* Result Outputs for Table E1
esttab using TableE1.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Impact on the Length of Stay of Inpatients")

esttab using TableE1_ci.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Impact on the Length of Stay of Inpatients")




**************************************************************
* Supplementary E2. Alternative Fixed Effects Specifications *
**************************************************************
eststo clear

*=========================================*
* Supplementary Table E2-2, Column 1      *
* Hospital FEs and Year FEs 			  *
*=========================================*
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.anon_hosp i.admyear ///
i.elective i.inter , cluster(anon_hosp)




*===========================================*
* Supplementary Table E2-2, Column 2        *
* Hospital FEs and Year-by-month FEs 		*
*===========================================*
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.anon_hosp i.modate ///
i.elective i.inter , cluster(anon_hosp)


*========================================*
* Supplementary Table E2-2, Column 3     *
* Hospital-by-year FEs					 *
*========================================*
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.anon_hosp#i.admyear ///
i.elective i.inter , cluster(anon_hosp)


*============================================*
* Supplementary Table E2-2, Column 4         *
* Hospital-by-year FEs and Year-by-month FEs *
* (Benchmark Regression) 					 *
*============================================*
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter , cluster(anon_hosp)

* Result Outputs for Table E2-2
esttab using TableE2_2.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Alternative Fixed Effects Specifications")

esttab using TableE2_2_ci.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Alternative Fixed Effects Specifications")



*********************************************************
* Supplementary E3. Logarithmic Transformation of LOS   *
*********************************************************
eststo clear

*====================================*
* Supplementary Table E3, Column 1   *
*====================================*
* Overall Sample

gen log_LOS=log(rawlos_winsor)

eststo:reg log_LOS ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter , cluster(anon_hosp)



*====================================*
* Supplementary Table E3, Column 2   *
*====================================*
* Public Patients

eststo:reg log_LOS ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter if public==1, cluster(anon_hosp)


*====================================*
* Supplementary Table E3, Column 3   *
*====================================*
* Private Patients

eststo:reg log_LOS ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter if public==0, cluster(anon_hosp)

* Result Outputs for Table E3 Logarithmic Transformation of LOS
esttab using TableE3.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Logarithmic Transformation of LOS")

esttab using TableE3_ci.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Logarithmic Transformation of LOS")



***************************************************
* Supplementary E4. Competing Hypothesis: 		  *
* Anticipation Effect of Activity-Based Funding   *
***************************************************
eststo clear

*=======================================*
* Supplementary Table E4, Column 1      *
*=======================================*
* Overall Sample
preserve

drop if modate > ym(2015,04)

eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)

restore


*=======================================*
* Supplementary Table E4, Column 2      *
*=======================================*
* Public Patients Sample
preserve

drop if modate > ym(2015,04)

eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter if public==1, cluster(anon_hosp)

restore


*===================================*
* Supplementary Table E4, Column 3  *
*===================================*
* Private Patients Sample
preserve

drop if modate > ym(2015,04)

eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter if public==0, cluster(anon_hosp)

restore

* Result Outputs for Table E4 Robustness Check: Potential Anticipation Effect from ABF 
esttab using TableE4.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Robustness Check: Potential Anticipation Effect from ABF")

esttab using TableE4_ci.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Robustness Check: Potential Anticipation Effect from ABF")


****************************************************
* Supplementary E5. The Effect on Mortality 	   * 
* (Logistic Regression and control for complexity) *
****************************************************
eststo clear

*====================================*
* Supplementary Table E5, Column 1   *
*====================================*
* Overall Sample

eststo:logistic die ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.complexity ///
i.elective i.inter, cluster(anon_hosp)


*====================================*
* Supplementary Table E5, Column 2   *
*====================================*
* Public Sample

eststo:logistic die ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.complexity ///
i.elective i.inter if public==1, cluster(anon_hosp)



*====================================*
* Supplementary Table E5, Column 3   *
*====================================*
* Private Sample

eststo:logistic die ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.complexity ///
i.elective i.inter if public==0, cluster(anon_hosp)

* Result Outputs for Table E5
esttab using TableE5.csv, eform b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("The Effect on Mortality (Logistic Regression and control for complexity)")

esttab using TableE5_ci.csv, eform b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("The Effect on Mortality (Logistic Regression and control for complexity)")




****************************************************
* Supplementary E6. Without Dropping Any Hospitals *
****************************************************

* Here we first run the data cleaning do file without dropping any hospitals.

eststo clear

*===============================*
* Supplementary Table E6 	   	*
*===============================*

* Column (1) 
* Full sample
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_pro ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)

* Column (2) 
* Public patients
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_pro ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter if public ==1, cluster(anon_hosp)

* Column (3) 
* Private patients
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_pro ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter if public ==0, cluster(anon_hosp)

* Result Outputs 
esttab using TableE6.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Without Dropping Any Hospitals")

esttab using TableE6_ci.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Without Dropping Any Hospitals")




*********************************************************
* Supplementary F1. Heterogeneous Effects on LOS by MDC *
*********************************************************

*1 = Diseases and disorders of the nervous system
*2 = Diseases and disorders of the eye
*3 = Diseases and disorders of the ear, nose, mouth and throat
*4 = Diseases and disorders of the respiratory system
*5 = Diseases and disorders of the circulatory system
*6 = Diseases and disorders of the digestive system
*7 = Diseases and disorders of the hepatobiliary system and pancreas
*8 = Diseases and disorders of the musculoskeletal system and connective tissue
*9 = Diseases and disorders of the skin, subcutaneous tissue and breast 
*10 = Endocrine, nutritional and metabolic diseases and disorders
*11 = Diseases and disorders of the kidney and urinary tract
*12 = Diseases and disorders of the male reproductive system
*13 = Diseases and disorders of the female reproductive system
*14 = Pregnancy, childbirth and the puerperium
*15 = Newborns and other neonates
*16 = Diseases and disorders of blood, blood forming organs, immunological disorders
*17 = Neoplastic disorders (haematological and solid neoplasms)
*18 = Infectious and parasitic diseases, systemic or unspecified  sites
*19 = Mental diseases and disorders
*20 = Alcohol/drug use and alcohol/drug induced organic mental disorders
*21 = Injuries, poisonings and toxic effects of drugs
*22 = Burns 
*23 = Factors influencing health status and other contacts with health services
*24 = Unassignable to MDC
*25 = Pre MDC

* Note that we do not have results for 14 and 15 as they are already excluded in the data cleaning
use base_dataset_2014, clear
eststo clear

* Supplementary Table F1 

foreach n of numlist 1/13 {
eststo: reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter if mdc==`n', cluster(anon_hosp)
  } 
  
foreach n of numlist 16/25 {
eststo: reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter if mdc==`n', cluster(anon_hosp)
  } 
  
* Result Outputs 
esttab using TableF1.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Heterogeneous Effects on LOS by MDC")

esttab using TableF1_ci.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Heterogeneous Effects on LOS by MDC")



****************************************************************
* Supplementary F2. Heterogeneous Effects on Mortality by MDC  *
* Public Patient Sample, Control for Complexity Category       *
****************************************************************
use base_dataset_2014, clear
keep if public == 1

eststo clear

* Supplementary Table F2 

foreach n of numlist 1/13 {
eststo:reg die ///
i.sex i.agegroup i.partner ///
i.specialty ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.complexity ///
i.elective i.inter if mdc==`n', cluster(anon_hosp)
  } 

foreach n of numlist 16/25 {
eststo:reg die ///
i.sex i.agegroup i.partner ///
i.specialty ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.complexity ///
i.elective i.inter if mdc==`n', cluster(anon_hosp)
  } 
  
* Result Outputs
esttab using TableF2.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Heterogeneous Effects on Mortality Rate for Public Patients by MDC")

esttab using TableF2_ci.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Heterogeneous Effects on Mortality Rate for Public Patients by MDC")


********************************************************************************
* Supplementary F3															   *
* New Entrants (hired since 2008) vs. Existing Consultants (hired before 2008) *
********************************************************************************
use base_dataset_2014, clear
eststo clear

*=======================================*
* Supplementary Table F3, Column 1  	*
*=======================================*
* Subsmaple of new entrants (hired after 2008)

eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter if old_diagcons==0, cluster(anon_hosp)




*=====================================*
* Supplementary Table F3, Column 2    *
*=====================================*
* Subsmaple of existing consultants (hired before 2008)

eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter if old_diagcons==1, cluster(anon_hosp)



*====================================*
* Supplementary Table F3, Column 3   *
*====================================*
* Overall sample of DiDiD
* Then we run DiDiD
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.inter_old_post i.inter_old_elec ///
i.elective i.inter i.inter_old_post_elec, cluster(anon_hosp)

* Result Outputs 
esttab using TableF3.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter 1.inter_old_post_elec) ///
title("New Entrants vs. Existing Consultants")

esttab using TableF3_ci.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter 1.inter_old_post_elec) ///
title("New Entrants vs. Existing Consultants")



**********************************************************
* Supplementary F4. Contract Compliers vs. Non-compliers *
**********************************************************
eststo clear

use base_dataset_2014, clear


*===============================================*
* Supplementary Table F4, Panel A, Column 1  	*
*===============================================*
* Possible Compliers
preserve
keep if complier == 1
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)
restore


*===============================================*
* Supplementary Table F4, Panel A Column 2   	*
*===============================================*
* Possible Non-compliers
preserve
keep if complier == 0
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)
restore


* Result Outputs
esttab using TableF4.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Contract Compliers vs. Non-compliers")

esttab using TableF4_ci.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Contract Compliers vs. Non-compliers")



*===============================================*
* Supplementary Table F4, Panel B, Column 1  	*
*===============================================*
* Possible Compliers
preserve
keep if complier == 1
eststo:reg die i.complexity ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)
restore


*===============================================*
* Supplementary Table F4, Panel B, Column 2  	*
*===============================================*
* Possible Non-compliers
preserve
keep if complier == 0
eststo:reg die i.complexity ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)
restore


* Result Outputs
esttab using TableF4b.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Contract Compliers vs. Non-compliers")

esttab using TableF4b_ci.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Contract Compliers vs. Non-compliers")


*****************************************************************
* Supplementary F5. Contract Constraint Binding vs. Not Binding *
*****************************************************************


*====================================*
* Supplementary Table F5, Column 1   *
*====================================*
eststo clear
use base_dataset_2014, clear

* For binding hospitals
preserve
keep if binding == 1
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)
restore


*======================================*
* Supplementary Table F5, Column 2     *
*======================================*
* For not binding hospitals

preserve
keep if not_binding == 1
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)
restore

* Result Outputs
esttab using TableF5.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Contract Constraint Binding vs. Not Binding")

esttab using TableF5_ci.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Contract Constraint Binding vs. Not Binding")




***********************************************************************************
* Supplementary G1. Composition of ED admissions before and after the 2014 reform *
***********************************************************************************
eststo clear
use base_dataset_2014, clear

* Create pre mean and sd
preserve
keep if POST==0 & elective==0
collapse (mean) rawlos_winsor die sex public hasmedcard partner itu complexity
xpose, clear varname
rename v1 mean_pre
order _varname mean
save temp1, replace
restore

preserve
keep if POST==0 & elective==0
collapse (sd) rawlos_winsor die sex public hasmedcard partner itu complexity
xpose, clear varname
rename v1 sd_pre
order _varname sd
save temp2, replace
restore

* Create post mean and sd
preserve
keep if POST==1 & elective==0
collapse (mean) rawlos_winsor die sex public hasmedcard partner itu complexity
xpose, clear varname
rename v1 mean_post
order _varname mean
save temp3, replace
restore

preserve
keep if POST==1 & elective==0
collapse (sd) rawlos_winsor die sex public hasmedcard partner itu complexity
xpose, clear varname
rename v1 sd_post
order _varname sd
save temp4, replace
restore

use temp1, clear

merge 1:1 _varname using temp2
drop _merge

merge 1:1 _varname using temp3
drop _merge

merge 1:1 _varname using temp4
drop _merge


* Create descriptive variables
gen Type = "Characteristics"
replace Type = "Outcome" if _varname == "rawlos_winsor"
replace Type = "Outcome" if _varname == "die"
replace Type = "Severity of illness" if _varname == "itu"
replace Type = "Severity of illness" if _varname == "complexity"


gen var_label = ""
replace var_label = "Length of Stay (days)" if _varname == "rawlos_winsor"
replace var_label = "Death (dummy)" if _varname == "die"
replace var_label = "Male (dummy)" if _varname == "sex"
replace var_label = "Public (dummy)" if _varname == "public"
replace var_label = "Has medical card (dummy)" if _varname == "hasmedcard"
replace var_label = "Married (dummy)" if _varname == "partner"
replace var_label = "Experienced ITU (dummy)" if _varname == "itu"
replace var_label = "Complexity (1-4)" if _varname == "complexity"

gen order_var = 1
replace order_var = 2 if Type == "Characteristics"
replace order_var = 3 if Type == "Severity of illness"

drop _varname
gsort order_var var_label
order Type var_label

drop order_var

format mean_pre %15.3fc
format sd_pre %15.3fc
format mean_post %15.3fc
format sd_post %15.3fc

tostring mean_pre, replace usedisplayformat force
tostring sd_pre, replace usedisplayformat force
tostring mean_post, replace usedisplayformat force
tostring sd_post, replace usedisplayformat force

export excel TableG1_cmpstn_ED_admssns_pre_post.xlsx,replace firstrow(variables) 


erase temp1.dta
erase temp2.dta
erase temp3.dta


**************************************************************************************
* Supplementary G2. Composition of private patients before and after the 2014 reform *
**************************************************************************************
eststo clear
use base_dataset_2014, clear
keep if public == 0


* Create pre mean and sd
preserve
keep if POST==0
collapse (mean) rawlos_winsor die sex hasmedcard partner itu complexity
xpose, clear varname
rename v1 mean_pre
order _varname mean
save temp1, replace
restore

preserve
keep if POST==0
collapse (sd) rawlos_winsor die sex hasmedcard partner itu complexity
xpose, clear varname
rename v1 sd_pre
order _varname sd
save temp2, replace
restore

* Create post mean and sd
preserve
keep if POST==1
collapse (mean) rawlos_winsor die sex hasmedcard partner itu complexity
xpose, clear varname
rename v1 mean_post
order _varname mean
save temp3, replace
restore

preserve
keep if POST==1
collapse (sd) rawlos_winsor die sex hasmedcard partner itu complexity
xpose, clear varname
rename v1 sd_post
order _varname sd
save temp4, replace
restore

use temp1, clear

merge 1:1 _varname using temp2
drop _merge

merge 1:1 _varname using temp3
drop _merge

merge 1:1 _varname using temp4
drop _merge


* Create descriptive variables
gen Type = "Characteristics"
replace Type = "Outcome" if _varname == "rawlos_winsor"
replace Type = "Outcome" if _varname == "die"
replace Type = "Severity of illness" if _varname == "itu"
replace Type = "Severity of illness" if _varname == "complexity"


gen var_label = ""
replace var_label = "Length of Stay (days)" if _varname == "rawlos_winsor"
replace var_label = "Death (dummy)" if _varname == "die"
replace var_label = "Male (dummy)" if _varname == "sex"
replace var_label = "Has medical card (dummy)" if _varname == "hasmedcard"
replace var_label = "Married (dummy)" if _varname == "partner"
replace var_label = "Experienced ITU (dummy)" if _varname == "itu"
replace var_label = "Complexity (1-4)" if _varname == "complexity"

gen order_var = 1
replace order_var = 2 if Type == "Characteristics"
replace order_var = 3 if Type == "Severity of illness"

drop _varname
gsort order_var var_label
order Type var_label

drop order_var

format mean_pre %15.3fc
format sd_pre %15.3fc
format mean_post %15.3fc
format sd_post %15.3fc

tostring mean_pre, replace usedisplayformat force
tostring sd_pre, replace usedisplayformat force
tostring mean_post, replace usedisplayformat force
tostring sd_post, replace usedisplayformat force

export excel TableG2_cmpstn_pvt_admssns_pre_post.xlsx,replace firstrow(variables) 


erase temp1.dta
erase temp2.dta
erase temp3.dta
erase temp4.dta




****************************************
*  Supplementary H. Equivalence Test   *
****************************************

* Step 1: Run the DiD regression 
* (with Public as the outcome variable) 
reg public ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard  ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)



* Step 2: Specify coefficient of interest (DiD coefficient)
local did_coef 1.inter



* Step 3: Report 90% CI
lincom `did_coef', level(90)



* Step 4: Calculate test statistics and P-values of TOST
foreach delta in 0.035 0.0418 {
	scalar t_l = (_b[`did_coef'] + `delta') / _se[`did_coef']
	scalar t_u = (_b[`did_coef'] - `delta') / _se[`did_coef']
	scalar p_l = ttail(e(df_r), t_l)
	scalar p_u = ttail(e(df_r), -t_u)
	scalar p_tost = max(p_l, p_u)
	display "TOST P-value = " %9.3e p_tost "  for  Δ = " %6.4f `delta'
}



* Step 5: Calculate approximate Bayes factor
foreach delta in 0.035 0.0418 {
	foreach tau_factor in 1 2 {
		scalar beta = _b[`did_coef']
		scalar s = _se[`did_coef']
		scalar tau = `tau_factor' * `delta'
		scalar bf_01 = sqrt((s^2 + tau^2)/(s^2)) * exp(-(beta^2 / 2) * (1/(s^2) - 1/(s^2 + tau^2)))
		display "For Δ = " %6.4f `delta' " and τ = " `tau_factor' "Δ (" %6.4f tau "):  BF_01 = " %9.3f bf_01
	}
}


*==================================*
*  References for Supplementary H  *
*==================================*

* Reference: Nguyen, M. (2025). Hypothesis Testing. In: Advanced Modeling and Data Challenges. Springer, Cham. https://doi.org/10.1007/978-3-032-01719-2_7
* Available online at: https://mike-data-analysis.share.connect.posit.cloud/sec-two-one-sided-tests-equivalence-testing.html

* Reference: Wakefield J. (2009). Bayes factors for genome-wide association studies: comparison with P-values. Genetic Epidemiology, 33(1), 79–86. https://doi.org/10.1002/gepi.20359



******************************************************
* Supplementary I. Detailed Results of Dynamic DiD   *
******************************************************
* See the codes for Figure 2a and 2b.



