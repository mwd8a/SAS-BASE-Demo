/*******************************************************************

SAS BASE Demonstration by Michael Williams
Please see README file for a description of this file.

********************************************************************/

/*********** Create the dataset STUDY from instream data ***********/
proc format ;
    value Sex 1='Female' 2='Male';
    value Race 1='Asian' 2='Black' 3='Caucasian' 4='Other';
run;

data study;
    infile datalines dsd missover firstobs=2;

    /*Input variables from datalines*/
    input Site	 :	$1. Pt	 :  	$2. Sex	 :	1. Race	 :	1. Dosedate :	mmddyy10.
		Height	 :	8. Weight	 :	8. Result1	 :	8. Result2	 :	8. Result3	 :	8.;

    /*Create labels for some of the input variables*/
    label Site='Study Site' Pt='Patient' Dosedate='Dose Date' 
        Doselot='Dose Lot' prot_amend='Protocol Amendment' 
        Limit='Lower Limit of Detection' site_name='Site Name';

    /*Create SITE_NAME variable*/
    length site_name $26;

    select;
        when (Site='J') site_name='Aurora Health Associates';
        when (Site='Q') site_name='Omaha Medical Center';
        when (Site='R') site_name='Sherwin Heights Healthcare';
        otherwise ;
    end;

    /*Create DOSELOT variable (depending on DOSEDATE)*/
    if '1jan1997'd le dosedate lt '1jan1998'd then
        Doselot='S0576';
    else if '1jan1998'd le dosedate le '10jan1998'd then
        Doselot='P1122';
    else if dosedate gt '10jan1998'd then
        Doselot='P0526';

    /*Create variables PROT_AMEND and LIMIT (depending on DOSELOT and SEX)*/
    if doselot='P0526' then
        do;
            prot_amend='B';

            if Sex=1 then
                Limit=0.03;

            if Sex=2 then
                Limit=0.02;
        end;
    else if doselot='S0576' or doselot='P1122' then
        do;
            prot_amend='A';
            Limit=0.02;
        end;

    /*Apply formats for SEX, RACE and DATE*/
    format Sex sex. 
			Race race.
			Dosedate date9.;
    datalines;
Site,Pt,Sex,Race,Dosedate,Height,Weight,Result1,Result2,Result3 
J,08,2,1,02/08/1998,74,280,1.9,4.3,6 
J,11,1, ,12/14/1997,66,169,3.5,3.3,5.2 
R,16,1,1,12/27/1997,70,233,1.6,1.6 
R,09,2,2,12/27/1997,74,387,4.4,1.5,2 
J,06,1,2,01/03/1998,64,210,4,4.2,4.4 
J,10,1,2,01/03/1998,68,258,10.3,9,5.2 
R,15,1,2, ,70,172,6.3 
J,07,2,3,01/10/1998,74,177,2.3,3.4,4.5 
J,09,2,3,01/11/1998,72,185,1.4,1.4,1.4 
J,12,2,3,01/17/1998,76,358,3.9,5,7.6 
R,08,2,3,01/24/1998,72,386,4,5.1 
R,10,2,3,02/21/1998,62,152,6 
J,14,1,3,01/04/1998,69,195,7.8,1.3,5.6 
R,24,1,3,02/07/1998,67,212,1.8,2.3,2.3 
J,13,1,4,01/31/1998,63,204,4.7,7.3,1
;

    /*********** Create the dataset DEMOG from instream data ***********/
    options yearcutoff=1916;

data demog;
    infile datalines dsd missover firstobs=2;
    input AGE DOB : date7. Pt : $2. Site : $1.;
    datalines;
Age,DOB,Pt,Site     
86,10JAN16,09,J
85,19FEB17,16,R
83,20FEB19,14,J
82,15MAR20,06,J
80,10FEB22,08,R
79,09JUN23,10,J
79,04JUL23,07,J
77,08MAR25,12,J
77,30MAY25,09,R
77,30NOV25,10,R
70,15MAY32,24,R
68,16JAN34,15,R
65,07FEB37,13,J
64,10MAY38,11,J
63,25DEC39,08,J
;

    /*********** Merge STUDY and DEMOG to create PAT_INFO along with new variables ***********/
    /*Sort the datasets STUDY and DEMOG (by SITE and PT), then merge the sorted datasets*/
proc sort data=study;
    by Site Pt;
run;

proc sort data=demog;
    by Site Pt;
run;

