

***************************************************************
*    	Codes for the results of the main manuscript		  * 
***************************************************************



clear 
set matsize 800

* We set the working directory here (location redacted for publication)

* Note by authors: We do not display the working directory or the original HIPE dataset file names to ensure data confidentiality. 
* Interested readers may contact the HPO directly (http://www.hpo.ie/) to request access to the HIPE microdata.

use base_dataset_2014, clear

*******************************************************************************
* Figure 1a																	  * 
* The proportion of private patients admitted via ED and admitted electively  *
*******************************************************************************
preserve
gen n=1
collapse (sum) n, by(modate public elective)
sort modate elective public
bysort modate elective: gen sum_n = sum(n)
gen private_n=. 
replace private_n=sum_n - n if public==1
drop if public==0
drop public
gen pratio= private_n/ sum_n
twoway (line pratio modate if elective==1 , lcolor(black) tline(2014m1, lc(black)) legend(label(1 "Elective Admissions"))) (line pratio modate if elective==0, lc(black) lpattern(shortdash) legend(label(2 "ED Admissions"))),  title("Proportion of Private Patients") ytitle("Proportion of Private Patients")  xlabel("") xtitle("Time") tlabel(2009m1 "2009/01" ,  add labsize(small)) tlabel(2014m1 "2014/01" , add labsize(small)) tlabel(2015m12 "2015/12" ,  add labsize(small)) xlab(, nogrid) graphregion(fcolor(white)) yscale(range(0 0.35)) ylabel(0(0.05)0.35)
restore
graph export Figure1a.pdf, replace


*******************************************************************************
* Figure 1b																	  * 
* The number of inpatients admitted via ED and admitted electively			  *
*******************************************************************************
preserve
gen n=1
collapse (sum) n, by(modate elective)
twoway (line n modate if elective==1, lc(black) lpattern(solid) tline(2014m1, lc(black)) legend(label(1 "Elective Admissions"))) (line n modate if elective==0, lc(black) lpattern(shortdash) legend(label(2 "ED Admissions"))), title("The Number of Inpatients by Admission Types") ytitle("Number of Admissions") xlabel("") xtitle("Time") tlabel(2009m1 "2009/01" , add labsize(small)) tlabel(2014m1 "2014/01" , add labsize(small)) tlabel(2015m12 "2015/12" , add labsize(small)) xlab(, nogrid) graphregion(fcolor(white)) yscale(range(0 25000)) ylabel(0 (5000) 25000)
restore
graph export Figure1b.pdf, replace


*******************************************************************************
* Figure 1d																	  * 
* The average LOS of inpatients admitted via ED and admitted electively		  *
*******************************************************************************
preserve
collapse (mean) rawlos_winsor, by(modate elective)
gen los_ele=.
replace los_ele=rawlos_winsor if elective==1
gen los_ed=.
replace los_ed=rawlos_winsor if elective==0
label variable los_ele "Elective"
label variable los_ed "Emergency"
twoway (line los_ele modate, lcolor(black) lpattern(solid) legend(label(1 "Elective Admissions"))) ///
(line los_ed modate, lcolor(black) lpattern(shortdash) legend(label(2 "ED Admissions"))), tline(2014m1, lc(black) ) ///  
title("LOS by Admission Types") ytitle("Length of Stay (LOS)") xlabel("") xtitle("Time")  ///
tlabel(2009m1 "2009/01" , add labsize(small)) tlabel(2014m1 "2014/01" , add labsize(small)) tlabel(2015m12 "2015/12" , add labsize(small))  /// 
xlab(, nogrid) graphregion(fcolor(white)) yscale(range(0 7.5)) ///
       ylabel(0(1)8)
restore
graph export Figure1d.pdf, replace


******************************************************
* Table 1 Panel A									 * 
* Total Annual Admissions						     *
******************************************************
use base_dataset_2014, clear

gen admissions = 1

collapse (sum) admissions , by(admyear POST elective)
collapse (mean) admissions, by( POST elective)

sort POST elective
format admissions %15.0fc
tostring admissions, replace usedisplayformat force

export excel Table_1a_dscrptv_stats_ttl.xlsx, replace firstrow(variables) 


******************************************************
* Table 1 Panel B									 * 
* Public Patients		   						     *
******************************************************
use base_dataset_2014, clear

gen admissions = 1
keep if public == 1

collapse (sum) admissions , by(admyear POST elective)
collapse (mean) admissions, by( POST elective)

sort POST elective
format admissions %15.0fc
tostring admissions, replace usedisplayformat force

export excel Table_1b_dscrptv_stats_public.xlsx, replace firstrow(variables)


******************************************************
* Table 1 Panel C									 * 
* Private Patients								     *
******************************************************
use base_dataset_2014, clear

gen admissions = 1
keep if public == 0

collapse (sum) admissions , by(admyear POST elective)
collapse (mean) admissions, by( POST elective)

sort POST elective
format admissions %15.0fc
tostring admissions, replace usedisplayformat force

export excel Table_1c_dscrptv_stats_private.xlsx, replace firstrow(variables)


******************************************************
* Table 2 											 * 
* Descriptive Statistics of Inpatient Record	     *
******************************************************
use base_dataset_2014, clear

* Create age group variables
gen agegroup_1 = 0
replace agegroup_1 = 1 if agegroup == 1
gen agegroup_2 = 0
replace agegroup_2 = 1 if agegroup == 2
gen agegroup_3 = 0
replace agegroup_3 = 1 if agegroup == 3
gen agegroup_4 = 0
replace agegroup_4 = 1 if agegroup == 4
gen agegroup_5 = 0
replace agegroup_5 = 1 if agegroup == 5

* Create number, mean, sd, min and max

preserve
collapse (count) rawlos_winsor die POST ele sex public hasmedcard partner old_diagcons exp_proc inter_exp_proc complexity agegroup_1 agegroup_2 agegroup_3 agegroup_4 agegroup_5
xpose, clear varname
rename v1 count
order _varname count
save temp1, replace
restore

preserve
collapse (mean) rawlos_winsor die POST ele sex public hasmedcard partner old_diagcons exp_proc inter_exp_proc complexity agegroup_1 agegroup_2 agegroup_3 agegroup_4 agegroup_5
xpose, clear varname
rename v1 mean
order _varname
save temp2, replace
restore

preserve
collapse (sd) rawlos_winsor die POST ele sex public hasmedcard partner old_diagcons exp_proc inter_exp_proc complexity agegroup_1 agegroup_2 agegroup_3 agegroup_4 agegroup_5
xpose, clear varname
rename v1 sd
order _varname
save temp3, replace
restore

preserve
collapse (min) rawlos_winsor die POST ele sex public hasmedcard partner old_diagcons exp_proc inter_exp_proc complexity agegroup_1 agegroup_2 agegroup_3 agegroup_4 agegroup_5
xpose, clear varname
rename v1 min
order _varname
save temp4, replace
restore

preserve
collapse (max) rawlos_winsor die POST ele sex public hasmedcard partner old_diagcons exp_proc inter_exp_proc complexity agegroup_1 agegroup_2 agegroup_3 agegroup_4 agegroup_5
xpose, clear varname
rename v1 max
order _varname
save temp5, replace
restore

use temp1, clear

merge 1:1 _varname using temp2
drop _merge

merge 1:1 _varname using temp3
drop _merge

merge 1:1 _varname using temp4
drop _merge

merge 1:1 _varname using temp5
drop _merge

gen Type = ""
replace Type = "Outcome variables" if _varname == "rawlos_winsor"
replace Type = "Outcome variables" if _varname == "die"

replace Type = "Main explanatory variables" if _varname == "POST"
replace Type = "Main explanatory variables" if _varname == "elective"

replace Type = "Other variables" if _varname == "sex"
replace Type = "Other variables" if _varname == "public"
replace Type = "Other variables" if _varname == "hasmedcard"
replace Type = "Other variables" if _varname == "partner"
replace Type = "Other variables" if _varname == "old_diagcons"
replace Type = "Other variables" if _varname == "exp_proc"
replace Type = "Other variables" if _varname == "inter_exp_proc"
replace Type = "Other variables" if _varname == "complexity"
replace Type = "Age groups" if _varname == "agegroup_1"
replace Type = "Age groups" if _varname == "agegroup_2"
replace Type = "Age groups" if _varname == "agegroup_3"
replace Type = "Age groups" if _varname == "agegroup_4"
replace Type = "Age groups" if _varname == "agegroup_5"

gen var_label = ""
replace var_label = "Length of Stay (days)" if _varname == "rawlos_winsor"
replace var_label = "Death (dummy)" if _varname == "die"
replace var_label = "Male (dummy)" if _varname == "sex"
replace var_label = "Post (dummy, =1 if since 2014)" if _varname == "POST"
replace var_label = "ELE (dummy, =1 if admitted electively)" if _varname == "elective"
replace var_label = "Public (dummy)" if _varname == "public"
replace var_label = "Has medical card (dummy)" if _varname == "hasmedcard"
replace var_label = "Married (dummy)" if _varname == "partner"
replace var_label = "Complexity (1-4)" if _varname == "complexity"
replace var_label = "Group 1 (18-27)" if _varname == "agegroup_1"
replace var_label = "Group 2 (28-47)" if _varname == "agegroup_2"
replace var_label = "Group 3 (48-67)" if _varname == "agegroup_3"
replace var_label = "Group 4 (68-87)" if _varname == "agegroup_4"
replace var_label = "Group 5 (88+)" if _varname == "agegroup_5"



replace var_label = "Diagnosed by senior consultants (dummy)" if _varname == "old_diagcons"
replace var_label = "Experienced procedure by a consultant (dummy)" if _varname == "exp_proc"
replace var_label = "Experienced procedure by a senior consultant (dummy)" if _varname == "inter_exp_proc"

gen order_var = 1
replace order_var = 2 if Type == "Main explanatory variables"
replace order_var = 3 if Type == "Other variables"
replace order_var = 4 if Type == "Age groups"

drop _varname
gsort order_var var_label
order Type var_label

drop order_var

format count %15.0fc
format mean %15.3fc
format sd %15.3fc
format min %15.3fc
format max %15.3fc

tostring count, replace usedisplayformat force
tostring mean, replace usedisplayformat force
tostring sd, replace usedisplayformat force
tostring min, replace usedisplayformat force
tostring max, replace usedisplayformat force

erase temp1.dta
erase temp2.dta
erase temp3.dta
erase temp4.dta

export excel Table2_descriptive_stats.xlsx,replace firstrow(variables) 

tab agegroup

tab complexity


******************************************************
* Table 3 Panel A									 * 
* Impact on the share of public patients		     *
* (Do not control for complexity)					 *
******************************************************
use base_dataset_2014, clear
eststo clear

eststo:reg public ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard  ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)

