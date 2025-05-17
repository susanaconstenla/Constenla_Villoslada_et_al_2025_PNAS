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
			global 	BASE_DIR "`drive'`path'/Library/CloudStorage/Box-Box/Kenya_MUAC" * CHANGE FOR LOCAL DIRECTORY
			}
		if "`c(os)'"=="MacOSX" {
		local path : env HOMEPATH
			global BASE_DIR "~`path'/Library/CloudStorage/Box-Box/Kenya_MUAC" * CHANGE FOR LOCAL DIRECTORY
		}


*----------------------------
cd "$BASE_DIR"
 
 *IN*

	    global xgboost     "$BASE_DIR/" * CHANGE FOR LOCAL DIRECTORY

 *OUT*	
		global OUTPUT	"$BASE_DIR/" * COMPLETE WITH LOCAL DIRECTORY
        global GRAPHS   "$BASE_DIR/" * COMPLETE WITH LOCAL DIRECTORY
	    global TABLES   "$BASE_DIR/" * COMPLETE WITH LOCAL DIRECTORY
        global LOGS     "$BASE_DIR/" * COMPLETE WITH LOCAL DIRECTORY
		global DOS	    "$BASE_DIR/" * COMPLETE WITH LOCAL DIRECTORY
		

*========================================================================================================
* MODEL PREDICTION *
*-------------------*
 *---------------------*
 * Full-feauture model *
 *---------------------*
* Importing all the results (causes trouble if inside a loop)

* Wasting *

	import  delimited  "$results/One_month_prediction_ff_36", clear
		tempfile ff_1_w
		save `ff_1_w', replace
	import  delimited  "$results/Three_month_prediction_ff_36", clear
		tempfile ff_2_w
		save `ff_2_w', replace
	import  delimited  "$results/Six_month_prediction_ff_36", clear
		tempfile ff_3_w
		save `ff_3_w', replace
	import  delimited  "$results/Nine_month_prediction_ff_36", clear
		tempfile ff_4_w
		save `ff_4_w', replace
	import  delimited  "$results/Twelve_month_prediction_ff_36", clear
		tempfile ff_5_w
		save `ff_5_w', replace
 
*-----------------------------------------------------------------------
* Generating r2 and sen, spec* 
*----------------------------*

tokenize w
forvalues x=1/1 {
  forvalues i=1/5 {
  	
     use `ff_`i'_``x''', clear
  
    if `x' == 1{
  	
gen R2_`i'_ff_``x'' =.
gen NRMSE_`i'_ff_``x''=. 
gen RMSE_`i'_ff_``x''=. 

  qui levelsof time_cont_enc, local(levels)
foreach l of local levels{
qui	corr wasting yhat if time_cont_enc==`l'
qui	replace R2_`i'_ff_``x'' = round((sign(r(rho))*(r(rho)^2)), 0.001) if time_cont_enc==`l'


qui reg yhat wasting if time_cont_enc==`l'
qui predict p if time_cont_enc==`l'
qui  sum wasting if time_cont_enc==`l', de
qui  replace NRMSE_`i'_ff_``x'' = round((e(rmse)/ (`r(max)' - `r(min)')), 0.001) if time_cont_enc==`l'
qui  replace RMSE_`i'_ff_``x'' = round(e(rmse), 0.001) if time_cont_enc==`l'

drop p
}

*------------------------*
  * SEN, SPEC, PPV, NPV *
