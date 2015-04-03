SAS Program Description
=======================

## Introduction

The accompanying SAS code was created for an assignment in an introductory SAS programming class. Running the code will produce the SAS datasets, lists, and reports. The creation of the datasets are explained below.
 	

## The Dataset STUDY

The first data set to be created is STUDY. We input the raw data below.

> 
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

The data correspond to the following variables and descriptions.

* **Site** for *Study Site*
* **Pt** for *Patient*
* **Sex** for *Patient Sex*
* **Race** for *Patient Race*
* **Dosedate** for *Dose Date*
* **Height** for *Patient Height*
* **Weight** for *Patient Weight*
* **Result1** for *Lab Result #1*
* **Result2** for *Lab Result #2*
* **Result3** for *Lab Result #3*

In the SAS code, a PROC FORMAT step will give labels to the SEX and RACE values.  A DATA STEP will create the STUDY dataset by reading-in the raw data as well as create new variables based on the raw data. The new variables in STUDY are described below.
 
* **Site_Name** for *Study Site Name*
* **Doselot** for *Dose Group Number*
* **Prot_Amend** for *Protocol Amendment*
* **Limit** for *Lower Limit of Detection*

## The Dataset DEMOG

Another dataset called DEMOG will be created from the raw data below.

> 
Age,DOB,Pt,Site  
86,10JAN16,09,J  
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

The data correspond to the following variables and descriptions.

* **Age** for *Patient Age*
* **DOB** for *Patient Date of Birth*
* **Pt** for *Patient* 
* **Site** for *Study Site*

## The Dataset PAT\_INFO

The datasets STUDY and DEMOG have common variables Site and Pt. These two datasets will be merged (by Site and Pt variables) into a dataset PAT\_INFO. A DATA step will be used for the merge, and new variables will be added to PAT\_INFO. 

The dataset PAT\_INFO will include all variables from STUDY and DEMOG along with new variables described below.

* **Pt\_ID** for *Patient Identification*
* **Dose\_QTR** for *Dose Quarter*
* **Mean\_Result** for *Mean of Results1, Results2, Results3*
* **BMI** for *Body Mass Index*
* **Est\_End** for *Estimated Termination Date*  

## The Datasets WT\_SET and CATEGORY

A new dataset WEIGHT\_SET is created, via a PROC MEANS step, to compute and store median weight by Sex. 

Each weight value will be compared to median weight to define a weight category (either ‘<=median weight’ or ‘> median weight’).  In order to do this, we will merge the datasets PAT\_INFO and WEIGHT\_SET by Sex, and then define the variable Wt\_Cat in the same DATA step. The new dataset is called CATEGORY. 
