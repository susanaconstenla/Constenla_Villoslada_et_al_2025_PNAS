********************************************************************************
clear all
		mata: mata clear
		cap log close
		set more off
		set trace off
		set linesize 140
		set memory 200m
		set matsize 1000
		set seed 123456789
		timer clear
		label drop _all 
		estimates clear
********************************************************************************
* DEFINITION OF THE WORKING DIRECTORY. INPUT AND OUTPUT FILES*

		if "`c(os)'"=="Windows" {								
		local drive: env HOMEDRIVE
		local path : env HOMEPATH
			global 	BASE_DIR "`drive'`path'/Library/CloudStorage/Box-Box/Kenya_MUAC"
			}
		if "`c(os)'"=="MacOSX" {
		local path : env HOMEPATH
			global BASE_DIR "~`path'/Library/CloudStorage/Box-Box/Kenya_MUAC"
		}

*----------------------------
cd "$BASE_DIR"
 
 *IN*

	    global DATA        "$BASE_DIR" * COMPLETE WITH LOCAL DIRECTORY WHERE RESULTS ARE
	    global DATA2        "$BASE_DIR" * COMPLETE WITH LOCAL DIRECTORY WHERE FULL DATASET FILE IS


 *OUT*	
		global OUTPUT	"$BASE_DIR" * COMPLETE WITH LOCAL DIRECTORY
        global GRAPHS   "$BASE_DIR" * COMPLETE WITH LOCAL DIRECTORY
	    global TABLES   "$BASE_DIR" * COMPLETE WITH LOCAL DIRECTORY

		
********************************************************************************
graph set window fontface "Times New Roman"
use  "$DATA/results", clear * CHANGE FOR LOCAL FILE
 
labmask time_cont_enc, values(time_cont)

preserve 
 use "$DATA2\Kenya_NDMA_MUAC_ward_level_pre_and_post_2016_for_Python", clear 
 bys ward_polygon_ID: keep if _n==1
 keep ward_polygon_ID ward_post2010_name
 rename  ward_polygon_ID ward_polygon_id
 tempfile names 
 save `names', replace 
restore 

 merge m:1 ward_polygon_id using `names'
  
  tsset ward_polygon_id time_cont_enc
   

twoway(lpoly wasting time_cont_enc if ward_polygon_id==450)(lpolyci w_2_ff time_cont_enc if ward_polygon_id==450, legend(pos(6) col(2)) ciplot(rline) ) /// 
(lpoly w_2_nv time_cont_enc if ward_polygon_id==450)(lpoly w_2_hb time_cont_enc if ward_polygon_id==450, ylabel(0(0.05)0.20) xlabel(4(3)120) )

twoway(line wasting time_cont_enc if ward_polygon_id==1080)(line w_2_ff time_cont_enc if ward_polygon_id==1080, legend(pos(6) col(2)) ) ///
      (line w_2_nv time_cont_enc if ward_polygon_id==1080)(line w_2_hb time_cont_enc if ward_polygon_id==1080,  ylabel(0(0.05)0.50))


* Figures *
*----------*
*--------------------------------------------------------------------------------------------
 * Sensitivity over time *
*--------------------------*

