# My Personal Notes for MVS 3.8

This a collection of notes I'm gathering meanwhile I learn, and I need to re-visit from time to time. Maybe it's useful to somebody else, so here it is.

---

# Shutting down

## Automated

 At READY prompt:
  * Type *SHUTDOWN* and press ENTER.
  * Type *LOGOFF* and press ENTER.
  
The automated shutdown procedure will bring the system down and quit Hercules (which is equivalent to powering off the mainframe).

## Manual

From the Hercules console, the system can be stopped manually too, following the nest steps:

* */F BSPPILOT,SHUTNOW*
* Wait for message *+BSPPILOT - Shutdown sequence terminated*
* */$PJES2*
* */Z EOD*
* /QUIESCE
* QUIT

## JES2 is not going down

If during the Automated Shutting down the system seems to not do anything, type */$PJES2* in the Hercules console.

If after this, or after typing it during the Manual Shutting down this message appears *$HASP000 JES2 NOT DORMANT -- SYSTEM NOW DRAINING*. Follow next steps:

* */$DU*
* Find out which device is still in *DRAINING* status.
* Try to close it with */$C device_name* (e.g. /$C PRINTER1)
* and try again */$PJES2*

If this fails:
* */$PJES2,ABEND*
* A message will appear: *$HASP098 ENTER TERMINATION OPTION*
* Reply with *PURGE* (e.g. */R 01,PURGE*)

---

# System Administration

## Remove Session Time out

* Edit SYS1.PROCLIB(TSOLOGON)
* Add *TIME=14440* to the line *//IKJACCNT EXEC PGM=IKJEFT01,PARM=USRLOGON,DYNAMNBR=64*

## IMON as Operator Console
Not need for **hercules/unattended/set_console_mode**.

* Go to *3 IM*
* Go to *O - OS CONSOLE*
* Screen goes blank.
* Press *T*
* Press *R* to freeze/unfreeze updates in the field *\*\<R\>*

## Clear log files

### ERP (Error Recovery Program) 

* */s clearerp*

### SMF (System Management Facility)
* */s clearsmf,man=x*
* */s clearsmf,man=y*

If any gives an error *IFA006A*, need to switch (*/switch smf*), clean and switch again:

## Increase JES2 spool space
* Check current percent spool utilization: */$dn*
* Create a DASD
  * Check which addresses are available (OFFLINE): */d u,dasd,,240,8*
  * *dasdinit -z -a HASP01.244 3350 HASP01*
* Attach new DASD to Hercules: *attach 244 3350 dasd/hasp01.244*
* Initialise DASD by SUBmitting corresponding JCL (e.g. [HER01.TOOLBOX(INITDASD)](https://github.com/asmCcoder/mainframeadventures/blob/master/MVStoolbox/src/VOL2TAPE))
* Put ONLINE the new DASD: */vary 244,online*
* Mount the new DASD: */mount 244,vol=(sl,hasp01),use=private*
* Allocate dataset, by SUBmitting:
```
							//ALLOCDS   JOB ,'ALLOCATE DATASET',CLASS=A,MSGCLASS=H
							//STEP1   EXEC PGM=IEFBR14
							//HASP01    DD DISP=(NEW,KEEP),
							//             DSN=SYS1.HASPACE,
							//             UNIT=3350,VOL=SER=HASP01,
							//             SPACE=(ABSTR,(16605,41))
							//
```
* Make DASD visible at IPL:
  * Add to *SYS1.PARMLIB(VATLST00)*: 
			*HASP01,1,2,3350    ,N                  MVS 3.8 JES Spool Disk 2*
* Shutdown
* Add line to *conf/tk4-.cnf*: *0244 3350 dasd/hasp01.244*
* IPL and re-check current percent spool utilization: */$dn*

## Remove BSPFCOOK (The Fortune Cookie Program)

Edit SYS1.CMDPROC(USRLOGON) and leave it like this:

```
000001         PROC 0                                                  
000002 CONTROL NOMSG,NOLIST,NOSYMLIST,NOCONLIST,NOFLUSH                
000003 FREE FILE(SYSHELP)                                              
000004 ALLOC FILE(SYSHELP) DSN('SYS1.HELP','SYS2.HELP') SHR            
000005 ALLOC FILE(X1) DSN('&SYSUID..CMDPROC(STDLOGON)') SHR            
000006 IF &LASTCC = 0 THEN +                                           
000007    DO                                                           
000008       FREE FILE(SYSPROC)                                        
000009       FREE FILE(X1)                                             
000010       ALLOC FILE(SYSPROC) +                                     
000011        DSN('&SYSUID..CMDPROC','SYS1.CMDPROC','SYS2.CMDPROC') SHR
000012    END                                                          
000013 ELSE +                                                          
000014    DO                                                           
000015       FREE FILE(X1)                                             
000016    END                                                          
000017 %STDLOGON                                                       
000018 %REVINIT                                                        
000019 TERMTYPE                                                        
000020 SET SZ = &LASTCC                                                
000021 IF &SZ NE 0 THEN -                                              
000022   DO                         
000023     WRITENR ***              
000024     READ BLABLA              
000025     CLS                      
000026     TSOAPPLS                 
000027   END                        
000028 ELSE -                       
000029   DO                         
000030     TERMINAL LINESIZE(100)   
000031     %TTYINTRO                
000032   END                        
000033 EXIT
```

---

# Technical

## DASD architecture

* [2314](https://www.ibm.com/ibm/history/exhibits/storage/storage_2314.html)
* [3330](https://www.ibm.com/ibm/history/exhibits/storage/storage_3330.html)
* [3340](https://www.ibm.com/ibm/history/exhibits/storage/storage_3340.html)
* [3350](https://www.ibm.com/ibm/history/exhibits/storage/storage_3350.html)
  * Bytes per track: 19,069
  * Tracks per logical cylinder: 30
  * Bytes per cylinder = 19,069 x 30 = 572,070‬
  * Logical cylinders per drive: 555
  * Capacity per drive 572,070‬ x 555 = 317,498,850 bytes (~317 MB)
* [3375](https://www.ibm.com/ibm/history/exhibits/storage/storage_3370.html)
* [3380](https://www.ibm.com/ibm/history/exhibits/storage/storage_3380.html)
* [3390](https://www.ibm.com/ibm/history/exhibits/storage/storage_3390.html)