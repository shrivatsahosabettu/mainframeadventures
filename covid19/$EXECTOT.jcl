//$EXECTOT JOB ,'COVID19',CLASS=A,MSGCLASS=A,MSGLEVEL=(0,0),            00000108
//             USER=HERC01,PASSWORD=CUL8TR                              00000204
/*JOBPARM ROOM=CV19                                                     00000300
//JOBLIB    DD DISP=SHR,DSN=COVID19.LINKLIB                             00000407
//************************************************                      00000507
//* SUBMITS TOTCNTRY                                                    00000600
//*  WHICH READS DAILY DATA AND SUMMARISES PER                          00000701
//*  COUNTRY                                                            00000801
//************************************************                      00000900
//STEP02  EXEC PGM=TOTCNTRY                                             00001007
//SYSOUT    DD SYSOUT=*                                                 00001100
//SYSPRINT  DD SYSOUT=*                                                 00001200
//SYSDUMP   DD SYSOUT=*                                                 00001306
//DAYFIL    DD DISP=SHR,DSN=COVID19.DATA.DAILY                          00001400
//TOTCTR    DD DISP=SHR,DSN=COVID19.DATA.TOTCNTRY                       00001500
//************************************************                      00001601
//* SUBMITS REPCNTRY                                                    00001701
//*  WHICH GENERATES THE REPORT                                         00001801
//************************************************                      00001901
//STEP03  EXEC PGM=REPCNTRY                                             00002007
//SYSOUT    DD SYSOUT=*                                                 00002101
//SYSPRINT  DD SYSOUT=*                                                 00002201
//SYSDUMP   DD SYSOUT=*                                                 00002301
//TOTCTR    DD DISP=SHR,DSN=COVID19.DATA.TOTCNTRY                       00002401
//TOTPRV    DD DISP=SHR,DSN=COVID19.DATA.TOTCPREV                       00002505
//* UP TO 5 COUNTRY CODES CAN BE SPECIFIED AS FAVOURITE COUNTRIES       00002602
//SYSIN     DD *                                                        00002701
DEUESPBGRCANSWE                                                         00002802
/*                                                                      00002901
//************************************************                      00003009
//* COPY TOTCNTRY TO TOTCPREV,                                          00003109
//*  WHICH WILL BE USED TO CALCULATE DELTAS                             00003209
//*  OF NUMBER OF CASES/DEATHS NEXT DAY                                 00003309
//************************************************                      00003409
//* CHECK IF SEQUENTIAL FILE ALREADY EXISTS                             00003509
//CHECKIS  EXEC PGM=IDCAMS                                              00003609
//SYSPRINT   DD SYSOUT=*                                                00003709
//SYSOUT     DD SYSOUT=*                                                00003809
//SYSDUMP    DD SYSOUT=*                                                00003909
//SYSIN      DD *                                                       00004009
  LISTCAT ENTRIES('COVID19.DATA.TOTCPREV')                              00004109
/*                                                                      00004209
//* DELETE SEQUENTIAL FILE ONLY IF IT                                   00004309
//* ALREADY EXISTS (COND=(4,EQ))                                        00004409
//DELETE   EXEC PGM=IEFBR14,COND=(4,EQ)                                 00004509
//SYSPRINT   DD SYSOUT=*                                                00004609
//SYSOUT     DD SYSOUT=*                                                00004709
//SYSDUMP    DD SYSOUT=*                                                00004809
//DD1        DD DSN=COVID19.DATA.TOTCPREV,                              00004909
//           DISP=(OLD,DELETE)                                          00005009
//* COPY TOTCNTRY TO TOTCPREV                                           00005109
//STEP01  EXEC PGM=IEBGENER                                             00005209
//SYSPRINT  DD SYSOUT=*                                                 00005309
//SYSOUT    DD SYSOUT=*                                                 00005409
//SYSDUMP   DD SYSOUT=*                                                 00005509
//SYSUT1    DD DISP=SHR,DSN=COVID19.DATA.TOTCNTRY                       00005609
//SYSUT2    DD DSN=COVID19.DATA.TOTCPREV,                               00005709
//             DISP=(NEW,CATLG,DELETE),                                 00005809
//             SPACE=(TRK,(1,1),RLSE),                                  00005909
//             UNIT=SYSDA,                                              00006009
//             VOL=SER=DASTA1,                                          00006109
//             DCB=(DSORG=PS,RECFM=FB,LRECL=59,BLKSIZE=590)             00006209
//SYSIN     DD DUMMY                                                    00006309
//                                                                      00006400
