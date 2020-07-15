# COVID-19 reports

In this project I created a series of programs for Linux and MVS 3.8j TK4- to get daily COVID-19 data and generates reports.

## Dependencies

* A Linux machine with
  * Python 3.x
  * Perl
  * crontab
  * Internet conection
  * hercsub.pl Perl script to submit jobs to MVS Internal Card Reader
* MVS 3.8j TK4- with
  * Internal Card Reader socket configured (*000C 3505 localhost:3505 sockdev autopad trunc ascii eof*)
  * COBOL compiler
  * Data set LRECL=59 for the totals per country. In my system it's called *COVID19.DATA.TOTCNTRY*, but you can modify the *$EXECTOT* JCL and then call it differently.

## On Linux

In crontab, I have a daily job (*copyCOVID19data_toMVS.sh*) that runs every day at midnight and retrieves data from the [EU Open Data Portal](https://data.europa.eu/euodp/en/data/dataset/covid-19-coronavirus-data), using a Shell script and a Python program.

This script, has several steps:

* Calls Python program *getcovid19data.py*, which downloads the latest covid-19 data in CSV format, and converts it into a flat file (no commas) with the data we need for our MVS programs (i.e date, number of cases, number of deaths, country code and country name). Actually date is not used, so I'll remove it some day.
* Builds a JCL file that:
  * checks if the data set COVID19.DATA.DAILY exists (using *IDCAMS*) and if it does, deletes it (using *IEFBR14*).
  * allocates data set again and adds all the covid-19 formatted data (using *IEBGENER*).
* Submits the JCL to the MVS Internal Reader, using a Perl script (*hercsub.pl*) I found on Internet. The Perl script is mentioned in [Jay Moseley's website](http://www.jaymoseley.com/hercules/faq/mvsfaq04.htm#USER001), but I don't remember where I got it from.

## On MVS 3.8j TK4-

Using my *Poor Man's MVS Scheduler (PMMS)* (soon to be published here), I scheduled a JCL (*$EXECTOT*) that runs every day at 7am (just before I start my working day) and generates a report with the latest data received.

### COVID19.SRC.JCL($EXECTOT)

Is the JCL scheduled in PMMS. It executes TOTCNTRY and then REPCNTRY.

The SYSIN can contain a list of up to 5 country codes, that will be taken as favourite countries. This is because the report prints the top 10 countries by number of cases and the top 10 countries by number of deaths. Some countries you wish to monitor may not be in the top 10 (that's a good thing!), so you can still make the report to print data of those countries.

The format for SYSIN is:

* 3 characters (uppercase) country codes with no separation (e.g. DEUESPCAN for Germany, Spain, Canada)
* Maximum 5 values.

### COVID19.SRC.COBOL(TOTCNTRY)

Reads COVID19.DATA.DAILY and for each country, aggregates the total number of cases and deaths. Then the data is written into COVID19.DATA.TOTCNTRY.

### COVID19.SRC.COBOL(REPCNTRY)

Reads COVID19.DATA.TOTCNTRY and generates a report of:
* top 10 countries ordered by number of cases, showing total number of cases and deaths.
* top 10 countries ordered by number of deaths, showing total number of cases and deaths.
* up to 5 countries (favourites), showing total number of cases and deaths.

![Printout Example](https://github.com/asmCcoder/mainframeadventures/blob/master/printout.png "Printout Example")