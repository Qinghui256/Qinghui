clear all
set more off
*************************************************************
******	Folder paths

** Please change the projectfolder directory to where you store the data
** Please change the output directory to where you store the output

** To run this file, you need to install the package below:

** coefplot, reghdfe, egenmore, mlogit, ppmlhdfe, outreg2
*************************************************************

global projectfolder "C:\Users\qingh\ASU Dropbox\Qinghui Zhang\PhD year2 SEM2\Econometrics2\jofi13412-sup-0002-replicationcode\Replication code-20230154"   // please change the path for this line
global output       "$projectfolder/Output"

cd "C:\Users\qingh\ASU Dropbox\Qinghui Zhang\PhD year2 SEM2\Econometrics2\jofi13412-sup-0002-replicationcode\Replication code-20230154\Data" // please change the path for this line

*************************************************************
******	Open log
*************************************************************
capture log close
log using "$output/JF_replication", text replace	

*************************************************************
******	define globals
*************************************************************
    
	global ind naics3
	global clu trifd  
	global firmvar lev q tang cash

	global coefplotspe 	yline(0) ci(90) recast(connected) ciopts(lp(dash) recast(rcap)) graphregion(color(white) lwidth(large)) bgcolor(white) ysize(3)  omitted
	global format booktabs noobs sfmt(%12.0gc %12.0fc)  b(%9.3f) se   starlevels(* .10 ** .05 *** .01 )  label collabels(none) noconstant  nonotes replace  nomtitles  r2(%8.3f) 
	global instruct "stats(coef se) bdec(3) tdec(2) rdec(3) alpha(.01, .05, .1) nocons label"
	
	global fe1 plantid year
	global fe2 plantid statecd#year
	global fe3 plantid naics3#year statecd#year

	global matchedfe1 cohort_id#plantid cohort_id#year 
	global matchedfe2 cohort_id#plantid cohort_id#statecd#year
	global matchedfe3 cohort_id#plantid cohort_id#statecd#year cohort_id#naics3#year 

	global chemicalfe1 chemicalid#plantid chemicalid#year
	global chemicalfe2 chemicalid#plantid chemicalid#year statecd#year
	global chemicalfe3 chemicalid#plantid chemicalid#year naics3#year statecd#year

	global matchedchemicalfe1 cohort_id#plantid#chemicalid cohort_id#year#chemicalid 
	global matchedchemicalfe2 cohort_id#plantid#chemicalid cohort_id#year#chemicalid  cohort_id#statecd#year
	global matchedchemicalfe3 cohort_id#plantid#chemicalid cohort_id#year#chemicalid  cohort_id#statecd#year cohort_id#naics3#year 

	global chemicalscalars scalars( "plantchemical Plant-Chemical FE" "chemicalyear Chemical-Year FE" "stateyear State-Year FE" "naics3year Industry-Year FE"   "model Model" "N Observations" )
	global scalars scalars( "plant Plant FE" "year Year FE" "stateyear State-Year FE" "naics3year Industry-Year FE"   "model Model" "N Observations"  )
		
	 
	global gdideventdynamics   zero time_3 time_2 time_1 time0 time1 time2 time3plus 
	global gdidcoeffs "time* zero" 
	global gdidrenames "zero=<-3  time_3=-3 time_2=-2 time_1=-1 time0=0 time1=1 time2 = 2 time3plus=3+>"  

	global matcheddynamics zero t_3_treat t_2_treat t_1_treat t0_treat t1_treat t2_treat t3plus_treat
	global matchedcoeffs "t*treat zero" 
	global matchedrenames "zero=<-3 t_3_treat=-3 t_2_treat=-2 t_1_treat=-1 t0_treat=0 t1_treat=1 t2_treat=2 t3plus_treat=3+> "  

			
*-------------Analysis--------------*

/******************************************************
	Table 9 & Table 14 Panel B  Business Ties between Buyers and Sellers of Pollutive Plants vs. Non-Pollutive Plants
******************************************************/

