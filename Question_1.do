*clear all
*************************************************************;
cd "C:\my literature\glasgow\job\GTA\Sisir\lab5"

* Question 1
log using Lab5.log, replace

*************************************************************;

* Import Quarterly Data from Excel file 
* first row considered as variable names

import excel "us_macro_quarterly.xlsx", sheet("Data") firstrow clear

describe
summarize


* This data is from FRED
* https://fred.stlouisfed.org/series/PCEPI#0

* import data directly from FRED using "import fred" or "import" from menus. You need to have API key at first.
* https://research.stlouisfed.org/docs/api/api_key.html

* or using freduse utility 
* ssc install freduse
* freduse PCEPI

**************************************************************
*formatting date

 *STATA stores the time index as an integer series. It uses the convention that the first quarter of 1960 is 0, the second quarter of 1960 is 1, the first quarter of 1961 is 4, etc. Dates before 1960 are negative integers, so that the fourth quarter of 1959 is -1, the third is -2, etc.
 
 
* create stata understandable date variable recursively starting from 1955q1
gen date = tq(1955q1) + _n-1

* express it in quarterly format 
format %tq date


* Alternatively 
*gen qdate = qofd(freq)
*format %tq  qdate 

* for monthly, weekly, and daily data we have %tm , %tw, %td operators.


* For more details on date and time in Stata, read Chapter 24,  Stata User's Guide

* tsmktim is an utility for easily working with dates and times in Stata. It must be installed.
* tsmktim time, start(1955q1) 
* tsset time 

***************************************************************
* setting up the time series data

tsset date

*tsset qdate, quarterly

***************************************************************

* Ques 1 (a.i)
gen logpce = log(PCECTPI)


* using stata's first difference operator
gen infl = 400*D.logpce

* alternatively 
* gen infl = 400*(logpce[_n] - logpce[_n-1])
*di logpce[5] 

***************************************************************
*line plot

* Ques 1 (a.ii)


* Plot for defined time range
tsline infl if tin(1963q1, 2017q4), title(" U.S. Inflation Rate (%)") 

* add trending line using locally weighted scatterplot smoothing (LOWESS) technique
*tsline infl if tin(1963q1, 2017q4), title(" U.S. Inflation Rate (%)") || lowess infl date



*gen infl2 = D.logpce
*tsline infl2 if tin(1963q1, 2017q4), title(" U.S. Inflation Rate (%)")


* or alternatively from menus
*twoway (tsline infl if twithin(1963:Q1, 2017:Q4))



* an upward trend during 1970s and early-1980s reaching the all-time high of 15.05% in 1981:Q2, and a downward trend * after that approaching the zero lower bond (ZLB) in recent years

* Interest rate reached all-time high of 15.05% in 1981:Q2

*from July 1981-November 1982 is identified as a recession period which is characterized by the largest decline of employment and output in the post-World War II period 

***************************************************************

* Ques 1 (b.i)
* Create Delta Infl as first difference of inflation rate
gen deltainfl = D.infl


* autocorrelation
corrgram deltainfl if tin(1963q1, 2017q4), lags(4)
*corrgram deltainfl if tin(1963q1,2017q4)


* plot of autocorrelations with 95% confidence bands (optional)
ac deltainfl if tin(1963q1,2017q4), lags(4)
*ac deltainfl if tin(1963q1,2017q4)
*pac deltainfl if tin(1963q1,2017q4)

***************************************************************
* Ques 1 (b.ii)

* plot of inflation change
tsline deltainfl if tin(1963q1,2017q4), title(" Change in U.S. Inflation ")

*******************************************************************

* Ques 1 (c.i)
* ar(1) regression - OLS estimates
* L. takes the lag
regress deltainfl L.deltainfl if tin(1963q1,2017q4), r


*******************************************************************

* Ques 1 (c.ii)

* AR(2) regression
regress deltainfl L.deltainfl L2.deltainfl if tin(1963q1,2017q4), r


*******************************************************************
* Ques 1 (c.iii)

*  to forecast a date out-of-sample, these dates need to be in the data set. This requires expanding the dataset to include these dates. This is done by the tsappend command. 

* Forecasting 1 period ahead deltainflation. First, add the extra period (next quarter)
tsappend, add(1)
*this command creates a new row at the end of dataset with missing values on other vars.

* estimate ar(2)
regress deltainfl L.deltainfl L2.deltainfl if tin(1963q1, 2017q4), r

* predict for next quarter
predict deltainflhat


* alternatively to obtain only out-of-sample prediction
*predict yhat if date>tq(2017q4)

list deltainflhat if tin(2017q4, 2018q1)
* the last observation is the predicted inflation change



********************************************************************

* Ques 1 (d.i)

* null hypothesis is non-stationarity (unit root) and the alternative is stationarity of the time series.

* augmented dicky fuller on Infl
dfuller infl if tin(1963q1, 2017q4), lags(2) regress

* augmented dicky fuller on Infl with a deterministic trend
dfuller infl if tin(1963q1, 2017q4), lags(2) trend regress

* regress option to produce the regression results
* trend option to include the linear trend in AR(p) regression

*************************************************************;
log close
clear