/*Create the dataset PAT_INFO*/
data PAT_INFO;
    merge study demog;
    by Site Pt;

    /*Create the variable PT_ID*/
    if not missing(Site) and not missing(Pt) then
        pt_id=cats(site, '-', pt);

    /*Create the variable DOSE_QTR*/
    if not Missing(dosedate) then
        dose_qtr=cats('Q', QTR(dosedate));

    /*Create the variable MEAN_RESULT*/
    mean_result=mean(of result1-result3);

    /*Create the variable BMI*/
    if nmiss(weight, height)=0 and height ne 0 then
        BMI=(weight/height**2)*703;

    /*Create the variable EST_END and label it as 'Estimated Termination Date'*/
    select(prot_amend);
        when ('A') est_end=120 + dosedate;
        when ('B') est_end=90 + dosedate;
        otherwise ;
    end;
    label est_end='Estimated Termination Date';
    format mean_result 8.2 BMI 8.1 est_end mmddyy10.;
run;

/*Create listing output (as specified in the assignment) using PROC PRINT*/
title1 "Listing of Baseline Patient Information";
title2 "for Patients Having Weight > 250";

proc print data=PAT_INFO double split='*';
    where weight gt 250;
    by site site_name;
    id site site_name;
    var pt sex race height weight dosedate doselot;
    label dosedate='Date of*First Dose' doselot='Dose Lot Number';
    format dosedate mmddyy.;
run;

title;

/*Create output stratified by Sex for Result1-Result3, Height and Weight. Also create an output data set that contains the median value of Weight stratified by Sex*/
title1 "Summary Statistics Stratified by Sex";
title2 "for Result1-Result3, Height and Weight";

proc means data=PAT_INFO n mean stderr min max maxdec=1 nway;
    class sex;
    var result1-result3 height weight;
    output out=weight_set(drop=_:) median(weight)=med_wt;
run;

title;

/*Sort the data sets PAT_INFO and WEIGHT_SET (by SEX) in order to merge them*/
proc sort data=PAT_INFO;
    by sex;
run;

proc sort data=weight_set;
    by sex;
run;

/*Creation of the dataset CATEGORY as a merge of PAT_INFO and WEIGHT_SET*/
proc format ;
    value wt_cat 1='<= Median Weight' 2='> Median Weight';
run;

data category;
    merge PAT_INFO weight_set;
    by sex;

    if . lt weight le med_wt then
        wt_cat=1;
    else if weight gt med_wt then
        wt_cat=2;
    label wt_cat='Median Weight Category';
    format wt_cat wt_cat.;
run;

/*Frequency distributions of DOSELOT and WT_CAT. Also create two-way table for RACE by WEIGHT*/
proc format ;
    value races 3='White' other='Other';
    value wt	.='Missing' low-<200='< 200' 200-<300='200 to <300' 
        300-high='>= 300';
run;

proc freq data=category;
    tables doselot med_wt;
    tables race * weight / missing;
    format race races.
		weight wt.;
run;

/*Generate summary statistics for HEIGHT stratified by WT_CAT, then identify the extreme values using the Site-Patient identifier variable*/
proc univariate data=category;
    class wt_cat;
    var height;
    id pt_id;
run;

/*Display missing values as blanks in the following summary and listing*/
options missing=' ';

/*Create a summary table using a single PROC REPORT*/
title "Summary of Mean Analyte Results by Weight Category and Sex";

proc report data=category nowd headline split='*';
    column wt_cat sex site_name, result1-result3;
    define site_name / across "Site" width=20 center;
    define sex / group "Sex";
    define result1 / analysis mean "Mean*Result1" width=12 format=3.2 right;
    define result2 / analysis mean "Mean*Result2" width=12 format=3.2 right;
    define result3 / analysis mean "Mean*Result3" width=12 format=3.2 right;
    define wt_cat / group "Weight Category" flow;
    break after wt_cat / skip;
run;

/*Create a listing using a single PROC REPORT*/
title "Listing of Baseline Patient Characteristics";

proc report data=category nowd split='*';
    column site pt_id dosedate sex race wt_cat bmi bmi_cat result1 result2 
        ab_change;
    define site / group noprint;
    define pt_id / order "Patient" width=7;
    define dosedate / "Dose Date" format=mmddyy10. center;
    define sex / display left;
    define race/ display left;
    define wt_cat / display "Weight Category";
    define bmi / display width=4;
    define bmi_cat / computed width=12 "BMI Categroy";
    define result1 / display "Analyte*Result 1" width=8 format=BEST3.1;
    define result2 / display "Analyte*Result 2" width=8 format=BEST3.1;
    define ab_change / computed "Absolute*Change" width=9 format=BEST3.1;
    compute bmi_cat / character length=10;

        if 0 le bmi lt 18.5 then
            bmi_cat='Underweight';
        else if 18.5 le bmi lt 25 then
            bmi_cat='Normal';
        else if 25 le bmi lt 30 then
            bmi_cat='Overweight';
        else if 30 le bmi then
            bmi_cat='Obese';
    endcomp;
    compute ab_change;
        ab_change=result2 - result1;
    endcomp;
    rbreak before / skip;
    break after site / skip;
run;