//PMMSTREP JOB (COBOL),                                                 00000100
//             'PMMSTREP',                                              00000200
//             CLASS=A,MSGCLASS=H,                                      00000300
//             MSGLEVEL=(1,1)                                           00000400
//COMPLINK EXEC COBUCL                                                  00000500
//COB.SYSLIB DD DISP=SHR,DSNAME=SYS1.COBLIB                             00000600
//           DD DISP=SHR,DSNAME=SYS1.LINKLIB                            00000700
//COB.SYSPUNCH DD DUMMY                                                 00000800
//COB.SYSIN DD *                                                        00000900
      ******************************************************************00001000
      * PROGRAM DESCRIPTION:                                            00001100
      *   This program is part of PMMS.                                 00001200
      *   Generates a printed report of all enries in PMMS.DATA.TASKLIST00001300
      ******************************************************************00001400
       IDENTIFICATION DIVISION.                                         00001500
       PROGRAM-ID.   'PMMSTREP'.                                        00001600
       AUTHOR.       'DAVID ASTA'.                                      00001700
       INSTALLATION. 'MVS 3.8j TK4-'.                                   00001800
       DATE-WRITTEN. '09/07/2020'.                                      00001900
       DATE-COMPILED.                                                   00002000
      ******************************************************************00002100
       ENVIRONMENT DIVISION.                                            00002200
      ******************************************************************00002300
       INPUT-OUTPUT SECTION.                                            00002400
       FILE-CONTROL.                                                    00002500
           SELECT TASKLIST-FILE ASSIGN DA-S-TASKFILE.                   00002600
           SELECT REPORT-PRINT  ASSIGN UR-S-SYSPRINT.                   00002700
      ******************************************************************00002800
       DATA DIVISION.                                                   00002900
      ******************************************************************00003000
       FILE SECTION.                                                    00003100
      **********************************                                00003200
       FD  TASKLIST-FILE                                                00003301
      **********************************                                00003400
           LABEL RECORDS ARE STANDARD                                   00003500
           BLOCK CONTAINS 0 RECORDS                                     00003600
           RECORD CONTAINS 80 CHARACTERS.                               00003700
       01  TSK-RECORD.                                                  00003800
           05 REC-INDICATOR           PIC X.                            00003900
           05 REC-WEEKDAY.                                              00004000
              10 REC-WEEKDAY-MO       PIC X.                            00004100
              10 REC-WEEKDAY-TU       PIC X.                            00004200
              10 REC-WEEKDAY-WE       PIC X.                            00004300
              10 REC-WEEKDAY-TH       PIC X.                            00004400
              10 REC-WEEKDAY-FR       PIC X.                            00004500
              10 REC-WEEKDAY-SA       PIC X.                            00004600
              10 REC-WEEKDAY-SU       PIC X.                            00004700
           05 REC-TIME.                                                 00004800
              10 REC-TIME-HH          PIC XX.                           00004900
              10 REC-TIME-MM          PIC XX.                           00005000
           05 REC-DATE.                                                 00005100
              10 REC-DATE-DD          PIC XX.                           00005200
              10 REC-DATE-MM          PIC XX.                           00005300
           05 REC-COMMAND             PIC X(06).                        00005400
           05 REC-SUBCOMMAND          PIC X(58).                        00005500
      **********************                                            00005600
       FD  REPORT-PRINT                                                 00005700
      **********************                                            00005800
           LABEL RECORDS ARE OMITTED                                    00005900
           REPORT IS TASKLIST-REPORT.                                   00006001
      **********************************                                00006100
       WORKING-STORAGE SECTION.                                         00006200
      **********************************                                00006300
       01  SWITCHES.                                                    00006400
           05 END-OF-FILE             PIC X      VALUE 'N'.             00006500
              88 EOF                             VALUE 'Y'.             00006600
       01  WS-TODAYS-DATE.                                              00006700
           05 TD-MONTH                PIC X(02).                        00006800
           05 FILLER                  PIC X.                            00006900
           05 TD-DAY                  PIC X(02).                        00007000
           05 FILLER                  PIC X.                            00007100
           05 TD-YEAR                 PIC X(02).                        00007200
       01  WS-TODAYS-TIME.                                              00007300
           05 TT-HOURS                PIC 9(02).                        00007400
           05 TT-MINUTES              PIC 9(02).                        00007500
           05 TT-SECONDS              PIC 9(02).                        00007600
      **********************************                                00007700
       REPORT SECTION.                                                  00007800
      **********************************                                00007900
       RD  TASKLIST-REPORT                                              00008001
           PAGE LIMIT IS 66 LINES                                       00008100
           HEADING 1                                                    00008200
           FIRST DETAIL 5                                               00008300
           LAST DETAIL 58.                                              00008400
       01  PAGE-HEAD-GROUP TYPE PAGE HEADING.                           00008500
           05 LINE 1.                                                   00008600
              10 COLUMN 01        PIC X(05)  VALUE 'DATE:'.             00008700
              10 COLUMN 07        PIC 99     SOURCE TD-DAY.             00008800
              10 COLUMN 09        PIC X      VALUE '/'.                 00008900
              10 COLUMN 10        PIC 99     SOURCE TD-MONTH.           00009000
              10 COLUMN 12        PIC X      VALUE '/'.                 00009100
              10 COLUMN 13        PIC 9999   SOURCE TD-YEAR.            00009200
              10 COLUMN 45        PIC A(37)  VALUE                      00009300
                                 'P M M S    C O N F I G U R A T I O N'.00009401
              10 COLUMN 122       PIC X(05)  VALUE 'PAGE:'.             00009500
              10 COLUMN 128       PIC ZZZZ9  SOURCE PAGE-COUNTER.       00009600
           05 LINE PLUS 1.                                              00009700
              10 COLUMN 01        PIC X(05)  VALUE 'TIME:'.             00009800
              10 COLUMN 07        PIC 99     SOURCE TT-HOURS.           00009900
              10 COLUMN 09        PIC X      VALUE ':'.                 00010000
              10 COLUMN 10        PIC 99     SOURCE TT-MINUTES.         00010100
              10 COLUMN 12        PIC X      VALUE ':'.                 00010200
              10 COLUMN 13        PIC 99     SOURCE TT-SECONDS.         00010300
           05 LINE PLUS 2.                                              00010400
              10 COLUMN 01        PIC A(27)  VALUE                      00010501
                                          'Mon Tue Wed Thu Fri Sat Sun'.00010601
              10 COLUMN 32        PIC A(03)  VALUE 'Day'.               00010701
              10 COLUMN 39        PIC A(05)  VALUE 'Month'.             00010801
              10 COLUMN 48        PIC A(04)  VALUE 'Time'.              00010901
              10 COLUMN 56        PIC A(07)  VALUE 'Command'.           00011001
              10 COLUMN 67        PIC A(10)  VALUE 'Subcommand'.        00011101
           05 LINE PLUS 1.                                              00011200
              10 COLUMN 01        PIC X(27)  VALUE                      00011301
                                          '---------------------------'.00011401
              10 COLUMN 32        PIC X(03)  VALUE '---'.               00011501
              10 COLUMN 39        PIC X(05)  VALUE '-----'.             00011601
              10 COLUMN 48        PIC X(05)  VALUE '-----'.             00011701
              10 COLUMN 56        PIC X(07)  VALUE '-------'.           00011801
              10 COLUMN 67        PIC X(58)  VALUE                      00011901
              '-------------------------------------------------------'.00012001
       01  REPORT-DETAIL TYPE DETAIL.                                   00012100
           05 LINE PLUS 1.                                              00012200
              10 COLUMN 02        PIC X      SOURCE REC-WEEKDAY-MO.     00012301
              10 COLUMN 06        PIC X      SOURCE REC-WEEKDAY-TU.     00012401
              10 COLUMN 10        PIC X      SOURCE REC-WEEKDAY-WE.     00012501
              10 COLUMN 14        PIC X      SOURCE REC-WEEKDAY-TH.     00012601
              10 COLUMN 18        PIC X      SOURCE REC-WEEKDAY-FR.     00012701
              10 COLUMN 22        PIC X      SOURCE REC-WEEKDAY-SA.     00012801
              10 COLUMN 26        PIC X      SOURCE REC-WEEKDAY-SU.     00012901
              10 COLUMN 32        PIC XX     SOURCE REC-DATE-DD.        00013001
              10 COLUMN 40        PIC XX     SOURCE REC-DATE-MM.        00013101
              10 COLUMN 48        PIC XX     SOURCE REC-TIME-HH.        00013201
              10 COLUMN 50        PIC X      VALUE ':'.                 00013301
              10 COLUMN 51        PIC XX     SOURCE REC-TIME-MM.        00013401
              10 COLUMN 56        PIC A(06)  SOURCE REC-COMMAND.        00013501
              10 COLUMN 67        PIC X(58)  SOURCE REC-SUBCOMMAND.     00013601
      *       10 COLUMN 130       PIC X      SOURCE REC-INDICATOR.      00013701
      ******************************************************************00013800
       PROCEDURE DIVISION.                                              00013900
      ******************************************************************00014000
       0000-MAIN.                                                       00014100
           PERFORM 0001-INITIALISE THRU 0001-EXIT.                      00014200
           PERFORM 1000-READ-TASKLIST-RECORDS THRU 1000-EXIT            00014301
               UNTIL EOF.                                               00014400
           TERMINATE TASKLIST-REPORT.                                   00014501
           CLOSE TASKLIST-FILE.                                         00014601
       0000-EXIT.                                                       00014700
           STOP RUN.                                                    00014800
      **********************************                                00014900
       0001-INITIALISE.                                                 00015000
      **********************************                                00015100
           MOVE CURRENT-DATE TO WS-TODAYS-DATE.                         00015200
           MOVE TIME-OF-DAY  TO WS-TODAYS-TIME.                         00015300
           OPEN INPUT  TASKLIST-FILE                                    00015401
                OUTPUT REPORT-PRINT.                                    00015500
           INITIATE TASKLIST-REPORT.                                    00015601
       0001-EXIT.                                                       00015700
           EXIT.                                                        00015800
      **********************************                                00015900
       1000-READ-TASKLIST-RECORDS.                                      00016001
      **********************************                                00016100
           READ TASKLIST-FILE                                           00016201
               AT END MOVE 'Y' TO END-OF-FILE.                          00016300
           IF NOT EOF THEN AND REC-INDICATOR = ' ' THEN                 00016401
               GENERATE REPORT-DETAIL.                                  00016501
       1000-EXIT.                                                       00016600
           EXIT.                                                        00016700
/*                                                                      00016800
//LKED.SYSLIB  DD DISP=SHR,DSNAME=SYS1.COBLIB                           00016900
//             DD DISP=SHR,DSNAME=SYS1.LINKLIB                          00017000
//             DD DISP=SHR,DSNAME=PMMS.LINKLIB                          00017100
//LKED.SYSLMOD DD DISP=SHR,DSNAME=PMMS.LINKLIB(PMMSTREP)                00017201
//                                                                      00017300