*-------- Table 9 Panel A ------------*

capture rm "$output/Table9_panelA.txt"
use Table9_panelA.dta, clear
gen pollutive = 1
rename dealnumber groupid
save "Table9_panelA_analysis.dta",replace
	

*-------- Table 14 Panel B ------------*

capture rm "$output/Table14_PanelB.txt"
use  Table14_PanelB.dta, clear
gen pollutive = 0
rename matched_group groupid
save "Table14_PanelB_analysis.dta",replace

*-------- pooled regression ------------*

use Table9_panelA_analysis.dta,clear
append using Table14_PanelB_analysis.dta
egen group_id = group(pollutive groupid )

reghdfe treat c.friends##i.pollutive, a(group_id) vce(cluster group_id fyear)
outreg2 using "$output/Table9&14_analysis.xls", $instruct replace
reghdfe fut_friends c.treat##i.pollutive, a(group_id) vce(cluster group_id fyear)
outreg2 using "$output/Table9&14_analysis.xls", $instruct 




/******************************************************
	Table 10 & Table 14 Panel C  Env disclosure between Buyers and Sellers of Pollutive Plants vs. Non-Pollutive Plants
******************************************************/

*-------- Table 10 ------------*

capture rm "$output/Table10.txt"	
use Table10_GDID.dta, clear
gen pollutive = 1
save "Table10_GDID_analysis.dta",replace
	

*-------- Table 14	Panel C ------------*
capture rm "$output/Table14_PanelC.txt"
use  Table14_PanelC.dta, clear
gen pollutive = 0
save "Table14_PanelC_analysis.dta",replace


*-------- pooled regression ------------*
use Table10_GDID_analysis.dta, clear
append using Table14_PanelC_analysis.dta


* Check duplicate firm-year-industry observations
duplicates report gvkey fyear naics3
duplicates tag gvkey fyear naics3, gen(dup)
tab dup
sort gvkey fyear naics3 pollutive
bys gvkey fyear naics3: gen n_in_group = _N
bys gvkey fyear naics3: egen n_treated   = total(target==1)
bys gvkey fyear naics3: egen treated_poll = total(target==1 & pollutive==1)
bys gvkey fyear naics3: egen treated_non  = total(target==1 & pollutive==0)

bys gvkey fyear naics3: gen first_in_group = (_n==1) // tag first obs in each duplicate group

* Conservative cleaning rule: if duplicates are all untreated (n_treated==0), keep only one copy
drop if dup>0 & n_treated==0 & first_in_group==0 


reghdfe have_pos_ml c.target##i.pollutive, a(fyear gvkey) cl(gvkey)
outreg2 using "$output/Table10&14_analysis.xls", $instruct  keep(c.target##i.pollutive)  replace
	
reghdfe have_pos_ml c.target##i.pollutive, a(naics3#fyear gvkey) cl(gvkey)
outreg2 using "$output/Table10&14_analysis.xls", $instruct  keep(c.target##i.pollutive)  
	
reghdfe have_pos_ml c.target##i.pollutive $firmvar , a(naics3#fyear gvkey) cl(gvkey)
outreg2 using "$output/Table10&14_analysis.xls", $instruct  keep(c.target##i.pollutive)  

reghdfe have_neg_ml c.target##i.pollutive, a(fyear gvkey) cl(gvkey)
outreg2 using "$output/Table10&14_analysis.xls", $instruct  keep(c.target##i.pollutive)  
	
reghdfe have_neg_ml c.target##i.pollutive, a(naics3#fyear gvkey) cl(gvkey)
outreg2 using "$output/Table10&14_analysis.xls", $instruct keep(c.target##i.pollutive)   
	
reghdfe have_neg_ml c.target##i.pollutive $firmvar , a(naics3#fyear gvkey) cl(gvkey)
outreg2 using "$output/Table10&14_analysis.xls", $instruct keep(c.target##i.pollutive)   
		

	

















		
