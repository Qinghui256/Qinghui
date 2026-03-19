clear all
set more off
*************************************************************
******	Folder paths

** Please change the projectfolder directory to where you store the data
** Please change the output directory to where you store the output

** To run this file, you need to install the package below:

** coefplot, reghdfe, egenmore, mlogit, ppmlhdfe, outreg2
*************************************************************

global projectfolder "C:\Users\qzhan256\Downloads\jofi13412-sup-0002-replicationcode\Replication code-20230154"   // please change the path for this line
global output       "$projectfolder/Output"

cd "C:\Users\qzhan256\Downloads\jofi13412-sup-0002-replicationcode\Replication code-20230154\Data" // please change the path for this line

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

			
		
*****************************************
**Table 1: Plant Summary Statistics 
****************************************		
		use Table1.dta, clear 
		estpost tabstat sold_pol_cusip  kldyear hq_dem_county pension_mean_tri have_e_event pressure_index1 seg_num  naics3_count n_subs  depth_max block_pct $firmvar, statistics( n mean median sd p25 p75) columns(stats)
		esttab . using "$output/Table1_PanelA.tex", booktabs  nomti cell(" count(fmt(%9.0fc)label(N)) mean(fmt(%9.2fc)label(Mean)) p50(fmt(%9.2fc)label(Median)) sd(fmt(%12.2fc)label(SD)) p25(fmt(%9.2fc)label(P25)) p75(fmt(%9.2fc)label(P75))") varlabels(`e(labels)')  label noobs var(23) nonumb replace		
						
   		use Table11_PanelA_gdid, clear 
		estpost tabstat  kld_csr_score kld_env_score , statistics( n mean median sd p25 p75) columns(stats)
		esttab . using "$output/Table1_PanelA.tex", booktabs  nomti cell(" count(fmt(%9.0fc)label(N)) mean(fmt(%9.2fc)label(Mean)) p50(fmt(%9.2fc)label(Median)) sd(fmt(%12.2fc)label(SD)) p25(fmt(%9.2fc)label(P25)) p75(fmt(%9.2fc)label(P75))") varlabels(`e(labels)')  label noobs var(23) nonumb append	
		
        use Table11_PanelB_GDID.dta, clear
	    replace parent_enf_cost=parent_enf_cost/1000000
        la var dum_enf  "Enforcement Action"
		la var parent_enf_cost "Enforcement Cost (Mil)"
	    estpost  tabstat dum_enf parent_enf_cost , statistics(N mean  median sd p25 p75) c(s)
		esttab . using "$output/Table1_PanelA.tex", booktabs  nomti cell(" count(fmt(%9.0fc)label(N)) mean(fmt(%9.2fc)label(Mean)) p50(fmt(%9.2fc)label(Median)) sd(fmt(%12.2fc)label(SD)) p25(fmt(%9.2fc)label(P25)) p75(fmt(%9.2fc)label(P75))") varlabels(`e(labels)')  label noobs var(23) nonumb append	

		use Table10_GDID.dta, clear
		la var have_pos_ml "Positive Env. Disclosure"
		la var have_neg_ml "Negative Env. Disclosure"
        estpost	tabstat have_pos_ml have_neg_ml , statistics(N mean  median sd p25 p75) c(s)
		esttab . using "$output/Table1_PanelA.tex", booktabs  nomti cell(" count(fmt(%9.0fc)label(N)) mean(fmt(%9.2fc)label(Mean)) p50(fmt(%9.2fc)label(Median)) sd(fmt(%12.2fc)label(SD)) p25(fmt(%9.2fc)label(P25)) p75(fmt(%9.2fc)label(P75))") varlabels(`e(labels)')  label noobs var(23) nonumb append
	
	   
	  use Table1_panelB.dta, clear  
  estpost tabstat total_release total_release_pratio cum_count_abatement1   pct_recycle pct_recovery pct_treatment   , statistics( n mean median sd p25 p75) columns(stats)   
	esttab . using "$output/Table1_panelB.tex", booktabs  nomti cell("count(fmt(%12.0fc)label(N)) mean(fmt(%12.2fc)label(Mean)) p50(fmt(%12.2fc)label(Median)) sd(fmt(%12.2fc)label(SD)) p25(fmt(%12.2fc)label(P25)) p75(fmt(%12.2fc)label(P75)) ")  ///
		varlabels(`e(labels)')  label noobs var(23) nonumb replace
	

	
*****************************************
**Table 2: Multi-logit choice model 
****************************************
use Table2_3.dta, clear 
	gen firm_choice = 0 //"do nothing"
	replace firm_choice = 1 if sell==1   //"only sell"
	replace firm_choice = 2 if sell==0 & plant_closure==1 & treat_pollution==0 //"only close"
	replace firm_choice = 3 if sell==0 & plant_closure==0 & treat_pollution==1 //"only treat"
	replace firm_choice = 4 if sell==0 & plant_closure==1 & treat_pollution==1 // "close&treat"
	tab firm_choice
	
	**For all other pressure indicators, include i. in the regresision for margin calcuation.  
	foreach x of varlist kldyear pension_mean_tri hq_dem_county have_e_event {
	
	eststo clear 
	qui: mlogit firm_choice i.`x' $firmvar, base(0)

	outreg2 using "$output/Table2.xls", drop($firmvar) $instruct ///
	addtext(Firm Controls, YES, Pollution Control Measure, top4_d1_pct_mgmn)	addstat(Pseudo R2, e(r2_p))
	
	eststo clear 
	margins, dydx(`x') atmeans post
	outreg2 using "$output/Table2.xls", $instruct 
	
	} //end of rhs variables 
	
	**For pressure_index which is a continuous variable, no need to include indicator in the regresision for margin calcuation.  
	foreach x of varlist pressure_index1{
	
	eststo clear 
	qui: mlogit firm_choice `x' $firmvar, base(0)
	
	outreg2 using "$output/Table2.xls", keep(`x') $instruct ///
	addtext(Firm Controls, YES, Pollution Control Measure, top4_d1_pct_mgmn)	addstat(Pseudo R2, e(r2_p))
	
	eststo clear 
	margins, dydx(`x') atmeans post
	outreg2 using "$output/Table2.xls", $instruct 
	
	} //end of rhs variables 
	
	
	
	/****************************
	*Table 3: pressure and propesity to sell 
	***************************/	
   use Table2_3.dta, clear  
	capture drop shock 
	gen shock=0	
	
		eststo clear
	   foreach z of varlist kldyear pension_mean_tri hq_dem_county have_e_event pressure_index1{
		replace shock=`z'
		la var shock "Environmental Pressure"
		eststo `z': qui: reghdfe sold_pol_cusip  shock $firmvar , a(year#naics3) cl(gvkey)
		           qui: estadd local naics3year "Yes", replace 
		}
		esttab  using "$output/Table3_PanelA.tex"  , drop($firmvar) $format  scalars("N Observations"   "naics3year Industry-Year FE"  ) mgroup( "Rated" "Pension Holidings"  "Democrat HQ" "Env. Event" "Pressure Index",  pattern( 1 1 1 1 1  ) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) 
		
			
			winsor2 llog_total_release llog_total_release_emp , cuts(1 99) replace
			
			forvalues i = 4/4 {
				egen r`i'_total = xtile(llog_total_release), nq(`i')
				egen r`i'_per = xtile(llog_total_release_emp), nq(`i')
			}
			
	cap drop pollution_id pressure pressureXpollution
	gen pollution_id=0
	gen pressure=0 
	gen pressureXpollution=0
	
	eststo clear 
	foreach x in  llog_total_release r4_total   llog_total_release_emp  r4_per{	
	display "`x'"
	winsor2 `x', cut(1 99) replace 
		foreach z in pressure_index1{
		replace pollution_id=`x'
		replace pressure=`z'
		replace pressureXpollution=`x'*`z'
		la var pollution_id "Pollution"
		la var pressureXpollution "Pressure Index X Pollution"
		la var pressure "Pressure Index"
		eststo `x': qui: reghdfe sold_pol_cusip pressureXpollution pollution_id pressure $firmvar, a(year#naics3) cl(gvkey)
		            qui: estadd local naics3year "Yes", replace 
		}
	}
		
	esttab llog_total_release r4_total   llog_total_release_emp  r4_per using "$output/Table3_PanelB.tex" , $format keep(pressureXpollution pollution_id pressure) scalars("N Observations"    "naics3year Industry-Year FE"  ) mgroup( "Quantity"  "Quantity(Qtile)" "Intensity" "Intensity(Qtile)",  pattern( 1 1 1 1  ) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) 
		
		

    /***********************************
	*Table 4: Reprisk tests 
	***********************************/	
	eststo clear	
	use Table4.dta, clear 

	 eststo reprisk1: qui: reghdfe  sold_pol_cusip   have_e_event , a(gvkey year) cl(gvkey)
	                   		qui: estadd local firm "Yes", replace 
							qui: estadd local year "Yes", replace 
		
	  eststo reprisk2: qui:	reghdfe  sold_pol_cusip    have_e_event $firmvar, a(gvkey year) cl(gvkey)
		                    qui: estadd local firm "Yes", replace 
							qui: estadd local year "Yes", replace 
							qui: estadd local controls "Yes", replace 
					
	  eststo reprisk3: qui:	reghdfe  sold_pol_cusip    have_e_event have_s_event have_g_event $firmvar, a(gvkey year) cl(gvkey)
				            qui: estadd local firm "Yes", replace 
							qui: estadd local year "Yes", replace 
							qui: estadd local controls "Yes", replace 
	  	
		eststo reprisk4: qui: reghdfe  sold_pol_cusip   have_e_event have_s_event have_g_event $firmvar, a(gvkey naics3year) cl(gvkey)
						    qui: estadd local firm "Yes", replace 
							qui: estadd local naics3year "Yes", replace 
							qui: estadd local controls "Yes", replace 	
	
	esttab  using "$output/Table4.tex" , $format keep(have_e_event have_s_event have_g_event) scalars("N Observations" "firm Firm FE" "year Year FE" "controls Firm Char"   "naics3year Industry-Year FE"  )
		

	
	 
***********************************************************************
*** Table 5: seller vs. buyer charactersitics
**********************************************	
		
		use Table5.dta, clear      
		eststo clear
		foreach y of varlist public kldyear pension_mean_tri ultparent_cty_dem  have_e_event pressure_index1{
			  eststo `y': 	qui:	reghdfe `y' buyer, noa 
		  }  
	
		estpost tabstat public kldyear pension_mean_tri ultparent_cty_dem have_e_event  pressure_index1   , statistics(  mean ) columns(stats)	 
		 
		esttab public kldyear pension_mean_tri ultparent_cty_dem have_e_event  pressure_index1  using  "$output/Table5.tex", $format   scalars("N Observations"    )  mgroup("Public" "Pension Holiding" "Rated"  "Democrat HQ" "Env. Event" "Pressure Index",  pattern( 1 1 1 1 1 1 ) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) 
		


	
   /*******************************
	*Table 6: plant-chemical pollution 
	*********************************/
	***************Panel A GDID pollution: Columns 1-3 and 5-7**************
	eststo clear 
	use Table6_7_PanelA_GDID.dta, clear 
    la var treatpost "Divested x Post"
			foreach y in total_release total_release_pratio {
			eststo `y'gdid1: 	qui:	ppmlhdfe `y' treatpost , a($chemicalfe1) cl($clu) 
			               	        qui: estadd local plantchemical "Yes", replace 
		                        	qui: estadd local chemicalyear "Yes", replace 
			                        qui: estadd local model "GDID PPML", replace 					
			eststo `y'gdid2: 	qui:	ppmlhdfe `y' treatpost , a($chemicalfe2) cl($clu) 
			               	        qui: estadd local plantchemical "Yes", replace 
									qui: estadd local chemicalyear   "Yes", replace 				
		                        	qui: estadd local stateyear "Yes", replace 
			                        qui: estadd local model "GDID PPML", replace 						
            eststo `y'gdid3: 	qui:	ppmlhdfe `y' treatpost , a($chemicalfe3) cl($clu) 
			               	        qui: estadd local plantchemical "Yes", replace 
									qui: estadd local chemicalyear   "Yes", replace 				
		                        	qui: estadd local naics3year "Yes", replace 
								    qui: estadd local stateyear "Yes", replace	
			                        qui: estadd local model "GDID PPML", replace 						
			}
	 ***********Panel A stacked  pollutionL Columns 4 and 8***********	
	   use Table6_7_PanelA_matched.dta, clear 
	   la var treatpost "Divested x Post"
			 foreach y in total_release total_release_pratio{
		      eststo `y'matched: qui: ppmlhdfe `y' treatpost , a($matchedchemicalfe3) cl($clu) 
			               	        qui: estadd local plantchemical "Yes", replace 
									qui: estadd local chemicalyear   "Yes", replace 									
		                        	qui: estadd local naics3year "Yes", replace 
								    qui: estadd local stateyear "Yes", replace	
			                        qui: estadd local sample "TRI", replace 
			                        qui: estadd local model "Matched  PPML", replace 						
			}	
			
	      esttab total_releasegdid* total_releasematched total_release_pratiogdid* total_release_pratiomatched   using "$output/Table6_panelA.tex", $format pr2 order(*post) keep(*post) $chemicalscalars   mgroup("Total Pollution"  "Pollution Intensity", pattern( 1 0  0  0 1  0 0 0 ) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span}))			
	
	
    ***************Panel B GDID peer pollution: Columns 1-3 and 5-7**************
	eststo clear 		
	use Table6_7_PanelB_GDID.dta, clear 	
	la var peerpost "Divested x Post"
		foreach y in  total_release total_release_pratio  { 	
		 eststo `y'gdid1:   qui: ppmlhdfe `y' peerpost , a($chemicalfe1) cluster($clu) 
							qui: estadd local plantchemical "Yes", replace 
							qui: estadd local chemicalyear "Yes", replace 
							qui: estadd local model "GDID", replace 
		
		 eststo `y'gdid2:   qui: ppmlhdfe `y' peerpost, a($chemicalfe2) cluster($clu) 
							qui: estadd local plantchemical "Yes", replace
							qui: estadd local chemicalyear   "Yes", replace 				
							qui: estadd local stateyear "Yes", replace 
							qui: estadd local model "GDID", replace 
	
		 eststo `y'gdid3:   qui: ppmlhdfe `y' peerpost, a($chemicalfe3) cluster($clu) 
							qui: estadd local plantchemical "Yes", replace 
							qui: estadd local chemicalyear   "Yes", replace 				
							qui: estadd local naics3year "Yes", replace 
							qui: estadd local stateyear "Yes", replace 		
							qui: estadd local model "GDID", replace 		
		}		
				
	 ***********Panel B stacked  peer pollution: Columns 4 and 8***********	   			
    use Table6_7_PanelB_matched.dta, clear 
	la var peerpost "Divested x Post"
		foreach y in  total_release total_release_pratio {
	    eststo `y'matched:  qui: ppmlhdfe `y' peerpost, a($matchedchemicalfe3) cluster($clu)
							qui: estadd local plantchemical "Yes", replace 
							qui: estadd local chemicalyear   "Yes", replace 				
							qui: estadd local naics3year "Yes", replace 
							qui: estadd local stateyear "Yes", replace 		
							qui: estadd local model "STACKED", replace 
				  }	
				  
     esttab total_releasegdid* total_releasematched total_release_pratiogdid* total_release_pratiomatched   using "$output/Table6_panelB.tex", $format pr2 order(*post) keep(*post) $chemicalscalars   mgroup("Total Pollution"  "Pollution Intensity", pattern( 1 0  0  0 1  0 0 0 ) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span}))	
					  
	


  
 
  		 		 
    /****************************
    *Table 7: plant-chemical abatement 
	*******************************/		
	***********Panel A GDID abatement: Columns 1-3 and 5-7***********
	eststo clear 
	use Table6_7_PanelA_GDID.dta, clear 
	la var treatpost "Divested x Post"
      	   foreach y of varlist cum_count_abatement1  pct_recycle pct_recovery pct_treatment {
							
            eststo `y'gdid3: qui: reghdfe `y' treatpost , a($chemicalfe3) cl($clu)
			               	        qui: estadd local plantchemical "Yes", replace 
									qui: estadd local chemicalyear   "Yes", replace 
		                        	qui: estadd local naics3year "Yes", replace 
								    qui: estadd local stateyear "Yes", replace	
			                        qui: estadd local model "GDID", replace 	
			}	
		   	  	 
	      ***********Panel A stacked  abatement: Columns 4 and 8***********
	use Table6_7_PanelA_matched.dta, clear  
	la var treatpost "Divested x Post"
		foreach y of varlist cum_count_abatement1  pct_recycle pct_recovery pct_treatment  {
            eststo `y'matched: qui:	reghdfe `y' treatpost , a($matchedchemicalfe3) cl($clu)
			               	        qui: estadd local plantchemical "Yes", replace 
									qui: estadd local chemicalyear   "Yes", replace 
		                        	qui: estadd local naics3year "Yes", replace 
								    qui: estadd local stateyear "Yes", replace	
			                        qui: estadd local model "Stacked", replace 	
			}	
  			
  		esttab  cum_count_abatement1gdid3 cum_count_abatement1matched  pct_recycle*3 pct_recycle*ed pct_recovery*3 pct_recovery*ed  pct_treatment*3 pct_treatment*ed  using "$output/Table7_PanelA.tex", $format order(*post) keep(*post)   $chemicalscalars  mgroup("Source Reduction" "Recycling"   "Recovery" "Treatment" , pattern( 1 0  1 0 1  0 1 0  ) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span}))	
 

  			  
				  
      ***********Panel B GDID peer abatement: Columns 1-3 and 5-7***********
	  eststo clear 
      use Table6_7_PanelB_GDID.dta, clear 
	  la var peerpost "Divested x Post"
		foreach y in  cum_count_abatement1  pct_recycle pct_recovery pct_treatment {		 
		 eststo `y'gdid3:  qui: reghdfe `y' peerpost, a($chemicalfe3) cluster($clu) 
							qui: estadd local plantchemical "Yes", replace 
							qui: estadd local chemicalyear   "Yes", replace 				
							qui: estadd local naics3year "Yes", replace 
							qui: estadd local stateyear "Yes", replace 		
							qui: estadd local model "GDID", replace 		
		}		
			
			
	 ***********Panel B stacked  peer abatement: Columns 4 and 8***********		  
    use Table6_7_PanelB_matched.dta, clear  
    la var peerpost "Divested x Post"
	foreach y in cum_count_abatement1  pct_recycle pct_recovery pct_treatment pct_release {	
	  eststo `y'matched:  qui: reghdfe `y' peerpost, a($matchedchemicalfe3) cluster($clu)
							qui: estadd local plantchemical "Yes", replace 
							qui: estadd local chemicalyear   "Yes", replace 				
							qui: estadd local naics3year "Yes", replace 
							qui: estadd local stateyear "Yes", replace 		
							qui: estadd local model "STACKED", replace 		
				  }				  
	  
			
  	esttab  cum_count_abatement1gdid3 cum_count_abatement1matched  pct_recycle*3 pct_recycle*ed pct_recovery*3 pct_recovery*ed  pct_treatment*3 pct_treatment*ed  using "$output/Table7_PanelB.tex", $format order(*post) keep(*post)   $chemicalscalars  mgroup("Source Reduction" "Recycling"   "Recovery" "Treatment" , pattern( 1 0  1 0 1  0 1 0  ) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span}))	
 

