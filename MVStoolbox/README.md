# MVS 3.8j TOOLBOX V1R2M0

## Contents                                                                        

### Backup

* **PDS2TAPE** : Backup a PDS to Tape.
* **TAPE2PDS** : Restore a PDS from Tape (from a backup created by PDS2TAPE).
* **TAPE2VOL** : Restore a Volume from Tape (from backup created by VOL2TAPE).
* **VOL2TAPE** : Backup an entire Volume to Tape.

### Data Sets

* **ALLOPS**   : Allocate PS Sequential File.
* **ALLOPDS**  : Allocate Partitioned Data Set.

### General

* **CLEARERP** : Clear ERP (Error Recovery Program) log file.
* **INITDASD** : Initialise a DASD.
* **PRINTSRC** : Print contents of a member. Usuful for printing source code.
* **PRNLGREC** : Print information recorded in SYS1.LOGREC.

## Installation

* Load the released tape into Hercules: devinit 0480 TOOLBOX.VxRxMx.HET
* Copy & Paste src/TAPE2PDS to your MVS, and SUBmit it.
  * Data set HERC01.TOOLBOX will be created.