*------------------------*
 gen pos=(yhat>0.15) if yhat!=. 
 gen true_pos=(yhat>0.15 & wasting>0.15) if (yhat!=. & wasting!=.)
 gen pos_r=(wasting>0.15) if wasting!=.
 gen neg=(yhat<=0.15) if yhat!=.
 gen true_neg=(yhat<=0.15 & wasting<=0.15) if yhat!=.
 gen neg_r=(wasting<=0.15) if wasting!=.
  }
  
  
 foreach z in pos true_pos pos_r neg true_neg neg_r {
bys time_cont_enc: egen t_`z'=total(`z')
 }

 gen F_pos_`i'_ff_``x'' = t_pos-t_true_pos
 gen F_neg_`i'_ff_``x'' = t_neg-t_true_neg

 gen PPV_`i'_ff_``x''  = t_true_pos/t_pos
 gen NPV_`i'_ff_``x''  = t_true_neg/t_neg
 gen sen_`i'_ff_``x''  = t_true_pos/ (t_true_pos+F_neg)
 gen spec_`i'_ff_``x'' = t_true_neg/(t_true_neg+F_pos)
 gen prec_`i'_ff_``x'' = t_true_pos / (t_true_pos+ F_pos)

 drop pos true_neg true_pos neg pos_r neg_r F_pos  
 
  foreach z in pos true_pos pos_r neg true_neg neg_r {
     drop t_`z'
 }

  rename yhat ``x''_`i'_ff

 tempfile ff2_`i'_``x''
 save `ff2_`i'_``x''', replace 
  }

  use `ff2_1_``x''', clear 
    forvalues i=2/5{
       merge  1:1 ward_polygon_id time_cont_enc using `ff2_`i'_``x''', nogen
	   
  }

  
  tempfile ff_full_``x''
  save `ff_full_``x''', replace 
}

     use `ff_full_w' , clear



  

 *---------------------------------------------------------------------------------------------
 

*-----------------------------------------------------------------------------------------------------------------

 *---------------------*
 * Hybrid model *
 *---------------------*
* Importing all the results (causes trouble if inside a loop)

* wasting *

	import  delimited  "$results/One_month_prediction_hb_36", clear
		tempfile hb_1_w
		save `hb_1_w', replace
	import  delimited  "$results/Three_month_prediction_hb_36", clear
		tempfile hb_2_w
		save `hb_2_w', replace
	import  delimited  "$results/Six_month_prediction_hb_36", clear
		tempfile hb_3_w
		save `hb_3_w', replace

		import  delimited  "$results/Nine_month_prediction_hb_36", clear
		tempfile hb_4_w
		save `hb_4_w', replace
	import  delimited  "$results/Twelve_month_prediction_hb_36", clear
		tempfile hb_5_w
		save `hb_5_w', replace
 
	
*-----------------------------------------------------------------------
* Generating r2 and sen, spec* 
*----------------------------*
tokenize w 
forvalues x=1/1 {

  forvalues i=1/5 {
  	
    use `hb_`i'_``x''', clear
  
  if `x' == 1{
*---------*
 * R2* 
*---------*
gen R2_`i'_hb_``x'' =.
gen NRMSE_`i'_hb_``x'' = .
gen RMSE_`i'_hb_``x'' = .

  qui levelsof time_cont_enc, local(levels)
foreach l of local levels{
qui	corr wasting yhat if time_cont_enc==`l'
qui	replace R2_`i'_hb_``x'' = round((sign(r(rho))*(r(rho)^2)), 0.001) if time_cont_enc==`l'


*---------*
 * NRMSE *
*---------*
qui reg yhat wasting if time_cont_enc==`l'
predict p if time_cont_enc==`l'
qui  sum wasting if time_cont_enc==`l', de
qui  replace NRMSE_`i'_hb_``x'' = round((e(rmse)/ (`r(max)' - `r(min)')), 0.001) if time_cont_enc==`l'
qui  replace RMSE_`i'_hb_``x'' = round(e(rmse), 0.001) if time_cont_enc==`l'

drop p

  }
  
*------------------------*
  * SEN, SPEC, PPV, NPV *
*------------------------*
 gen pos=(yhat>0.15) if yhat!=. 
 gen true_pos=(yhat>0.15 & wasting>0.15) if (yhat!=. & wasting!=.)
 gen pos_r=(wasting>0.15) if wasting!=.
 gen neg=(yhat<=0.15) if yhat!=.
 gen true_neg=(yhat<=0.15 & wasting<=0.15) if yhat!=.
 gen neg_r=(wasting<=0.15) if wasting!=.
  }
  
 foreach z in pos true_pos pos_r neg true_neg neg_r {
bys time_cont_enc: egen t_`z'=total(`z')
 }

 gen F_pos_`i'_hb_``x'' = t_pos-t_true_pos
 gen F_neg_`i'_hb_``x'' = t_neg-t_true_neg

 gen PPV_`i'_hb_``x''  = t_true_pos/t_pos
 gen NPV_`i'_hb_``x'' = t_true_neg/t_neg
 gen sen_`i'_hb_``x''  = t_true_pos/ (t_true_pos+F_neg)
 gen spec_`i'_hb_``x'' = t_true_neg/(t_true_neg+F_pos)
 gen prec_`i'_hb_``x'' = t_true_pos / (t_true_pos+ F_pos)


 drop pos true_neg true_pos neg pos_r neg_r F_pos 
 
  foreach z in pos true_pos pos_r neg true_neg neg_r {
     drop t_`z'
 }

 rename yhat ``x''_`i'_hb
 
 tempfile hb2_`i'_``x''
 save `hb2_`i'_``x''', replace 
  
  }

  use `hb2_1_``x''', clear 
    forvalues i=2/5{
       merge  1:1 ward_polygon_id time_cont_enc using `hb2_`i'_``x''', nogen
  }
  
  
  tempfile hb_full_``x''
  save `hb_full_``x''', replace 
}
*-----------------------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------------------

  
	
 *---------------------*
 * Naive model *
 *---------------------*
* Importing all the results (causes trouble if inside a loop)

* wasting *

	import  delimited  "$results/One_month_prediction_nv_36", clear
		tempfile nv_1_w
		save `nv_1_w', replace
	import  delimited  "$results/Three_month_prediction_nv_36", clear
		tempfile nv_2_w
		save `nv_2_w', replace
	import  delimited  "$results/Six_month_prediction_nv_36", clear
		tempfile nv_3_w
		save `nv_3_w', replace
	import  delimited  "$results/Nine_month_prediction_nv_36", clear
		tempfile nv_4_w
		save `nv_4_w', replace
	import  delimited  "$results/Twelve_month_prediction_nv_36", clear
		tempfile nv_5_w
		save `nv_5_w', replace

*-----------------------------------------------------------------------
* Generating r2 and sen, spec* 
*----------------------------*
tokenize w wr
forvalues x=1/1 {
	
  forvalues i=1/5 {
  	
     use `nv_`i'_``x''', clear
	 
