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
  * [Operator Console Commands](#operator-console-commands)
  * [OS/VS2 MVS Utilities](#osvs2-mvs-utilities)
  * [Remove Session Time out](#remove-session-time-out)
  * [Cancel stuck session](#cancel-stuck-session)
  * [Enable 3270 Console](#enable-3270-console)
  * [IMON as Operator Console](#imon-as-operator-console)
  * [Clear log files](#clear-log-files)
    * [ERP (Error Recovery Program)](#erp-error-recovery-program)
    * [SMF (System Management Facility)](#smf-system-management-facility)
  * [Increase JES2 spool space](#increase-jes2-spool-space)
  * [Repair JES2 after $HASP050 JES RESOURCE SHORTAGE](#repair-jes2-after-hasp050-jes-resource-shortage)
  * [Remove BSPFCOOK (The Fortune Cookie Program)](#remove-bspfcook-the-fortune-cookie-program)
  * [Add a new Direct-Access Storage Device (DASD)](#add-a-new-direct-access-storage-device-(DASD))
    * [Create a User Catalog](#create-a-user-catalog)
    * [Create ALIAS for data sets](#create-alias-for-data-sets)
  * [Services](#services)
    * [MF/1](#mf1)
    * [FTP Server](#ftp-server)
    * [HTTP Server](#http-server)
* [Technical](#technical)
  * [Data sets](#data-sets)
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

## Tape Backups

### Backup/Restore a PDS

#### Backup PDS to tape

Create tape in Linux:

> hetinit TAPE01.het HERC01

SUBmit:

```JCL
//TAPETO JOB (01),'COPY TO TAPE',CLASS=A,MSGCLASS=H
//COPY   EXEC PGM=IEBCOPY,REGION=720K
//SYSPRINT DD SYSOUT=*
//INPDS    DD DISP=SHR,DSN=dataset.name.here
//OUTTAPE  DD UNIT=TAPE,DISP=NEW,
//            DSN=dataset.name.here,
//            VOL=SER=mylabel,LABEL=(,SL)
//SYSUT3   DD UNIT=SYSDA,SPACE=(80,(60,45)),DISP=(NEW,DELETE)
//SYSIN    DD *
  COPY INDD=INPDS OUTDD=OUTTAPE
/*
//
```

In Hercules console will appear a message *\*IEF233A M 480,TAPE01,,HERC01F,COPY*, reply with

> devinit 480 tapes/TAPE01.aws

#### Restore PDS from tape

Create destination PDS in MVS at 3.2 with same configuration as original

SUBmit:

```JCL
//TAPEFROM JOB (01),'RESTORE FROM TAPE',CLASS=A,MSGCLASS=H
//COPY    EXEC PGM=IEBCOPY,REGION=720K
//SYSPRINT  DD SYSOUT=*
//INTAPE   DD UNIT=TAPE,DISP=OLD,
//            DSN=dataset.name.here,
//            VOL=SER=mylabel,LABEL=(,SL)
//OUTPDS   DD UNIT=DISK,DISP=(NEW,CATLG,DELETE),
//            DSN=dataset.name.here,
//            VOL=SER=myvolume,
//            SPACE=(CYL,(10,5,10))
//SYSUT3   DD UNIT=SYSDA,SPACE=(80,(60,45)),DISP=(NEW,DELETE)
//SYSIN    DD *
  COPY INDD=INTAPE,OUTDD=OUTPDS
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

```JCL
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

```JCL
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

### Operator Console Commands

This commands can also be executed from Hercules' console  by prefixing them with /

|Command|Description|
|:------|:----------|
|D A,L|Show all active jobs and users|
|D R,L|Display unanswered WTOR|
|D U,DASD,ONLINE|Display all online DASD volumes|
|D U,TAPE|Display status of all tapes|
|D U,,,devnum,n|Display status of device, starting from devnum to devnum+n|
|D TS,L|Display all TSO active users|
|D DUMP|Display status of dump datasets|
|D J|Display number of active jobs and initiators|
|D T|Display date and time|
|K E,1|Erase top line (permanent messages) of console display area|
|K E,D|Erase bottom of console display area|
|SE ‘message’|Send a message to all TSO users|
|SE ‘message’ USER=xxxx|Send a message to TSO user xxxx|
|M volnum,VOL=(SL,volser),USE=usetype|Mount command|

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

### Cancel stuck session

If you don't log off properly, the next time you try to log in you will get an error message:
> IKJ56425I LOGON REJECTED, USERID HERC01 IN USE

To free the session, log in with another user (e.g. HERC02) and use IMON as Operator Console to enter the command:
> /C U=HERC01

you will see the message
> IEE301I HERC01   CANCEL COMMAND ACCEPTED

and log in will be available again

### Enable 3270 Console

> /attach 010 3270 CONS

Connect a 3270 emulator. Use *CONS* for the *LU Name*.

>/v 010,console,auth=all

### IMON as Operator Console

Not need for *hercules/unattended/set_console_mode*.

* Go to *3 IM*
* Go to *O - OS CONSOLE*
* Screen goes blank.
* Press *T* and *ENTER*.
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

* Initialise DASD by SUBmitting corresponding JCL (e.g. [HER01.TOOLBOX(INITDASD)](https://github.com/asmCcoder/mainframeadventures/blob/master/MVStoolbox/VOL2TAPE))
* Put ONLINE the new DASD:

>      /vary 244,online

* Mount the new DASD:

>      /mount 244,vol=(sl,hasp01),use=private

* Allocate dataset, by SUBmitting:

```JCL
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

### Add a new Direct-Access Storage Device (DASD)

Create DASD with Hercules tool:
> dasdinit -a filename devtype volser
>
> (e.g. dasdinit -a vsam01.246 3350 VSAM01)

where:

* -a: build DASD image file that includes alternate cylinders.
* filename: any name and any extension, but typically filename is the same as the *volser* and extension is the same as the *devnum* or *devtype*. (e.g. VSAM01.246 or VSAM01.3350).
* devtype: is one of the [IBM magnetic disk drives](https://en.wikipedia.org/wiki/History_of_IBM_magnetic_disk_drives). Typically 3350, 3380 or 3390.
* volser: is the Volume Serial that will be used by MVS. Maximum 6 characters.

Attach DASD to Hercules, by typing at Hercules console:
> attach devnum devtype filename
>
>(e.g. attach 0246 3350 VSAM01.246)

Put the DASD offline, from the Hercules console
> /v devnum,offline
>
>(e.g. /v 246,offline)

Dealloacate it
>/s dealloc

Format DASD, by SUBmitting JCL below after changing values for *volnum*, *volser* and *VTOC_tracks*:

```JCL
//INITDASD JOB (1),ICKDSF,CLASS=A,MSGCLASS=H
//ICKDSF  EXEC PGM=ICKDSF,REGION=4096K
//SYSPRINT  DD SYSOUT=*
//SYSIN     DD *
  INIT UNITADDRESS(volnum) NOVERIFY VOLID(volser) OWNER(HERCULES) - 
       VTOC(0,1,VTOC_tracks)
/*
//
```

In the console will appear the message
> *00 ICK003D REPLY U TO ALTER VOLUME 246 CONTENTS, ELSE T

Reply with
>/R 00,U

Check printout (RFE option 3.8) for INITDASD. It should have RC=0000

Put the DASD online, from the Hercules console
> /v devnum,online
>
>(e.g. /v 246,online)

Mount the DASD
> /m volnum,vol=(sl,volser),use=usetype

where usetype:

* STORAGE: MVS can use the disc to create temporary and permanent libraries.
* PUBLIC: MVS can use the disc to create temporary libraries.
* PRIVATE: MVS will not use this disc unless user specifies manually this disk.

At this point, if you try to access the volume (RFE option 3.4), you will get error *No data sets found*. But this is good. This means, the DASD has been formatted and mounted correctly, and it's ready to be used. For example to add dataset or create a User Catalog.

#### Create a User Catalog

**NOTE**: I find VSAM and Catalogs a bit complicated subject, therefore I won't trust too much what I say here. Better look at [Jay Moseley's VSAM Tutorial](http://www.jaymoseley.com/hercules/vs_tutor/vstutor.htm) or read *DFSMS/MVS Version 1 Release 2 Access Method Services for VSAM (SC26-4905-01)*.

It's a recomended practice to have ONLY system data sets in the Master Catalog (SYS1.VMASTCAT), and create User Catalogs for all other data sets. In other words; never user Master Catalog for your new data sets. This way the Master Catalog will only contain the TK4- data sets.

Therefore, when adding a new DASD like we just did, create a User Catalog for it. This requires a bit of planning ahead: Is the DASD going to contain VSAM or non-VSAM data sets? (I heard is better to have a dedicated DASD for VSAM only) Do we allocate space for VSAM now or we will do it as we need it?

For a VSAM only DASD (e.g. VOL=SER= with *DASTA1*) we SUBmit:

```JCL
//DEFUCAT1 JOB 'DEFINE USER CAT',CLASS=A,MSGLEVEL=(1,1),MSGCLASS=H
//IDCAMS   EXEC PGM=IDCAMS,REGION=4096K
//SYSPRINT DD  SYSOUT=A
//DASTA1   DD  UNIT=3350,VOL=SER=DASTA1,DISP=OLD
//SYSIN    DD  *
  DEFINE USERCATALOG (                                      -
               NAME (UCDASTA1)                              -
               VOLUME (DASTA1)                              -
               TRACKS (13259 0)                             -
               FOR (9999) )                                 -
         DATA (TRACKS (15 5) )                              -
         INDEX (TRACKS (15) )

  IF LASTCC = 0 THEN                                        -
        LISTCAT ALL CATALOG(UCDASTA1)
/*
//
```

For a non-VSAM only DASD (e.g. VOL=SER= with *DASTA2*) we SUBmit:

```JCL
//DEFUCAT1 JOB 'DEFINE USER CAT',CLASS=A,MSGLEVEL=(1,1),MSGCLASS=H
//IDCAMS   EXEC PGM=IDCAMS,REGION=4096K
//SYSPRINT DD  SYSOUT=A
//DASTA2   DD  UNIT=3350,VOL=SER=DASTA,DISP=OLD
//SYSIN    DD  *
  DEFINE USERCATALOG (                                      -
               NAME (UCDASTA2)                              -
               VOLUME (DASTA2)                              -
               TRACKS (15)                                  -
               FOR (9999) )                                 -

  IF LASTCC = 0 THEN                                        -
        LISTCAT ALL CATALOG(UCDASTA2)
/*
//
```

If now we access the volume (RFE option 3.4), we will see a data set like *Z9999994.VSAMDSPC.TD83D7D1.T43508F0*.

#### Create ALIAS for data sets

```JCL
//DEFALIAS JOB 'DEFINE ALIAS',CLASS=A,MSGLEVEL=(1,1),MSGCLASS=H
//IDCAMS   EXEC PGM=IDCAMS,REGION=4096K
//SYSPRINT DD  SYSOUT=A
//SYSIN    DD  *
  DEFINE ALIAS (NAME(DASTA1)                                -
                RELATE(UCDASTA1) )

  DEFINE ALIAS (NAME(DASTA2)                                -
                RELATE(UCDASTA2) )

  IF MAXCC = 0 THEN DO                                      -
        LISTCAT ALIAS                                       -
     END
/*
//
```

If now we list the alias in the Master Catalog:

```JCL
//LISTCAT  JOB 'LIST ALIAS',CLASS=A,MSGLEVEL=(1,1),MSGCLASS=H
//IDCAMS   EXEC PGM=IDCAMS,REGION=4096K
//SYSPRINT DD  SYSOUT=A
//SYSIN    DD  *
  LISTCAT ALIAS NAME
  LISTCAT ALL CATALOG(UCDASTA1)
  LISTCAT ALL CATALOG(UCDASTA2)
/*
//
```

we should see 2 entries for the alias of our 2 DASD:

```text
                             LISTING FROM CATALOG -- SYS1.VMASTCAT
ALIAS --------- DASTA1
ALIAS --------- DASTA2
```

If now we allocate a data set (RFE option 3.2) with HLQ DASTA2, it will be cataloged in the UCDASTA2 User Catalog instead of the Master Catalog, as we wanted.

For example, we allocate a data set called *DASTA2.TEST.SEQ*.

Then we SUBmit:

```JCL
//LISTCAT  JOB 'LIST CATALOGS',CLASS=A,MSGLEVEL=(1,1),MSGCLASS=H
//IDCAMS   EXEC PGM=IDCAMS,REGION=4096K
//SYSPRINT DD  SYSOUT=A
//SYSIN    DD  *
  LISTCAT ALIAS NAME
  LISTCAT ALL CATALOG(UCDASTA1)
  LISTCAT ALL CATALOG(UCDASTA2)
  LISTCAT NONVSAM ALL CAT(UCDASTA2)
/*
//
```

and in the printout we will see:

```text
  LISTCAT NONVSAM ALL CAT(UCDASTA2)
IDCAMS  SYSTEM SERVICES                                           TIME: 10:35:18
                             LISTING FROM CATALOG -- UCDASTA2
NONVSAM ------- DASTA2.TEST.SEQ
     HISTORY
       OWNER-IDENT-------(NULL)     CREATION----------20.201
       RELEASE----------------2     EXPIRATION--------00.000
     VOLUMES
       VOLSER------------DASTA2     DEVTYPE------X'3050200B'     FSEQN----------
     ASSOCIATIONS--------(NULL)
```

**IMPORTANT**:

* Before allocating any data sets with a new HLQ (i.e. an HLQ for which we don't have an ALIAS), we SHOULD create the alias for the HLQ that we want to create, to avoid it will be cataloged in th Master Catalog.
* When allocating data sets, we still need to specify the VOLUME if we want the data set to be allocated in our new DASD. Defining an ALIAS only affects cataloging, not where the data set will physically be allocated.

#### Make volume mounted at each IPL

* Add at the end of SYS1.PARMLIB(VATLST00) in the format as follows:
  * Columns 1-6: volser
  * Column 8: 0=resident, 1=reserved
  * Columns 10: 0=storage, 1=public, 2=private
  * Columns 12-19: devtype
  * Column 21: Y=mandatory that DASD is present to start MVS, N=optional
  * Columns 23-71: comments

Example:

```text
----+----1----+----2----+----3----+----4----+----5----+----6----+----7-
VSAM01,0,2,3350    ,N VSAM Volume 1
```

Add DASD to Hercules’ configuration
> volser devtype filename
> (e.g. 0246 3350 VSAM01.246)

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

### Data sets

* **Sequential (PS)**: records are data items stored consecutively. Hence, to read a record, all previous records must be read. New records are added at the end.
  * To allocate: use RFE option 3.2 or [MVStoolbox's ALLOPS JCL](https://github.com/asmCcoder/mainframeadventures/blob/master/MVStoolbox/ALLOPS)
* **Partitioned (PDS)**: Often called libraries. Consist of a directory and members. The directory holds the address of each member. Each member consist of sequentially stored records. To reuse the space left by a deleted member, the library must be compressed manually.
  * To allocate: use RFE option 3.2 or [MVStoolbox's ALLOPDS JCL](https://github.com/asmCcoder/mainframeadventures/blob/master/MVStoolbox/ALLOPDS)
* **Partitioned Extended (PDSE)**: Space is reclaimed automatically when a member is deleted. Flexible size. Can be shared. Faster directory searches. Cannot no be used for PROCLIB or libraries that are part of the IPL.
* **Virtual Storage Access Method (VSAM)**: http://www.jaymoseley.com/hercules/vs_tutor/vstutor.htm
  * **Key Sequenced Data Set (KSDS)**: each record is identified for <u>access by specifying its key value</u>. Records may be accessed sequentially, in order by key value, or directly, by supplying the key value. KSDS datasets are similar to Indexed Sequential Access Method (ISAM). Records may be added or deleted at any point.
  * **Entry Sequence Data Set (ESDS)**: each record is identified for <u>access by specifying its physical location (Relative Byte Address [RBA])</u>.  Records may be accessed sequentially, in order by RBA value, or directly, by supplying the RBA of the desired record. ESDS datasets are similar to Basic Sequential Access Method (BSAM) or Queued Sequential Access Method (QSAM) datasets. Records cannot be deleted, and they can only be appended (added to the end of the dataset).
  * **Relative Record Data Set (RRDS)**: each record is identified for <u>access by specifying its record number</u>. Records may be accessed sequentially, in relative record number order, or directly, by supplying the relative record number of the desired record. RRDS datasets are similar to Basic Direct Access Method (BDAM) datasets. Records may be added into an empty record or deleted, leaving an empty record.
  * **Linear Data Set (LDS)**
* **Generation Data Group (GDG)**: catalogues successive updates of related data. Allows to keep the historical data of n updates.

**Permanent**: exists before a job starts and persist after job completes.

**Temporary**: Used to pass data from one job step to another. Exist only during the life cycle of the job.

#### Data set Record Formats

* **Fixed records (F)**: all records have the same length. One record is send for each I/O operation. Not really used.
* **Fixed Blocked records (FB)**:  all records have the same length. Several records are send for each I/O operation.
* **Variable records (V)**: each record can have a different length. Several records are send for each I/O operation.
* **Variable Blocked records (VB)**: each record can have a different length. Several records are send for each I/O operation.
* **Undefined records (U)**: undefined structure. Used for libraries that contain compiled modules (programs).

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