*** Outputs
esttab using Table3a.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Impact on the Length of Stay of Inpatients")

esttab using Table3a_ci.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter) ///
title("Impact on the Length of Stay of Inpatients")


*****************************************************************
* Table 3 Panel B									 		    * 
* Impact on Length of Stay (LOS) of Public and Private Patients *
* (Do not control for complexity)					            *
*****************************************************************
eststo clear
use base_dataset_2014, clear


* Column 1: Overall sample (benchmark regression)
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter , cluster(anon_hosp)

* Column 2: public patients
preserve
keep if public==1
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter , cluster(anon_hosp)
restore

*Column 3: private patients
preserve
drop if public==1
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter , cluster(anon_hosp)
restore

*Column 4: DiDiD
eststo:reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.inter_public_post i.inter_public_elect ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter i.interpep, cluster(anon_hosp)

*** Outputs
esttab using Table3b.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter 1.interpep) ///
title("Impact on the Length of Stay of Inpatients")

esttab using Table3b_ci.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label ///
s(N r2, label("N" "R2")) keep(1.elective 1.inter 1.interpep) ///
title("Impact on the Length of Stay of Inpatients")


******************************************************
* Figure 2a											 * 
* The dynamic impact on the LOS of public patients	 *
******************************************************
reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
ib2009.admyear##ib0.elective if public==1, vce(cluster anon_hosp) baselevels

