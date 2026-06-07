********************************
*   Data Cleaning  			   *
********************************

clear 
set matsize 800

* We set the working directory here (location redacted for publication)

* Combine raw datasets to build period from 2009 to 2018 (original HIPE dataset file names redacted for publication)

* Note by authors: We do not display the working directory or the original HIPE dataset file names to ensure data confidentiality. 
* Interested readers may contact the HPO directly (http://www.hpo.ie/) to request access to the HIPE microdata.


* Convert consultant flag to numeric
gen proccons = real(proccons1_flg)
drop proccons1_flg
rename proccons proccons1_flg

* Combine admission year and month
gen modate = ym(admyear,admmonth)

format modate %tm



********************************
*   Dropping data 			   *
********************************

* Drop data from 2016 onwards
drop if admyear >=2016

* Next we drop the people who were admitted in 2008 and before
drop if admyear <=2008

* Drop all day cases
tab isdaycase
drop if isdaycase == 1

* Drop people who usually live outside Ireland
tab resid_country
drop if resid_country ==27


* Drop Pregnancy, childbirth and the puerperium (major diagnosis category code 14)
drop if mdc==14

* Drop specialities related to maternity and pediatrics, 
* as well a small number of specialties with very few observations
drop if specialty==601
drop if specialty==1302
drop if specialty==1402
drop if specialty==1802
drop if specialty==1900
drop if specialty==1902
drop if specialty==1903
drop if specialty==1904
drop if specialty==1905
drop if specialty==1906
drop if specialty==1907
drop if specialty==1908
drop if specialty==1909
drop if specialty==1910
drop if specialty==1911
drop if specialty==1912
drop if specialty==1914 //Dropped already when dropping mdc == 14
drop if specialty==1915 //Dropped already when dropping mdc == 14
drop if specialty==1916
drop if specialty==2102
drop if specialty==2105
drop if specialty==6000
drop if specialty==6200
drop if specialty==6500
drop if specialty==6700
drop if specialty==7200
drop if specialty==7700
drop if specialty==7803
drop if specialty==8002
drop if specialty==8400
drop if specialty==8900




* Drop 15 hospitals that experienced structural change.
* This leaves us with 49 hospitals.
* Note by authors: We do not display the unique IDs of the anonymous hospitals to ensure data confidentiality. 
* Interested readers may contact the HPO directly (http://www.hpo.ie/) to obtain information on hospitals that experienced structural changes.



* Drop some observations to avoid double counting.
* This is because some patients already got pre-treatment before they were admitted to public hospitals.
* EMADM refers to non-hospital institutions.
* This is also known as AMAU (Accurate Medical Assessment Unit).
* The real() function converts a string to a numeric

gen emadm_real = real(emadm)

drop if emadm_real ==2 | emadm_real == 5  | emadm_real == 6  | emadm_real == 7  | emadm_real == 8

drop emadm emadm_real





*********************************************
* Renaming data and defining new variables  *
*********************************************


* Create a dummy ID for whether it's a record of public patient
gen public=.
replace public = 1 if disstatus == 1 
replace public = 0 if disstatus == 2

tab disstatus
drop disstatus


* Re-code the admission type variable
* Elective was coded as 1; ED (emergency department) was 2.
gen elective = .
replace elective = 1 if admissiontype == 1
replace elective = 0 if admissiontype == 2
drop admissiontype


* This is a dummy variable where male is 1
rename ïsex sex_orig
gen sex = .
replace sex = 1 if sex_orig == 1
replace sex = 0 if sex_orig == 2
drop sex_orig



* Create complexity variable
* Variable drg refers to Diagnosis related group, we just take the last letter of the classification. 
* The last letter is a categorical variable from 1-4, based on the complexity of the condition.
* A Highest consumption of resources 
* B Second highest consumption of resources
* C Third highest consumption of resources
* D Fourth highest consumption of resources
* Z No complexity split
gen drg4 = substr(drg,-1,1)
tab drg4

gen complexity = .
replace complexity = 4 if drg4 == "A"
replace complexity = 3 if drg4 == "B"
replace complexity = 2 if drg4 == "C"
replace complexity = 1 if drg4 == "D"





* Create marital status variable
/*"1 = single 
2 = married 
3 = widowed 
4 = other (includes separated)
5 = unknown 
6 = divorced 
7 = civil partner 
8 = former civil partner 
9 = surviving civil partner"
*/
gen partner = .
replace partner = 1 if marrstatus ==2 | marrstatus == 7
replace partner = 0 if marrstatus ==1
replace partner = 0 if marrstatus ==3 | marrstatus == 4
replace partner = 0 if marrstatus ==5 | marrstatus == 6
replace partner = 0 if marrstatus ==8 | marrstatus == 9

* Medical card: Whether a patient is confirmed to have a medical card
* We standardise this variable to a dummy variable.
/*
"0= no (not medical card holder)
1 = yes (medical card holder)
2 = unknown"
*/
replace hasmedcard = 0 if hasmedcard ==2

* Winsorise the length of stay
* Some people stay in the hospital for a very large amount of time
* Either drop them out or winsorise them
* We decide to winsorise length of stay at the 99th percentile.
winsor2 rawlos, cuts(0 99) suffix(_winsor)


* Create death dummy
/*dischargecode:
"1 = home 
2 = long stay accommodation 
3 = transfer to other hospital 
4 = died 
5 = other"
*/
gen die = .
replace die =1 if dischargecode ==4
replace die =0 if dischargecode !=4



* Create post variable
/*
The 2014 Reform
- In January 2014, the Health (Amendment) Act 2013 was enacted. It made two important changes.
- Firstly, private patients could still use public services in a hospital, but would simply not be deemed public patients.
- Secondly, the bed designation (20:80) was removed.
In other words:
- Private patients can be treated in the public wards.
- And pay the private fee.
*/
gen POST = .
replace POST =1 if admyear >= 2014
replace POST =0 if admyear < 2014

* Renaming things
rename agegroups_20yr agegroup
rename diagcons1_flg old_diagcons
rename proccons1_flg old_proccons

* Add some interaction terms
* Generate a variable to capture: whether a patient experienced a procedure by consultants
gen exp_proc = .
replace exp_proc = 1 if old_proccons == 0 // Experienced a procedure, but performed by a consultant hired since 2008.
replace exp_proc = 1 if old_proccons == 1 // Experienced a procedure, and performed by a consultant hired before 2008.
replace exp_proc = 0 if old_proccons == . // If missing value, then one didn't have a proceedure performed by a consultant.


* Generate a variable to capture whether a patient experienced a procedure by consultant hired before 2008.
gen old_proc = 0
replace old_proc = 1 if old_proccons == 1 

* Then we have the variable: If this patient experienced a procedure performed by a consultant, whether such consultant was hired before 2008 or not. 
gen inter_exp_proc =.
replace inter_exp_pro = exp_proc*old_proc

* Generate a variable (i.e., DiD interaction term) to capture the treatment effect of the 2014 policy.
gen inter =.
replace inter= POST*elective

* Change ITU days to ITU dummy variable
* ITU = ICU. Intensive treatment unit care
gen itu =.
replace itu = 1 if itudays >0
replace itu = 0 if itudays == 0



* DiDiD
* Define triple difference variable and other double-difference variables
gen inter_public_post = .
replace inter_public_post=public*POST

gen inter_public_elect=.
replace inter_public_elect=public*elective

gen interpep=.
replace interpep = public*elective*POST



* We interact another DiDiD to capture the heterogeneous impacts on patients treated by different consultants:
* Diagnosed by a pre-2008 contract consultant * POST
* Diagnosed by a pre-2008 contract consultant * elective
* Diagnosed by a pre-2008 contract consultant * POST * elective 
gen inter_old_post=old_diagcons*POST
gen inter_old_elec=old_diagcons*elective
gen inter_old_post_elec= old_diagcons*POST*elective

* Calculate the mean hospital share of public patients
sort anon_hosp
by anon_hosp: egen hospital_share = mean(public)

* Calculate complier variable
* We estimate hospitals to be non-compliers if their mean share of private 
* patients are greater than 30 percent (i.e., share of public patients is less than 70)
* There are 9 potential non-compliers in our dataset
gen complier = 1
replace complier =0 if hospital_share <0.7


***************************************************************
* Define whether the contract constraint is binding or not    *
***************************************************************

preserve

* We consider the contract constraint based on the pre-policy period
drop if admyear>=2014


* Generate a new variable, which is the average rate of public patients by hospital
bysort anon_hosp: egen mean_public_hosp=mean(public)

* Rank the public rate by hospital
collapse (mean) public, by(anon_hosp)
format public %15.2fc
sort public

gen private = 1- public
format private %15.2fc

gen  not_binding = 0
replace not_binding = 1 if private <0.2

gen binding = 0
replace binding = 1 if (private >=0.2 & private <0.3)

rename public hosp_share_public
rename private hosp_share_private

save temp, replace
restore




merge m:1 anon_hosp using temp
erase temp.dta


save base_dataset_2014, replace

