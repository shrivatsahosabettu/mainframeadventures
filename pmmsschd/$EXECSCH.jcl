//PMMSSCH  JOB ,'PMMS',CLASS=A,MSGCLASS=H,TIME=1440                     00000116
/*JOBPARM ROOM=PMMS                                                     00000219
//************************************************                      00000303
//* SUBMITS PMMSSCHD                                                    00000403
//* WHICH WILL RUN IN AN INFINITE LOOP                                  00000503
//************************************************                      00000603
//JOBLIB    DD DISP=SHR,DSN=PMMS.LINKLIB                                00000711
//GO      EXEC PGM=PMMSSCHD                                             00000812
//SYSOUT    DD SYSOUT=*                                                 00000914
//SYSPRINT  DD SYSOUT=*                                                 00001014
//SYSDUMP   DD SYSOUT=*                                                 00001114
//INFILE    DD DISP=SHR,DSN=PMMS.DATA.TASKLIST                          00001205
//REPORT    DD DISP=SHR,DSN=PMMS.DATA.REPORT                            00001313
//MESSAGES  DD DISP=SHR,DSN=PMMS.DATA.MESSAGES                          00001418
//JCLDD     DD SYSOUT=(*,INTRDR)                                        00001513
//                                                                      00001613