eststo m
coefplot m , keep(*admyear#* ) baselevels mcolor(black) ciopts(lcolor(black)) vert ///
title("Dynamic Impact of Reform on Public Patients' LOS", color(black)) ///
rename(*.event="") ytitle(Coefficient Estimates) ///
yline(-1.5 -1 -.5 0 .5 1, lwidth(vvvthin) lpattern(dash) lcolor(black)) ///
xtitle(Time) xline(5.5, lcolor(black)) xlabel("") level(95) ///
xlab(, nogrid) ///
ylab(-1.5 -1 -.5 0 .5 1, nogrid) ///
yscale(range(-1.5 1)) ///
graphregion(fcolor(white)) ///
tlabel(1 "2009", add labsize(small)) ///
tlabel(2 "2010", add labsize(small)) ///
tlabel(3 "2011", add labsize(small)) ///
tlabel(4 "2012", add labsize(small)) ///
tlabel(5 "2013", add labsize(small)) ///
tlabel(6 "2014", add labsize(small)) ///
tlabel(7 "2015", add labsize(small)) ///
name(figure2a, replace)
graph export figure2a.pdf, replace


******************************************************
* Figure 2b											 * 
* The dynamic impact on the LOS of private patients  *
******************************************************
reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
ib2009.admyear##ib0.elective if public==0, vce(cluster anon_hosp) baselevels

eststo m
coefplot m , keep(*admyear#* ) baselevels mcolor(black) ciopts(lcolor(black)) vert ///
title("Dynamic Impact of Reform on Private Patients' LOS", color(black)) ///
rename(*.event="") ytitle(Coefficient Estimates) ///
yline(-1.5 -1 -.5 0 .5 1, lwidth(vvvthin) lpattern(dash) lcolor(black)) ///
xtitle(Time) xline(5.5, lcolor(black)) xlabel("") level(95) ///
xlab(, nogrid) ///
ylab(-1.5 -1 -.5 0 .5 1, nogrid) ///
yscale(range(-1.5 1)) ///
graphregion(fcolor(white)) ///
tlabel(1 "2009", add labsize(small)) ///
tlabel(2 "2010", add labsize(small)) ///
tlabel(3 "2011", add labsize(small)) ///
tlabel(4 "2012", add labsize(small)) ///
tlabel(5 "2013", add labsize(small)) ///
tlabel(6 "2014", add labsize(small)) ///
tlabel(7 "2015", add labsize(small)) ///
name(figure2b, replace)
graph export figure2b.pdf, replace


******************************************************
* Table 4											 *
* Impact on the Probability of Death				 *
* (Do not control for complexity)					 *
******************************************************
use base_dataset_2014, clear
eststo clear

*Column 1: Treatment effect overall (public and private patients)
eststo:reg die ///
i.sex i.agegroup i.partner ///
i.mdc i.specialty ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)

*Column 2: Public patients
eststo:reg die ///
i.sex i.agegroup i.partner ///
i.mdc i.specialty ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter if public==1, cluster(anon_hosp)

*Column 3: Private patients
eststo:reg die ///
i.sex i.agegroup i.partner ///
i.mdc i.specialty ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter if public==0, cluster(anon_hosp)

*Column 4: DiDiD
eststo:reg die ///
i.sex i.agegroup i.partner ///
i.mdc i.specialty ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.inter_public_post i.inter_public_elect ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter i.interpep, cluster(anon_hosp)

*** Outputs
esttab using Table4_prob_death.csv, b(4) p(4) p ar2 star(* 0.05 ** 0.01 *** 0.001) replace label s(fixed N, label("Fixed effects")) keep(1.elective 1.inter 1.interpep) ///
title ("Impact on probability of death")

esttab using Table4_prob_death_ci.csv, b(4) ci(4) ci ar2 star(* 0.05 ** 0.01 *** 0.001) replace label s(fixed N, label("Fixed effects")) keep(1.elective 1.inter 1.interpep) ///
title ("Impact on probability of death")


******************************************************
* Table 5											 *
* Impact on Complexity Level of Patients			 *
******************************************************
use base_dataset_2014, clear
eststo clear

* Column 1: Overall Sample
eststo: reg complexity ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter , cluster(anon_hosp)

* Column 2: Public Patients
preserve
keep if public == 1
eststo: reg complexity ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter , cluster(anon_hosp)
restore

* Column 3: Private Patients
preserve
keep if public == 0
eststo: reg complexity ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter , cluster(anon_hosp)
restore

* Column 4: DiDiD
eststo: reg complexity ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.inter_public_post i.inter_public_elect ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter i.interpep , cluster(anon_hosp)

*** Outputs
esttab using table5_Impact_on_complexity.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label s(N r2, label("N" "R2")) keep(1.elective 1.inter 1.interpep) ///
title ("Impact on Complexity Level")

esttab using table5_Impact_on_complexity_ii.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label s(N r2, label("N" "R2")) keep(1.elective 1.inter 1.interpep) ///
title ("Impact on Complexity Level")


******************************************************
* Table 6 Panel A									 *
* Impact on LOS	(control for complexity category)	 *
******************************************************
use base_dataset_2014, clear

eststo clear

* Column 1: Overall Sample
eststo: reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.complexity ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)