*---------*
 * R2* 
*---------*
    if `x' == 1{
		
gen R2_`i'_nv_``x'' =.
gen NRMSE_`i'_nv_``x''=.
gen RMSE_`i'_nv_``x''=.

  qui levelsof time_cont_enc, local(levels)
foreach l of local levels{
qui	corr wasting yhat if time_cont_enc==`l'
qui	replace R2_`i'_nv_``x'' = round((sign(r(rho))*(r(rho)^2)), 0.001) if time_cont_enc==`l'

*---------*
 * NRMSE *
*---------*
qui reg yhat wasting if time_cont_enc==`l'
predict p if time_cont_enc==`l'
qui  sum wasting if time_cont_enc==`l', de
qui  replace NRMSE_`i'_nv_``x'' = round((e(rmse)/ (`r(max)' - `r(min)')), 0.001) if time_cont_enc==`l'
qui  replace RMSE_`i'_nv_``x'' = round(e(rmse), 0.001) if time_cont_enc==`l'

drop p

  }
  
*------------------------*
  * SEN, SPEC, PPV, NPV *
*------------------------*

 gen pos=(yhat>0.15) if yhat!=. 
 gen true_pos=(yhat>0.15 & wasting>0.15) if (yhat!=. & wasting!=.)
 gen pos_r=(wasting>0.15) if wasting!=.
 gen neg=(yhat<=0.15) if yhat!=.
 gen true_neg=(yhat<=0.15 & wasting<=0.15) if yhat!=.
 gen neg_r=(wasting<=0.15) if wasting!=.
  }
  
 foreach z in pos true_pos pos_r neg true_neg neg_r {
bys time_cont_enc: egen t_`z'=total(`z')
 }

 gen F_pos_`i'_nv_``x'' = t_pos-t_true_pos
 gen F_neg_`i'_nv_``x'' = t_neg-t_true_neg

 gen PPV_`i'_nv_``x''  = t_true_pos/t_pos
 gen NPV_`i'_nv_``x'' = t_true_neg/t_neg
 gen sen_`i'_nv_``x''  = t_true_pos/ (t_true_pos+F_neg)
 gen spec_`i'_nv_``x'' = t_true_neg/(t_true_neg+F_pos)
 gen prec_`i'_nv_``x'' = t_true_pos / (t_true_pos+ F_pos)

 drop pos true_neg true_pos neg pos_r neg_r F_pos 
 
  foreach z in pos true_pos pos_r neg true_neg neg_r {
     drop t_`z'
 }

  rename yhat ``x''_`i'_nv

  
 tempfile nv2_`i'_``x''
 save `nv2_`i'_``x''', replace 
  }
  
  use `nv2_1_``x''', clear 
    forvalues i=2/5{
       merge  1:1 ward_polygon_id time_cont_enc using `nv2_`i'_``x''', nogen
  }
    
  tempfile nv_full_``x''
  save `nv_full_``x''', replace 
}
*-----------------------------------------------------------------------------------------------------------------
  
  
use `hb_full_w', clear 
       * merge  1:1 ward_polygon_id time_cont_enc using `hb_full_wr', nogen
        merge  1:1 ward_polygon_id time_cont_enc using `ff_full_w', nogen
       * merge  1:1 ward_polygon_id time_cont_enc using `ff_full_wr', nogen
        merge  1:1 ward_polygon_id time_cont_enc using `nv_full_w', nogen
       * merge  1:1 ward_polygon_id time_cont_enc using `nv_full_wr', nogen

	 sort  time_cont_enc ward_polygon_id
	 save "$results/results_36_June2023_CI", replace 
	 
*-----------------------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------------------
*------------------------------

*-----------------------------------------------------------------------------------------------------------------

* Variable importance* 
* wasting *

* Hybrid model *

	import  delimited  "~\One_month_feat_imp_hb_36", clear
		tempfile hb_1_w
		save `hb_1_w', replace
	import  delimited  "~\Three_month_feat_imp_hb_36", clear
		tempfile hb_2_w
		save `hb_2_w', replace
	import  delimited  "~\Six_month_feat_imp_hb_36", clear
		tempfile hb_3_w
		save `hb_3_w', replace
	import  delimited  "~\Nine_month_feat_imp_hb_36", clear
		tempfile hb_4_w
		save `hb_4_w', replace
	import  delimited  "~\Twelve_month_feat_imp_hb_36", clear
		tempfile hb_5_w
		save `hb_5_w', replace
		
* Full-feature model * 

	import  delimited  "~\One_month_feat_imp_36", clear
		tempfile ff_1_w
		save `ff_1_w', replace
	import  delimited  "~\Three_month_feat_imp_36", clear
		tempfile ff_2_w
		save `ff_2_w', replace
	import  delimited  "~\Six_month_feat_imp_36", clear
		tempfile ff_3_w
		save `ff_3_w', replace
	import  delimited  "~\Nine_month_feat_imp_36", clear
		tempfile ff_4_w
		save `ff_4_w', replace
	import  delimited  "~\Twelve_month_feat_imp_36", clear
		tempfile ff_5_w
		save `ff_5_w', replace
		
*-----------------------------------------------------------------------
*----------------------------*
foreach m in w {

foreach h in hb  ff{
	
forvalues i=1/5 {
  	
     use ``h'_`i'_`m'', clear
	

reshape long fi, i(var_names) j(time_cont)  

levelsof var_names, local(levels)
foreach l of local levels{
	gen vi`i'_`l' = fi if var_names=="`l'"
}

 if `i' ==1{
    local x = 1
	local z = 2
	local y = 3
}

 if `i' ==2{
    local x = 4
	local z = 5
	local y = 6
}

 if `i' ==3{
    local x = 7
	local z = 8
	local y = 9
}

 if `i' ==4{
    local x = 10
	local z = 11
	local y = 12
}

 if `i' ==5{
    local x = 13
	local z = 14
	local y = 15
}

bys time_cont: egen vi`i'`h'_static= total(fi) if (var_names=="crop_mask_1km"  ///
      | var_names=="rangeland_mask_1km" | var_names=="remoteness" | var_names=="elevation_1km" /// 
	  | var_names=="pop_den_1km" | var_names=="LHZ_max_area")


bys time_cont: egen vi`i'`h'_wlags = total(fi) if (var_names=="wlag`x'" | var_names=="wlag`z'" | var_names=="wla`y'" )

bys time_cont: egen vi`i'`h'_prec = total(fi) if (var_names=="l`x'_prec_zscore" | var_names=="l`z'_prec_zscore" | var_names=="l`y'_prec_zscore" | ///
var_names=="l`x'_max_cons_dry_days" | var_names=="l`z'_max_cons_dry_days" | var_names=="l`y'_max_cons_dry_days" |  ///
var_names=="l`x'_total_wet_days" | var_names=="l`z'_total_wet_days" | var_names=="l`y'_total_wet_days" )

bys time_cont: egen vi`i'`h'_gpp = total(fi) if   (var_names=="l`x'_gosif_gpp_zscore" | var_names=="l`z'_gosif_gpp_zscore" | var_names=="l`y'_gosif_gpp_zscore" )

bys time_cont: egen vi`i'`h'_temp = total(fi) if (var_names=="l`x'_temp_zscore" | var_names=="l`z'_temp_zscore" | var_names=="l`y'_temp_zscore"  | ///
var_names=="l`x'_max_cons_hot_days" | var_names=="l`z'_max_cons_hot_days" | var_names=="l`y'_max_cons_hot_days"  )

bys time_cont: egen vi`i'`h'_conflict = total(fi) if (var_names=="l`x'_conflict_fat_12m" | var_names=="l`z'_conflict_fat_12m" /// 
| var_names=="l`y'_conflict_fat_12m" | var_names=="l`x'_conflict_12m" /// 
| var_names=="l`z'_conflict_12m" | var_names=="l`y'_conflict_12m")

bys time_cont: egen vi`i'`h'_prices = total(fi) if (var_names=="l`x'_beensprice" | var_names=="l`z'_beensprice" /// 
| var_names=="l`y'_beensprice" | var_names=="l`x'_maizeprice" | var_names=="l`z'_maizeprice" ///
| var_names=="l`y'_maizeprice" |var_names=="l`x'_riceprice" | var_names=="l`z'_riceprice" | var_names=="l`y'_riceprice" )

collapse (max) vi`i'`h'_*, by(time_cont)


tempfile var`h'_imp`i'_`m'
 save `var`h'_imp`i'_`m'', replace 
 
  }
  
  use `var`h'_imp1_`m'', clear 
    forvalues i=2/5{
       merge  1:1  time_cont using `var`h'_imp`i'_`m'', nogen
  }
    
  tempfile varimp`h'_full_`m'
  save `varimp`h'_full_`m'', replace   
 
  
  }
}
 

use `varimphb_full_w', clear 
        merge  1:1  time_cont using `varimpff_full_w', nogen

	
rename time_cont time_cont_enc

preserve 
 gen n=1
 collapse (mean) vi*, by(n)
 reshape long vi1@_static vi2@_static vi3@_static  vi4@_static  vi5@_static ///
              vi1@_prec vi2@_prec vi3@_prec  vi4@_prec  vi5@_prec ///
			  vi1@_gpp vi2@_gpp vi3@_gpp  vi4@_gpp  vi5@_gpp ///
			  vi1@_temp vi2@_temp vi3@_temp  vi4@_temp  vi5@_temp ///
			  vi1@_conflict vi2@_conflict vi3@_conflict  vi4@_conflict  vi5@_conflict ///
	          vi1@_prices vi2@_prices vi3@_prices  vi4@_prices  vi5@_prices ///
	          vi1@_wlags vi2@_wlags vi3@_wlags  vi4@_wlags  vi5@_wlags ///
			  , i(n) j(group) string

graph bar vi1_static vi2_static vi3_static vi4_static vi5_static, legend(pos(6) col(5) order(1 "1-month" 2 "3-month" 3 "6-month" 4 "9-month" 5 "12-month")) ///
           ylabel(0(0.1)0.40, format(%9.2f)) over(group) b1title("Static") name(bar1, replace) bargap(50) blabel(bar, format(%9.2f))
graph bar vi1_wlags vi2_wlags vi3_wlags vi4_wlags vi5_wlags, ylabel(0(0.1)0.40, format(%9.2f)) over(group) b1title("Lags") name(bar2, replace) bargap(50) blabel(bar, format(%9.2f))
graph bar vi1_prec vi2_prec vi3_prec vi4_prec vi5_prec, ylabel(0(0.1)0.40, format(%9.2f)) over(group) b1title("Precipitation") name(bar3, replace) bargap(50) blabel(bar, format(%9.2f))
graph bar vi1_temp vi2_temp vi3_temp vi4_temp vi5_temp, ylabel(0(0.1)0.40, format(%9.2f)) over(group) b1title("Temperature") name(bar4, replace) bargap(50) blabel(bar, format(%9.2f))
graph bar vi1_conflict vi2_conflict vi3_conflict vi4_conflict vi5_conflict, ylabel(0(0.1)0.40, format(%9.2f)) over(group) b1title("Conflict") name(bar5, replace) bargap(50) blabel(bar, format(%9.2f))
graph bar vi1_prices vi2_prices vi3_prices vi4_prices vi5_prices, ylabel(0(0.1)0.40, format(%9.2f)) over(group) b1title("Prices") name(bar6, replace) bargap(50) blabel(bar, format(%9.2f))
graph bar vi1_gpp vi2_gpp vi3_gpp vi4_gpp vi5_gpp, ylabel(0(0.1)0.40, format(%9.2f)) over(group) b1title("GPP") name(bar7, replace) bargap(50) blabel(bar, format(%9.2f))

grc1leg bar1 bar2 bar3 bar4  bar5 bar6 , ycommon graphregion(color(white))  rows(3) legendfrom(bar1)

graph export "$GRAPHS\Average_MDI.tif", replace 

restore 

 merge 1:m time_cont_enc using "$OUTPUT\results_36", nogen
 
 	 sort  time_cont_enc ward_polygon_id
	 save "$OUTPUT\results_36", replace 
	 
	 