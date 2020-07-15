//PMMSRP1  JOB ,'PMMS',CLASS=A,MSGCLASS=A,MSGLEVEL=(0,0)                00000100
/*JOBPARM ROOM=PMMS                                                     00000200
//************************************************                      00000300
//* SUBMITS PMMSSREP                                                    00000400
//* WHICH WILL GENERATE A REPORT OF SUBMITED CMDS                       00000500
//************************************************                      00000600
//JOBLIB    DD DISP=SHR,DSN=PMMS.LINKLIB                                00000700
//GO      EXEC PGM=PMMSSREP                                             00000800
//SYSOUT    DD SYSOUT=*                                                 00000900
//SYSPRINT  DD SYSOUT=*                                                 00001000
//SYSDUMP   DD SYSOUT=*                                                 00001100
//RPRTFILE  DD DISP=SHR,DSN=PMMS.DATA.REPORT                            00001200
//                                                                      00001300
