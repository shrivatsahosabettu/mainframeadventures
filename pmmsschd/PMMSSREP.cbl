//PMMSSREP JOB (COBOL),                                                 00000100
//             'PMMSSREP',                                              00000200
//             CLASS=A,MSGCLASS=H,                                      00000300
//             MSGLEVEL=(1,1)                                           00000400
//COMPLINK EXEC COBUCL                                                  00000500
//COB.SYSLIB DD DISP=SHR,DSNAME=SYS1.COBLIB                             00000600
//           DD DISP=SHR,DSNAME=SYS1.LINKLIB                            00000700
//COB.SYSPUNCH DD DUMMY                                                 00000800
//COB.SYSIN DD *                                                        00000900
      ******************************************************************00001001
      * PROGRAM DESCRIPTION:                                            00001101
      *   This program is part of PMMS.                                 00001201
      *   Generates a printed report of all submitted commands.         00001301
      *   It takes information from PMMS.DATA.REPORT                    00001401
      ******************************************************************00001501
       IDENTIFICATION DIVISION.                                         00001601
       PROGRAM-ID.   'PMMSSREP'.                                        00001701
       AUTHOR.       'DAVID ASTA'.                                      00001801
       INSTALLATION. 'MVS 3.8j TK4-'.                                   00001901
       DATE-WRITTEN. '09/07/2020'.                                      00002001
       DATE-COMPILED.                                                   00002101
      ******************************************************************00002201
       ENVIRONMENT DIVISION.                                            00002301
      ******************************************************************00002401
       INPUT-OUTPUT SECTION.                                            00002501
       FILE-CONTROL.                                                    00002601
           SELECT REPORT-FILE   ASSIGN DA-S-RPRTFILE.                   00002701
           SELECT REPORT-PRINT  ASSIGN UR-S-SYSPRINT.                   00002801
      ******************************************************************00002901
       DATA DIVISION.                                                   00003001
      ******************************************************************00003101
       FILE SECTION.                                                    00003201
      **********************************                                00003301
       FD  REPORT-FILE                                                  00003401
      **********************************                                00003501
           LABEL RECORDS ARE STANDARD                                   00003601
           BLOCK CONTAINS 0 RECORDS                                     00003701
           RECORD CONTAINS 80 CHARACTERS.                               00003801
       01  REP-RECORD.                                                  00003901
           05 REP-EXEC-RESULT          PIC X.                           00004001
           05 REP-DATE-SCHED.                                           00004101
              10 REP-DATE-SCHED-DD     PIC XX.                          00004201
              10 REP-DATE-SCHED-MM     PIC XX.                          00004301
           05 REP-TIME-SCHED.                                           00004401
              10 REP-TIME-SCHED-HH     PIC XX.                          00004501
              10 REP-TIME-SCHED-MM     PIC XX.                          00004601
           05 REP-DATE-SUBMI.                                           00004701
              10 REP-DATE-SUBMI-DD     PIC 9(02).                       00004801
              10 REP-DATE-SUBMI-MM     PIC 9(02).                       00004901
              10 REP-DATE-SUBMI-YY     PIC 9(02).                       00005001
           05 REP-TIME-SUBMI.                                           00005101
              10 REP-TIME-SUBMI-HH     PIC 9(02).                       00005201
              10 REP-TIME-SUBMI-MM     PIC 9(02).                       00005301
              10 REP-TIME-SUBMI-SS     PIC 9(02).                       00005401
           05 REP-COMMAND              PIC X(06).                       00005501
           05 REP-SUBCOMMAND           PIC X(53).                       00005601
      **********************                                            00005701
       FD  REPORT-PRINT                                                 00005801
      **********************                                            00005901
           LABEL RECORDS ARE OMITTED                                    00006001
           REPORT IS SUBMITS-REPORT.                                    00006101
      **********************************                                00006201
       WORKING-STORAGE SECTION.                                         00006301
      **********************************                                00006401
       01  TABLES.                                                      00006504
           05 WS-TABLE-MONTHS-VALUES.                                   00006604
              10 FILLER               PIC X(09)  VALUE 'January  '.     00006704
              10 FILLER               PIC X(09)  VALUE 'February '.     00006804
              10 FILLER               PIC X(09)  VALUE 'March    '.     00006904
              10 FILLER               PIC X(09)  VALUE 'April    '.     00007004
              10 FILLER               PIC X(09)  VALUE 'May      '.     00007104
              10 FILLER               PIC X(09)  VALUE 'June     '.     00007204
              10 FILLER               PIC X(09)  VALUE 'July     '.     00007304
              10 FILLER               PIC X(09)  VALUE 'August   '.     00007404
              10 FILLER               PIC X(09)  VALUE 'September'.     00007504
              10 FILLER               PIC X(09)  VALUE 'October  '.     00007604
              10 FILLER               PIC X(09)  VALUE 'November '.     00007704
              10 FILLER               PIC X(09)  VALUE 'December '.     00007804
           05 WS-TABLE-MONTHS REDEFINES WS-TABLE-MONTHS-VALUES.         00007904
              10 WS-MONTH-NAME        PIC X(09)  OCCURS 12 TIMES.       00008004
       01  SUBSCRIPTS.                                                  00008104
           05 WS-MONTHS-SUB    PIC S99.                                 00008204
       01  SWITCHES.                                                    00008301
           05 END-OF-FILE             PIC X      VALUE 'N'.             00008401
              88 EOF                             VALUE 'Y'.             00008501
       01  WS-TODAYS-DATE.                                              00008601
           05 TD-MONTH                PIC X(02).                        00008701
           05 FILLER                  PIC X.                            00008801
           05 TD-DAY                  PIC X(02).                        00008901
           05 FILLER                  PIC X.                            00009001
           05 TD-YEAR                 PIC X(02).                        00009101
       01  WS-TODAYS-TIME.                                              00009201
           05 TT-HOURS                PIC 9(02).                        00009301
           05 TT-MINUTES              PIC 9(02).                        00009401
           05 TT-SECONDS              PIC 9(02).                        00009501
       01  WS-SCHEDULED.                                                00009604
           05 WS-SCHED-TEXT1          PIC X(11)  VALUE 'Runs every '.   00009704
           05 WS-SCHED-DAY            PIC X(03).                        00009804
           05 WS-SCHED-TEXT2          PIC X(04).                        00009904
           05 WS-SCHED-MONTH          PIC X(09).                        00010004
           05 WS-SCHED-TEXT3          PIC X(04)  VALUE ' at '.          00010104
           05 WS-SCHED-HH             PIC X(02).                        00010204
           05 WS-SCHED-TIMESEP        PIC X      VALUE ':'.             00010304
           05 WS-SCHED-MM             PIC X(02).                        00010404
      **********************************                                00010501
       REPORT SECTION.                                                  00010601
      **********************************                                00010701
       RD  SUBMITS-REPORT                                               00010801
           PAGE LIMIT IS 66 LINES                                       00010901
           HEADING 1                                                    00011001
           FIRST DETAIL 5                                               00011101
           LAST DETAIL 58.                                              00011201
       01  PAGE-HEAD-GROUP TYPE PAGE HEADING.                           00011301
           05 LINE 1.                                                   00011401
              10 COLUMN 01        PIC X(05)  VALUE 'DATE:'.             00011501
              10 COLUMN 07        PIC 99     SOURCE TD-DAY.             00011601
              10 COLUMN 09        PIC X      VALUE '/'.                 00011701
              10 COLUMN 10        PIC 99     SOURCE TD-MONTH.           00011801
              10 COLUMN 12        PIC X      VALUE '/'.                 00011901
              10 COLUMN 13        PIC 9999   SOURCE TD-YEAR.            00012001
              10 COLUMN 45        PIC A(37)  VALUE                      00012104
                                'P M M S    S U B M I T    R E P O R T'.00012201
              10 COLUMN 122       PIC X(05)  VALUE 'PAGE:'.             00012301
              10 COLUMN 128       PIC ZZZZ9  SOURCE PAGE-COUNTER.       00012401
           05 LINE PLUS 1.                                              00012501
              10 COLUMN 01        PIC X(05)  VALUE 'TIME:'.             00012601
              10 COLUMN 07        PIC 99     SOURCE TT-HOURS.           00012701
              10 COLUMN 09        PIC X      VALUE ':'.                 00012801
              10 COLUMN 10        PIC 99     SOURCE TT-MINUTES.         00012901
              10 COLUMN 12        PIC X      VALUE ':'.                 00013001
              10 COLUMN 13        PIC 99     SOURCE TT-SECONDS.         00013101
           05 LINE PLUS 2.                                              00013201
              10 COLUMN 05        PIC A(12)  VALUE 'Submitted on'.      00013304
              10 COLUMN 22        PIC A(07)  VALUE 'Command'.           00013404
              10 COLUMN 32        PIC A(10)  VALUE 'Subcommand'.        00013504
              10 COLUMN 83        PIC A(13)  VALUE 'Scheduled for'.     00013604
           05 LINE PLUS 1.                                              00013702
              10 COLUMN 03        PIC X(17)  VALUE '-----------------'. 00013804
              10 COLUMN 22        PIC X(07)  VALUE '-------'.           00013904
              10 COLUMN 32        PIC X(50)  VALUE                      00014004
                   '--------------------------------------------------'.00014104
              10 COLUMN 83        PIC X(50)  VALUE                      00014204
                   '--------------------------------------------------'.00014304
       01  REPORT-DETAIL TYPE DETAIL.                                   00014401
           05 LINE PLUS 1.                                              00014501
              10 COLUMN 01        PIC X      SOURCE REP-EXEC-RESULT.    00014604
              10 COLUMN 03        PIC XX     SOURCE REP-DATE-SUBMI-DD.  00014704
              10 COLUMN 05        PIC X      VALUE '/'.                 00014804
              10 COLUMN 06        PIC XX     SOURCE REP-DATE-SUBMI-MM.  00014904
              10 COLUMN 08        PIC X      VALUE '/'.                 00015004
              10 COLUMN 09        PIC XX     SOURCE REP-DATE-SUBMI-YY.  00015104
              10 COLUMN 12        PIC XX     SOURCE REP-TIME-SUBMI-HH.  00015204
              10 COLUMN 14        PIC X      VALUE ':'.                 00015304
              10 COLUMN 15        PIC XX     SOURCE REP-TIME-SUBMI-MM.  00015404
              10 COLUMN 17        PIC X      VALUE ':'.                 00015504
              10 COLUMN 18        PIC XX     SOURCE REP-TIME-SUBMI-SS.  00015604
              10 COLUMN 22        PIC A(06)  SOURCE REP-COMMAND.        00015704
              10 COLUMN 32        PIC X(50)  SOURCE REP-SUBCOMMAND.     00015804
              10 COLUMN 83        PIC X(50)  SOURCE WS-SCHEDULED.       00015904
      ******************************************************************00016001
       PROCEDURE DIVISION.                                              00016101
      ******************************************************************00016201
       0000-MAIN.                                                       00016301
           PERFORM 0001-INITIALISE THRU 0001-EXIT.                      00016401
           PERFORM 1000-READ-REPORT-RECORDS THRU 1000-EXIT              00016501
               UNTIL EOF.                                               00016601
           TERMINATE SUBMITS-REPORT.                                    00016701
           CLOSE REPORT-FILE.                                           00016801
       0000-EXIT.                                                       00016901
           STOP RUN.                                                    00017001
      **********************************                                00017101
       0001-INITIALISE.                                                 00017201
      **********************************                                00017301
           MOVE CURRENT-DATE TO WS-TODAYS-DATE.                         00017401
           MOVE TIME-OF-DAY  TO WS-TODAYS-TIME.                         00017501
           OPEN INPUT  REPORT-FILE,                                     00017601
                OUTPUT REPORT-PRINT.                                    00017701
           INITIATE SUBMITS-REPORT.                                     00017801
       0001-EXIT.                                                       00017901
           EXIT.                                                        00018001
      **********************************                                00018101
       1000-READ-REPORT-RECORDS.                                        00018201
      **********************************                                00018301
           READ REPORT-FILE                                             00018401
               AT END MOVE 'Y' TO END-OF-FILE.                          00018501
           IF NOT EOF THEN                                              00018601
               PERFORM 2000-PROCESS-REPORT-RECORD THRU 2000-EXIT.       00018704
       1000-EXIT.                                                       00018801
           EXIT.                                                        00018901
      **********************************                                00019004
       2000-PROCESS-REPORT-RECORD.                                      00019104
      **********************************                                00019204
           IF REP-DATE-SCHED-DD > 0                                     00019304
               MOVE REP-DATE-SCHED-DD TO WS-SCHED-DAY                   00019404
           ELSE                                                         00019504
               MOVE 'day'             TO WS-SCHED-DAY.                  00019604
           IF REP-DATE-SCHED-MM > 0                                     00019704
               MOVE ' of '            TO WS-SCHED-TEXT2                 00019804
               MOVE REP-DATE-SCHED-MM TO WS-MONTHS-SUB                  00019904
               MOVE WS-MONTH-NAME (WS-MONTHS-SUB)                       00020004
                                      TO WS-SCHED-MONTH                 00020104
           ELSE                                                         00020204
               MOVE SPACES            TO WS-SCHED-TEXT2                 00020304
               MOVE SPACES            TO WS-SCHED-MONTH.                00020404
           MOVE REP-TIME-SCHED-HH     TO WS-SCHED-HH.                   00020504
           MOVE REP-TIME-SCHED-MM     TO WS-SCHED-MM.                   00020604
           GENERATE REPORT-DETAIL.                                      00020704
       2000-EXIT.                                                       00020804
           EXIT.                                                        00020904
/*                                                                      00021001
//LKED.SYSLIB  DD DISP=SHR,DSNAME=SYS1.COBLIB                           00021101
//             DD DISP=SHR,DSNAME=SYS1.LINKLIB                          00021201
//             DD DISP=SHR,DSNAME=PMMS.LINKLIB                          00021301
//LKED.SYSLMOD DD DISP=SHR,DSNAME=PMMS.LINKLIB(PMMSSREP)                00021401
//                                                                      00021501