/******************************
**Table 8: Information costs
************************************/		
	
	use Table8.dta, clear 
	gen pressure=0
	gen complex_id=0 
	gen pressureXcomplex=0	
	 eststo clear 
	foreach x of varlist seg_num  naics3_count n_subs  depth_max block_pct {	
	display "`x'"
	      winsor2 `x', cut(1 99) replace 
		foreach z of varlist  pressure_index1{
		replace complex_id=`x'
		replace pressure=`z'
		replace pressureXcomplex=`x'*`z'
		la var complex_id "Info. Asymmetry"
		la var pressure "Pressure Index"
		la var pressureXcomplex "Pressure index X Info. Asymmetry"
		eststo `x': qui: reghdfe sold_pol_cusip pressureXcomplex complex_id pressure $firmvar, a(year#naics3) cl(gvkey)
		qui: estadd local naics3year "Yes", replace 
		}
	}	
	
  esttab   seg_num  naics3_count n_subs  depth_max block_pct using "$output/Table8.tex" , $format keep( pressureXcomplex complex_id pressure) scalars("N Observations"   "naics3year Industry-Year FE"  )
 
 
 
 	
	
/******************************************************
	Table 9. Business Ties between Buyers and Sellers of Pollutive Plants
******************************************************/

*Panel A

capture rm "$output/Table9_panelA.txt"
use Table9_panelA.dta, clear
	
	reghdfe treat friends , a(dealnumber) cl(dealnumber fyear)
	outreg2 using "$output/Table9_panelA.xls", $instruct replace
	
	reghdfe fut_friends treat, a(dealnumber) cl(dealnumber fyear)
	outreg2 using "$output/Table9_panelA.xls", $instruct 
	


*Panel B

capture rm "$output/Table9_panelB.txt"
use Table9_PanelB.dta, clear
	
	reghdfe sell pressure_index_own min_pressure_index_friend , a(naics3 year) cl(firm_id)
		outreg2 using "$output/Table9_PanelB.xls", $instruct keep(pressure_index_own min_pressure_index_friend) replace
		
	reghdfe sell pressure_index_own min_pressure_index_friend , a(naics3#year) cl(firm_id)
		outreg2 using "$output/Table9_PanelB.xls", $instruct keep(pressure_index_own min_pressure_index_friend)
	
	reghdfe sell pressure_index_own min_pressure_index_friend   $firmvar, a(naics3#year) cl(firm_id)
		outreg2 using "$output/Table9_PanelB.xls", $instruct keep(pressure_index_own min_pressure_index_friend)
	
	
	
	
/****************************************************
	Table 10. Conference Call Environmental Disclosures
****************************************************/

capture rm "$output/Table10.txt"
*Columns 1-3 and 5-7: GDID 	
	use Table10_GDID.dta, clear
	
	reghdfe have_pos_ml target, a(fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table10.xls", $instruct  keep(target)  replace
	
	reghdfe have_pos_ml target, a(naics3#fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table10.xls", $instruct  keep(target)  
	
	reghdfe have_pos_ml target $firmvar , a(naics3#fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table10.xls", $instruct  keep(target)  

	reghdfe have_neg_ml target, a(fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table10.xls", $instruct  keep(target)  
	
	reghdfe have_neg_ml target, a(naics3#fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table10.xls", $instruct keep(target)   
	
	reghdfe have_neg_ml target $firmvar , a(naics3#fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table10.xls", $instruct keep(target)   
		
		
*Columns 4 and 8: matched 
use Table10_stacked.dta, clear

	reghdfe  have_pos_ml target $firmvar, a(naics3#fyear#cohort gvkey#cohort) cl(gvkey)
	outreg2 using "$output/Table10.xls", $instruct keep(target) 
	
	reghdfe  have_neg_ml target $firmvar, a(naics3#fyear#cohort gvkey#cohort) cl(gvkey)
	outreg2 using "$output/Table10.xls", $instruct keep(target)  
	


/*********************************************
Table 11, Changes in ESG Ratings and Regulatory Costs
***********************************************/

*PanelA: ESG ratings
		eststo clear
		
		use Table11_PanelA_gdid.dta, clear
	    la var divtargetpost "Seller (Pollutive) x Post"
		foreach y in kld_csr_score kld_env_score   {
			        
			qui: eststo `y'gdid0: reghdfe `y' divtargetpost , a(gvkey year) cluster(gvkey)
				            qui: estadd local firm "Yes", replace 
							qui: estadd local year "Yes", replace 
		
			qui: eststo `y'gdid1: reghdfe `y' divtargetpost  , a(gvkey naics3year ) cluster(gvkey)
							qui: estadd local firm "Yes", replace 
							qui: estadd local naics3year "Yes", replace 
				
										
			qui: eststo `y'gdid2: reghdfe `y' divtargetpost $firmvar , a(gvkey naics3year ) cluster(gvkey)
							qui: estadd local firm "Yes", replace 
							qui: estadd local naics3year "Yes", replace  		
							qui: estadd local controls "Yes", replace						
					}
					
					
		use Table11_PanalA_matched.dta, clear 
		la var divtargetpost "Seller (Pollutive) x Post"			
		foreach y in kld_csr_score kld_env_score  {	
						
			qui: eststo `y'matched2: reghdfe `y' divtargetpost $firmvar , a(cohort_id#gvkey cohort_id#naics3year ) cluster(gvkey)
							qui: estadd local firm "Yes", replace 
							qui: estadd local naics3year "Yes", replace 
							qui: estadd local controls "Yes", replace					
					}
								
			esttab kld_csr_scoregdid0 kld_csr_scoregdid1 kld_csr_scoregdid2 kld_csr_scorematched2 kld_env_scoregdid0  kld_env_scoregdid1  kld_env_scoregdid2  kld_env_scorematched2  using "$output/Table11_PanelA.tex", $format  keep(*post)  scalars("N Observations"   "firm Firm FE" "year Year FE" "naics3year Industry-Year FE"  "controls Firm Characteristics" )	
					
	

