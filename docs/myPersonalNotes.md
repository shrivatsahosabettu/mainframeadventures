# My Personal Notes for MVS 3.8

This a collection of notes I'm gathering meanwhile I learn, and I need to re-visit from time to time. Maybe it's useful to somebody else, so here it is.

## Table of Contents

* [System Start (IPL)](#system-start-ipl)
  * [Automatic IPL](#automatic-ipl)
  * [Manual IPL](#manual-ipl)
* [Default Users/Passwords](#default-userspasswords)
* [Shutting down](#shutting-down)
  * [Automated](#automated)
  * [Manual](#manual)
  * [JES2 is not going down](#jes2-is-not-going-down)
* [Data sets](#data-sets)
  * [Data set Types](#data-set-types)
  * [Data set Record Formats](#data-set-record-formats)
* [Tape Backups](#tape-backups)
  * [Backup/Restore a PDS](#backuprestore-a-pds)
    * [Backup PDS to tape](#backup-pds-to-tape)
    * [Restore PDS from tape](#restore-pds-from-tape)
  * [Backup/Restore an entire VOLUME](#backuprestore-an-entire-volume)
    * [Backup VOLUME to tape](#backup-volume-to-tape)
    * [Restore VOLUME from tape](#restore-volume-from-tape)
* [JCL](#jcl)
  * [The MSGLEVEL Parameter](#the-msglevel-parameter)
* [COBOL](#cobol)
  * [Level Number](#level-number)
* [KICKS](#kicks)
* [System Administration](#system-administration)
  * [OS/VS2 MVS Utilities](#osvs2-mvs-utilities)
  * [Remove Session Time out](#remove-session-time-out)
  * [Enable 3270 Console](#enable-3270-console)
  * [IMON as Operator Console](#imon-as-operator-console)
  * [Clear log files](#clear-log-files)
    * [ERP (Error Recovery Program)](#erp-error-recovery-program)
    * [SMF (System Management Facility)](#smf-system-management-facility)
  * [Increase JES2 spool space](#increase-jes2-spool-space)
  * [Repair JES2 after $HASP050 JES RESOURCE SHORTAGE](#repair-jes2-after-hasp050-jes-resource-shortage)
  * [Remove BSPFCOOK (The Fortune Cookie Program)](#remove-bspfcook-the-fortune-cookie-program)
  * [Services](#services)
    * [MF/1](#mf1)
    * [FTP Server](#ftp-server)
    * [HTTP Server](#http-server)
* [Technical](#technical)
  * [DASD architecture](#dasd-architecture)
  * [Printers](#printers)

---

## System Start (IPL)

### Automatic IPL

> ./mvs

### Manual IPL

> hercules -f conf/tk4-.cnf

in the operator console, type

> ipl 148

and reply with

> /r 00,cmd=xx

to the message *IEA101A SPECIFY SYSTEM PARAMETERS FOR RELEASE 03.8 .VS2*

where *xx* is one of the following values:

|value|description|
|-----|:----------|
|00|Normal IPL. Everything started|
|01|???|
|02|minimal system. No start for MF1, JRP, SNASOL|
|03|all steps must be done manually|

---

## Default Users/Passwords

|Username|Password|Details|
|:--------|:--------|:---------|
|HERC01|CUL8TR|Fully authorized user|
|HERC02|CUL8TR|Fully authorized user|
|HERC03|PASS4U|Regular user|
|HERC04|PASS4U|Regular user|
|IBMUSER|IBMPASS|Fully authorized user without access to the RAKF users and profiles tables. This account is meant to be used for recovery  purposes only.|

## Shutting down

### Automated

 At READY prompt:

> * SHUTDOWN
> * LOGOFF

The automated shutdown procedure will bring the system down and quit Hercules (which is equivalent to powering off the mainframe).

### Manual

From the Hercules console, the system can be stopped manually too, following the nest steps:

> /F BSPPILOT,SHUTNOW

Wait for message *+BSPPILOT - Shutdown sequence terminated*

> * /$PJES2
> * /Z EOD
> * /QUIESCE
> * QUIT

### JES2 is not going down

If during the Automated Shutting down the system seems to not do anything, type in the Hercules console:

> /$PJES2

If after this, or after typing it during the Manual Shutting down this message appears *$HASP000 JES2 NOT DORMANT -- SYSTEM NOW DRAINING*. Follow next steps:

> /$DU

Find out which device is still in *DRAINING* status.

Try to close it

> /$C device_name

and try again

> /$PJES2

If this fails:

> /$PJES2,ABEND

 A message will appear: *$HASP098 ENTER TERMINATION OPTION*

Reply with

> /R 01,PURGE

---

## Data sets

### Data set Types

* **Sequential (PS)**: records are data items stored consecutively. Hence, to read a record, all previous records must be read. New records are added at the end.
  * To allocate: use RFE option 3.2 or [MVStoolbox's ALLOPS JCL](https://github.com/asmCcoder/mainframeadventures/blob/master/MVStoolbox/src/ALLOPS)
* **Partitioned (PDS)**: Often called libraries. Consist of a directory and members. The directory holds the address of each member. Each member consist of sequentially stored records. To reuse the space left by a deleted member, the library must be compressed manually.
  * To allocate: use RFE option 3.2 or [MVStoolbox's ALLOPDS JCL](https://github.com/asmCcoder/mainframeadventures/blob/master/MVStoolbox/src/ALLOPDS)
* **Partitioned Extended (PDSE)**: Space is reclaimed automatically when a member is deleted. Flexible size. Can be shared. Faster directory searches. Cannot no be used for PROCLIB or libraries that are part of the IPL.
* **Virtual Storage Access Method (VSAM)**: http://www.jaymoseley.com/hercules/vs_tutor/vstutor.htm
  * **Key Sequenced Data Set (KSDS)**: each record is identified for <u>access by specifying its key value</u>. Records may be accessed sequentially, in order by key value, or directly, by supplying the key value. KSDS datasets are similar to Indexed Sequential Access Method (ISAM). Records may be added or deleted at any point.
  * **Entry Sequence Data Set (ESDS)**: each record is identified for <u>access by specifying its physical location (Relative Byte Address [RBA])</u>.  Records may be accessed sequentially, in order by RBA value, or directly, by supplying the RBA of the desired record. ESDS datasets are similar to Basic Sequential Access Method (BSAM) or Queued Sequential Access Method (QSAM) datasets. Records cannot be deleted, and they can only be appended (added to the end of the dataset).
  * **Relative Record Data Set (RRDS)**: each record is identified for <u>access by specifying its record number</u>. Records may be accessed sequentially, in relative record number order, or directly, by supplying the relative record number of the desired record. RRDS datasets are similar to Basic Direct Access Method (BDAM) datasets. Records may be added into an empty record or deleted, leaving an empty record.
  * **Linear Data Set (LDS)**
* **Generation Data Group (GDG)**: catalogues successive updates of related data. Allows to keep the historical data of n updates.

**Permanent**: exists before a job starts and persist after job completes.

**Temporary**: Used to pass data from one job step to another. Exist only during the life cycle of the job.

### Data set Record Formats

* **Fixed records (F)**: all records have the same length. One record is send for each I/O operation. Not really used.
* **Fixed Blocked records (FB)**:  all records have the same length. Several records are send for each I/O operation.
* **Variable records (V)**: each record can have a different length. Several records are send for each I/O operation.
* **Variable Blocked records (VB)**: each record can have a different length. Several records are send for each I/O operation.
* **Undefined records (U)**: undefined structure. Used for libraries that contain compiled modules (programs).

---

## Tape Backups

### Backup/Restore a PDS

#### Backup PDS to tape

Create tape in Linux:

> hetinit TAPE01.het HERC01

SUBmit:

```jcl
//TAPETO JOB (01),'COPY TO TAPE',CLASS=A,MSGCLASS=H
//COPY   EXEC PGM=IEBCOPY,REGION=720K
//SYSPRINT DD SYSOUT=*
//PDS      DD DSN=SYS2.JCLLIB,DISP=SHR
//TAPE     DD UNIT=TAPE,DISP=NEW,DSN=SYS2.JCLLIB,
//            VOL=SER=TAPE01,LABEL=(,SL)
//SYSUT3   DD UNIT=SYSDA,SPACE=(80,(60,45)),DISP=(NEW,DELETE)
//SYSIN    DD *
  COPY INDD=PDS,OUTDD=TAPE
/*
//
```

In Hercules console will appear a message *\*IEF233A M 480,TAPE01,,HERC01F,COPY*, reply with

> devinit 480 tapes/TAPE01.aws

#### Restore PDS from tape

Create destination PDS in MVS at 3.2 with same configuration as original

SUBmit:

```jcl
//TAPEFROM JOB (01),'RESTORE FROM TAPE',CLASS=A,MSGCLASS=H
//COPY    EXEC PGM=IEBCOPY,REGION=720K
//SYSPRINT  DD SYSOUT=*
//PDS       DD DSN=HERC01.TAPE.JCLLIB,DISP=SHR
//TAPE      DD UNIT=TAPE,DISP=NEW,DSN=SYS2.JCLLIB,
//             VOL=SER=TAPE01,LABEL=(,SL)
//SYSUT3    DD UNIT=SYSDA,SPACE=(80,(60,45)),DISP=(NEW,DELETE)
//SYSIN     DD *
  COPY INDD=TAPE,OUTDD=PDS
/*
//
```

In Hercules console will appear a message *\*IEF233A M 480,TAPE01,,HERC01F,COPY*, reply with

>devinit 480 tapes/TAPE01.het

### Backup/Restore an entire VOLUME

#### Backup VOLUME to tape

Create tape in Linux:

>hetinit TAPE01.het TAPE01 HERC01

Load tape in Hercules console

> devinit 0480 tapes/TAPE01.het

SUBmit:

```jcl
//VOL2TAPE JOB CLASS=A,MSGLEVEL=(1,1),MSGCLASS=A
//IEHDASDR EXEC PGM=IEHDASDR,REGION=4096K
//SYSPRINT DD  SYSOUT=A
//DASD     DD  UNIT=3350,VOL=SER=MVSRES,DISP=OLD
//TAPE     DD DSN=DASTA.DUMP,UNIT=TAPE,DISP=(,KEEP),
//         VOL=SER=200604,DCB=(LRECL=0,BLKSIZE=32480,RECFM=U)
//SYSIN    DD  *
  DUMP FROMDD=DASD,TODD=TAPE
/*
//
```

### Restore VOLUME from tape

Load tape in Hercules console:

> devinit 0480 tapes/TAPE01.het

SUBmit:

```jcl
//TAPE2VOL JOB CLASS=A,MSGLEVEL=(1,1),MSGCLASS=A
//IEHDASDR EXEC PGM=IEHDASDR,REGION=4096K
//SYSPRINT DD  SYSOUT=A
//DASD     DD  UNIT=3350,VOL=SER=WORK00,DISP=OLD
//TAPE     DD DSN=DASTA.DUMP,UNIT=TAPE,DISP=(,KEEP),
//         VOL=SER=200604,DCB=(LRECL=0,BLKSIZE=32480,RECFM=U)
//SYSIN    DD  *
  RESTORE FROMDD=TAPE,TODD=DASD
/*
//
```
---

## JCL

### The MSGLEVEL Parameter

> MSGLEVEL=( [statements] [,messages] )

* statements
  * 0 = only the JOB statement is to be written.
  * 1 = all input job control statements, cataloged procedure statements, and the internal
representation of procedure statement parameters after symbolic parameter substitution
are to be written.
  * 2 = only input job control statements are to be written.
* messages
  * 0 = no allocation/ termination messages are to be written, unless the job terminates
abnormally.
  * 1 = allocation/ termination messages are to be written.

---

## COBOL

### Level Number

|Level|Description|
|:-:|:-|
|01|Record description entry|
|02-49|Group and Elementary items
|66|Rename Clause items|
|77|Items which cannot be sub-divided|
|88|Condition name entry|

---

## KICKS

At READY prompt:

* Start: *EXEC KICKSSYS.V1R5M0.CLIST(KICKS)*
* Start easier:
  * Copy *HERC01.KICKSSYS.V1R5M0.CLIST(KICKS)* to *SYS1.CMDPROC(KICKS)*
  * then you can start by just typing *KICKS*
* Stop: *KSSF*

---

## System Administration

### OS/VS2 MVS Utilities

This utilities are explained in depth in GC26-3902-1

* **System utilities**
  * **IEHATLAS**: to assign alternate tracks and recover usable data records when defective tracks are indicated.
  * **IEHDASDR**: to initialize and label direct access volumes, to assign alternate tracks when defective tracks are indicated, or to dump or restore data.
  * **IEHINITT**: to write standard labels on tape volumes.
  * **IEHLIST**: to list system control data.
  * **IEHMOVE**: to move or copy collections of data.
  * **IEHPROGM**: to build and maintain system control data.
  * **IFHSTATR**: to select, format, and write information about tape errors from the IFASMFDP tape or the SYS1.MAN data set.
* **Data Set utilities**
  * **IEBCOMPR**: to compare records in sequential or partitioned data sets.
  * **IEBCOPY**: to copy, compress, or merge partitioned data sets, to select or exclude specified members in a copy operation, and to rename and/or replace selected members of partitioned data sets.
  * **IEBDG**: to create a test data set consisting of patterned data.
  * **IEBEDIT**: to selectively copy job steps and their associated JOB statements.
  * **IEBGENER**: to copy records from a sequential data set or to convert a data set from sequential organization to partitioned organization.
  * **IEBISAM**: to place source data from an indexed sequential data set into a sequential data set in a format suitable for subsequent reconstruction.
  * **IEBPTPCH**: to print or punch records that reside in a sequential or partitioned data set.
  * **IEBTCRIN**: to construct records from the input data stream that have been read from the IBM 2495 Tape Cartridge Reader.
  * **IEBUPDTE**: to incorporate changes to sequential or partitioned data sets.
* **Independet utilities**
  * **IBCDASDI**: to initialize a direct access volume and to assign alternate tracks.
  * **IBCDMPRS**: to dump and restore the data contents of a direct access volume.
  * **ICAPRTBL**: to load the forms control and Universal Character Set buffers of a 3211 after an unsuccessful attempt to IPL, with the 3211 printer assigned as the output portion of a composite console.

### Remove Session Time out

* Edit SYS1.PROCLIB(TSOLOGON)
* Add *TIME=1440* to the line *//IKJACCNT...*
  * Before: *//IKJACCNT EXEC PGM=IKJEFT01,PARM=USRLOGON,DYNAMNBR=64*
  * After: *//IKJACCNT EXEC PGM=IKJEFT01,PARM=USRLOGON,DYNAMNBR=64,TIME=1440*

### Enable 3270 Console

> /attach 010 3270 CONS

Connect a 3270 emulator. Use *CONS* for the *LU Name*.

>/v 010,console,auth=all

### IMON as Operator Console

Not need for *hercules/unattended/set_console_mode*.

* Go to *3 IM*
* Go to *O - OS CONSOLE*
* Screen goes blank.
* Press *T*
* Press *R* to freeze/unfreeze updates in the field *\*\<R\>*

### Clear log files

#### ERP (Error Recovery Program)

> /s clearerp

#### SMF (System Management Facility)

> * /s clearsmf,man=x
> * /s clearsmf,man=y

If any gives an error *IFA006A*, need to switch (*/switch smf*), clean and switch again:

### Increase JES2 spool space

* Check current percent spool utilization:

>      /$dn

* Create a DASD
  * Check which addresses are available (OFFLINE):

>           /d u,dasd,,240,8

>           dasdinit -z -a HASP01.244 3350 HASP01

* Attach new DASD to Hercules:

>      attach 244 3350 dasd/hasp01.244

* Initialise DASD by SUBmitting corresponding JCL (e.g. [HER01.TOOLBOX(INITDASD)](https://github.com/asmCcoder/mainframeadventures/blob/master/MVStoolbox/src/VOL2TAPE))
* Put ONLINE the new DASD:

>      /vary 244,online

* Mount the new DASD:

>      /mount 244,vol=(sl,hasp01),use=private

* Allocate dataset, by SUBmitting:

```jcl
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

>           HASP01,1,2,3350    ,N                  MVS 3.8 JES Spool Disk 2

* Shutdown
* Add line to *conf/tk4-.cnf*: *0244 3350 dasd/hasp01.244*
* IPL and re-check current percent spool utilization:

>     /$dn

### Repair JES2 after $HASP050 JES RESOURCE SHORTAGE

Whenever JES2 spool utilisation is approaching 100%, that message will appear in the console. If you allow JES2 to go 100%, your system will halt and you won’t be able to IPL normally.

* IPL with */R 00,CMD=03*

* Start JES2

>      /S JES2

* Reply with

>      /R 00,FORMAT

When finished, shutdown system and re-IPL.

### Remove BSPFCOOK (The Fortune Cookie Program)

Edit SYS1.CMDPROC(USRLOGON) and leave it like this:

```txt
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

### Services

#### MF/1

* Start: */S MF1*
* Stop: ???

#### FTP Server

* Start: */start ftpd,srvport=<port_num>*
* Stop: */stop ftpd*

#### HTTP Server

* Start: *http start*
* Stop: *http stop*

Must have in conf/tk4-.conf:

* *HTTP PORT ${HTTPPORT:=8038}*
* *HTTP ROOT hercules/httproot*

---

## Technical

### DASD architecture

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

### Printers

|device number|file|SYSOUT|
|:-------------:|:---:|:------:|
|000E|prt00e.txt|A|
|0002|prt002.txt|X|
|000F|prt00f.txt|Z|