foreach x in hb nv ff{
twoway(scatter wasting time_cont_enc if wasting>0.15,  mlwidth(medthick) yaxis(1) xlabel(4(5)176, valuelabel angle(45)) mcolor(orange_red%40) msymbol(Oh) yline(0.15, lcolor(gray%40))) ///
	  (scatter wasting time_cont_enc if wasting<=0.15, yaxis(1) mlwidth(thick) ///
	  mcolor(gray%10) msymbol(Oh) xline(48 126 150, lcolor(orange_red) lwidth(medthick)) yline(0.15) ylabel(0(0.10)1,format(%9.2f))) ///
	  (lpoly sen_1_`x'_w time_cont_enc,  lwidth(medthick) lpattern(solid)) (lpoly spec_1_`x'_w time_cont_enc,  lwidth(medthick) lpattern(solid)) ///
	  (lpoly sen_2_`x'_w time_cont_enc, lwidth(medthick)  lpattern(solid) lcolor(dkgreen) xtitle("") ytitle("", height(5) axis(1)) ///
      legend(order( 1 "Wasting (>0.15)" 2 "Wasting (<= 0.15)" 3 "1-month sensitivity" /// 
	  4 "1-month specificity" 5 "3-month sensitivity" ///
	  6 "3-month specificity" 7 "6-month sensitivity"  8 "6-month specificity") /// 
	  pos(6) col(4)) ylabel(0(0.10)1,format(%9.2f) axis(1)) yaxis(1)) (lpoly spec_2_`x'_w time_cont_enc, lwidth(medthick) lpatter(solid)) ///
	  (lpoly sen_3_`x'_w time_cont_enc,  lwidth(medthick) lpattern(solid)) (lpoly spec_3_`x'_w time_cont_enc,  lwidth(medthick) lpattern(solid)) ///
  
	graph export "$GRAPHS/Sensitivity_over_time_v2_36_`x'_with_CI.tif", replace
}

* Suplemental information *

foreach x in hb nv ff{
twoway(scatter wasting time_cont_enc if wasting>0.15,  mlwidth(medthick) yaxis(1) xlabel(4(5)176, valuelabel angle(45)) mcolor(orange_red%40) msymbol(Oh) yline(0.15, lcolor(gray%40))) ///
	  (scatter wasting time_cont_enc if wasting<=0.15, yaxis(1) mlwidth(thick) ///
	  mcolor(gray%10) msymbol(Oh) xline(48 126 150, lcolor(orange_red) lwidth(medthick)) yline(0.15) ylabel(0(0.10)1,format(%9.2f))) ///
	  (lpoly sen_4_`x'_w time_cont_enc,  lwidth(medthick) lpattern(solid)) (lpoly spec_4_`x'_w time_cont_enc,  lwidth(medthick) lpattern(solid)) ///
	  (lpoly sen_5_`x'_w time_cont_enc, lwidth(medthick)  lpattern(solid) lcolor(dkgreen) xtitle("") ytitle("", height(5) axis(1)) ///
      legend(order( 1 "Wasting (>0.15)" 2 "Wasting (<= 0.15)" 3 "9-month sensitivity" /// 
	  4 "9-month specificity" 5 "12-month sensitivity" ///
	  6 "12-month specificity") /// 
	  pos(6) col(4)) ylabel(0(0.10)1,format(%9.2f) axis(1)) yaxis(1)) (lpoly spec_5_`x'_w time_cont_enc, lwidth(medthick) lpatter(solid))   
	graph export "$GRAPHS/Sensitivity_over_time_v2_36_`x'_SI.tif", replace
}


 * Sensitivity over time *
*--------------------------*

foreach x in hb nv ff{
twoway(scatter wasting time_cont_enc if wasting>0.15,  mlwidth(medthick) yaxis(1) xlabel(4(5)176, valuelabel angle(45)) mcolor(orange_red%40) msymbol(Oh) yline(0.15, lcolor(gray%40))) ///
	  (scatter wasting time_cont_enc if wasting<=0.15, yaxis(1) mlwidth(thick) ///
	  mcolor(gray%10) msymbol(Oh) xline(48 126 150, lcolor(orange_red) lwidth(medthick)) yline(0.15) ylabel(0(0.10)1,format(%9.2f))) ///
	  (lpoly prec_1_`x'_w time_cont_enc,  lwidth(medthick) lpattern(solid)) ///
	  (lpoly prec_2_`x'_w time_cont_enc, lwidth(medthick)  lpattern(solid) lcolor(dkgreen) xtitle("") ytitle("", height(5) axis(1)) ///
      legend(order( 1 "Wasting (>0.15)" 2 "Wasting (<= 0.15)" 3 "1-month precision" /// 
	   4 "3-month precision" 5 "6-month precision"  ) /// 
	  pos(6) col(3)) ylabel(0(0.10)1,format(%9.2f) axis(1)) yaxis(1)) ///
	  (lpoly prec_3_`x'_w time_cont_enc, color(eltblue) lwidth(medthick) lpattern(solid)) 
  
	graph export "$GRAPHS/Precision_over_time_v2_36_`x'_with_CI.tif", replace
}


* Suplemental information *

foreach x in hb nv ff{
twoway(scatter wasting time_cont_enc if wasting>0.15,  mlwidth(medthick) yaxis(1) xlabel(4(5)176, valuelabel angle(45)) mcolor(orange_red%40) msymbol(Oh) yline(0.15, lcolor(gray%40))) ///
	  (scatter wasting time_cont_enc if wasting<=0.15, yaxis(1) mlwidth(thick) ///
	  mcolor(gray%10) msymbol(Oh) xline(48 126 150, lcolor(orange_red) lwidth(medthick)) yline(0.15) ylabel(0(0.10)1,format(%9.2f))) ///
	  (lpoly prec_4_`x'_w time_cont_enc,  lwidth(medthick) lpattern(solid)) ///
	  (lpoly prec_5_`x'_w time_cont_enc, lwidth(medthick)  lpattern(solid) lcolor(dkgreen) xtitle("") ytitle("", height(5) axis(1)) ///
      legend(order( 1 "Wasting (>0.15)" 2 "Wasting (<= 0.15)" 3 "9-month precision" 4 "12-month precision"  ) pos(6) col(3)) ylabel(0(0.10)1,format(%9.2f) axis(1)) yaxis(1))  
	graph export "$GRAPHS/Precision_over_time_v2_36_`x'_SI.tif", replace
}

 * Sensitivity over time - oversample comparison *
*--------------------------*

preserve
use  "$DATA/results_36_Jan2024", clear 
rename (sen* spec* R2*)  (sen*_og spec*_og R2*_og)
keep ward_polygon_id time_cont_enc sen* spec* R2*
tempfile comparison	
save `comparison', replace
restore 

merge 1:1 ward_polygon_id time_cont_enc using `comparison', nogen

foreach x in hb{
twoway(scatter wasting time_cont_enc if wasting>0.15,  mlwidth(medthick) yaxis(1) xlabel(4(5)176, valuelabel angle(45)) mcolor(orange_red%40) msymbol(Oh) yline(0.15, lcolor(gray%40))) ///
	  (scatter wasting time_cont_enc if wasting<=0.15, yaxis(1) mlwidth(thick) ///
	  mcolor(gray%10) msymbol(Oh) xline(48 126 150, lcolor(orange_red) lwidth(medthick)) yline(0.15) ylabel(0(0.10)1,format(%9.2f))) ///
	  (lpoly sen_3_`x'_w_og time_cont_enc,  lwidth(medthick) lpattern(solid))  ///
	  (lpoly sen_3_`x'_w time_cont_enc, lwidth(medthick)  lpattern(solid) lcolor(dkgreen) xtitle("") ytitle("", height(5) axis(1)) ///
      legend(order( 1 "Wasting (>0.15)" 2 "Wasting (<= 0.15)" 3 "6-month sensitivity, no oversample" /// 
	  4 "6-month sensitivity, oversample" 5 "6-month specificity, oversample" 6 "6-month specificity, oversample") ///
	  pos(6) col(2)) ylabel(0(0.10)1,format(%9.2f) axis(1)) yaxis(1)) ///
	  (lpoly spec_3_`x'_w_og time_cont_enc, lwidth(medthick) lpatter(solid)) ///
      (lpoly spec_3_`x'_w time_cont_enc, lwidth(medthick) lpatter(solid))
	graph export "$GRAPHS/Sensitivity_over_time_oversample_comp.tif", replace
}

  
  * Average values over time *
 *---------------------------------------------- 
    foreach x in nv ff hb {
     foreach z in  R2  sen prec spec{
	    foreach y in 1 2 3{

gen mean_`z'_`y'_`x'=.

 sum `z'_`y'_`x'_w if time_cont_enc>=4 & time_cont_enc<48
 replace  mean_`z'_`y'_`x'=`r(mean)' if time_cont_enc>=4 & time_cont_enc<48
 
   sum `z'_`y'_`x'_w if time_cont_enc>=48 & time_cont_enc<126
 replace  mean_`z'_`y'_`x'=`r(mean)' if time_cont_enc>=48 & time_cont_enc<126
 
   sum `z'_`y'_`x'_w if time_cont_enc>=126 & time_cont_enc<150
 replace  mean_`z'_`y'_`x'=`r(mean)' if time_cont_enc>=126 & time_cont_enc<150
 
  sum `z'_`y'_`x'_w if time_cont_enc>=150 
 replace  mean_`z'_`y'_`x'=`r(mean)' if time_cont_enc>=150
 
		}	
	 }
	}
	
	
twoway(scatter w_1_hb time_cont_enc if w_1_hb<0.10, xline(48 126 150, lcolor(orange_red) lwidth(medthick)) mcolor(none) ylabel(0(0.10)1,format(%9.2f)) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
 (lpoly mean_sen_1_ff time_cont_enc,   ytitle("Sensitivity",  height(20)) lwidth(thick) lcolor(orange) xlabel(4 48 120 150 176)) ///
 (lpoly mean_sen_2_ff time_cont_enc, lwidth(thick) lcolor(dkgreen)) ///
 (lpoly mean_sen_3_ff time_cont_enc, lwidth(thick) lcolor(eltblue) legend(order( 2 "1-month" 3 "3-month" 4 "6-month") pos(6) col(3))), saving(sen_ff, replace)
	  
twoway(scatter w_1_hb time_cont_enc if w_1_hb<0.10, xline(48 126 150, lcolor(orange_red) lwidth(medthick)) mcolor(none) ylabel(0(0.10)1,format(%9.2f)) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
 (lpoly mean_sen_1_hb time_cont_enc,lwidth(thick) lcolor(orange) xlabel(4 48 126 150 176)) ///
 (lpoly mean_sen_2_hb time_cont_enc,lwidth(thick) lcolor(dkgreen)) ///
 (lpoly mean_sen_3_hb time_cont_enc,lwidth(thick) lcolor(eltblue)legend(order( 2 "1-month" 3 "3-month" 4 "6-month") pos(6) col(3))), saving(sen_hb, replace)
 
twoway(scatter w_1_hb time_cont_enc if w_1_hb<0.10, xline(48 126 150, lcolor(orange_red) lwidth(medthick)) mcolor(none) ylabel(0(0.10)1,format(%9.2f)) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
 (lpoly mean_sen_1_nv time_cont_enc, lwidth(thick) lcolor(orange) xlabel(4 48 126 150 176)) ///
 (lpoly mean_sen_2_nv time_cont_enc, lwidth(thick) lcolor(dkgreen)) ///
 (lpoly mean_sen_3_nv time_cont_enc, lwidth(thick) lcolor(eltblue)legend(order( 2 "1-month" 3 "3-month" 4 "6-month") pos(6) col(3))), saving(sen_nv, replace)
 
*----------------------------------------------
 twoway(scatter w_1_hb time_cont_enc if w_1_hb<0.10,xline(48 126 150, lcolor(orange_red) lwidth(medthick)) mcolor(none) ylabel(0(0.10)1,format(%9.2f)) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
 (lpoly mean_spec_1_ff time_cont_enc,  ytitle("Specificity",  height(20)) lwidth(thick) lcolor(orange) xlabel(4 48 120 150 176)) ///
 (lpoly mean_spec_2_ff time_cont_enc, lwidth(thick) lcolor(dkgreen)) ///
 (lpoly mean_spec_3_ff time_cont_enc, lwidth(thick) lcolor(eltblue)legend(order( 2 "1-month" 3 "3-month" 4 "6-month") pos(6) col(3))), saving(spec_ff, replace)
	  
twoway(scatter w_1_hb time_cont_enc if w_1_hb<0.10, xline(48 126 150, lcolor(orange_red) lwidth(medthick)) mcolor(none) ylabel(0(0.10)1,format(%9.2f)) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
 (lpoly mean_spec_1_hb time_cont_enc, lwidth(thick) lcolor(orange) xlabel(4 48 126 150 176)) ///
 (lpoly mean_spec_2_hb time_cont_enc, lwidth(thick) lcolor(dkgreen)) ///
 (lpoly mean_spec_3_hb time_cont_enc, lwidth(thick) lcolor(eltblue) legend(order( 2 "1-month" 3 "3-month" 4 "6-month") pos(6) col(3))), saving(spec_hb, replace)
 
twoway(scatter w_1_hb time_cont_enc if w_1_hb<0.10, xline(48 126 150, lcolor(orange_red) lwidth(medthick)) mcolor(none) ylabel(0(0.10)1,format(%9.2f)) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
 (lpoly mean_spec_1_nv time_cont_enc,  lwidth(thick) lcolor(orange) xlabel(4 48 126 150 176)) ///
 (lpoly mean_spec_2_nv time_cont_enc, lwidth(thick) lcolor(dkgreen)) ///
 (lpoly mean_spec_3_nv time_cont_enc, lwidth(thick) lcolor(eltblue) legend(order( 2 "1-month" 3 "3-month" 4 "6-month") pos(6) col(3))), saving(spec_nv, replace)
 
 *----------------------------------------------
 twoway(scatter w_1_hb time_cont_enc if w_1_hb<0.10,xline(48 126 150, lcolor(orange_red) lwidth(medthick)) mcolor(none) ylabel(0(0.10)1,format(%9.2f)) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
 (lpoly mean_prec_1_ff time_cont_enc,  ytitle("Precision",  height(20)) lwidth(thick) lcolor(orange) xlabel(4 48 120 150 176)) ///
 (lpoly mean_prec_2_ff time_cont_enc, lwidth(thick) lcolor(dkgreen)) ///
 (lpoly mean_prec_3_ff time_cont_enc, lwidth(thick) lcolor(eltblue)legend(order( 2 "1-month" 3 "3-month" 4 "6-month") pos(6) col(3))), saving(prec_ff, replace)
	  
twoway(scatter w_1_hb time_cont_enc if w_1_hb<0.10, xline(48 126 150, lcolor(orange_red) lwidth(medthick)) mcolor(none) ylabel(0(0.10)1,format(%9.2f)) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
 (lpoly mean_prec_1_hb time_cont_enc, lwidth(thick) lcolor(orange) xlabel(4 48 126 150 176)) ///
 (lpoly mean_prec_2_hb time_cont_enc, lwidth(thick) lcolor(dkgreen)) ///
 (lpoly mean_prec_3_hb time_cont_enc, lwidth(thick) lcolor(eltblue) legend(order( 2 "1-month" 3 "3-month" 4 "6-month") pos(6) col(3))), saving(prec_hb, replace)
 
twoway(scatter w_1_hb time_cont_enc if w_1_hb<0.10, xline(48 126 150, lcolor(orange_red) lwidth(medthick)) mcolor(none) ylabel(0(0.10)1,format(%9.2f)) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
 (lpoly mean_prec_1_nv time_cont_enc,  lwidth(thick) lcolor(orange) xlabel(4 48 126 150 176)) ///
 (lpoly mean_prec_2_nv time_cont_enc, lwidth(thick) lcolor(dkgreen)) ///
 (lpoly mean_prec_3_nv time_cont_enc, lwidth(thick) lcolor(eltblue) legend(order( 2 "1-month" 3 "3-month" 4 "6-month") pos(6) col(3))), saving(prec_nv, replace)

 *----------------------------------------------
  twoway(scatter w_1_hb time_cont_enc if w_1_hb<0.10, xline(48 126 150, lcolor(orange_red) lwidth(medthick)) mcolor(none) ylabel(0(0.10)1,format(%9.2f)) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
 (lpoly mean_R2_1_ff time_cont_enc,  ytitle("R2", height(20)) lwidth(thick) lcolor(orange) xlabel(4 48 126 150 176)) ///
 (lpoly mean_R2_2_ff time_cont_enc, lwidth(thick) lcolor(dkgreen)) ///
 (lpoly mean_R2_3_ff time_cont_enc, lwidth(thick) lcolor(eltblue) legend(order( 2 "1-month" 3 "3-month" 4 "6-month") pos(6) col(3))), saving(R2_ff, replace)
	  
twoway(scatter w_1_hb time_cont_enc if w_1_hb<0.10, xline(48 126 150, lcolor(orange_red) lwidth(medthick)) mcolor(none) ylabel(0(0.10)1,format(%9.2f)) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
 (lpoly mean_R2_1_hb time_cont_enc, lwidth(thick) lcolor(orange) xlabel(4 48 126 150 176)) ///
 (lpoly mean_R2_2_hb time_cont_enc, lwidth(thick) lcolor(dkgreen)) ///
 (lpoly mean_R2_3_hb time_cont_enc, lwidth(thick) lcolor(eltblue) legend(order( 2 "1-month" 3 "3-month" 4 "6-month") pos(6) col(3))), saving(R2_hb, replace)
 
twoway(scatter w_1_hb time_cont_enc if w_1_hb<0.10, xline(48 126 150, lcolor(orange_red) lwidth(medthick)) mcolor(none) ylabel(0(0.10)1,format(%9.2f)) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
 (lpoly mean_R2_1_nv time_cont_enc,   lwidth(thick) lcolor(orange)  xlabel(4 48 126 150 176)) ///
 (lpoly mean_R2_2_nv time_cont_enc, lwidth(thick) lcolor(dkgreen)) ///
 (lpoly mean_R2_3_nv time_cont_enc, lwidth(thick) lcolor(eltblue) legend(order( 2 "1-month" 3 "3-month" 4 "6-month") pos(6) col(3))), saving(R2_nv, replace)
 
 
gr combine R2_ff.gph R2_nv.gph R2_hb.gph,   xcommon col(3) 
 				graph export "$GRAPHS/Average_R2_with_CI.tif", replace
gr combine sen_ff.gph sen_nv.gph sen_hb.gph,  ycommon xcommon col(3) 
				graph export "$GRAPHS/Average_sensi_with_CI.tif", replace
gr combine spec_ff.gph spec_nv.gph spec_hb.gph, ycommon xcommon col(3) 
				graph export "$GRAPHS/Average_spec_with_CI.tif", replace
gr combine prec_ff.gph prec_nv.gph prec_hb.gph, ycommon xcommon col(3) 
				graph export "$GRAPHS/Average_prec_with_CI.tif", replace

				

*--------------------------------------------------------------------------------------------
 * Predicted distributions *
*--------------------------*
		twoway(scatter w_1_hb time_cont_enc if w_1_hb<0.10,xline(48 126 150, lcolor(orange_red) lwidth(medthick)) mcolor(none) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
		 (lpoly w_1_hb time_cont_enc, lwidth(thick) lpattern(dash)) ///
		 (lpoly w_2_hb time_cont_enc, lwidth(thick) lcolor(blue) lpattern(dash)) ///
		 (lpoly w_3_hb time_cont_enc, lwidth(thick) lcolor(gold) lpattern(dash)) ///
		 (lpoly wasting time_cont_enc, lpattern(solid) lwidth(thick) lcolor(orange_red) ///
		 legend(order(2 "1-month" 3 "3-months" 4 "6-months" 5  "Wasting prevalence") pos(6) col(5)) xtitle("") ylabel(0(0.02)0.16, format(%9.2f)))
				graph export "$GRAPHS/Predicted_wasting_hb_with_zero.tif", replace

		twoway(scatter w_1_hb time_cont_enc if w_1_hb<0.10,xline(48 126 150, lcolor(orange_red) lwidth(medthick)) mcolor(none) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
		 (lpoly w_1_hb time_cont_enc if wasting>0, lwidth(thick) lpattern(dash)) ///
		 (lpoly w_2_hb time_cont_enc if wasting>0, lwidth(thick) lcolor(blue) lpattern(dash)) ///
		 (lpoly w_3_hb time_cont_enc if wasting>0, lwidth(thick) lcolor(gold) lpattern(dash)) ///
		 (lpoly wasting time_cont_enc if wasting>0, lpattern(solid) lwidth(thick) lcolor(orange_red) ///
		 legend(order(2 "1-month" 3 "3-months" 4 "6-months" 5  "Wasting prevalence") pos(6) col(5)) xtitle("") ylabel(0(0.02)0.16, format(%9.2f)))
						graph export "$GRAPHS/Predicted_wasting_hb_no_zero.tif", replace
*#-----------------------------------------
		twoway(scatter w_1_nv time_cont_enc if w_1_nv<0.05, xline(48 126 150, lcolor(orange_red) lwidth(medthick))  mcolor(none) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
		 (lpoly w_1_nv time_cont_enc, lwidth(thick) lpattern(dash)) ///
		 (lpoly w_2_nv time_cont_enc, lwidth(thick) lcolor(blue) lpattern(dash)) ///
		 (lpoly w_3_nv time_cont_enc, lwidth(thick) lcolor(gold) lpattern(dash)) ///
		 (lpoly wasting time_cont_enc, lpattern(solid) lwidth(thick) lcolor(orange_red) ///
		 legend(order(2 "1-month" 3 "3-months" 4 "6-months" 5  "Wasting prevalence") pos(6) col(5)) xtitle("") ylabel(0(0.02)0.16, format(%9.2f)))
		 				graph export "$GRAPHS/Predicted_wasting_nv_with_zero.tif", replace
						
		twoway(scatter w_1_nv time_cont_enc if w_1_nv<0.10,xline(48 126 150, lcolor(orange_red) lwidth(medthick)) mcolor(none) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
		 (lpoly w_1_nv time_cont_enc if wasting>0, lwidth(thick) lpattern(dash)) ///
		 (lpoly w_2_nv time_cont_enc if wasting>0, lwidth(thick) lcolor(blue) lpattern(dash)) ///
		 (lpoly w_3_nv time_cont_enc if wasting>0, lwidth(thick) lcolor(gold) lpattern(dash)) ///
		 (lpoly wasting time_cont_enc if wasting>0, lpattern(solid) lwidth(thick) lcolor(orange_red) ///
		 legend(order(2 "1-month" 3 "3-months" 4 "6-months" 5  "Wasting prevalence") pos(6) col(5)) xtitle("") ylabel(0(0.02)0.16, format(%9.2f)))
						graph export "$GRAPHS/Predicted_wasting_nv_no_zero.tif", replace
						
*#-----------------------------------------
		 twoway(scatter w_1_ff time_cont_enc if w_1_ff<0.10, xline(48 126 150, lcolor(orange_red) lwidth(medthick)) mcolor(none) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
		 (lpoly w_1_ff time_cont_enc, lwidth(thick) lpattern(dash)) ///
		 (lpoly w_2_ff time_cont_enc, lwidth(thick) lcolor(blue) lpattern(dash)) ///
		 (lpoly w_3_ff time_cont_enc, lwidth(thick) lcolor(gold) lpattern(dash)) ///
		 (lpoly wasting time_cont_enc, lpattern(solid) lwidth(thick) lcolor(orange_red) ///
		 legend(order(2 "1-month" 3 "3-months" 4 "6-months" 5  "Wasting prevalence") pos(6) col(5)) xtitle("") ylabel(0(0.02)0.16, format(%9.2f)))
		 
				graph export "$GRAPHS/Predicted_wasting_ff_with_zero.tif", replace
	
		 twoway(scatter w_1_ff time_cont_enc if w_1_ff==0.10 & wasting>0, xline(48 126 150, lcolor(orange_red) lwidth(medthick)) mcolor(none) xlabel(4(5)176, valuelabel angle(45))mlcolor(none)) ///
		 (lpoly w_1_ff time_cont_enc if wasting>0, lwidth(thick) lpattern(dash)) ///
		 (lpoly w_2_ff time_cont_enc if wasting>0, lwidth(thick) lcolor(blue) lpattern(dash)) ///
		 (lpoly w_3_ff time_cont_enc if wasting>0, lwidth(thick) lcolor(gold) lpattern(dash)) ///
		 (lpoly wasting time_cont_enc if wasting>0, lpattern(solid) lwidth(thick) lcolor(orange_red) ///
		 legend(order(2 "1-month" 3 "3-months" 4 "6-months" 5  "Wasting prevalence") pos(6) col(5)) xtitle("") ylabel(0(0.02)0.16, format(%9.2f)))	
		 				graph export "$GRAPHS/Predicted_wasting_ff_no_zero.tif", replace

*--------------------------------------------------------------------------------------------
 * Autocorrelation and crosscorrelation analyses *
*--------------------------*

**# Bookmark #1  
  tsset ward_polygon_id time_cont_enc
  
 forvalues i=1/12{
  gen corr_wasting_l`i'=.
 qui levelsof time_cont_enc, local(levels)
foreach l of local levels{	
capture noisily qui	corr wasting l`i'.wasting if time_cont_enc==`l'
capture noisily qui	replace corr_wasting_l`i' = r(rho) if time_cont_enc==`l'

}
 }
 
foreach x in nv hb ff{
	forvalues p=1/5{
  forvalues i=1/9{
  gen corr_w_`p'_`x'_l`i'=.
 qui levelsof time_cont_enc, local(levels)
foreach l of local levels{	
capture noisily qui	corr w_`p'_`x' l`i'.wasting if time_cont_enc==`l'
capture noisily qui	replace corr_w_`p'_`x'_l`i' = r(rho) if time_cont_enc==`l'

}
 }
}
}

 sum corr_wasting_l3 if time_cont_enc>=4 & time_cont_enc<48
 
 sum corr_wasting_l3 if time_cont_enc>=48 & time_cont_enc<126
 
 sum corr_wasting_l3 if time_cont_enc>=126 & time_cont_enc<150
 
 sum corr_wasting_l3 if time_cont_enc>=150
  
*-----------------------*
* Autocorrelation plots *
*-----------------------*
 
		 
twoway(scatter wasting time_cont_enc if wasting>0.15, ///
       mlwidth(medthick) yaxis(1) xlabel(4(5)176, valuelabel angle(45)) mcolor(orange_red%40) msymbol(Oh) yline(0.15, lcolor(gray%40))) ///
	  (scatter wasting time_cont_enc if wasting<=0.15, yaxis(1) mlwidth(thick) ///
	  mcolor(gray%10) msymbol(Oh) xline(48 126 150, lcolor(orange_red) lwidth(medthick)) yline(0.15) ylabel(0(0.10)1,format(%9.2f))) ///
	  (lpoly corr_wasting_l1 time_cont_enc, lwidth(medthick) xlabel(,valuelabel) yaxis(1)) /// 
	 (lpoly corr_wasting_l3 time_cont_enc, lwidth(medthick) xlabel(,valuelabel) yaxis(1)) ///
	 (lpoly corr_wasting_l6 time_cont_enc, lwidth(medthick) xlabel(,valuelabel) yaxis(1) ytitle("Prevalence/Autocorrelation/Sensitivity")) ///
	 (lpoly corr_wasting_l9 time_cont_enc, lwidth(medthick) xlabel(,valuelabel) yaxis(1)) ///
	 (lpoly corr_wasting_l12 time_cont_enc, lwidth(medthick) xlabel(,valuelabel) yaxis(1)) ///
	 (lpoly sen_1_hb_w time_cont_enc , lcolor(dkgreen) lpatter(longdash) lwidth(medthick)  ///
	 	 legend(order(1 "Wasting prevalence (>0.15)" 2 "Wasting prevalence (<= 0.15)" 3 "wasting vs 1-month lag"  /// 
		 4 "wasting vs 3-month lag"  5 "wasting vs 6-month lag" 6 "wasting vs 9-month lag" 7 "wasting vs 12-month lag" 8 "1-month sensitivity hybrid model")  ///
		 pos(6) col(2))  xlabel(,valuelabel) yaxis(1))
		 				graph export "$GRAPHS/Autocorrelation_Wasting_1_3_6_9_12_lags_last.tif", replace

						*======================
*-----------------------*
* Cross-correlation plots *
*-----------------------* 

foreach x in nv hb ff{

twoway(scatter wasting time_cont_enc if wasting>0.15, ///
       mlwidth(thick) yaxis(1) xlabel(4(5)176, valuelabel angle(45)) mcolor(orange_red%40) msymbol(Oh) yline(0.15, lcolor(gray%40))) ///
	  (scatter wasting time_cont_enc if wasting<=0.15, yaxis(1) mlwidth(thick) ///
	  mcolor(gray%10) msymbol(Oh) xline(48 126 150, lcolor(orange_red) lwidth(medthick))  yline(0.15) ylabel(0(0.10)1,format(%9.2f))) ///
	 (lowess corr_w_2_`x'_l1 time_cont_enc, bwidth(0.05) xlabel(,valuelabel) yaxis(1)) /// 
	 (lowess corr_w_2_`x'_l2 time_cont_enc, bwidth(0.05) xlabel(,valuelabel) yaxis(1)) ///
	 (lowess corr_w_2_`x'_l3 time_cont_enc, bwidth(0.05) xlabel(,valuelabel) yaxis(1)) ///
	 (lowess corr_w_2_`x'_l4 time_cont_enc, bwidth(0.05) xlabel(,valuelabel) yaxis(1)) ///
	 (lowess corr_w_2_`x'_l5 time_cont_enc, bwidth(0.05) xlabel(,valuelabel) yaxis(1)) ///
	 (lowess corr_w_2_`x'_l6 time_cont_enc, bwidth(0.05) xlabel(,valuelabel) yaxis(1)) ///
	 (lpoly spec_2_`x'_w time_cont_enc, lcolor(dkblue) lpatter(dash)) ///
	 (lpoly sen_2_`x'_w time_cont_enc, lcolor(dkgreen) lpatter(dash)  legend(order(1 "Wasting prevalence (>0.15)" 2 "Wasting prevalence (<= 0.15)" 3 "3-month pred vs 1-month lag"  4 "3-month pred vs 2-month lag"  5 "3-month pred vs 3-month lag" 6 "3-month pred vs 4-month lag" ///
	 7 "3-month pred vs 5-month lag" 8 "3-month pred vs 6-month lag" 9 "3-month specificity" 10 "3-month sensitivity")  /// 
	 pos(6) col(2))  xlabel(,valuelabel) yaxis(1)) 
	 		 				graph export "$GRAPHS/Cross_correlation_3_month_`x'_last.tif", replace
}
	 
**# 
*------------------------------------------*
* Predictive performance during hunger crises *
*------------------------------------------*
gen alert = wasting>0.15 if wasting!=. 

	bys time_cont_enc: egen total_alerts = total(alert)

	bys time_cont_enc: gen alert_high = (total_alerts>=3)
	
preserve
bys time_cont_enc: keep if _n==1

	gen run_high=0

    replace run_high = cond(total_alerts>=3, run_high[_n-1]+1,0) if time_cont_enc>4
	
	sum run_high, de
keep time_cont_enc run_high
tempfile cumsum
sav `cumsum', replace
restore

merge m:1  time_cont_enc using `cumsum', nogen

lpoly total_alerts time_cont_enc

twoway(scatter wasting time_cont_enc if wasting>0.15, ///
       mlwidth(medthick) yaxis(2) xlabel(4(5)176, valuelabel angle(45)) mcolor(orange_red%40) msymbol(Oh) yline(0.15, lcolor(gray%40))) ///
	  (scatter wasting time_cont_enc if wasting<=0.15, yaxis(2) mlwidth(thick) ///
mcolor(gray%10) msymbol(Oh) xline(48 126 150, lcolor(orange_red) lwidth(medthick))  yline(0.15) ytitle("Prevalence/Sensitivity",axis(2)) ylabel(0(0.10)1,format(%9.2f) axis(2))) ///
	  (bar run_high time_cont_enc, yaxis(1) ytitle("Cumulative number of months", angle(270) axis(1)) ylabel(0(1)9,format(%9.0f) axis(1) )) ///
	  (lpoly sen_2_hb time_cont_enc, lwidth(medthick) yaxis(2) legend(order(1 "Wasting prevalence (>0.15)" 2 "Wasting prevalence (<= 0.15)" 4 "Months with more than 2 wards on alert"  3 "3-month sensitivity, hybrid model") pos(6) col(2)) )
		 
graph export "$GRAPHS/Cum_month_alert_last.tif", replace

*--------------------------------------------------------------------------------------------
 * R2 over time *
*--------------------------*
* Wasting *
*---------*

foreach x in nv hb ff {

		twoway(scatter R2_1_`x'_w time_cont_enc, xline(48 126 150, lcolor(orange_red) lwidth(medthick)) xlabel(4(5)176, valuelabel angle(45)) mcolor(none) mlcolor(none)) ///
		 (lpolyci R2_1_`x'_w time_cont_enc,  lcolor(forest_green) lwidth(medthick)) ///
		 (lpolyci R2_2_`x'_w time_cont_enc,   lwidth(medthick) ) ///
		 (lpolyci R2_3_`x'_w time_cont_enc, lcolor(blue) lwidth(medthick) ) ///
		 (lpolyci R2_4_`x'_w time_cont_enc,  lwidth(medthick)  lpattern(solid) ) ///
		 (lpolyci R2_5_`x'_w time_cont_enc, lwidth(medthick)  lpattern(solid) ///
		 legend(order(3 "1-month" 5 "3-months" 7 "6-months" 9  "9-months" 11 "12-months") pos(6) col(5)) xtitle("") ylabel(0(0.1)1, format(%9.2f)))

				graph export "$GRAPHS/R2_over_time_`x'_last.tif", replace
}

foreach x in nv hb ff{
forvalues i=1/5{
sum NRMSE_`i'_`x'_w
 local m`i'=`r(mean)'
}
		twoway(scatter R2_1_`x'_w time_cont_enc,  xline(120 131) xlabel(4(5)176, valuelabel angle(45)) mcolor(none) mlcolor(none)) ///
		 (lpolyci NRMSE_1_`x'_w time_cont_enc, fitplot(area)  lwidth(thick)) ///
		 (lpolyci NRMSE_2_`x'_w time_cont_enc,  lwidth(thick) ) ///
		 (lpolyci NRMSE_3_`x'_w time_cont_enc,  lwidth(thick) ) ///
		 (lpolyci NRMSE_4_`x'_w time_cont_enc,  lwidth(thick)  lpattern(solid) ) ///
		 (lpolyci NRMSE_5_`x'_w time_cont_enc,  lwidth(thick)  lpattern(solid) ///
		 legend(order(3 "1-month" 5 "3-months" 7 "6-months" 9  "9-months" 11 "12-months") pos(6) col(5)) xtitle("") ylabel(0(0.1)1, format(%9.2f)))

				graph export "$GRAPHS/NRMSE_over_time_`x'_oversample02.tif", replace
}


*---------------------------*
* Variable importance *
*---------------------------*
twoway(scatter vi1hb_gpp time_cont_enc, xtitle("") xlabel(4(5)176, valuelabel angle(45)) mcolor(none) ) ///
      (lpoly vi1hb_gpp time_cont_enc, lcolor(sand) yaxis(1) ytitle("MDI", axis(1) height(5)) ylabel(0(0.05)0.25, axis(1) format(%9.2f)) lpattern(solid) lwidth(thick)) ///
	  (lpoly vi2hb_gpp time_cont_enc, yaxis(1) lpattern(solid) lwidth(thick)) ///
	  (lpoly vi3hb_gpp time_cont_enc, yaxis(1) lpattern(solid) lwidth(thick))(lpoly vi4hb_gpp time_cont_enc, lpattern(solid) yaxis(1) lwidth(thick)) ///
	  (lpoly vi5hb_gpp time_cont_enc,  yaxis(1) lpattern(solid) lwidth(thick  ) ///
	  legend(pos(6) col(6) order( 2 "1-month" 3 "3-month" 4 "6-month" 5 "9-month" 6 "12-month" 7 "Wasting prevalence"))  xline(48 126 150, lcolor(orange_red) lwidth(medthick))) ///
	  (scatter wasting time_cont_enc, ylabel(0(0.1)0.8, axis(2) format(%9.2f)) ytitle("Wasting prevalence", axis(2) angle(360)) msize(medium) mcolor(gray%15) yaxis(2))
	  				graph export "$GRAPHS/MDI_GPP_over_time.tif", replace

	  
	  twoway(scatter vi1hb_wlags time_cont_enc, xtitle("") xlabel(4(5)176, valuelabel angle(45)) mcolor(none) ) ///
      (lpoly vi1hb_wlags time_cont_enc, lcolor(sand) yaxis(1) ytitle("MDI", axis(1) height(5)) ylabel(0(0.05)0.50, axis(1) format(%9.2f)) lpattern(solid) lwidth(thick)) ///
	  (lpoly vi2hb_wlags time_cont_enc, yaxis(1) lpattern(solid) lwidth(thick)) ///
	  (lpoly vi3hb_wlags time_cont_enc, yaxis(1) lpattern(solid) lwidth(thick))(lpoly vi4hb_wlags time_cont_enc, lpattern(solid) yaxis(1) lwidth(thick)) ///
	  (lpoly vi5hb_wlags time_cont_enc,  yaxis(1) lpattern(solid) lwidth(thick  ) ///
	  legend(pos(6) col(6) order( 2 "1-month" 3 "3-month" 4 "6-month" 5 "9-month" 6 "12-month" 7 "Wasting prevalence"))  xline(48 126 150, lcolor(orange_red) lwidth(medthick))) ///
	  (scatter wasting time_cont_enc, ylabel(0(0.1)0.8, axis(2) format(%9.2f)) ytitle("Wasting prevalence", axis(2) angle(360)) msize(medium) mcolor(gray%15) yaxis(2))
	  	  				graph export "$GRAPHS/MDI_lags_over_time.tif", replace
						
	  twoway(scatter vi1hb_static time_cont_enc, xtitle("") xlabel(4(5)176, valuelabel angle(45)) mcolor(none) ) ///
      (lpoly vi1hb_static time_cont_enc, lcolor(sand) yaxis(1) ytitle("MDI", axis(1) height(5)) ylabel(0(0.05)0.50, axis(1) format(%9.2f)) lpattern(solid) lwidth(thick)) ///
	  (lpoly vi2hb_static time_cont_enc, yaxis(1) lpattern(solid) lwidth(thick)) ///
	  (lpoly vi3hb_static time_cont_enc, yaxis(1) lpattern(solid) lwidth(thick))(lpoly vi4hb_static time_cont_enc, lpattern(solid) yaxis(1) lwidth(thick)) ///
	  (lpoly vi5hb_static time_cont_enc,  yaxis(1) lpattern(solid) lwidth(thick  ) ///
	  legend(pos(6) col(6) order( 2 "1-month" 3 "3-month" 4 "6-month" 5 "9-month" 6 "12-month" 7 "Wasting prevalence"))  xline(48 126 150, lcolor(orange_red) lwidth(medthick))) ///
	  (scatter wasting time_cont_enc, ylabel(0(0.1)0.8, axis(2) format(%9.2f)) ytitle("Wasting prevalence", axis(2) angle(360)) msize(medium) mcolor(gray%15) yaxis(2))
	  	  				graph export "$GRAPHS/MDI_static_over_time.tif", replace
						
	  twoway(scatter vi1hb_prices time_cont_enc, xtitle("") xlabel(4(5)176, valuelabel angle(45)) mcolor(none) ) ///
      (lpoly vi1hb_prices time_cont_enc, lcolor(sand) yaxis(1) ytitle("MDI", axis(1) height(5)) ylabel(0(0.05)0.30, axis(1) format(%9.2f)) lpattern(solid) lwidth(thick)) ///
	  (lpoly vi2hb_prices time_cont_enc, yaxis(1) lpattern(solid) lwidth(thick)) ///
	  (lpoly vi3hb_prices time_cont_enc, yaxis(1) lpattern(solid) lwidth(thick))(lpoly vi4hb_prices time_cont_enc, lpattern(solid) yaxis(1) lwidth(thick)) ///
	  (lpoly vi5hb_prices time_cont_enc,  yaxis(1) lpattern(solid) lwidth(thick  ) ///
	  legend(pos(6) col(6) order( 2 "1-month" 3 "3-month" 4 "6-month" 5 "9-month" 6 "12-month" 7 "Wasting prevalence")) xline(48 126 150, lcolor(orange_red) lwidth(medthick))) ///
	  (scatter wasting time_cont_enc, ylabel(0(0.1)0.8, axis(2) format(%9.2f)) ytitle("Wasting prevalence", axis(2) angle(360)) msize(medium) mcolor(gray%15) yaxis(2))
	  	  				graph export "$GRAPHS/MDI_prices_over_time.tif", replace

		  twoway(scatter vi1hb_temp time_cont_enc, xtitle("") xlabel(4(5)176, valuelabel angle(45)) mcolor(none) ) ///
      (lpoly vi1hb_temp time_cont_enc, lcolor(sand) yaxis(1) ytitle("MDI", axis(1) height(5)) ylabel(0(0.05)0.25, axis(1) format(%9.2f)) lpattern(solid) lwidth(thick)) ///
	  (lpoly vi2hb_temp time_cont_enc, yaxis(1) lpattern(solid) lwidth(thick)) ///
	  (lpoly vi3hb_temp time_cont_enc, yaxis(1) lpattern(solid) lwidth(thick))(lpoly vi4hb_temp time_cont_enc, lpattern(solid) yaxis(1) lwidth(thick)) ///
	  (lpoly vi5hb_temp time_cont_enc,  yaxis(1) lpattern(solid) lwidth(thick  ) ///
	  legend(pos(6) col(6) order( 2 "1-month" 3 "3-month" 4 "6-month" 5 "9-month" 6 "12-month" 7 "Wasting prevalence"))  xline(48 126 150, lcolor(orange_red) lwidth(medthick))) ///
	  (scatter wasting time_cont_enc, ylabel(0(0.1)0.8, axis(2) format(%9.2f)) ytitle("Wasting prevalence", axis(2) angle(360)) msize(medium) mcolor(gray%15) yaxis(2))
	  	  				graph export "$GRAPHS/MDI_temp_over_time.tif", replace
						
			  twoway(scatter vi1hb_prec time_cont_enc, xtitle("") xlabel(4(5)176, valuelabel angle(45)) mcolor(none) ) ///
      (lpoly vi1hb_prec time_cont_enc, lcolor(sand) yaxis(1) ytitle("MDI", axis(1) height(5)) ylabel(0(0.05)0.25, axis(1) format(%9.2f)) lpattern(solid) lwidth(thick)) ///
	  (lpoly vi2hb_prec time_cont_enc, yaxis(1) lpattern(solid) lwidth(thick)) ///
	  (lpoly vi3hb_prec time_cont_enc, yaxis(1) lpattern(solid) lwidth(thick))(lpoly vi4hb_prec time_cont_enc, lpattern(solid) yaxis(1) lwidth(thick)) ///
	  (lpoly vi5hb_prec time_cont_enc,  yaxis(1) lpattern(solid) lwidth(thick  ) ///
	  legend(pos(6) col(6) order( 2 "1-month" 3 "3-month" 4 "6-month" 5 "9-month" 6 "12-month" 7 "Wasting prevalence")) xline(48 126 150, lcolor(orange_red) lwidth(medthick))) ///
	  (scatter wasting time_cont_enc, ylabel(0(0.1)0.8, axis(2) format(%9.2f)) ytitle("Wasting prevalence", axis(2) angle(360)) msize(medium) mcolor(gray%15) yaxis(2))
	  	  	  				graph export "$GRAPHS/MDI_precipitation_over_time.tif", replace
							
				  twoway(scatter vi1hb_conflict time_cont_enc, xtitle("") xlabel(4(5)176, valuelabel angle(45)) mcolor(none) ) ///
      (lpoly vi1hb_conflict time_cont_enc, lcolor(sand) yaxis(1) ytitle("MDI", axis(1) height(5)) ylabel(0(0.05)0.30, axis(1) format(%9.2f)) lpattern(solid) lwidth(thick)) ///
	  (lpoly vi2hb_conflict time_cont_enc, yaxis(1) lpattern(solid) lwidth(thick)) ///
	  (lpoly vi3hb_conflict time_cont_enc, yaxis(1) lpattern(solid) lwidth(thick))(lpoly vi4hb_conflict time_cont_enc, lpattern(solid) yaxis(1) lwidth(thick)) ///
	  (lpoly vi5hb_conflict time_cont_enc,  yaxis(1) lpattern(solid) lwidth(thick  ) ///
	  legend(pos(6) col(6) order( 2 "1-month" 3 "3-month" 4 "6-month" 5 "9-month" 6 "12-month" 7 "Wasting prevalence"))  xline(48 126 150, lcolor(orange_red) lwidth(medthick))) ///
	  (scatter wasting time_cont_enc, ylabel(0(0.1)0.8, axis(2) format(%9.2f)) ytitle("Wasting prevalence", axis(2) angle(360)) msize(medium) mcolor(gray%15) yaxis(2))
	  	  	  				graph export "$GRAPHS/MDI_conflict_over_time.tif", replace
							