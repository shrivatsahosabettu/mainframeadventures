//$EXECTOT JOB ,'COVID19',CLASS=A,MSGCLASS=H,TIME=1440                  00000100
/*JOBPARM ROOM=CV19                                                     00000200
//************************************************                      00000300
//* SUBMITS TOTCNTRY                                                    00000400
//*  WHICH READS DAILY DATA AND SUMMARISES PER                          00000501
//*  COUNTRY                                                            00000601
//************************************************                      00000700
//JOBLIB    DD DISP=SHR,DSN=COVID19.LINKLIB                             00000800
//STEP01  EXEC PGM=TOTCNTRY                                             00000901
//SYSOUT    DD SYSOUT=*                                                 00001000
//SYSPRINT  DD SYSOUT=*                                                 00001100
//SYSDUMP   DD SYSOUT=*                                                 00001200
//DAYFIL    DD DISP=SHR,DSN=COVID19.DATA.DAILY                          00001300
//TOTCTR    DD DISP=SHR,DSN=COVID19.DATA.TOTCNTRY                       00001400
//************************************************                      00001501
//* SUBMITS REPCNTRY                                                    00001601
//*  WHICH GENERATES THE REPORT                                         00001701
//************************************************                      00001801
//STEP02  EXEC PGM=REPCNTRY                                             00001901
//SYSOUT    DD SYSOUT=*                                                 00002001
//SYSPRINT  DD SYSOUT=*                                                 00002101
//SYSDUMP   DD SYSOUT=*                                                 00002201
//TOTCTR    DD DISP=SHR,DSN=COVID19.DATA.TOTCNTRY                       00002301
//* UP TO 5 COUNTRY CODES CAN BE SPECIFIED AS FAVOURITE COUNTRIES       00002402
//SYSIN     DD *                                                        00002501
DEUESPBGRCANSWE                                                         00002602
/*                                                                      00002701
//                                                                      00002800
