//REPCNTRY    JOB (COBOL),'COVID19',CLASS=A,MSGCLASS=H,MSGLEVEL=(0,0)   00000100
//COMPLINK   EXEC COBUCL                                                00000200
//COB.SYSLIB   DD DISP=SHR,DSNAME=SYS1.COBLIB                           00000300
//             DD DISP=SHR,DSNAME=SYS1.LINKLIB                          00000400
//COB.SYSPUNCH DD DUMMY                                                 00000500
//COB.SYSIN    DD *                                                     00000600
      ******************************************************************00000700
      * PROGRAM DESCRIPTION:                                            00000800
      *   Reads COVID19.DATA.TOTCNTRY                                   00000900
      *   And generates a report of                                     00001003
      *                  - TOP 10 countries ordered by number of cases. 00001103
      *                  - TOP 10 countries ordered by number of deaths.00001203
      *                  - Up to 5 countries (favourites).              00001303
      *   Also reads COVID.DATA.TOTCPREV, to calculate a delta          00001406
      *    from previous day                                            00001506
      *                                                                 00001606
      *   Favourites countries are ACCEPTed from JCL in the form of     00001703
      *    3 character each country codes.                              00001803
      *                                                                 00001903
      *   I guess this program could have been done with SORT,          00002003
      *    but as I yet have to learn how to do it, I did it manually   00002103
      *    with tables.                                                 00002203
      ******************************************************************00002300
       IDENTIFICATION DIVISION.                                         00002400
       PROGRAM-ID.   'REPCNTRY'.                                        00002500
       AUTHOR.       'DAVID ASTA'.                                      00002600
       INSTALLATION. 'MVS 3.8J TK4-'.                                   00002700
       DATE-WRITTEN. '14/07/2020'.                                      00002800
       DATE-COMPILED.                                                   00002900
       REMARKS.      'V1R1M0'.                                          00003000
      ******************************************************************00003100
       ENVIRONMENT DIVISION.                                            00003200
      ******************************************************************00003300
       INPUT-OUTPUT SECTION.                                            00003400
       FILE-CONTROL.                                                    00003500
           SELECT TOTCNTRY-FILE  ASSIGN DA-S-TOTCTR.                    00003600
           SELECT TOTCPREV-FILE  ASSIGN DA-S-TOTPRV.                    00003706
           SELECT REPORT-PRINT   ASSIGN UR-S-SYSPRINT.                  00003800
      ******************************************************************00003900
       DATA DIVISION.                                                   00004000
      ******************************************************************00004100
       FILE SECTION.                                                    00004200
      **********************************                                00004300
       FD  TOTCNTRY-FILE                                                00004400
      *******************                                               00004500
           RECORDING MODE F                                             00004600
           LABEL RECORDS ARE STANDARD                                   00004700
           BLOCK CONTAINS 0 RECORDS                                     00004800
           RECORD CONTAINS 59 CHARACTERS.                               00004900
       01  TOT-RECORD.                                                  00005000
           05 TOT-COUNTRYCODE         PIC A(03).                        00005100
           05 TOT-CASES               PIC 9(08).                        00005200
           05 TOT-DEATHS              PIC 9(08).                        00005300
           05 TOT-COUNTRYNAME         PIC X(40).                        00005400
      *******************                                               00005506
       FD  TOTCPREV-FILE                                                00005606
      *******************                                               00005706
           RECORDING MODE F                                             00005806
           LABEL RECORDS ARE STANDARD                                   00005906
           BLOCK CONTAINS 0 RECORDS                                     00006006
           RECORD CONTAINS 59 CHARACTERS.                               00006106
       01  PRV-RECORD.                                                  00006206
           05 PRV-COUNTRYCODE         PIC A(03).                        00006306
           05 PRV-CASES               PIC 9(08).                        00006406
           05 PRV-DEATHS              PIC 9(08).                        00006506
           05 PRV-COUNTRYNAME         PIC X(40).                        00006606
      *******************                                               00006700
       FD  REPORT-PRINT                                                 00006800
      *******************                                               00006900
           LABEL RECORDS ARE OMITTED                                    00007000
           REPORT IS TOP10-REPORT.                                      00007100
      **********************************                                00007200
       WORKING-STORAGE SECTION.                                         00007300
      **********************************                                00007400
       77  WS-YEAR-CC                 PIC 99     VALUE 20.              00007503
       77  WS-CASES                   PIC 9(08).                        00007603
       77  WS-DEATHS                  PIC 9(08).                        00007702
       01  SWITCHES.                                                    00007800
           05 END-OF-FILE             PIC X      VALUE 'N'.             00007900
              88 EOF                             VALUE 'Y'.             00008000
       01  COUNTERS.                                                    00008100
           05 COUNTER-TAB-OCCURS      PIC 99     VALUE 10.              00008200
       01  SUBSCRIPTS.                                                  00008300
           05 WS-TABLE-SUB            PIC S99.                          00008400
           05 WS-TABLE-SUB-FAVS       PIC S99.                          00008503
           05 WS-MOVE-SUB-ORIG        PIC S99.                          00008600
           05 WS-MOVE-SUB-DEST        PIC S99.                          00008700
       01  TABLES.                                                      00008800
           05 WS-TAB-TOP10-CASES  OCCURS 10 TIMES.                      00008903
              10 WS-TAB-CASES-CCODE   PIC X(03).                        00009006
              10 WS-TAB-CASES-CNAME   PIC X(40).                        00009106
              10 WS-TAB-CASES-CASES   PIC 9(08).                        00009200
              10 WS-TAB-CASES-DEATHS  PIC 9(08).                        00009302
           05 WS-TAB-TOP10-DEATHS OCCURS 10 TIMES.                      00009400
              10 WS-TAB-DEATHS-CCODE  PIC X(03).                        00009506
              10 WS-TAB-DEATHS-CNAME  PIC X(40).                        00009600
              10 WS-TAB-DEATHS-CASES  PIC 9(08).                        00009702
              10 WS-TAB-DEATHS-DEATHS PIC 9(08).                        00009802
           05 WS-TAB-FAVOURITES   OCCURS 5 TIMES.                       00009903
              10 WS-TAB-FAVS-CCODE    PIC X(03).                        00010006
              10 WS-TAB-FAVS-CNAME    PIC X(40).                        00010103
              10 WS-TAB-FAVS-CASES    PIC 9(08).                        00010203
              10 WS-TAB-FAVS-DEATHS   PIC 9(08).                        00010303
       01  COUNTRY-DATA.                                                00010400
           05 WS-CTR-COUNTRYCODE      PIC A(03).                        00010506
           05 WS-CTR-COUNTRYNAME.                                       00010607
              10 WS-CTR-CNAME-FAV     PIC X(02).                        00010707
              10 WS-CTR-CNAME-NAME    PIC X(38).                        00010807
           05 WS-CTR-CASES            PIC 9(08).                        00010900
           05 WS-CTR-CASES-PREV       PIC 9(08).                        00011006
           05 WS-CTR-CASES-DELTA      PIC 9(06).                        00011106
           05 WS-CTR-CASES-DSIGN      PIC X.                            00011206
           05 WS-CTR-DEATHS           PIC 9(08).                        00011300
           05 WS-CTR-DEATHS-PREV      PIC 9(08).                        00011406
           05 WS-CTR-DEATHS-DELTA     PIC 9(06).                        00011506
           05 WS-CTR-DEATHS-DSIGN     PIC X.                            00011606
       01  MYFAVCOUNTRY-DATA.                                           00011700
           05 WS-FAV-COUNTRYCODE.                                       00011803
              10 WS-FAV-CC-1          PIC A(03).                        00011903
              10 WS-FAV-CC-2          PIC A(03).                        00012003
              10 WS-FAV-CC-3          PIC A(03).                        00012103
              10 WS-FAV-CC-4          PIC A(03).                        00012203
              10 WS-FAV-CC-5          PIC A(03).                        00012303
           05 WS-FAV-COUNTRYNAME      PIC X(40).                        00012400
           05 WS-FAV-CASES            PIC 9(08).                        00012500
           05 WS-FAV-DEATHS           PIC 9(08).                        00012600
       01  WS-TODAYS-DATE.                                              00012700
           05 TD-MONTH                PIC X(02).                        00012800
           05 FILLER                  PIC X.                            00012900
           05 TD-DAY                  PIC X(02).                        00013000
           05 FILLER                  PIC X.                            00013100
           05 TD-YEAR                 PIC X(02).                        00013200
       01  WS-TODAYS-TIME.                                              00013300
           05 TT-HOURS                PIC X(02).                        00013400
           05 TT-MINUTES              PIC X(02).                        00013500
           05 TT-SECONDS              PIC X(02).                        00013600
      **********************************                                00013700
       REPORT SECTION.                                                  00013800
      **********************************                                00013900
       RD  TOP10-REPORT                                                 00014000
           PAGE LIMIT IS 66 LINES                                       00014100
           HEADING 1                                                    00014200
           FIRST DETAIL 5                                               00014300
           LAST DETAIL 58.                                              00014400
       01  PAGE-HEAD-GROUP TYPE PAGE HEADING.                           00014500
           05 LINE 1.                                                   00014600
              10 COLUMN 01        PIC X(05)  VALUE 'DATE:'.             00014700
              10 COLUMN 07        PIC 99     SOURCE TD-DAY.             00014800
              10 COLUMN 09        PIC X      VALUE '/'.                 00014900
              10 COLUMN 10        PIC 99     SOURCE TD-MONTH.           00015000
              10 COLUMN 12        PIC X      VALUE '/'.                 00015100
              10 COLUMN 13        PIC 99     SOURCE WS-YEAR-CC.         00015203
              10 COLUMN 15        PIC 99     SOURCE TD-YEAR.            00015303
              10 COLUMN 40        PIC A(49)  VALUE                      00015406
                    'COVID-19 TOP10 BY CASES AND DEATHS + MY FAVORITES'.00015504
              10 COLUMN 121       PIC X(05)  VALUE 'PAGE:'.             00015600
              10 COLUMN 127       PIC ZZ,ZZ9 SOURCE PAGE-COUNTER.       00015700
           05 LINE PLUS 1.                                              00015800
              10 COLUMN 01        PIC X(05)  VALUE 'TIME:'.             00015900
              10 COLUMN 07        PIC 99     SOURCE TT-HOURS.           00016000
              10 COLUMN 09        PIC X      VALUE ':'.                 00016100
              10 COLUMN 10        PIC 99     SOURCE TT-MINUTES.         00016200
              10 COLUMN 12        PIC X      VALUE ':'.                 00016300
              10 COLUMN 13        PIC 99     SOURCE TT-SECONDS.         00016400
       01  TOP10-CASES-HEADER TYPE DETAIL.                              00016502
           05 LINE PLUS 2.                                              00016602
              10 COLUMN 01        PIC A(24)  VALUE                      00016702
                                             'TOP10 by number of Cases'.00016802
              10 COLUMN 50        PIC A(18)  VALUE 'Cases      (delta)'.00016906
              10 COLUMN 78        PIC A(18)  VALUE 'Deaths     (delta)'.00017006
           05 LINE PLUS 1.                                              00017102
              10 COLUMN 01        PIC A(25)  VALUE                      00017202
                                            '-------------------------'.00017302
              10 COLUMN 47        PIC A(22)  VALUE                      00017406
                                               '----------------------'.00017506
              10 COLUMN 75        PIC A(22)  VALUE                      00017606
                                               '----------------------'.00017706
       01  TOP10-DEATHS-HEADER TYPE DETAIL.                             00017802
           05 LINE PLUS 2.                                              00017902
              10 COLUMN 01        PIC A(25)  VALUE                      00018002
                                            'TOP10 by number of Deaths'.00018102
              10 COLUMN 50        PIC A(17)  VALUE 'Cases     (delta)'. 00018206
              10 COLUMN 78        PIC A(17)  VALUE 'Deaths    (delta)'. 00018306
           05 LINE PLUS 1.                                              00018402
              10 COLUMN 01        PIC A(25)  VALUE                      00018502
                                            '-------------------------'.00018602
              10 COLUMN 47        PIC A(22)  VALUE                      00018706
                                               '----------------------'.00018806
              10 COLUMN 75        PIC A(22)  VALUE                      00018906
                                               '----------------------'.00019006
       01  FAVOURITE-HEADER TYPE DETAIL.                                00019102
           05 LINE PLUS 2.                                              00019202
              10 COLUMN 01        PIC A(10)  VALUE 'FAVOURITES'.        00019304
              10 COLUMN 50        PIC A(17)  VALUE 'Cases     (delta)'. 00019406
              10 COLUMN 78        PIC A(17)  VALUE 'Deaths    (delta)'. 00019506
           05 LINE PLUS 1.                                              00019602
              10 COLUMN 01        PIC A(25)  VALUE                      00019702
                                            '-------------------------'.00019802
              10 COLUMN 47        PIC A(22)  VALUE                      00019906
                                               '----------------------'.00020006
              10 COLUMN 75        PIC A(22)  VALUE                      00020106
                                               '----------------------'.00020206
       01  TOP10-DETAIL TYPE DETAIL.                                    00020300
           05 LINE PLUS 1.                                              00020400
              10 COLUMN 01        PIC X(40)  SOURCE WS-CTR-COUNTRYNAME. 00020500
              10 COLUMN 47        PIC ZZZ,ZZZ,ZZZ SOURCE WS-CTR-CASES.  00020600
              10 COLUMN 59        PIC X      VALUE '('.                 00020706
              10 COLUMN 60        PIC ZZZ,ZZZ SOURCE WS-CTR-CASES-DELTA.00020806
              10 COLUMN 67        PIC X      SOURCE WS-CTR-CASES-DSIGN. 00020906
              10 COLUMN 68        PIC X      VALUE ')'.                 00021006
              10 COLUMN 75        PIC ZZZ,ZZZ,ZZZ SOURCE WS-CTR-DEATHS. 00021106
              10 COLUMN 87        PIC X      VALUE '('.                 00021206
              10 COLUMN 88       PIC ZZZ,ZZZ SOURCE WS-CTR-DEATHS-DELTA.00021306
              10 COLUMN 95        PIC X      SOURCE WS-CTR-DEATHS-DSIGN.00021406
              10 COLUMN 96        PIC X      VALUE ')'.                 00021506
      ******************************************************************00021600
       PROCEDURE DIVISION.                                              00021700
      ******************************************************************00021800
       0000-MAIN.                                                       00021900
      **********************************                                00022000
           PERFORM 0001-INITIALISE THRU 0001-EXIT.                      00022100
           PERFORM 1000-READ-COUNTRY-TOTALS THRU 1000-EXIT              00022201
               UNTIL EOF.                                               00022301
      * TOP10 by number of cases                                        00022403
           MOVE 1 TO WS-TABLE-SUB.                                      00022500
           GENERATE TOP10-CASES-HEADER.                                 00022602
           PERFORM 4000-PRINT-TOP10-CASES  THRU 4000-EXIT.              00022702
      * TOP10 by number of deaths                                       00022803
           MOVE 1 TO WS-TABLE-SUB.                                      00022902
           GENERATE TOP10-DEATHS-HEADER.                                00023002
           PERFORM 4001-PRINT-TOP10-DEATHS THRU 4001-EXIT.              00023102
      * 5 FAVOURITES                                                    00023203
           GENERATE FAVOURITE-HEADER.                                   00023302
           PERFORM 4100-PROCESS-FAVOURITES THRU 4100-EXIT.              00023403
           TERMINATE TOP10-REPORT.                                      00023503
           CLOSE TOTCNTRY-FILE.                                         00023600
       0000-EXIT.                                                       00023700
           STOP RUN.                                                    00023800
      **********************************                                00023900
       0001-INITIALISE.                                                 00024000
      **********************************                                00024100
           ACCEPT WS-FAV-COUNTRYCODE.                                   00024200
           MOVE CURRENT-DATE TO WS-TODAYS-DATE.                         00024300
           MOVE TIME-OF-DAY  TO WS-TODAYS-TIME.                         00024400
           OPEN INPUT TOTCNTRY-FILE,                                    00024500
                OUTPUT REPORT-PRINT.                                    00024600
           INITIATE TOP10-REPORT.                                       00024702
       0001-EXIT.                                                       00024800
           EXIT.                                                        00024900
      **********************************                                00025000
       1000-READ-COUNTRY-TOTALS.                                        00025100
      **********************************                                00025200
           READ TOTCNTRY-FILE                                           00025300
               AT END MOVE 'Y' TO END-OF-FILE.                          00025400
           IF NOT EOF THEN                                              00025500
               PERFORM 2000-PROCESS-COUNTRY-DATA THRU 2000-EXIT.        00025600
       1000-EXIT.                                                       00025700
           EXIT.                                                        00025800
      **********************************                                00025906
       1001-READ-COUNTRY-PREV-TOTALS.                                   00026006
      **********************************                                00026106
           READ TOTCPREV-FILE                                           00026206
               AT END MOVE 'Y' TO END-OF-FILE.                          00026306
           IF NOT EOF THEN                                              00026406
               PERFORM 2003-PROCESS-PREV-DATA THRU 2003-EXIT.           00026506
       1001-EXIT.                                                       00026606
           EXIT.                                                        00026706
      **********************************                                00026800
       2000-PROCESS-COUNTRY-DATA.                                       00026900
      **********************************                                00027000
      * If it is a Favorite Country, store the data to show in report   00027102
           PERFORM 2001-CHECK-IF-FAVOURITE THRU 2001-EXIT.              00027203
      * For each value, we want to check if the value is one of         00027300
      *  the TOP10, so that we can print it later on the report.        00027400
      *  To do so, we start by checking subscript 1 and go up,          00027500
      *  until either a TOP10 is found or we reached 10.                00027600
           MOVE 1 TO WS-TABLE-SUB.                                      00027700
           PERFORM 3000-UPDATE-TABLE-CASES THRU 3000-EXIT               00027802
               UNTIL WS-TABLE-SUB > COUNTER-TAB-OCCURS.                 00027900
           MOVE 1 TO WS-TABLE-SUB.                                      00028001
           PERFORM 3001-UPDATE-TABLE-DEATHS THRU 3001-EXIT              00028102
               UNTIL WS-TABLE-SUB > COUNTER-TAB-OCCURS.                 00028202
           MOVE 1 TO WS-TABLE-SUB.                                      00028302
       2000-EXIT.                                                       00028400
           EXIT.                                                        00028500
      **********************************                                00028600
       2001-CHECK-IF-FAVOURITE.                                         00028703
      **********************************                                00028803
           IF TOT-COUNTRYCODE = WS-FAV-CC-1 THEN                        00028903
               MOVE 1 TO WS-TABLE-SUB-FAVS                              00029003
               PERFORM 2002-ADD-TO-FAV THRU 2002-EXIT                   00029103
               GO TO 2001-EXIT.                                         00029203
           IF TOT-COUNTRYCODE = WS-FAV-CC-2 THEN                        00029303
               MOVE 2 TO WS-TABLE-SUB-FAVS                              00029403
               PERFORM 2002-ADD-TO-FAV THRU 2002-EXIT                   00029503
               GO TO 2001-EXIT.                                         00029603
           IF TOT-COUNTRYCODE = WS-FAV-CC-3 THEN                        00029703
               MOVE 3 TO WS-TABLE-SUB-FAVS                              00029803
               PERFORM 2002-ADD-TO-FAV THRU 2002-EXIT                   00029903
               GO TO 2001-EXIT.                                         00030003
           IF TOT-COUNTRYCODE = WS-FAV-CC-4 THEN                        00030103
               MOVE 4 TO WS-TABLE-SUB-FAVS                              00030203
               PERFORM 2002-ADD-TO-FAV THRU 2002-EXIT                   00030303
               GO TO 2001-EXIT.                                         00030403
           IF TOT-COUNTRYCODE = WS-FAV-CC-5 THEN                        00030503
               MOVE 5 TO WS-TABLE-SUB-FAVS                              00030603
               PERFORM 2002-ADD-TO-FAV THRU 2002-EXIT                   00030703
               PERFORM 2002-ADD-TO-FAV.                                 00030803
       2001-EXIT.                                                       00030903
           EXIT.                                                        00031003
      **********************************                                00031103
       2002-ADD-TO-FAV.                                                 00031203
      **********************************                                00031303
           MOVE TOT-COUNTRYCODE                                         00031406
                TO WS-TAB-FAVS-CCODE (WS-TABLE-SUB-FAVS).               00031506
           MOVE TOT-COUNTRYNAME                                         00031603
                TO WS-TAB-FAVS-CNAME (WS-TABLE-SUB-FAVS).               00031703
           MOVE TOT-CASES                                               00031803
                TO WS-TAB-FAVS-CASES (WS-TABLE-SUB-FAVS).               00031903
           MOVE TOT-DEATHS                                              00032003
                TO WS-TAB-FAVS-DEATHS (WS-TABLE-SUB-FAVS).              00032103
       2002-EXIT.                                                       00032203
           EXIT.                                                        00032303
      **********************************                                00032403
       2003-PROCESS-PREV-DATA.                                          00032506
      **********************************                                00032606
           IF PRV-COUNTRYCODE = WS-CTR-COUNTRYCODE THEN                 00032706
               COMPUTE WS-CTR-CASES-DELTA =                             00032806
                   WS-CTR-CASES - PRV-CASES                             00032906
               COMPUTE WS-CTR-DEATHS-DELTA =                            00033006
                   WS-CTR-DEATHS - PRV-DEATHS                           00033106
               PERFORM 2004-DELTA-SIGN-IS THRU 2004-EXIT                00033206
      *      Countries previous found, no need to read more countries   00033306
               MOVE 'Y' TO END-OF-FILE.                                 00033407
       2003-EXIT.                                                       00033506
           EXIT.                                                        00033606
      **********************************                                00033706
       2004-DELTA-SIGN-IS.                                              00033806
      **********************************                                00033906
           IF WS-CTR-CASES < PRV-CASES THEN                             00034006
               MOVE '-' TO WS-CTR-CASES-DSIGN                           00034106
           ELSE                                                         00034206
               MOVE '+' TO WS-CTR-CASES-DSIGN.                          00034306
           IF WS-CTR-CASES = PRV-CASES THEN                             00034406
               MOVE ' ' TO WS-CTR-CASES-DSIGN.                          00034506
           IF WS-CTR-DEATHS < PRV-DEATHS THEN                           00034606
               MOVE '-' TO WS-CTR-DEATHS-DSIGN                          00034706
           ELSE                                                         00034806
               MOVE '+' TO WS-CTR-DEATHS-DSIGN.                         00034906
           IF WS-CTR-DEATHS = PRV-DEATHS THEN                           00035006
               MOVE ' ' TO WS-CTR-DEATHS-DSIGN.                         00035106
       2004-EXIT.                                                       00035206
           EXIT.                                                        00035306
      **********************************                                00035406
       3000-UPDATE-TABLE-CASES.                                         00035502
      **********************************                                00035600
      * If the total cases is greater than the one stored               00035700
      *  at the table(subscript), then we want to store it.             00035800
      *  To do so, we need to displace all values to the right          00035900
      *  (i.e. 1 to 2, 2 to 3 and so on).                               00036000
           MOVE WS-TAB-CASES-CASES (WS-TABLE-SUB) TO WS-CASES.          00036101
           IF TOT-CASES > WS-CASES THEN                                 00036201
               MOVE COUNTER-TAB-OCCURS TO WS-MOVE-SUB-DEST              00036301
               MOVE COUNTER-TAB-OCCURS TO WS-MOVE-SUB-ORIG              00036401
               SUBTRACT 1 FROM WS-MOVE-SUB-ORIG                         00036501
               PERFORM 3100-DISPLACE-TABLE-CASES THRU 3100-EXIT         00036602
               MOVE TOT-COUNTRYCODE                                     00036706
                    TO WS-TAB-CASES-CCODE (WS-TABLE-SUB)                00036806
               MOVE TOT-COUNTRYNAME                                     00036900
                    TO WS-TAB-CASES-CNAME (WS-TABLE-SUB)                00037000
               MOVE TOT-CASES                                           00037100
                    TO WS-TAB-CASES-CASES (WS-TABLE-SUB)                00037200
               MOVE TOT-DEATHS                                          00037302
                    TO WS-TAB-CASES-DEATHS (WS-TABLE-SUB)               00037402
      *        If value was stored, we do not need to continue          00037500
      *          checking the table. Therefore, we make                 00037600
      *          WS-TABLE-SUB greater than COUNTER-TAB-OCCURS           00037700
      *          to stop 2000 calling here.                             00037800
               MOVE COUNTER-TAB-OCCURS TO WS-TABLE-SUB.                 00037900
           ADD 1 TO WS-TABLE-SUB.                                       00038000
       3000-EXIT.                                                       00038100
           EXIT.                                                        00038200
      **********************************                                00038302
       3001-UPDATE-TABLE-DEATHS.                                        00038402
      **********************************                                00038502
      * If the total deaths is greater than the one stored              00038602
      *  at the table(subscript), then we want to store it.             00038702
      *  To do so, we need to displace all values to the right          00038802
      *  (i.e. 1 to 2, 2 to 3 and so on).                               00038902
           MOVE WS-TAB-DEATHS-DEATHS (WS-TABLE-SUB) TO WS-DEATHS.       00039002
           IF TOT-DEATHS > WS-DEATHS THEN                               00039102
               MOVE COUNTER-TAB-OCCURS TO WS-MOVE-SUB-DEST              00039202
               MOVE COUNTER-TAB-OCCURS TO WS-MOVE-SUB-ORIG              00039302
               SUBTRACT 1 FROM WS-MOVE-SUB-ORIG                         00039402
               PERFORM 3101-DISPLACE-TABLE-DEATHS THRU 3101-EXIT        00039502
               MOVE TOT-COUNTRYCODE                                     00039606
                    TO WS-TAB-DEATHS-CCODE (WS-TABLE-SUB)               00039706
               MOVE TOT-COUNTRYNAME                                     00039802
                    TO WS-TAB-DEATHS-CNAME (WS-TABLE-SUB)               00039902
               MOVE TOT-CASES                                           00040002
                    TO WS-TAB-DEATHS-CASES (WS-TABLE-SUB)               00040102
               MOVE TOT-DEATHS                                          00040202
                    TO WS-TAB-DEATHS-DEATHS (WS-TABLE-SUB)              00040302
      *        If value was stored, we do not need to continue          00040402
      *          checking the table. Therefore, we make                 00040502
      *          WS-TABLE-SUB greater than COUNTER-TAB-OCCURS           00040602
      *          to stop 2000 calling here.                             00040702
               MOVE COUNTER-TAB-OCCURS TO WS-TABLE-SUB.                 00040802
           ADD 1 TO WS-TABLE-SUB.                                       00040902
       3001-EXIT.                                                       00041002
           EXIT.                                                        00041102
      **********************************                                00041200
       3100-DISPLACE-TABLE-CASES.                                       00041302
      **********************************                                00041400
      * Move values in table from WS-TABLE-SUB to WS-TABLE-SUB+1,       00041500
      * and continue to do it until reach bottom of the table           00041600
      * which is defined by COUNTER-TAB-OCCURS                          00041700
           MOVE WS-TAB-CASES-CCODE (WS-MOVE-SUB-ORIG)                   00041806
                TO WS-TAB-CASES-CCODE (WS-MOVE-SUB-DEST).               00041906
           MOVE WS-TAB-CASES-CNAME (WS-MOVE-SUB-ORIG)                   00042000
                TO WS-TAB-CASES-CNAME (WS-MOVE-SUB-DEST).               00042100
           MOVE WS-TAB-CASES-CASES (WS-MOVE-SUB-ORIG)                   00042200
                TO WS-TAB-CASES-CASES (WS-MOVE-SUB-DEST).               00042300
           MOVE WS-TAB-CASES-DEATHS (WS-MOVE-SUB-ORIG)                  00042402
                TO WS-TAB-CASES-DEATHS (WS-MOVE-SUB-DEST).              00042502
           SUBTRACT 1 FROM WS-MOVE-SUB-ORIG.                            00042600
           IF WS-MOVE-SUB-ORIG > WS-TABLE-SUB                           00042701
             OR WS-MOVE-SUB-ORIG = WS-TABLE-SUB THEN                    00042802
               SUBTRACT 1 FROM WS-MOVE-SUB-DEST                         00042900
               GO TO 3100-DISPLACE-TABLE-CASES.                         00043002
       3100-EXIT.                                                       00043102
           EXIT.                                                        00043200
      **********************************                                00043302
       3101-DISPLACE-TABLE-DEATHS.                                      00043402
      **********************************                                00043502
      * Move values in table from WS-TABLE-SUB to WS-TABLE-SUB+1,       00043602
      * and continue to do it until reach bottom of the table           00043702
      * which is defined by COUNTER-TAB-OCCURS                          00043802
           MOVE WS-TAB-DEATHS-CCODE (WS-MOVE-SUB-ORIG)                  00043906
                TO WS-TAB-DEATHS-CCODE (WS-MOVE-SUB-DEST).              00044006
           MOVE WS-TAB-DEATHS-CNAME (WS-MOVE-SUB-ORIG)                  00044102
                TO WS-TAB-DEATHS-CNAME (WS-MOVE-SUB-DEST).              00044202
           MOVE WS-TAB-DEATHS-CASES (WS-MOVE-SUB-ORIG)                  00044302
                TO WS-TAB-DEATHS-CASES (WS-MOVE-SUB-DEST).              00044402
           MOVE WS-TAB-DEATHS-DEATHS (WS-MOVE-SUB-ORIG)                 00044502
                TO WS-TAB-DEATHS-DEATHS (WS-MOVE-SUB-DEST).             00044602
           SUBTRACT 1 FROM WS-MOVE-SUB-ORIG.                            00044702
           IF WS-MOVE-SUB-ORIG > WS-TABLE-SUB                           00044802
             OR WS-MOVE-SUB-ORIG = WS-TABLE-SUB THEN                    00044902
               SUBTRACT 1 FROM WS-MOVE-SUB-DEST                         00045002
               GO TO 3101-DISPLACE-TABLE-DEATHS.                        00045102
       3101-EXIT.                                                       00045202
           EXIT.                                                        00045302
      **********************************                                00045400
       4000-PRINT-TOP10-CASES.                                          00045502
      **********************************                                00045602
           MOVE WS-TAB-CASES-CCODE (WS-TABLE-SUB) TO WS-CTR-COUNTRYCODE.00045706
           MOVE WS-TAB-CASES-CNAME (WS-TABLE-SUB)  TO WS-CTR-CNAME-NAME.00045807
           MOVE WS-TAB-CASES-CASES (WS-TABLE-SUB)  TO WS-CTR-CASES.     00045907
           MOVE WS-TAB-CASES-DEATHS (WS-TABLE-SUB) TO WS-CTR-DEATHS.    00046007
           MOVE SPACES                             TO WS-CTR-CNAME-FAV. 00046107
           PERFORM 5001-MARK-IF-FAVOURITE THRU 5001-EXIT.               00046207
           PERFORM 5000-GET-CTRY-DELTAS THRU 5000-EXIT.                 00046306
           GENERATE TOP10-DETAIL.                                       00046402
           ADD 1 TO WS-TABLE-SUB.                                       00046502
           IF WS-TABLE-SUB < COUNTER-TAB-OCCURS                         00046602
             OR WS-TABLE-SUB = COUNTER-TAB-OCCURS THEN                  00046702
               GO TO 4000-PRINT-TOP10-CASES.                            00046802
       4000-EXIT.                                                       00046902
           EXIT.                                                        00047002
      **********************************                                00047102
       4001-PRINT-TOP10-DEATHS.                                         00047202
      **********************************                                00047302
           MOVE WS-TAB-DEATHS-CCODE (WS-TABLE-SUB)                      00047406
                                                  TO WS-CTR-COUNTRYCODE.00047506
           MOVE WS-TAB-DEATHS-CNAME (WS-TABLE-SUB)                      00047602
                                                   TO WS-CTR-CNAME-NAME.00047707
           MOVE WS-TAB-DEATHS-CASES (WS-TABLE-SUB)  TO WS-CTR-CASES.    00047802
           MOVE WS-TAB-DEATHS-DEATHS (WS-TABLE-SUB) TO WS-CTR-DEATHS.   00047902
           MOVE SPACES                              TO WS-CTR-CNAME-FAV.00048007
           PERFORM 5001-MARK-IF-FAVOURITE THRU 5001-EXIT.               00048107
           PERFORM 5000-GET-CTRY-DELTAS THRU 5000-EXIT.                 00048207
           GENERATE TOP10-DETAIL.                                       00048302
           ADD 1 TO WS-TABLE-SUB.                                       00048402
           IF WS-TABLE-SUB < COUNTER-TAB-OCCURS                         00048502
             OR WS-TABLE-SUB = COUNTER-TAB-OCCURS THEN                  00048602
               GO TO 4001-PRINT-TOP10-DEATHS.                           00048702
       4001-EXIT.                                                       00048802
           EXIT.                                                        00048902
      **********************************                                00049002
       4100-PROCESS-FAVOURITES.                                         00049103
      **********************************                                00049202
           IF WS-FAV-CC-1 IS ALPHABETIC THEN                            00049303
               MOVE 1 TO WS-TABLE-SUB-FAVS                              00049403
               PERFORM 4101-PRINT-FAV THRU 4101-EXIT.                   00049503
           IF WS-FAV-CC-2 IS ALPHABETIC THEN                            00049603
               MOVE 2 TO WS-TABLE-SUB-FAVS                              00049703
               PERFORM 4101-PRINT-FAV THRU 4101-EXIT.                   00049803
           IF WS-FAV-CC-3 IS ALPHABETIC THEN                            00049903
               MOVE 3 TO WS-TABLE-SUB-FAVS                              00050003
               PERFORM 4101-PRINT-FAV THRU 4101-EXIT.                   00050103
           IF WS-FAV-CC-4 IS ALPHABETIC THEN                            00050203
               MOVE 4 TO WS-TABLE-SUB-FAVS                              00050303
               PERFORM 4101-PRINT-FAV THRU 4101-EXIT.                   00050403
           IF WS-FAV-CC-5 IS ALPHABETIC THEN                            00050503
               MOVE 5 TO WS-TABLE-SUB-FAVS                              00050603
               PERFORM 4101-PRINT-FAV THRU 4101-EXIT.                   00050703
       4100-EXIT.                                                       00050803
           EXIT.                                                        00050903
      **********************************                                00051003
       4101-PRINT-FAV.                                                  00051103
      **********************************                                00051203
           MOVE WS-TAB-FAVS-CCODE (WS-TABLE-SUB-FAVS)                   00051306
                TO WS-CTR-COUNTRYCODE.                                  00051406
           MOVE WS-TAB-FAVS-CNAME (WS-TABLE-SUB-FAVS)                   00051503
                TO WS-CTR-COUNTRYNAME.                                  00051603
           MOVE WS-TAB-FAVS-CASES (WS-TABLE-SUB-FAVS)                   00051703
                TO WS-CTR-CASES.                                        00051803
           MOVE WS-TAB-FAVS-DEATHS (WS-TABLE-SUB-FAVS)                  00051903
                TO WS-CTR-DEATHS.                                       00052003
           PERFORM 5000-GET-CTRY-DELTAS THRU 5000-EXIT.                 00052106
           GENERATE TOP10-DETAIL.                                       00052202
       4101-EXIT.                                                       00052303
           EXIT.                                                        00052402
      **********************************                                00052506
       5000-GET-CTRY-DELTAS.                                            00052606
      **********************************                                00052706
           OPEN INPUT TOTCPREV-FILE.                                    00052806
           MOVE 'N' TO END-OF-FILE.                                     00052906
           PERFORM 1001-READ-COUNTRY-PREV-TOTALS THRU 1001-EXIT         00053006
               UNTIL EOF.                                               00053106
           CLOSE TOTCPREV-FILE.                                         00053206
       5000-EXIT.                                                       00053306
           EXIT.                                                        00053406
      **********************************                                00053507
       5001-MARK-IF-FAVOURITE.                                          00053607
      **********************************                                00053707
           IF WS-CTR-COUNTRYCODE = WS-FAV-CC-1 THEN                     00053807
               MOVE '* ' TO WS-CTR-CNAME-FAV                            00053907
               GO TO 5001-EXIT.                                         00054007
           IF WS-CTR-COUNTRYCODE = WS-FAV-CC-2 THEN                     00054107
               MOVE '* ' TO WS-CTR-CNAME-FAV                            00054207
               GO TO 5001-EXIT.                                         00054307
           IF WS-CTR-COUNTRYCODE = WS-FAV-CC-3 THEN                     00054407
               MOVE '* ' TO WS-CTR-CNAME-FAV                            00054507
               GO TO 5001-EXIT.                                         00054607
           IF WS-CTR-COUNTRYCODE = WS-FAV-CC-4 THEN                     00054707
               MOVE '* ' TO WS-CTR-CNAME-FAV                            00054807
               GO TO 5001-EXIT.                                         00054907
           IF WS-CTR-COUNTRYCODE = WS-FAV-CC-5 THEN                     00055007
               MOVE '* ' TO WS-CTR-CNAME-FAV.                           00055107
       5001-EXIT.                                                       00055207
           EXIT.                                                        00055307
      ******************************************************************00055400
/*                                                                      00055500
//LKED.SYSLIB  DD DISP=SHR,DSNAME=SYS1.COBLIB                           00055600
//             DD DISP=SHR,DSNAME=SYS1.LINKLIB                          00055700
//             DD DISP=SHR,DSNAME=COVID19.LINKLIB                       00055800
//LKED.SYSLMOD DD DISP=SHR,DSNAME=COVID19.LINKLIB(REPCNTRY)             00055900
//                                                                      00056000
