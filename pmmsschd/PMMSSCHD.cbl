//COMPPMMS JOB (COBOL),                                                 00000100
//             'PMMSSCHD',                                              00000200
//             CLASS=A,MSGCLASS=H,                                      00000300
//             MSGLEVEL=(1,1)                                           00000400
//COMPLINK EXEC COBUCL,                                                 00000500
//         PARM.COB='LOAD,SUPMAP,SIZE=2048K,BUF=1024K'                  00000600
//COB.SYSLIB DD DISP=SHR,DSNAME=SYS1.COBLIB                             00000700
//           DD DISP=SHR,DSNAME=SYS1.LINKLIB                            00000800
//COB.SYSPUNCH DD DUMMY                                                 00000900
//COB.SYSIN DD *                                                        00001000
      ******************************************************************00001100
      * PROGRAM DESCRIPTION:                                           *00001200
      *   This program is an infinite loop.                            *00001300
      *   In the loop, the program reads from TASKLIST sequential file *00001400
      *   and for each line determines if a task should be submitted.  *00001500
      *   If a task is submitted, an entry is saved in REPORT seq. file*00001600
      *   If a task cannot be submitted, the first column will be E.   *00001700
      *                                                                *00001800
      *   TASKLIST   Input for tasks to submit.                        *00001900
      *   REPORT     Output for execution log.                         *00002000
      *   MESSAGES   Ouput for program messages.                       *00002100
      ******************************************************************00002200
      * MODIFICATION LOG:                                              *00002300
      *   12/MAY/2020 - D. ASTA - Code started.                         00002400
      ******************************************************************00002500
       IDENTIFICATION DIVISION.                                         00002600
       PROGRAM-ID.   'PMMSSCHD'.                                        00002700
       AUTHOR.       'DAVID ASTA'.                                      00002800
       INSTALLATION. 'MVS 3.8j TK4-'.                                   00002900
       DATE-WRITTEN. '12/06/2020'.                                      00003000
       DATE-COMPILED.                                                   00003100
       REMARKS.      'V1R1M0'.                                          00003200
      ******************************************************************00003300
       ENVIRONMENT DIVISION.                                            00003400
      ******************************************************************00003500
       INPUT-OUTPUT SECTION.                                            00003600
       FILE-CONTROL.                                                    00003700
           SELECT TASKLIST-FILE ASSIGN TO DA-S-INFILE.                  00003800
           SELECT REPORT-FILE   ASSIGN TO DA-S-REPORT.                  00003900
           SELECT JCLFILE       ASSIGN TO UR-S-JCLDD.                   00004000
      ******************************************************************00004100
       DATA DIVISION.                                                   00004200
      ******************************************************************00004300
       FILE SECTION.                                                    00004400
      *******************                                               00004500
       FD  TASKLIST-FILE                                                00004600
      *******************                                               00004700
           LABEL RECORDS ARE STANDARD                                   00004800
           BLOCK CONTAINS 0 RECORDS                                     00004900
           RECORD CONTAINS 80 CHARACTERS.                               00005000
       01  IN-RECORD.                                                   00005100
           05 REC-INDICATOR            PIC X.                           00005200
           05 REC-WEEKDAY.                                              00005300
              10 REC-WEEKDAY-MO        PIC X.                           00005400
              10 REC-WEEKDAY-TU        PIC X.                           00005500
              10 REC-WEEKDAY-WE        PIC X.                           00005600
              10 REC-WEEKDAY-TH        PIC X.                           00005700
              10 REC-WEEKDAY-FR        PIC X.                           00005800
              10 REC-WEEKDAY-SA        PIC X.                           00005900
              10 REC-WEEKDAY-SU        PIC X.                           00006000
           05 REC-TIME.                                                 00006100
              10 REC-TIME-HH           PIC XX.                          00006200
              10 REC-TIME-MM           PIC XX.                          00006300
           05 REC-DATE.                                                 00006400
              10 REC-DATE-DD           PIC XX.                          00006500
              10 REC-DATE-MM           PIC XX.                          00006600
           05 REC-COMMAND              PIC X(06).                       00006700
           05 REC-SUBCOMMAND           PIC X(58).                       00006800
      *******************                                               00006900
       FD  REPORT-FILE                                                  00007000
      *******************                                               00007100
           LABEL RECORDS ARE STANDARD                                   00007200
           RECORD CONTAINS 80 CHARACTERS                                00007300
           RECORDING MODE IS F.                                         00007400
       01  REP-RECORD.                                                  00007500
           05 REP-EXEC-RESULT          PIC X.                           00007600
           05 REP-DATE-SCHED.                                           00007700
              10 REP-DATE-SCHED-DD     PIC XX.                          00007800
              10 REP-DATE-SCHED-MM     PIC XX.                          00007900
           05 REP-TIME-SCHED.                                           00008000
              10 REP-TIME-SCHED-HH     PIC XX.                          00008100
              10 REP-TIME-SCHED-MM     PIC XX.                          00008200
           05 REP-DATE-SUBMI.                                           00008300
              10 REP-DATE-SUBMI-DD     PIC 9(02).                       00008400
              10 REP-DATE-SUBMI-MM     PIC 9(02).                       00008500
              10 REP-DATE-SUBMI-YY     PIC 9(02).                       00008600
           05 REP-TIME-SUBMI           PIC 9(06).                       00008700
           05 REP-COMMAND              PIC X(06).                       00008800
           05 REP-SUBCOMMAND           PIC X(53).                       00008900
      *******************                                               00009000
       FD  JCLFILE                                                      00009100
      *******************                                               00009200
           LABEL RECORDS ARE OMITTED                                    00009300
           RECORD CONTAINS 80 CHARACTERS                                00009400
           RECORDING MODE IS F.                                         00009500
       01  OUTPUT-REC                  PIC X(80).                       00009600
      **********************************                                00009700
       WORKING-STORAGE SECTION.                                         00009800
      **********************************                                00009900
       01  SWITCHES.                                                    00010000
           05 WS-STOP-LOOP-SW          PIC X        VALUE 'N'.          00010100
              88 WS-STOP-LOOP                       VALUE 'Y'.          00010200
           05 WS-EOF-SW                PIC X        VALUE 'N'.          00010300
              88 WS-EOF                             VALUE 'Y'.          00010400
           05 WS-VALID-DATA-SW         PIC X        VALUE 'Y'.          00010500
              88 WS-VALID-DATA                      VALUE 'Y'.          00010600
           05 WS-SUBMIT-SW             PIC X        VALUE 'Y'.          00010700
              88 WS-SUBMIT                          VALUE 'Y'.          00010800
       01  COUNTERS.                                                    00010900
           05 WS-COUNT-CMMD            PIC 9.                           00011000
           05 WS-COUNT-SCMD            PIC 9.                           00011100
           05 WS-COUNT-WDAY            PIC 9.                           00011200
       01  WS-TODAYS-DATE.                                              00011300
           05 TD-MONTH                 PIC X(02).                       00011400
           05 FILLER                   PIC X.                           00011500
           05 TD-DAY                   PIC X(02).                       00011600
           05 FILLER                   PIC X.                           00011700
           05 TD-YEAR                  PIC X(02).                       00011800
       01  WS-TODAYS-TIME.                                              00011900
           05 TT-HOURS                 PIC 9(02).                       00012000
           05 TT-MINUTES               PIC 9(02).                       00012100
           05 TT-SECONDS               PIC 9(02).                       00012200
       01  WS-TODAYS-TIME-HHMM REDEFINES WS-TODAYS-TIME PIC 9(04).      00012300
       01  WS-DAY1                     PIC X(02).                       00012400
       01  WS-DAY2                     PIC X(02).                       00012500
       01  WS-DIFF-START-END-TIME.                                      00012600
           05 WS-START-HHMM            PIC 9(02).                       00012700
       01  WS-DIFF-START-END-TIME.                                      00012800
           05 WS-START-HHMMSSHS.                                        00012900
              10 WS-START-HH           PIC 9(02).                       00013000
              10 WS-START-MM           PIC 9(02).                       00013100
              10 WS-START-SS           PIC 9(02)    VALUE ZERO.         00013200
              10 WS-START-HUNDRS       PIC 9(02)    VALUE ZERO.         00013300
           05 WS-DIFF-HHMMSSHS.                                         00013400
              10 WS-DIFF-HH            PIC 9(02).                       00013500
              10 WS-DIFF-MM            PIC 9(02).                       00013600
              10 WS-DIFF-SS            PIC 9(02).                       00013700
              10 WS-DIFF-HUNDRS        PIC 9(02).                       00013800
           05 WS-DIFF-START-TIME       PIC 9(11).                       00013900
           05 WS-DIFF-END-TIME         PIC 9(11).                       00014000
           05 WS-DIFF-TIME             PIC 9(11).                       00014100
           05 WS-DIFF-TOTMINS          PIC 9(04).                       00014200
       01  WS-ZELLER-FORMULA.                                           00014300
           05 WS-DD                    PIC 9(02).                       00014400
           05 WS-MM                    PIC 9(02).                       00014500
           05 WS-YY1                   PIC 9(02).                       00014600
           05 WS-YY2                   PIC 9(02).                       00014700
           05 WS-PART1                 PIC 9(03).                       00014800
           05 WS-PART2                 PIC 9(02).                       00014900
           05 WS-PART3                 PIC 9(02).                       00015000
           05 WS-PART4                 PIC 9(02).                       00015100
           05 WS-PART5                 PIC 9(03).                       00015200
           05 WS-DOW                   PIC 9.                           00015300
       01  WS-UNSTRING-SUBCMD.                                          00015400
           05 WS-SUBCMD-PARM1          PIC X(10).                       00015500
           05 WS-SUBCMD-PARM2          PIC X(04).                       00015600
       01  WS-JCLREC                   PIC X(80).                       00015700
       01  WS-STRING-JCL.                                               00015800
           05 WS-STRING-DSN-CMD        PIC X(36).                       00015900
           05 WS-STRING-FULL.                                           00016000
              10 WS-STRING-DSN-SYSUT1  PIC X(26).                       00016100
              10 WS-SUBCOMMAND         PIC X(46).                       00016200
       01  WS-SLEEP-PARM.                                               00016300
           05 WS-SLEEP-PARM-LENGTH     PIC 999 COMP VALUE 4.            00016400
           05 WS-SLEEP-PARM-TEXT       PIC X(04).                       00016500
       01  WS-SLEEP-TIME.                                               00016600
           05 WS-SLEEP-SECS-UNSIGN     PIC 9(04).                       00016700
           05 WS-SLEEP-MINS-UNSIGN     PIC 9(04).                       00016800
      ******************************************************************00016900
       PROCEDURE DIVISION.                                              00017000
      ******************************************************************00017100
       0000-MAIN.                                                       00017200
      **********************************                                00017300
           PERFORM 0001-INITIALISE.                                     00017400
           PERFORM 0002-LOOP THRU 0002-EXIT                             00017500
               UNTIL WS-STOP-LOOP.                                      00017600
           PERFORM 0009-LEAVE.                                          00017700
      **********************************                                00017800
       0001-INITIALISE.                                                 00017900
      **********************************                                00018000
           MOVE '//SYSUT1 DD  DISP=SHR,DSN=' TO WS-STRING-DSN-SYSUT1.   00018100
           MOVE 10      TO WS-SLEEP-MINS-UNSIGN.                        00018200
           MOVE ZERO    TO WS-DOW.                                      00018300
           MOVE 'N'     TO WS-STOP-LOOP-SW.                             00018400
           MOVE CURRENT-DATE TO WS-TODAYS-DATE.                         00018500
           MOVE TD-DAY TO WS-DAY1.                                      00018600
           MOVE TD-DAY TO WS-DAY2.                                      00018700
           PERFORM 9000-GET-DAY-OF-THE-WEEK THRU 9000-EXIT.             00018800
           DISPLAY 'SCHEDULER STARTED: ' WS-TODAYS-TIME.                00018900
           PERFORM 9200-RECALC-SLEEP-TIME.                              00019000
           OPEN OUTPUT REPORT-FILE.                                     00019100
      **********************************                                00019200
       0002-LOOP.                                                       00019300
      **********************************                                00019400
           MOVE CURRENT-DATE TO WS-TODAYS-DATE.                         00019500
           MOVE TD-DAY TO WS-DAY1.                                      00019600
           IF NOT WS-DAY1 = WS-DAY2 THEN                                00019700
               MOVE TD-DAY TO WS-DAY2                                   00019800
               PERFORM 9000-GET-DAY-OF-THE-WEEK THRU 9000-EXIT.         00019900
           MOVE TIME-OF-DAY TO WS-TODAYS-TIME.                          00020000
           OPEN INPUT  TASKLIST-FILE.                                   00020100
           MOVE 'N' TO WS-EOF-SW.                                       00020200
           PERFORM 3000-READ-TASKLIST-RECORDS THRU 3000-EXIT            00020302
               UNTIL WS-EOF.                                            00020400
           CLOSE TASKLIST-FILE.                                         00020500
           IF NOT WS-STOP-LOOP THEN                                     00020600
               PERFORM 0003-SLEEP.                                      00020700
       0002-EXIT.                                                       00020800
           EXIT.                                                        00020900
      **********************************                                00021000
       0003-SLEEP.                                                      00021100
      **********************************                                00021200
           CALL 'SLEEP' USING WS-SLEEP-PARM.                            00021300
      **********************************                                00021400
       0009-LEAVE.                                                      00021500
      **********************************                                00021600
           CLOSE REPORT-FILE.                                           00021700
           DISPLAY 'SCHEDULER STOPPED: ' WS-TODAYS-TIME.                00021800
           STOP RUN.                                                    00021900
      **********************************                                00022000
       3000-READ-TASKLIST-RECORDS.                                      00022100
      **********************************                                00022200
           READ TASKLIST-FILE                                           00022300
               AT END MOVE 'Y' TO WS-EOF-SW.                            00022400
           IF NOT WS-EOF THEN                                           00022500
             PERFORM 4000-PROCESS-TASKLIST-RECORD THRU 4000-EXIT.       00022600
       3000-EXIT.                                                       00022702
           EXIT.                                                        00022800
      **********************************                                00022900
       3100-UPDATE-REPORT.                                              00023000
      **********************************                                00023100
           MOVE REC-INDICATOR  TO REP-EXEC-RESULT.                      00023200
           MOVE REC-DATE-DD    TO REP-DATE-SCHED-DD.                    00023300
           MOVE REC-DATE-MM    TO REP-DATE-SCHED-MM.                    00023400
           MOVE REC-TIME       TO REP-TIME-SCHED.                       00023500
           MOVE TD-DAY         TO REP-DATE-SUBMI-DD.                    00023600
           MOVE TD-MONTH       TO REP-DATE-SUBMI-MM.                    00023700
           MOVE TD-YEAR        TO REP-DATE-SUBMI-YY.                    00023800
           MOVE WS-TODAYS-TIME TO REP-TIME-SUBMI.                       00023900
           MOVE REC-COMMAND    TO REP-COMMAND.                          00024000
           MOVE REC-SUBCOMMAND TO REP-SUBCOMMAND.                       00024100
           WRITE REP-RECORD.                                            00024200
       3100-EXIT.                                                       00024300
           EXIT.                                                        00024400
      **********************************                                00024500
       4000-PROCESS-TASKLIST-RECORD.                                    00024600
      **********************************                                00024700
      *  Check that line is not a comment                               00024800
           MOVE 'N' TO WS-SUBMIT-SW.                                    00024900
           IF REC-INDICATOR = ' ' THEN                                  00025000
               PERFORM 4001-VALIDATE-RECORD THRU 4001-EXIT              00025100
           IF REC-INDICATOR = ' ' AND WS-VALID-DATA THEN                00025200
                   PERFORM 5000-CHECK-WHEN-TO-SUBMIT THRU 5000-EXIT     00025300
           IF REC-INDICATOR = ' ' AND WS-SUBMIT THEN                    00025400
               PERFORM 5400-CHECK-TIME-IS-NOW THRU 5400-EXIT.           00025500
      *  What kind of COMMAND is?                                       00025600
           IF REC-INDICATOR = ' ' AND WS-SUBMIT THEN                    00025700
               PERFORM 4002-WHAT-COMMAND-IS THRU 4002-EXIT.             00025800
           IF REC-INDICATOR = ' ' AND WS-SUBMIT THEN                    00025900
               PERFORM 3100-UPDATE-REPORT THRU 3100-EXIT.               00026000
       4000-EXIT.                                                       00026100
           EXIT.                                                        00026200
      **********************************                                00026300
       4001-VALIDATE-RECORD.                                            00026400
      **********************************                                00026500
           MOVE 'Y' TO WS-VALID-DATA-SW.                                00026600
      *  Check that mandatory fields exist                              00026700
           MOVE ZERO TO WS-COUNT-CMMD                                   00026800
           MOVE ZERO TO WS-COUNT-SCMD                                   00026900
           MOVE ZERO TO WS-COUNT-WDAY                                   00027000
           EXAMINE REC-COMMAND TALLYING UNTIL FIRST ' '.                00027100
           MOVE TALLY TO WS-COUNT-CMMD.                                 00027200
           EXAMINE REC-SUBCOMMAND TALLYING UNTIL FIRST ' '.             00027300
           MOVE TALLY TO WS-COUNT-SCMD.                                 00027400
           IF WS-COUNT-CMMD = 0 OR WS-COUNT-SCMD = 0 THEN               00027500
               MOVE 'N' TO WS-VALID-DATA-SW.                            00027600
      *  Does the record contain weekdays?                              00027700
           IF WS-VALID-DATA THEN                                        00027800
               EXAMINE REC-WEEKDAY TALLYING ALL 'X'                     00027900
               MOVE TALLY TO WS-COUNT-WDAY.                             00028000
       4001-EXIT.                                                       00028100
           EXIT.                                                        00028200
      **********************************                                00028300
       4002-WHAT-COMMAND-IS.                                            00028400
      **********************************                                00028500
           IF REC-COMMAND IS EQUAL TO 'SUBMIT' THEN                     00028600
               PERFORM 7000-WRITE-SUBMIT-JCL.                           00028700
           IF REC-COMMAND IS EQUAL TO 'CONFIG' THEN                     00028800
               PERFORM 8000-CHANGE-CONFIG THRU 8000-EXIT.               00028900
       4002-EXIT.                                                       00029000
           EXIT.                                                        00029100
      **********************************                                00029200
       5000-CHECK-WHEN-TO-SUBMIT.                                       00029300
      **********************************                                00029400
      * Valid scenarios:                                                00029500
      * Weekday = submit on the day of the week of any day and any month00029600
      * Weekday + Month = submit on the day of the week of the month    00029700
      * Weekday + Day = submit on the day of the week of the day        00029800
      * Weekday + Month + Day = submit on the day of the week of the    00029900
      *                         day of the month                        00030000
      * No Weekday + Month = ERROR. No day or weekday.                  00030100
      * No Weekday + Day = submit on the day of any month               00030200
      * No Weekday + Month + Day = submit on the day of the month       00030300
      *                                                                 00030400
           MOVE 'Y' TO WS-SUBMIT-SW.                                    00030500
           IF REC-DATE-MM > 0 THEN                                      00030600
               PERFORM 5200-CHECK-MONTH-IS-TODAY THRU 5200-EXIT         00030700
               IF REC-DATE-DD = ' ' AND WS-COUNT-WDAY = 0 THEN          00030800
      *          There is month, but there is not day nor weekday       00030900
                   MOVE 'N' TO WS-SUBMIT-SW.                            00031000
           IF WS-SUBMIT AND REC-DATE-DD > 0 THEN                        00031100
               PERFORM 5300-CHECK-DAY-IS-TODAY THRU 5300-EXIT.          00031200
           IF WS-SUBMIT AND WS-COUNT-WDAY > 0 THEN                      00031300
               PERFORM 5100-CHECK-WEEKDAY-IS-TODAY THRU 5100-EXIT.      00031400
       5000-EXIT.                                                       00031500
           EXIT.                                                        00031600
      **********************************                                00031700
       5100-CHECK-WEEKDAY-IS-TODAY.                                     00031800
      **********************************                                00031900
           MOVE 'N' TO WS-SUBMIT-SW.                                    00032000
      *  Monday                                                         00032100
           IF WS-DOW = 1 AND REC-WEEKDAY-MO = 'X' THEN                  00032200
               MOVE 'Y' TO WS-SUBMIT-SW                                 00032300
               GO TO 5100-EXIT.                                         00032400
      *  Tuesday                                                        00032500
           IF WS-DOW = 2 AND REC-WEEKDAY-TU = 'X' THEN                  00032600
               MOVE 'Y' TO WS-SUBMIT-SW                                 00032700
               GO TO 5100-EXIT.                                         00032800
      *  Wednesday                                                      00032900
           IF WS-DOW = 3 AND REC-WEEKDAY-WE = 'X' THEN                  00033000
               MOVE 'Y' TO WS-SUBMIT-SW                                 00033100
               GO TO 5100-EXIT.                                         00033200
      *  Thursday                                                       00033300
           IF WS-DOW = 4 AND REC-WEEKDAY-TH = 'X' THEN                  00033400
               MOVE 'Y' TO WS-SUBMIT-SW                                 00033500
               GO TO 5100-EXIT.                                         00033600
      *  Friday                                                         00033700
           IF WS-DOW = 5 AND REC-WEEKDAY-FR = 'X' THEN                  00033800
               MOVE 'Y' TO WS-SUBMIT-SW                                 00033900
               GO TO 5100-EXIT.                                         00034000
      *  Saturday                                                       00034100
           IF WS-DOW = 6 AND REC-WEEKDAY-SA = 'X' THEN                  00034200
               MOVE 'Y' TO WS-SUBMIT-SW                                 00034300
               GO TO 5100-EXIT.                                         00034400
      *  Sunday                                                         00034500
           IF WS-DOW = 7 AND REC-WEEKDAY-SU = 'X' THEN                  00034600
               MOVE 'Y' TO WS-SUBMIT-SW.                                00034700
       5100-EXIT.                                                       00034800
           EXIT.                                                        00034900
      **********************************                                00035000
       5200-CHECK-MONTH-IS-TODAY.                                       00035100
      **********************************                                00035200
           IF REC-DATE-MM = TD-MONTH THEN                               00035300
               MOVE 'Y' TO WS-SUBMIT-SW                                 00035400
           ELSE                                                         00035500
               MOVE 'N' TO WS-SUBMIT-SW.                                00035600
       5200-EXIT.                                                       00035700
           EXIT.                                                        00035800
      **********************************                                00035900
       5300-CHECK-DAY-IS-TODAY.                                         00036000
      **********************************                                00036100
           IF REC-DATE-DD = TD-DAY THEN                                 00036200
               MOVE 'Y' TO WS-SUBMIT-SW                                 00036300
           ELSE                                                         00036400
               MOVE 'N' TO WS-SUBMIT-SW.                                00036500
       5300-EXIT.                                                       00036600
           EXIT.                                                        00036700
      **********************************                                00036800
       5400-CHECK-TIME-IS-NOW.                                          00036900
      **********************************                                00037000
           IF REC-TIME IS LESS THAN WS-TODAYS-TIME-HHMM                 00037100
                       OR EQUAL TO WS-TODAYS-TIME-HHMM                  00037200
               PERFORM 9100-CALC-DIFF-TIMES THRU 9100-EXIT              00037300
           ELSE                                                         00037400
               MOVE 'N' TO WS-SUBMIT-SW.                                00037500
       5400-EXIT.                                                       00037600
           EXIT.                                                        00037700
      **********************************                                00037800
       7000-WRITE-SUBMIT-JCL.                                           00037900
      **********************************                                00038000
           OPEN OUTPUT JCLFILE.                                         00038100
      * Compose JCL to be submitted                                     00038200
           MOVE '//PMMSSUBM JOB ,'                   TO WS-JCLREC.      00038300
           WRITE OUTPUT-REC                        FROM WS-JCLREC.      00038400
           MOVE '//             CLASS=A,MSGCLASS=A'  TO WS-JCLREC.      00038500
           WRITE OUTPUT-REC                        FROM WS-JCLREC.      00038600
           MOVE '/*JOBPARM ROOM=PMMS'                TO WS-JCLREC.      00038701
           WRITE OUTPUT-REC                        FROM WS-JCLREC.      00038801
           MOVE '//STEP01  EXEC PGM=IEBGENER'        TO WS-JCLREC.      00038900
           WRITE OUTPUT-REC                        FROM WS-JCLREC.      00039000
           MOVE REC-SUBCOMMAND                       TO WS-SUBCOMMAND.  00039100
           MOVE WS-STRING-FULL                       TO WS-JCLREC.      00039200
           WRITE OUTPUT-REC                        FROM WS-JCLREC.      00039300
           MOVE '//SYSUT2   DD SYSOUT=(,INTRDR)'     TO WS-JCLREC.      00039400
           WRITE OUTPUT-REC                        FROM WS-JCLREC.      00039500
           MOVE '//SYSPRINT DD SYSOUT=*'             TO WS-JCLREC.      00039600
           WRITE OUTPUT-REC                        FROM WS-JCLREC.      00039700
           MOVE '//SYSIN    DD DUMMY'                TO WS-JCLREC.      00039800
           WRITE OUTPUT-REC                        FROM WS-JCLREC.      00039900
           CLOSE JCLFILE.                                               00040000
       7000-EXIT.                                                       00040100
           EXIT.                                                        00040200
      **********************************                                00040300
       8000-CHANGE-CONFIG.                                              00040400
      **********************************                                00040500
           MOVE REC-SUBCOMMAND TO WS-UNSTRING-SUBCMD.                   00040600
           IF WS-SUBCMD-PARM1 IS EQUAL TO 'STOP' THEN                   00040700
               GO TO 8001-CHANGE-CONFIG-STOP.                           00040800
           IF WS-SUBCMD-PARM1 IS EQUAL TO 'INTERVAL' THEN               00040900
               GO TO 8002-CHANGE-CONFIG-INTERVAL.                       00041000
       8000-EXIT.                                                       00041100
           EXIT.                                                        00041200
      **********************************                                00041300
       8001-CHANGE-CONFIG-STOP.                                         00041400
      **********************************                                00041500
           MOVE 'Y'     TO WS-STOP-LOOP-SW.                             00041600
           GO TO 8000-EXIT.                                             00041700
      **********************************                                00041800
       8002-CHANGE-CONFIG-INTERVAL.                                     00041900
      **********************************                                00042000
           MOVE WS-SUBCMD-PARM2 TO WS-SLEEP-MINS-UNSIGN.                00042100
           PERFORM 9200-RECALC-SLEEP-TIME.                              00042200
           GO TO 8000-EXIT.                                             00042300
      **********************************                                00042400
       9000-GET-DAY-OF-THE-WEEK.                                        00042500
      **********************************                                00042600
      * Calculate the day of the week for any date, using Zeller''s Rule00042700
      *                                                                 00042800
      * Formula: d + ((13 * m - 1) / 5) + y + (y / 4) + (c / 4) - 2 * c 00042900
      *   Where:                                                        00043000
      *          d is the day of the month                              00043100
      *          m is the month number, but starting with March=1       00043200
      *          c is the first two digits of the year                  00043300
      *          y is the last two digits of the year                   00043400
      *                                                                 00043500
      *   I have broken it up in parts for easy understanding:          00043600
      *     WS-PART1 = (13 * m - 1) / 5)                                00043700
      *     WS-PART2 = (y / 4)                                          00043800
      *     WS-PART3 = (c / 4)                                          00043900
      *     WS-PART4 = 2 + c                                            00044000
      *     WS-PART5 = d + WS-PART1 + y + WS-PART2 + WS-PART3 - WS-PART400044100
      *     WS-DOW   = WS-PART5 mod 7                                   00044200
      *                                                                 00044300
      * Limitations:                                                    00044400
      *    Only works for years between 2000 and 2099                   00044500
      *      The CURRENT-DATE function of this COBOL compiler           00044600
      *         gives the date in format MM/DD/YY, so I hardcoded the   00044700
      *         first part of the year (century) to 20.                 00044800
      *    Only works for Gregorian calendar (i.e. after 14th Sept 1752)00044900
      **********************************                                00045000
           MOVE TD-DAY   TO WS-DD.                                      00045100
           MOVE TD-MONTH TO WS-MM.                                      00045200
           MOVE TD-YEAR  TO WS-YY2.                                     00045300
      * Convert YY to YYYY, using 20 for century                        00045400
           MOVE 20      TO WS-YY1.                                      00045500
      * In Zeller''rule, months do not start on January but March       00045600
           IF WS-MM IS GREATER THAN 2 THEN                              00045700
               SUBTRACT 2 FROM WS-MM                                    00045800
           ELSE                                                         00045900
               ADD 10 TO WS-MM.                                         00046000
      * In Zeller''rule, year must be decreased by 1 when               00046100
      *   using January or February                                     00046200
           IF WS-MM EQUAL 11 OR WS-MM EQUAL 12 THEN                     00046300
               SUBTRACT 1 FROM WS-YY2.                                  00046400
      * Perform Zeller''s calculation                                   00046500
      *  WS-PART1 = (13 * m - 1) / 5                                    00046600
           COMPUTE WS-PART1 = 13 * WS-MM - 1.                           00046700
           DIVIDE WS-PART1 BY 5 GIVING WS-PART1.                        00046800
      *  WS-PART2 = (y / 4)                                             00046900
           DIVIDE WS-YY2 BY 4 GIVING WS-PART2.                          00047000
      *  WS-PART3 = (c / 4)                                             00047100
           DIVIDE WS-YY1 BY 4 GIVING WS-PART3.                          00047200
      *  WS-PART4 = 2 * c                                               00047300
           MULTIPLY 2 BY WS-YY1 GIVING WS-PART4.                        00047400
      *  WS-PART5 = d + WS-PART1 + y + WS-PART2 + WS-PART3 - WS-PART4   00047500
           COMPUTE WS-PART5 = WS-DD + WS-PART1 + WS-YY2 + WS-PART2.     00047600
           COMPUTE WS-PART5 = WS-PART5 + WS-PART3 - WS-PART4            00047700
      *  WS-DOW   = WS-PART5 mod 7                                      00047800
           DIVIDE WS-PART5 BY 7 GIVING WS-PART5 REMAINDER WS-DOW.       00047900
           IF WS-DOW = 0 THEN                                           00048000
               MOVE 7 TO WS-DOW.                                        00048100
       9000-EXIT.                                                       00048200
           EXIT.                                                        00048300
      **********************************                                00048400
       9100-CALC-DIFF-TIMES.                                            00048500
      **********************************                                00048600
           MOVE 'N'  TO WS-SUBMIT-SW.                                   00048700
           MOVE ZERO TO WS-DIFF-HHMMSSHS                                00048800
                        WS-DIFF-START-TIME                              00048900
                        WS-DIFF-END-TIME                                00049000
                        WS-DIFF-TIME                                    00049100
                        WS-DIFF-TOTMINS.                                00049200
      * Start time = Time in the record                                 00049300
           MOVE REC-TIME-HH TO WS-START-HH.                             00049400
           MOVE REC-TIME-MM TO WS-START-MM.                             00049500
           COMPUTE WS-DIFF-START-TIME = WS-START-HH * 60.               00049600
           COMPUTE WS-DIFF-START-TIME =                                 00049700
                  (WS-DIFF-START-TIME + WS-START-MM) * 60.              00049800
           COMPUTE WS-DIFF-START-TIME = WS-DIFF-START-TIME * 100.       00049900
      * End time = current time                                         00050000
           COMPUTE WS-DIFF-END-TIME = TT-HOURS * 60.                    00050100
           COMPUTE WS-DIFF-END-TIME =                                   00050200
                  (WS-DIFF-END-TIME + TT-MINUTES) * 60.                 00050300
           COMPUTE WS-DIFF-END-TIME = WS-DIFF-END-TIME * 100.           00050400
      * Calc time difference                                            00050500
           COMPUTE WS-DIFF-TIME = WS-DIFF-END-TIME - WS-DIFF-START-TIME.00050600
           DIVIDE WS-DIFF-TIME BY 100 GIVING WS-DIFF-TIME               00050700
                                      REMAINDER WS-DIFF-HUNDRS.         00050800
           DIVIDE WS-DIFF-TIME BY 60  GIVING WS-DIFF-TIME               00050900
                                      REMAINDER WS-DIFF-SS.             00051000
           MOVE WS-DIFF-TIME TO WS-DIFF-TOTMINS.                        00051100
           IF WS-DIFF-TOTMINS < WS-SLEEP-MINS-UNSIGN                    00051200
               MOVE 'Y' TO WS-SUBMIT-SW.                                00051300
       9100-EXIT.                                                       00051400
           EXIT.                                                        00051500
      **********************************                                00051600
       9200-RECALC-SLEEP-TIME.                                          00051700
      **********************************                                00051800
           MOVE ZERO TO WS-SLEEP-SECS-UNSIGN.                           00051900
           MULTIPLY WS-SLEEP-MINS-UNSIGN BY 60                          00052000
                    GIVING WS-SLEEP-SECS-UNSIGN.                        00052100
           MOVE WS-SLEEP-SECS-UNSIGN TO WS-SLEEP-PARM-TEXT.             00052200
           MOVE TIME-OF-DAY  TO WS-TODAYS-TIME.                         00052300
       9200-EXIT.                                                       00052400
           EXIT.                                                        00052500
/*                                                                      00052600
//LKED.SYSLIB  DD DISP=SHR,DSNAME=SYS1.COBLIB                           00052700
//             DD DISP=SHR,DSNAME=SYS1.LINKLIB                          00052800
//             DD DISP=SHR,DSNAME=PMMS.LINKLIB                          00052900
//LKED.SYSLMOD DD DISP=SHR,DSNAME=PMMS.LINKLIB(PMMSSCHD)                00053000
//                                                                      00053100
