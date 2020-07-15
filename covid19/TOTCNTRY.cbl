//TOTCNTRY    JOB (COBOL),'COVID19',CLASS=A,MSGCLASS=H,MSGLEVEL=(0,0)   00000100
//COMPLINK   EXEC COBUCL                                                00000200
//COB.SYSLIB   DD DISP=SHR,DSNAME=SYS1.COBLIB                           00000300
//             DD DISP=SHR,DSNAME=SYS1.LINKLIB                          00000400
//COB.SYSPUNCH DD DUMMY                                                 00000500
//COB.SYSIN    DD *                                                     00000600
      ******************************************************************00000700
      * PROGRAM DESCRIPTION:                                            00000800
      *   Reads COVID19.DATA.DAILY                                      00000901
      *   And for each country, aggregates the total number of          00001001
      *   cases and deaths                                              00001101
      *   Then data is written into COVID19.DATA.TOTCNTRY               00001201
      ******************************************************************00001300
       IDENTIFICATION DIVISION.                                         00001400
       PROGRAM-ID.   'TOTCNTRY'.                                        00001500
       AUTHOR.       'DAVID ASTA'.                                      00001600
       INSTALLATION. 'MVS 3.8J TK4-'.                                   00001700
       DATE-WRITTEN. '14/07/2020'.                                      00001800
       DATE-COMPILED.                                                   00001900
       REMARKS.      'V1R1M0'.                                          00002000
      ******************************************************************00002100
       ENVIRONMENT DIVISION.                                            00002201
      ******************************************************************00002301
       INPUT-OUTPUT SECTION.                                            00002401
       FILE-CONTROL.                                                    00002501
           SELECT DAILY-FILE     ASSIGN DA-S-DAYFIL.                    00002601
           SELECT TOTCNTRY-FILE  ASSIGN DA-S-TOTCTR.                    00002702
      ******************************************************************00002801
       DATA DIVISION.                                                   00002901
      ******************************************************************00003001
       FILE SECTION.                                                    00003101
      **********************************                                00003201
       FD  DAILY-FILE                                                   00003301
      *******************                                               00003401
           LABEL RECORDS ARE STANDARD                                   00003501
           BLOCK CONTAINS 0 RECORDS                                     00003601
           RECORD CONTAINS 80 CHARACTERS.                               00003701
       01  DAILY-RECORD.                                                00003801
           05 DAY-DATE.                                                 00003901
              10 DAY-DATE-YYYY    PIC X(04).                            00004001
              10 DAY-DATE-MM      PIC X(02).                            00004101
              10 DAT-DATE-DD      PIC X(02).                            00004201
           05 DAY-CASES           PIC 9(08).                            00004301
           05 DAY-DEATHS          PIC 9(08).                            00004401
           05 DAY-COUNTRYCODE     PIC A(03).                            00004501
           05 DAY-COUNTRYNAME     PIC X(40).                            00004601
           05 FILLER              PIC X(13).                            00004701
      *******************                                               00004802
       FD  TOTCNTRY-FILE                                                00004902
      *******************                                               00005002
           RECORDING MODE F                                             00005102
           LABEL RECORDS ARE STANDARD                                   00005202
           BLOCK CONTAINS 0 RECORDS                                     00005302
           RECORD CONTAINS 59 CHARACTERS.                               00005402
       01  TOT-RECORD             PIC X(59).                            00005502
      **********************************                                00005601
       WORKING-STORAGE SECTION.                                         00005701
      **********************************                                00005801
       01  SWITCHES.                                                    00005901
           05 END-OF-FILE         PIC X      VALUE 'N'.                 00006002
              88 EOF                         VALUE 'Y'.                 00006102
       01  WS-TOTALS-RECORD.                                            00006202
           05 WS-TOT-COUNTRYCODE  PIC A(03).                            00006302
           05 WS-TOT-CASES        PIC 9(08).                            00006402
           05 WS-TOT-DEATHS       PIC 9(08).                            00006502
           05 WS-TOT-COUNTRYNAME  PIC X(40).                            00006603
      ******************************************************************00006701
       PROCEDURE DIVISION.                                              00006801
      ******************************************************************00006901
       0000-MAIN.                                                       00007001
           OPEN INPUT  DAILY-FILE,                                      00007102
                OUTPUT TOTCNTRY-FILE.                                   00007202
           PERFORM 1000-READ-DAILY-DATA THRU 1000-EXIT                  00007302
               UNTIL EOF.                                               00007402
           WRITE TOT-RECORD FROM WS-TOTALS-RECORD.                      00007503
           CLOSE DAILY-FILE,                                            00007602
                 TOTCNTRY-FILE.                                         00007702
       0000-EXIT.                                                       00007801
           STOP RUN.                                                    00007901
      **********************************                                00008001
       1000-READ-DAILY-DATA.                                            00008102
      **********************************                                00008202
           READ DAILY-FILE                                              00008302
               AT END MOVE 'Y' TO END-OF-FILE.                          00008402
           IF NOT EOF THEN                                              00008502
               PERFORM 2000-PROCESS-DAILY-DATA THRU 2000-EXIT.          00008602
       1000-EXIT.                                                       00008702
           EXIT.                                                        00008802
      **********************************                                00008902
       2000-PROCESS-DAILY-DATA.                                         00009002
      **********************************                                00009101
           IF DAY-COUNTRYNAME = WS-TOT-COUNTRYNAME THEN                 00009202
               ADD DAY-CASES  TO WS-TOT-CASES                           00009302
               ADD DAY-DEATHS TO WS-TOT-DEATHS                          00009402
           ELSE                                                         00009501
               PERFORM 2001-RECORD-TOTALS-DATA THRU 2001-EXIT           00009603
               MOVE DAY-CASES       TO WS-TOT-CASES                     00009702
               MOVE DAY-DEATHS      TO WS-TOT-DEATHS                    00009802
               MOVE DAY-COUNTRYCODE TO WS-TOT-COUNTRYCODE               00009903
               MOVE DAY-COUNTRYNAME TO WS-TOT-COUNTRYNAME.              00010003
       2000-EXIT.                                                       00010102
           EXIT.                                                        00010201
      **********************************                                00010302
       2001-RECORD-TOTALS-DATA.                                         00010402
      **********************************                                00010502
           IF WS-TOT-COUNTRYCODE IS ALPHABETIC THEN                     00010603
               WRITE TOT-RECORD     FROM WS-TOTALS-RECORD.              00010703
       2001-EXIT.                                                       00010802
           EXIT.                                                        00010902
      ******************************************************************00011001
/*                                                                      00011100
//LKED.SYSLIB  DD DISP=SHR,DSNAME=SYS1.COBLIB                           00011200
//             DD DISP=SHR,DSNAME=SYS1.LINKLIB                          00011300
//             DD DISP=SHR,DSNAME=COVID19.LINKLIB                       00011400
//LKED.SYSLMOD DD DISP=SHR,DSNAME=COVID19.LINKLIB(TOTCNTRY)             00011500
//                                                                      00011600