*Panel B, Columns 1-3 and 5-7 GDID Estimates

capture rm "$output/Table11_PanelB.txt"
use Table11_PanelB_GDID.dta, clear

	reghdfe dum_enf target , a(fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table11_PanelB.xls", $instruct keep(target)  replace
	
	reghdfe dum_enf target, a(naics3#fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table11_PanelB.xls", $instruct  keep(target)  
	
	reghdfe dum_enf target $firmvar, a(naics3#fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table11_PanelB.xls", $instruct keep(target)  
		

	ppmlhdfe parent_enf_cost target  , a(fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table11_PanelB.xls", $instruct  keep(target) addstat(Pseudo R2, e(r2_p))
	
	ppmlhdfe  parent_enf_cost target, a(naics3#fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table11_PanelB.xls", $instruct  keep(target)  addstat(Pseudo R2, e(r2_p))
	
	ppmlhdfe parent_enf_cost target $firmvar, a(naics3#fyear gvkey) cl(gvkey) 
	outreg2 using "$output/Table11_PanelB.xls", $instruct keep(target) addstat(Pseudo R2, e(r2_p))
		
	
	
* Panel B, Columns 4 and 8  Matched Sample

use Table11_PanelB_stacked.dta, clear

	reghdfe  dum_enf target $firmvar, a(naics3#fyear#cohort gvkey#cohort) cl(gvkey)
		outreg2 using "$output/Table11_PanelB.xls", $instruct keep(target)  
	
	ppmlhdfe parent_enf_cost target $firmvar , a(naics3#fyear#cohort gvkey#cohort) cl(gvkey)
	outreg2 using "$output/Table11_PanelB.xls", $instruct keep(target)  addstat(Pseudo R2, e(r2_p))
	


/****************************************
	Table 12. Divestiture Announcement Returns
****************************************/
capture rm "$output/Table12.txt"
use Table12.dta, clear

	gen  pollution_quartile = r4_total
	
	reghdfe target_ult_parent_car1_mkt pollution_quartile, a(year seller_naics3) cl(year seller_naics3)
		outreg2 using "$output/Table12.xls", $instruct  ctitle("Seller CAR[−1 +1]","Market", "Quantity") replace
	drop pollution_quartile
	gen  pollution_quartile = r4_per

	reghdfe target_ult_parent_car1_mkt pollution_quartile, a(year seller_naics3) cl(year seller_naics3)
		outreg2 using "$output/Table12.xls", $instruct  ctitle("Seller CAR[−1 +1]","Market", "Intensity")
	
	drop pollution_quartile
	gen  pollution_quartile = r4_total
	
	reghdfe target_ult_parent_car1_FF pollution_quartile, a(year seller_naics3) cl(year seller_naics3)
		outreg2 using "$output/Table12.xls", $instruct  ctitle("Seller CAR[−1 +1]","FF", "Quantity")
	
	drop pollution_quartile
	gen  pollution_quartile = r4_per
	
	reghdfe target_ult_parent_car1_FF pollution_quartile, a(year seller_naics3) cl(year seller_naics3)
		outreg2 using "$output/Table12.xls", $instruct  ctitle("Seller CAR[−1 +1]","FF", "Intensity")
		
		
/************************************************************
	Table 13. Conference Call Announcement Returns
************************************************************/
capture rm "$output/Table13_PanelA.txt"
capture rm "$output/Table13_PanelB.txt"

use Table13.dta,  clear

*Panel A
	reg confcall_car1_mkt 1.have_pos_ml##1.divest, cl(naics3)
	outreg2 using "$output/Table13_PanelA.xls", $instruct replace
	reghdfe confcall_car1_mkt 1.have_pos_ml##1.divest, a(naics3 year) cl(naics3)
	outreg2 using "$output/Table13_PanelA.xls", $instruct 
	
	reg confcall_car1_FF 1.have_pos_ml##1.divest, cl(naics3)
	outreg2 using "$output/Table13_PanelA.xls", $instruct 
	reghdfe confcall_car1_FF 1.have_pos_ml##1.divest, a(naics3 year) cl(naics3)
	outreg2 using "$output/Table13_PanelA.xls", $instruct 
	
* Panel B	

	reghdfe confcall_car1_mkt have_pos_ml if divest, a(naics3 year) cl(naics3)
		outreg2 using "$output/Table13_PanelB.xls", $instruct replace 
	
	reghdfe confcall_car1_FF have_pos_ml if divest, a(naics3 year) cl(naics3)
		outreg2 using "$output/Table13_PanelB.xls", $instruct 
		

/**********************************
**Table 14  Divestitures of Non-Pollutive Plants
************************************************/

* Panel A: Sellers vs Buyers		
		eststo clear		
		use Table14_PanelA.dta, clear 

		foreach y of varlist  public  kldyear pension_mean ultparent_cty_dem  have_e_event pressure_index1    {
			  eststo `y': 	qui:	reghdfe `y' buyer, noa  
		  }   
		 
		 esttab public  kldyear pension_mean ultparent_cty_dem  have_e_event pressure_index1  using  "$output/Table14_PanelA.tex", $format   scalars("N Observations"     )  mgroup("Public"  "Rated" "Pension Holiding"  "Democrat County" "Env. Event" "Pressure Index",  pattern( 1 1 1 1 1 1 ) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) 	
		
			

*	Panel B: Business Ties

capture rm "$output/Table14_PanelB.txt"
use  Table14_PanelB.dta, clear

	reghdfe treat friends , a(matched_group) cl(matched_group fyear)
	outreg2 using "$output/Table14_PanelB.xls", $instruct replace
	
	reghdfe fut_friends treat, a(matched_group) cl(matched_group fyear)
	outreg2 using "$output/Table14_PanelB.xls", $instruct 

	
	

*	Panel C: Environmental Disclosures

capture rm "$output/Table14_PanelC.txt"

use  Table14_PanelC.dta, clear


	reghdfe have_pos_ml target, a(fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table14_PanelC.xls", $instruct  keep(target) replace
	
	reghdfe have_pos_ml target, a(naics3#fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table14_PanelC.xls", $instruct  keep(target)
	
	reghdfe have_pos_ml target $firmvar , a(naics3#fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table14_PanelC.xls", $instruct  keep(target)
	
	reghdfe have_neg_ml target, a(fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table14_PanelC.xls", $instruct  keep(target)
	
	reghdfe have_neg_ml target, a(naics3#fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table14_PanelC.xls", $instruct  keep(target)
	
	reghdfe have_neg_ml target $firmvar , a(naics3#fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table14_PanelC.xls", $instruct  keep(target)



*  Panel D: ESG Ratings

	    eststo clear
		use Table14_PanelD.dta, clear 
		la var divtargetpost "Seller (NonPollutive) x Post"					
				foreach y in kld_csr_score kld_env_score  {
					
					qui: eststo `y'0: reghdfe `y' divtargetpost , a(gvkey year) cluster(gvkey)
							qui: estadd local firm "Yes", replace 
							qui: estadd local year "Yes", replace 
						   	
						 
					qui: eststo `y'1: reghdfe `y' divtargetpost , a(gvkey naics3year ) cluster(gvkey)
							qui: estadd local firm "Yes", replace 
							qui: estadd local naics3year "Yes", replace 

					
					qui: eststo `y'2: reghdfe `y' divtargetpost $firmvar , a(gvkey naics3year ) cluster(gvkey)
							qui: estadd local firm "Yes", replace 
							qui: estadd local naics3year "Yes", replace 		
							qui: estadd local controls "Yes", replace
						
					}
							
	 esttab kld_csr_score* kld_env_score*  using "$output/Table14_PanelD.tex", $format order(*post)   ///
	 keep(*post)  scalars("N Observations"  "firm Firm FE" "year Year FE" "naics3year Industry-Year FE"  "controls Firm Characteristics"  "sample Sample"  ) 
			

*Panel E: EPA Regulatory Enforcement 


use Table14_PanelE.dta, clear

	reghdfe dum_enf target, a(fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table14_PanelE.xls", $instruct keep(target) replace
	
	reghdfe dum_enf target, a(naics3#fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table14_PanelE.xls", $instruct keep(target)
	
	reghdfe dum_enf target $firmvar, a(naics3#fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table14_PanelE.xls", $instruct keep(target)
		

	ppmlhdfe parent_enf_cost target  , a(fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table14_PanelE.xls", $instruct keep(target) addstat(Pseudo R2, e(r2_p))
	
	ppmlhdfe  parent_enf_cost target, a(naics3#fyear gvkey) cl(gvkey)
	outreg2 using "$output/Table14_PanelE.xls", $instruct keep(target) addstat(Pseudo R2, e(r2_p))
	
	ppmlhdfe parent_enf_cost target $firmvar, a(naics3#fyear gvkey) cl(gvkey) 
	outreg2 using "$output/Table14_PanelE.xls", $instruct keep(target) addstat(Pseudo R2, e(r2_p))
			
	
	/**************************************
	*Figure 2: Reprisk event dynamics ***********
	***************************************/
			
	use Table4.dta, clear 
	 tsset gvkey year 
	foreach x in  have_e_event  {
		gen l_`x' = L.`x'
		gen l2_`x' = L2.`x'
		gen l3_`x' = L3.`x'	
		gen f_`x' = F.`x'
		gen f2_`x' = F2.`x'
		gen f3_`x' = F3.`x'
	
	}

    eststo sold_pol_cusip : qui: reghdfe sold_pol_cusip   f3_have_e_event f2_have_e_event f_have_e_event have_e_event l_have_e_event l2_have_e_event l3_have_e_event   $firmvar, a(gvkey year) cl(gvkey)
	coefplot sold_pol_cusip , keep(*have*event*) vertical $coefplotspe ///
	rename(f3_have_e_event=-3 f2_have_e_event =-2 f_have_e_event=-1 have_e_event=0 l_have_e_event=1 l2_have_e_event=2 l3_have_e_event=3) ///
	 ytitle("Probability of Divestitures (%)", size(4)) xtitle("Time Since Environmental Events")  name(sold_pol_cusip , replace) 
	graph export "$output/Figure2.png",   replace 
	


	
	/****************************
    *Figure 3 plant-chemical Pollution 
	*******************************/
	   eststo clear 
*Panel A & C: GDID 
	    use Table6_7_PanelA_GDID.dta, clear		
			eststo didf3: 	qui:	ppmlhdfe total_release $gdideventdynamics , a($chemicalfe3) cl($clu) 
			coefplot didf3, keep($gdidcoeffs zero)  vertical rename($gdidrenames) $coefplotspe ///
		    xtitle("Time Since Divestiture") ytitle("Effect of Divestiture") name(`y'didf3, replace)  
			 graph export "$output/Figure3_PanelA.png",   replace
		     
		
			eststo didf3: 	qui:	ppmlhdfe  total_release_pratio $gdideventdynamics , a($chemicalfe3) cl($clu) 
			coefplot didf3, keep($gdidcoeffs zero)  vertical rename($gdidrenames) $coefplotspe ///
		    xtitle("Time Since Divestiture") ytitle("Effect of Divestiture") name(`y'didf3, replace)  
			 graph export "$output/Figure3_PanelC.png",   replace
		     
		
		
*Panel B & D: stacked
		use Table6_7_PanelA_matched.dta, clear   
		
			eststo didf3: 	qui:	ppmlhdfe total_release $matcheddynamics , a($matchedchemicalfe3) cl($clu)
			coefplot didf3, keep($matchedcoeffs )  vertical rename($matchedrenames) $coefplotspe ///
		    xtitle("Time Since Divestiture") ytitle("Effect of Divestiture") name(`y'didf3, replace)  
			 graph export "$output/Figure3_PanelB.png",   replace 
		     
 
			eststo didf3: 	qui:	ppmlhdfe total_release_pratio $matcheddynamics , a($matchedchemicalfe3) cl($clu)
			coefplot didf3, keep($matchedcoeffs )  vertical rename($matchedrenames) $coefplotspe ///
		    xtitle("Time Since Divestiture") ytitle("Effect of Divestiture") name(`y'didf3, replace)  
			 graph export "$output/Figure3_PanelD.png",   replace 
		  
 
 
 
  /********************************
 ****Figure 4 : pollution around Reprisk triggered divestitures 
 ******************************************/
	
	   eststo clear 
*Panel A & C: GDID 
	   use Figure4_panelac.dta, clear 
	   
			eststo didf3: 	qui:	ppmlhdfe total_release $gdideventdynamics , a($chemicalfe3) cl($clu) 
			coefplot didf3, keep($gdidcoeffs zero*)  vertical rename($gdidrenames) $coefplotspe ///
		    xtitle("Time Since Divestiture") ytitle("Effect of Divestiture") name(`y'didf3, replace)  
			 graph export "$output/Figure4_panelA.png",   replace
		     
		  	eststo didf3: 	qui:	ppmlhdfe total_release_pratio $gdideventdynamics , a($chemicalfe3) cl($clu) 
			coefplot didf3, keep($gdidcoeffs zero*)  vertical rename($gdidrenames) $coefplotspe ///
		    xtitle("Time Since Divestiture") ytitle("Effect of Divestiture") name(`y'didf3, replace)  
			 graph export "$output/Figure4_panelC.png",   replace
		     	 	 
			 
*Panel B & D: stacked
	   use Figure4_panelbd.dta, clear 
						
			eststo didf3: qui:	ppmlhdfe total_release $matcheddynamics , a($matchedchemicalfe3) cl($clu)		
			coefplot didf3, keep($matchedcoeffs zero)  vertical rename($matchedrenames) $coefplotspe ///
		    xtitle("Time Since Divestiture") ytitle("Effect of Divestiture") name(`y'didf3, replace)  
			 graph export "$output/Figure4_panelB.png",   replace 
		     
			eststo didf3: qui:	ppmlhdfe total_release_pratio $matcheddynamics , a($matchedchemicalfe3) cl($clu)		
			coefplot didf3, keep($matchedcoeffs zero)  vertical rename($matchedrenames) $coefplotspe ///
		    xtitle("Time Since Divestiture") ytitle("Effect of Divestiture") name(`y'didf3, replace)  
			 graph export "$output/Figure4_panelD.png",   replace 
	


/**********************************************
Figure 5. Changes in Environmental Disclosures, ESG Ratings, and Regulatory
Enforcement Actions around Divestitures
**********************************************/

global renames "zero = <-3 time_3 = -3 time_2=-2 time_1=-1  time0=0  time1=1  time2=2  time3plus= 3+"
global coeffs "zero time_3 time_2 time_1 time0 time1 time2 time3plus"

* Panel A. Positive Environmental Disclosure, GDID

	use figure5_PanelA.dta, clear

	reghdfe have_pos_ml zero time_3 time_2 time_1 time0 time1 time2 time3plus $firmvar treat , a(fyear#naics3  gvkey) cl(gvkey)
	estimates store ml
		
	coefplot ml, keep($coeffs) vertical rename($renames) $coefplotspe ///
	 ytitle("Effects of Divestiture", size(4)) ylabel(-0.2(.1).3) xtitle("Time Since Divestiture")   name(ml, replace) 
	graph export "$output/Figure5_PanelA.png", replace 

	
* Panel B. Positive Environmental Disclosure, Stacked

	use figure5_PanelB.dta, clear

	reghdfe have_pos_ml zero time_3 time_2 time_1 time0 time1 time2 time3plus $firmvar, a(fyear#cohort#naics3  gvkey#cohort) cl(gvkey)
	estimates store conf_call
	
	coefplot conf_call, keep($coeffs) vertical rename($renames) $coefplotspe ///
	ytitle("Effects of Divestiture", size(4)) ylabel(-0.2(.1).3) xtitle("Time Since Divestiture") 
	graph export "$output/Figure5_PanelB.png", replace 
	

	
*Panel C. Env. Ratings, GDID
	
	use Table11_PanelA_gdid.dta, clear					
						
	 eststo  kld_env_score: qui: reghdfe  kld_env_score $gdideventdynamics  $firmar, a(gvkey naics3year) cl(gvkey)
		coefplot  kld_env_score, keep($gdideventdynamics) vertical rename($gdidrenames)  $coefplotspe ///
		 ytitle("Effects of Divestiture", size(4)) xtitle("Time Since Divestment")   
		graph export "$output/Figure5_PanelC.png",   replace
	

*Panel D. Env. Ratings, Statcked 
	use Table11_PanalA_matched.dta, clear 

		eststo kld_env_score: 	qui:	reghdfe kld_env_score $matcheddynamics $firmar, a(cohort_id#gvkey cohort_id#naics3year) cl(gvkey) 
			coefplot kld_env_score, keep($matcheddynamics zero) vertical rename($didrenames) $coefplotspe ///
		 xtitle("Time Since Divestiture") ytitle("Effect of Divestiture") 
			 graph export "$output/Figure5_PanelD.png",   replace 
	
	
* Panel E. Enforcement Likelihood, GDID

	use figure5_PanelE.dta, clear
	
	reghdfe dum_enf zero time_3 time_2 time_1 time0 time1 time2 time3plus $firmvar, a(parent_id fyear#naics3 ) cl(parent_id)	
	estimates store enf_dynamic
	
	coefplot enf_dynamic, keep($coeffs) vertical rename($renames) $coefplotspe ///
	 ytitle("Effects of Divestiture", size(4)) ylabel(-0.1(.05).15) xtitle("Time Since Divestiture")   
	graph export "$output/Figure5_PanelE.png", replace 
	
* Panel F. Enforcement Likelihood, Stacked

use figure5_PanelF.dta, clear
		
	reghdfe dum_enf zero time_3 time_2 time_1 time0 time1 time2 time3plus $firmvar, a(fyear#cohort#naics3 parent_id#cohort) cl(parent_id)
	estimates store enf_matched
	
	coefplot enf_matched, keep($coeffs) vertical rename($renames) $coefplotspe ///
	 ytitle("Effects of Divestiture", size(4)) ylabel(-0.15(.05).15) xtitle("Time Since Divestiture")   
	graph export "$output/Figure5_PanelF.png", replace 


	
/**********************************************************
Figure 6. Relative Gains from Divesting Pollutive Plants
***********************************************************/	
	
use Table12.dta, clear

	tabstat diff_ult_car1_mkt, by (r4_total) statistics(mean) c(s)
	tabstat diff_ult_car1_mkt, by (r4_per) statistics(mean) c(s)
	
	tabstat diff_ult_car1_FF, by (r4_total) statistics(mean) c(s)
	tabstat diff_ult_car1_FF, by (r4_per) statistics(mean) c(s)
	* Summarized the mean for each group, then plotted in Excel
	
	
*close log file 
log close 	
	
