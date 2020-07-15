# Poor Man's MVS Scheduler (PMMS)

A scheduler for [MVS 3.8j Tur(n)key 4-](http://wotho.ethz.ch/tk4-/).

Current version V1R1M0

## Table of Contents

* [**Description**](##Description)
* [**Remarks**](##Remarks)
* [**Components**](##Components)
  * [**Programs**](##Programs)
  * [**Data Sets**](##Data-Sets)
* [**Installation and Execution**](##Installation-and-Execution)
* [**Changelog**](##Changelog)
* [**Frequently Asked Questions (FAQs)**](##Frequently-Asked-Questions-(FAQs))

## Description

PMMS main program (PMMSSCHD) is an infinite loop (using an ASM program i found in *[Xephon magazine](http://www.cbttape.org/xephon/) MVS #182 November 2001* to suspend the execution for a number of minutes), that reads from a sequential file and for each line determines if a task should be submitted, depending on date, time and/or weekday.

If a task is submitted, an entry is saved in a sequential file. If an error is found, the first column in this file will be E, for error. Error here means that PMMSSCHD could not submit the job, not that the job ended in error. Currently PMMS is not able to read RC from submitted jobs.

## Remarks

1. **IMPORTANT**: Please read and be sure you understand the included LICENSE file before using this software. Run it on your own risk.

2. Currently, between loops the program is suspended for 10 minutes (though this can be changed). Therefore, the time scheduled is not necessarily always the exact time when the task will be submitted. For example, if the last loop run at 19:10 and is now in sleep until 19:20 and you have a task scheduled at 19:15, it will not run until 19:20.

3. I'm not sure of the license under which programs published in Xephon magazine are, so to avoid any issues I won't provide the source for SLEEP. You can find the original source code in pages 31 and 32 of the [Xephon magazine MVS #182 November 2001](http://www.cbttape.org/xephon/xephonm/mvs0111.pdf) (which has a very similar scheduler to this one, but written in REXX), and assemble it with *ASMFCL*.

## Components

### Programs

#### JCL

* **$EXECSCH**: Submits PMMSSCHD.
* **$EXECRP1**: Submits PMMSSREP.
* **$EXECRP2**: Submits PMMSTREP.
* **DUMMYJCL**: Used for testing purposes. It just executes IEFBR14.

#### COBOL

* **PMMSSCHD**: Main program running in infinite loop.
* **PMMSSREP**: Generates a printed report of all submitted commands. It takes information from PMMS.DATA.REPORT.
* **PMMSTREP**: Generates a printed report of all entries in PMMS.DATA.TASKLIST.

### Data Sets

#### PMMS.DATA.TASKLIST

Allocate a sequential file with LRECL=80.

Contains all the tasks to be submitted.

* Column 1: Blank should be the normal value. Any other letter in this column will prevent it from be submitted. I personally use an asterisk to indicate a comment line.
* Columns 2 to 8 (MTWTFSS): Day of the week (from Monday to Sunday) to be submitted, marked with an X.
* Columns 9 to 12 (HHMM): Hour and minutes (24 hour format) to be submitted. This field is mandatory.
* Columns 13 to 14 (DD): Day of the month (1 to 31) to be submitted.
* Columns 15 to 16 (MM): Month of the year (1 to 12) to be submitted.
* Columns 17 to 22 (CMMAND): Command to be executed. This field is mandatory.
  * if it is SUBMIT, it will try to submit whatever JCL is specified in COMMANDPARM.
  * if it is CONFIG, the Scheduler configuration can be changed by specifying some options.
* Columns 23 to 80 (COMMANDPARM): Parameters for CMMAND. This field is mandatory.
  * For CMMAND=SUBMIT, specify DSN of the JCL to be submitted.
  * For CMMAND=CONFIG, specify:
    * Columns 23 to 32:
      * STOP: will stop the infinite loop and PMMSSCHD will end with RC=0.
      * INTERVAL re-defines the number of seconds the program sleeps between loops. Default is 600 (10 minutes).
    * Columns 33 to 36:
      * STOP: blank.
      * INTERVAL: Four digits to specify the number of minutes to wait (sleep) between loops. 166 minutes is the maximum. Use always 4 digits, with leading zeros.

##### Examples

```text
     ----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
     *MTWTFSSHHMMDDMMCMMANDSUBCOMMANDPARM------------------------------------------->
1            20151201SUBMITPMMS.SRC.JCL(DUMMYJCL)
2     XXXXXXX0230    SUBMITPMMS.SRC.JCL(DUMMYJCL)
3    *XXXXXXX0130    SUBMITPMMS.SRC.JCL(DUMMYJCL)
4           X000028  SUBMITPMMS.SRC.JCL(DUMMYJCL)
6     XXXXXXX1530  10SUBMITPMMS.SRC.JCL(DUMMYJCL)
7     XXXXXXX        SUBMITPMMS.SRC.JCL(DUMMYJCL)
8           X000028  
9     XXXXXX 0800    CONFIGINTERVAL  0120
10    XXXXX  2000    CONFIGINTERVAL  0010
11           18003112CONFIGSTOP
```

* 1st line is a comment.
* 1st command: DUMMYJCL will be submitted every 12th of January at 8.15pm.
* 2nd command: DUMMYJCL will be submitted everyday at 2.30am.
* 3rd command: won't be submitted, because it's commented.
* 5th command: DUMMYJCL will be submitted on the every Sunday 28th at midnight.
* 6th command: DUMMYJCL will be submitted everyday during October at 3.30pm.
* 7th command: is wrong. It doesn't have a specific time.
* 8th command: is wrong. It doesn't have a command to execute.
* The next two commands are very typical for production environments. We want to increase the number of submitted tasks during the night, when nobody is working, so we also adjust the sleep to be lower. And then set it back to 2 hours sleep at 8am.:
  * 9th command: will change, the interval between loops to 2 hours (120 minutes) every day of the week except on Sundays, at 8am.
  * 10th command: will change, the interval between loops to 10 minutes every day of the week except on weekends, at 8pm.
* 11th command: will stop PMMSSCHD on 31st December at 6pm.

#### PMMS.DATA.REPORT

Allocate a sequential file with LRECL=80.

It will be filled automatically by *PMMSSCHD*, with a list of all tasks submitted.

* Column 1: Execution result. Not the RC from the submitted job, but what was the result of PMMSCHED trying to execute the scheduled command.
  * EMPTY = Submitted.
  * E = Error. Couldn't submit the job.
* Column 2 to 5: Scheduled date (DDMM).
* Column 6 to 9: Scheduled time (HHMM).
* Column 10 to 17: Submitted date (YYYYMMDD).
* Column 18 to 23: Submitted time (HHMMSS).
* Column 24 to 29: Submitted command.
* Column 30 to 80: Parameters for submitted command.

##### Examples

```test
----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
 DDMMHHMMDDMMYYHHMMSSCMMANDCOMMANDPARM----------------------------------------->
 12012015120120101642SUBMITPMMS.SRC.JCL(DUMMYJCL)
E        120120102642SUBMITPMMS.SRC.JCL(DUMMYJCL)
 1000150720100910CONFIGINTERVAL  0010
```

## Installation and Execution

* Allocate sequential file PMMS.DATA.TASKLIST with LRECL=80.
* Allocate sequential file PMMS.DATA.REPORT with LRECL=80.
* Compile all COBOL programs.
* Assemble *SLEEP*. Source code found in pages 31 and 32 of the [Xephon magazine MVS #182 November 2001](http://www.cbttape.org/xephon/xephonm/mvs0111.pdf).
* Enter some data in PMMS.DATA.TASKLIST
* SUBmit $EXECSCH.

## Changelog

### V1R1M0

* First release.

## Frequently Asked Questions (FAQs)

* **Any future improvements planned?**
  * Avoid opening, closing and reading the whole TASKLIST file after each SLEEP loop.
    * Proposed solution:
      * Read entire PMMS.DATA.TASKLIST and store in memory all tasks for today and tomorrow.
      * After each SLEEP
        * Only use the lines in memory.
        * IF current date changed THEN read and store in memory tasks for today and tomorrow.
  * Store day of the week in REPORT.
    * Consequently, change PMMSSREP to print "Runs every" + weekday
  * Some kind of UI (with KICKS or BREXX) to maintain the TASKLIST.
* **How do you use this Scheduler?**
  * I use it for different tasks:
    * **Backups**: I have a cron job on my Linux host that creates tapes (with HETINIT) for each day (e.g. 200612.HET). In PMMSSCHD's TASKLIST I have scheduled a JCL that submits a COBOL program that gets the CURRENT-DATE and submits to the card internal reader a JCL, which uses HERCCMD to execute Hercules command DEVINIT to mount the tape, and then IEHDASDR to backup my entire development DASD to tape. Hercules unmounts the tape automatically when the backup job is finished, so the tape device is available for next tape.
    * **Clean up JES2 Spool**: I can't be bothered to purge manually the printouts of the numerous compilations I do daily on my development environment. So I scheduled a JCL that uses HERCCMD to execute /$PJ at 4am, which is usually a time when I'm not coding. The printouts that I'm interested to keep I already converted to PDF with my [mvssplitspl](https://github.com/asmCcoder/mvssplitspl) tool.
    * **Report generation**: In addition to PMMS reports, I have a few programs I wrote for personal projects (e.g. personal finances, weather station, covid-19 reports), and I use COBOL reports for data generated by those projects.
