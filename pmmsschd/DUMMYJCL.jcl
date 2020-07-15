//DUMMYJCL JOB ,'PMMS DUMMY',CLASS=A,MSGCLASS=H                         00000100
/*JOBPARM ROOM=PMMS                                                     00000200
//************************************************                      00000300
//* DOES NOTHING. IT'S USED FOR TESTING PURPOSES                        00000400
//************************************************                      00000500
//STEP1   EXEC PGM=IEFBR14                                              00000600
//SYSPRINT  DD SYSOUT=*                                                 00000700
//SYSABEND  DD SYSOUT=*                                                 00000800