* Column 2: Public Patients
preserve
keep if public == 1
eststo: reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.complexity ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)
restore

* Column 3: Private Patients
preserve
keep if public == 0
eststo: reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.complexity ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)
restore

* Column 4: DiDiD
eststo: reg rawlos_winsor ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.complexity ///
i.inter_public_post i.inter_public_elect ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter i.interpep, cluster(anon_hosp)

*** Outputs
esttab using table6a_LOS_ctrl_for_complex.csv, b(3) p(3) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label s(N r2, label("N" "R2")) keep(1.elective 1.inter 1.interpep) ///
title ("Impact on LOS controlling for complexity")

esttab using table6a_LOS_ctrl_for_complex_ii.csv, b(3) ci(3) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label s(N r2, label("N" "R2")) keep(1.elective 1.inter 1.interpep) ///
title ("Impact on LOS controlling for complexity")


**************************************************************
* Table 6 Panel B											 *
* Impact on Probability of Death (control for complexity)	 *
**************************************************************

eststo clear

* Column 1: Overall Sample
eststo: reg die ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.public i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.complexity ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)

* Column 2: Public Patients
preserve
keep if public == 1
eststo: reg die ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.complexity ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)
restore

* Column 3: Private Patients
preserve
keep if public == 0
eststo: reg die ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.complexity ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter, cluster(anon_hosp)
restore

* Column 4: DiDiD
eststo: reg die ///
i.sex i.agegroup i.partner ///
i.specialty i.mdc ///
i.hasmedcard i.public ///
i.old_diagcons i.exp_proc i.inter_exp_proc ///
i.complexity ///
i.inter_public_post i.inter_public_elect ///
i.modate i.anon_hosp#i.admyear ///
i.elective i.inter i.interpep, cluster(anon_hosp)

*** Outputs
esttab using table6b_death_ctrl_for_complex.csv, b(4) p(4) p r2 star(* 0.05 ** 0.01 *** 0.001) replace label s(N r2, label("N" "R2")) keep(1.elective 1.inter 1.interpep) ///
title ("Impact on death controlling for complexity")

esttab using table6b_death_ctrl_for_complex_ii.csv, b(4) ci(4) ci r2 star(* 0.05 ** 0.01 *** 0.001) replace label s(N r2, label("N" "R2")) keep(1.elective 1.inter 1.interpep) ///
title ("Impact on death controlling for complexity")

