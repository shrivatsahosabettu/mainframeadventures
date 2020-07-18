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
           05 WS-CTR-COUNTRYNAME      PIC X(40).                        00010600
           05 WS-CTR-CASES            PIC 9(08).                        00010700
           05 WS-CTR-CASES-PREV       PIC 9(08).                        00010806
           05 WS-CTR-CASES-DELTA      PIC 9(06).                        00010906
           05 WS-CTR-CASES-DSIGN      PIC X.                            00011006
           05 WS-CTR-DEATHS           PIC 9(08).                        00011100
           05 WS-CTR-DEATHS-PREV      PIC 9(08).                        00011206
           05 WS-CTR-DEATHS-DELTA     PIC 9(06).                        00011306
           05 WS-CTR-DEATHS-DSIGN     PIC X.                            00011406
       01  MYFAVCOUNTRY-DATA.                                           00011500
           05 WS-FAV-COUNTRYCODE.                                       00011603
              10 WS-FAV-CC-1          PIC A(03).                        00011703
              10 WS-FAV-CC-2          PIC A(03).                        00011803
              10 WS-FAV-CC-3          PIC A(03).                        00011903
              10 WS-FAV-CC-4          PIC A(03).                        00012003
              10 WS-FAV-CC-5          PIC A(03).                        00012103
           05 WS-FAV-COUNTRYNAME      PIC X(40).                        00012200
           05 WS-FAV-CASES            PIC 9(08).                        00012300
           05 WS-FAV-DEATHS           PIC 9(08).                        00012400
       01  WS-TODAYS-DATE.                                              00012500
           05 TD-MONTH                PIC X(02).                        00012600
           05 FILLER                  PIC X.                            00012700
           05 TD-DAY                  PIC X(02).                        00012800
           05 FILLER                  PIC X.                            00012900
           05 TD-YEAR                 PIC X(02).                        00013000
       01  WS-TODAYS-TIME.                                              00013100
           05 TT-HOURS                PIC X(02).                        00013200
           05 TT-MINUTES              PIC X(02).                        00013300
           05 TT-SECONDS              PIC X(02).                        00013400
      **********************************                                00013500
       REPORT SECTION.                                                  00013600
      **********************************                                00013700
       RD  TOP10-REPORT                                                 00013800
           PAGE LIMIT IS 66 LINES                                       00013900
           HEADING 1                                                    00014000
           FIRST DETAIL 5                                               00014100
           LAST DETAIL 58.                                              00014200
       01  PAGE-HEAD-GROUP TYPE PAGE HEADING.                           00014300
           05 LINE 1.                                                   00014400
              10 COLUMN 01        PIC X(05)  VALUE 'DATE:'.             00014500
              10 COLUMN 07        PIC 99     SOURCE TD-DAY.             00014600
              10 COLUMN 09        PIC X      VALUE '/'.                 00014700
              10 COLUMN 10        PIC 99     SOURCE TD-MONTH.           00014800
              10 COLUMN 12        PIC X      VALUE '/'.                 00014900
              10 COLUMN 13        PIC 99     SOURCE WS-YEAR-CC.         00015003
              10 COLUMN 15        PIC 99     SOURCE TD-YEAR.            00015103
              10 COLUMN 40        PIC A(49)  VALUE                      00015206
                    'COVID-19 TOP10 BY CASES AND DEATHS + MY FAVORITES'.00015304
              10 COLUMN 121       PIC X(05)  VALUE 'PAGE:'.             00015400
              10 COLUMN 127       PIC ZZ,ZZ9 SOURCE PAGE-COUNTER.       00015500
           05 LINE PLUS 1.                                              00015600
              10 COLUMN 01        PIC X(05)  VALUE 'TIME:'.             00015700
              10 COLUMN 07        PIC 99     SOURCE TT-HOURS.           00015800
              10 COLUMN 09        PIC X      VALUE ':'.                 00015900
              10 COLUMN 10        PIC 99     SOURCE TT-MINUTES.         00016000
              10 COLUMN 12        PIC X      VALUE ':'.                 00016100
              10 COLUMN 13        PIC 99     SOURCE TT-SECONDS.         00016200
       01  TOP10-CASES-HEADER TYPE DETAIL.                              00016302
           05 LINE PLUS 2.                                              00016402
              10 COLUMN 01        PIC A(24)  VALUE                      00016502
                                             'TOP10 by number of Cases'.00016602
              10 COLUMN 50        PIC A(18)  VALUE 'Cases      (delta)'.00016706
              10 COLUMN 78        PIC A(18)  VALUE 'Deaths     (delta)'.00016806
           05 LINE PLUS 1.                                              00016902
              10 COLUMN 01        PIC A(25)  VALUE                      00017002
                                            '-------------------------'.00017102
              10 COLUMN 47        PIC A(22)  VALUE                      00017206
                                               '----------------------'.00017306
              10 COLUMN 75        PIC A(22)  VALUE                      00017406
                                               '----------------------'.00017506
       01  TOP10-DEATHS-HEADER TYPE DETAIL.                             00017602
           05 LINE PLUS 2.                                              00017702
              10 COLUMN 01        PIC A(25)  VALUE                      00017802
                                            'TOP10 by number of Deaths'.00017902
              10 COLUMN 50        PIC A(17)  VALUE 'Cases     (delta)'. 00018006
              10 COLUMN 78        PIC A(17)  VALUE 'Deaths    (delta)'. 00018106
           05 LINE PLUS 1.                                              00018202
              10 COLUMN 01        PIC A(25)  VALUE                      00018302
                                            '-------------------------'.00018402
              10 COLUMN 47        PIC A(22)  VALUE                      00018506
                                               '----------------------'.00018606
              10 COLUMN 75        PIC A(22)  VALUE                      00018706
                                               '----------------------'.00018806
       01  FAVOURITE-HEADER TYPE DETAIL.                                00018902
           05 LINE PLUS 2.                                              00019002
              10 COLUMN 01        PIC A(10)  VALUE 'FAVOURITES'.        00019104
              10 COLUMN 50        PIC A(17)  VALUE 'Cases     (delta)'. 00019206
              10 COLUMN 78        PIC A(17)  VALUE 'Deaths    (delta)'. 00019306
           05 LINE PLUS 1.                                              00019402
              10 COLUMN 01        PIC A(25)  VALUE                      00019502
                                            '-------------------------'.00019602
              10 COLUMN 47        PIC A(22)  VALUE                      00019706
                                               '----------------------'.00019806
              10 COLUMN 75        PIC A(22)  VALUE                      00019906
                                               '----------------------'.00020006
       01  TOP10-DETAIL TYPE DETAIL.                                    00020100
           05 LINE PLUS 1.                                              00020200
              10 COLUMN 01        PIC X(40)  SOURCE WS-CTR-COUNTRYNAME. 00020300
              10 COLUMN 47        PIC ZZZ,ZZZ,ZZZ SOURCE WS-CTR-CASES.  00020400
              10 COLUMN 59        PIC X      VALUE '('.                 00020506
              10 COLUMN 60        PIC ZZZ,ZZZ SOURCE WS-CTR-CASES-DELTA.00020606
              10 COLUMN 67        PIC X      SOURCE WS-CTR-CASES-DSIGN. 00020706
              10 COLUMN 68        PIC X      VALUE ')'.                 00020806
              10 COLUMN 75        PIC ZZZ,ZZZ,ZZZ SOURCE WS-CTR-DEATHS. 00020906
              10 COLUMN 87        PIC X      VALUE '('.                 00021006
              10 COLUMN 88       PIC ZZZ,ZZZ SOURCE WS-CTR-DEATHS-DELTA.00021106
              10 COLUMN 95        PIC X      SOURCE WS-CTR-DEATHS-DSIGN.00021206
              10 COLUMN 96        PIC X      VALUE ')'.                 00021306
      ******************************************************************00021400
       PROCEDURE DIVISION.                                              00021500
      ******************************************************************00021600
       0000-MAIN.                                                       00021700
      **********************************                                00021800
           PERFORM 0001-INITIALISE THRU 0001-EXIT.                      00021900
           PERFORM 1000-READ-COUNTRY-TOTALS THRU 1000-EXIT              00022001
               UNTIL EOF.                                               00022101
      * TOP10 by number of cases                                        00022203
           MOVE 1 TO WS-TABLE-SUB.                                      00022300
           GENERATE TOP10-CASES-HEADER.                                 00022402
           PERFORM 4000-PRINT-TOP10-CASES  THRU 4000-EXIT.              00022502
      * TOP10 by number of deaths                                       00022603
           MOVE 1 TO WS-TABLE-SUB.                                      00022702
           GENERATE TOP10-DEATHS-HEADER.                                00022802
           PERFORM 4001-PRINT-TOP10-DEATHS THRU 4001-EXIT.              00022902
      * 5 FAVOURITES                                                    00023003
           GENERATE FAVOURITE-HEADER.                                   00023102
           PERFORM 4100-PROCESS-FAVOURITES THRU 4100-EXIT.              00023203
           TERMINATE TOP10-REPORT.                                      00023303
           CLOSE TOTCNTRY-FILE.                                         00023400
       0000-EXIT.                                                       00023500
           STOP RUN.                                                    00023600
      **********************************                                00023700
       0001-INITIALISE.                                                 00023800
      **********************************                                00023900
           ACCEPT WS-FAV-COUNTRYCODE.                                   00024000
           MOVE CURRENT-DATE TO WS-TODAYS-DATE.                         00024100
           MOVE TIME-OF-DAY  TO WS-TODAYS-TIME.                         00024200
           OPEN INPUT TOTCNTRY-FILE,                                    00024300
                OUTPUT REPORT-PRINT.                                    00024400
           INITIATE TOP10-REPORT.                                       00024502
       0001-EXIT.                                                       00024600
           EXIT.                                                        00024700
      **********************************                                00024800
       1000-READ-COUNTRY-TOTALS.                                        00024900
      **********************************                                00025000
           READ TOTCNTRY-FILE                                           00025100
               AT END MOVE 'Y' TO END-OF-FILE.                          00025200
           IF NOT EOF THEN                                              00025300
               PERFORM 2000-PROCESS-COUNTRY-DATA THRU 2000-EXIT.        00025400
       1000-EXIT.                                                       00025500
           EXIT.                                                        00025600
      **********************************                                00025706
       1001-READ-COUNTRY-PREV-TOTALS.                                   00025806
      **********************************                                00025906
           READ TOTCPREV-FILE                                           00026006
               AT END MOVE 'Y' TO END-OF-FILE.                          00026106
           IF NOT EOF THEN                                              00026206
               PERFORM 2003-PROCESS-PREV-DATA THRU 2003-EXIT.           00026306
       1001-EXIT.                                                       00026406
           EXIT.                                                        00026506
      **********************************                                00026600
       2000-PROCESS-COUNTRY-DATA.                                       00026700
      **********************************                                00026800
      * If it is a Favorite Country, store the data to show in report   00026902
           PERFORM 2001-CHECK-IF-FAVOURITE THRU 2001-EXIT.              00027003
      * For each value, we want to check if the value is one of         00027100
      *  the TOP10, so that we can print it later on the report.        00027200
      *  To do so, we start by checking subscript 1 and go up,          00027300
      *  until either a TOP10 is found or we reached 10.                00027400
           MOVE 1 TO WS-TABLE-SUB.                                      00027500
           PERFORM 3000-UPDATE-TABLE-CASES THRU 3000-EXIT               00027602
               UNTIL WS-TABLE-SUB > COUNTER-TAB-OCCURS.                 00027700
           MOVE 1 TO WS-TABLE-SUB.                                      00027801
           PERFORM 3001-UPDATE-TABLE-DEATHS THRU 3001-EXIT              00027902
               UNTIL WS-TABLE-SUB > COUNTER-TAB-OCCURS.                 00028002
           MOVE 1 TO WS-TABLE-SUB.                                      00028102
       2000-EXIT.                                                       00028200
           EXIT.                                                        00028300
      **********************************                                00028400
       2001-CHECK-IF-FAVOURITE.                                         00028503
      **********************************                                00028603
           IF TOT-COUNTRYCODE = WS-FAV-CC-1 THEN                        00028703
               MOVE 1 TO WS-TABLE-SUB-FAVS                              00028803
               PERFORM 2002-ADD-TO-FAV THRU 2002-EXIT                   00028903
               GO TO 2001-EXIT.                                         00029003
           IF TOT-COUNTRYCODE = WS-FAV-CC-2 THEN                        00029103
               MOVE 2 TO WS-TABLE-SUB-FAVS                              00029203
               PERFORM 2002-ADD-TO-FAV THRU 2002-EXIT                   00029303
               GO TO 2001-EXIT.                                         00029403
           IF TOT-COUNTRYCODE = WS-FAV-CC-3 THEN                        00029503
               MOVE 3 TO WS-TABLE-SUB-FAVS                              00029603
               PERFORM 2002-ADD-TO-FAV THRU 2002-EXIT                   00029703
               GO TO 2001-EXIT.                                         00029803
           IF TOT-COUNTRYCODE = WS-FAV-CC-4 THEN                        00029903
               MOVE 4 TO WS-TABLE-SUB-FAVS                              00030003
               PERFORM 2002-ADD-TO-FAV THRU 2002-EXIT                   00030103
               GO TO 2001-EXIT.                                         00030203
           IF TOT-COUNTRYCODE = WS-FAV-CC-5 THEN                        00030303
               MOVE 5 TO WS-TABLE-SUB-FAVS                              00030403
               PERFORM 2002-ADD-TO-FAV THRU 2002-EXIT                   00030503
               PERFORM 2002-ADD-TO-FAV.                                 00030603
       2001-EXIT.                                                       00030703
           EXIT.                                                        00030803
      **********************************                                00030903
       2002-ADD-TO-FAV.                                                 00031003
      **********************************                                00031103
           MOVE TOT-COUNTRYCODE                                         00031206
                TO WS-TAB-FAVS-CCODE (WS-TABLE-SUB-FAVS).               00031306
           MOVE TOT-COUNTRYNAME                                         00031403
                TO WS-TAB-FAVS-CNAME (WS-TABLE-SUB-FAVS).               00031503
           MOVE TOT-CASES                                               00031603
                TO WS-TAB-FAVS-CASES (WS-TABLE-SUB-FAVS).               00031703
           MOVE TOT-DEATHS                                              00031803
                TO WS-TAB-FAVS-DEATHS (WS-TABLE-SUB-FAVS).              00031903
       2002-EXIT.                                                       00032003
           EXIT.                                                        00032103
      **********************************                                00032203
       2003-PROCESS-PREV-DATA.                                          00032306
      **********************************                                00032406
           IF PRV-COUNTRYCODE = WS-CTR-COUNTRYCODE THEN                 00032506
               COMPUTE WS-CTR-CASES-DELTA =                             00032606
                   WS-CTR-CASES - PRV-CASES                             00032706
               COMPUTE WS-CTR-DEATHS-DELTA =                            00032806
                   WS-CTR-DEATHS - PRV-DEATHS                           00032906
               PERFORM 2004-DELTA-SIGN-IS THRU 2004-EXIT                00033006
      *      Countries previous found, no need to read more countries   00033106
               MOVE 'Y' TO END-OF-FILE                                  00033206
       2003-EXIT.                                                       00033306
           EXIT.                                                        00033406
      **********************************                                00033506
       2004-DELTA-SIGN-IS.                                              00033606
      **********************************                                00033706
           IF WS-CTR-CASES < PRV-CASES THEN                             00033806
               MOVE '-' TO WS-CTR-CASES-DSIGN                           00033906
           ELSE                                                         00034006
               MOVE '+' TO WS-CTR-CASES-DSIGN.                          00034106
           IF WS-CTR-CASES = PRV-CASES THEN                             00034206
               MOVE ' ' TO WS-CTR-CASES-DSIGN.                          00034306
           IF WS-CTR-DEATHS < PRV-DEATHS THEN                           00034406
               MOVE '-' TO WS-CTR-DEATHS-DSIGN                          00034506
           ELSE                                                         00034606
               MOVE '+' TO WS-CTR-DEATHS-DSIGN.                         00034706
           IF WS-CTR-DEATHS = PRV-DEATHS THEN                           00034806
               MOVE ' ' TO WS-CTR-DEATHS-DSIGN.                         00034906
       2004-EXIT.                                                       00035006
           EXIT.                                                        00035106
      **********************************                                00035206
       3000-UPDATE-TABLE-CASES.                                         00035302
      **********************************                                00035400
      * If the total cases is greater than the one stored               00035500
      *  at the table(subscript), then we want to store it.             00035600
      *  To do so, we need to displace all values to the right          00035700
      *  (i.e. 1 to 2, 2 to 3 and so on).                               00035800
           MOVE WS-TAB-CASES-CASES (WS-TABLE-SUB) TO WS-CASES.          00035901
           IF TOT-CASES > WS-CASES THEN                                 00036001
               MOVE COUNTER-TAB-OCCURS TO WS-MOVE-SUB-DEST              00036101
               MOVE COUNTER-TAB-OCCURS TO WS-MOVE-SUB-ORIG              00036201
               SUBTRACT 1 FROM WS-MOVE-SUB-ORIG                         00036301
               PERFORM 3100-DISPLACE-TABLE-CASES THRU 3100-EXIT         00036402
               MOVE TOT-COUNTRYCODE                                     00036506
                    TO WS-TAB-CASES-CCODE (WS-TABLE-SUB)                00036606
               MOVE TOT-COUNTRYNAME                                     00036700
                    TO WS-TAB-CASES-CNAME (WS-TABLE-SUB)                00036800
               MOVE TOT-CASES                                           00036900
                    TO WS-TAB-CASES-CASES (WS-TABLE-SUB)                00037000
               MOVE TOT-DEATHS                                          00037102
                    TO WS-TAB-CASES-DEATHS (WS-TABLE-SUB)               00037202
      *        If value was stored, we do not need to continue          00037300
      *          checking the table. Therefore, we make                 00037400
      *          WS-TABLE-SUB greater than COUNTER-TAB-OCCURS           00037500
      *          to stop 2000 calling here.                             00037600
               MOVE COUNTER-TAB-OCCURS TO WS-TABLE-SUB.                 00037700
           ADD 1 TO WS-TABLE-SUB.                                       00037800
       3000-EXIT.                                                       00037900
           EXIT.                                                        00038000
      **********************************                                00038102
       3001-UPDATE-TABLE-DEATHS.                                        00038202
      **********************************                                00038302
      * If the total deaths is greater than the one stored              00038402
      *  at the table(subscript), then we want to store it.             00038502
      *  To do so, we need to displace all values to the right          00038602
      *  (i.e. 1 to 2, 2 to 3 and so on).                               00038702
           MOVE WS-TAB-DEATHS-DEATHS (WS-TABLE-SUB) TO WS-DEATHS.       00038802
           IF TOT-DEATHS > WS-DEATHS THEN                               00038902
               MOVE COUNTER-TAB-OCCURS TO WS-MOVE-SUB-DEST              00039002
               MOVE COUNTER-TAB-OCCURS TO WS-MOVE-SUB-ORIG              00039102
               SUBTRACT 1 FROM WS-MOVE-SUB-ORIG                         00039202
               PERFORM 3101-DISPLACE-TABLE-DEATHS THRU 3101-EXIT        00039302
               MOVE TOT-COUNTRYCODE                                     00039406
                    TO WS-TAB-DEATHS-CCODE (WS-TABLE-SUB)               00039506
               MOVE TOT-COUNTRYNAME                                     00039602
                    TO WS-TAB-DEATHS-CNAME (WS-TABLE-SUB)               00039702
               MOVE TOT-CASES                                           00039802
                    TO WS-TAB-DEATHS-CASES (WS-TABLE-SUB)               00039902
               MOVE TOT-DEATHS                                          00040002
                    TO WS-TAB-DEATHS-DEATHS (WS-TABLE-SUB)              00040102
      *        If value was stored, we do not need to continue          00040202
      *          checking the table. Therefore, we make                 00040302
      *          WS-TABLE-SUB greater than COUNTER-TAB-OCCURS           00040402
      *          to stop 2000 calling here.                             00040502
               MOVE COUNTER-TAB-OCCURS TO WS-TABLE-SUB.                 00040602
           ADD 1 TO WS-TABLE-SUB.                                       00040702
       3001-EXIT.                                                       00040802
           EXIT.                                                        00040902
      **********************************                                00041000
       3100-DISPLACE-TABLE-CASES.                                       00041102
      **********************************                                00041200
      * Move values in table from WS-TABLE-SUB to WS-TABLE-SUB+1,       00041300
      * and continue to do it until reach bottom of the table           00041400
      * which is defined by COUNTER-TAB-OCCURS                          00041500
           MOVE WS-TAB-CASES-CCODE (WS-MOVE-SUB-ORIG)                   00041606
                TO WS-TAB-CASES-CCODE (WS-MOVE-SUB-DEST).               00041706
           MOVE WS-TAB-CASES-CNAME (WS-MOVE-SUB-ORIG)                   00041800
                TO WS-TAB-CASES-CNAME (WS-MOVE-SUB-DEST).               00041900
           MOVE WS-TAB-CASES-CASES (WS-MOVE-SUB-ORIG)                   00042000
                TO WS-TAB-CASES-CASES (WS-MOVE-SUB-DEST).               00042100
           MOVE WS-TAB-CASES-DEATHS (WS-MOVE-SUB-ORIG)                  00042202
                TO WS-TAB-CASES-DEATHS (WS-MOVE-SUB-DEST).              00042302
           SUBTRACT 1 FROM WS-MOVE-SUB-ORIG.                            00042400
           IF WS-MOVE-SUB-ORIG > WS-TABLE-SUB                           00042501
             OR WS-MOVE-SUB-ORIG = WS-TABLE-SUB THEN                    00042602
               SUBTRACT 1 FROM WS-MOVE-SUB-DEST                         00042700
               GO TO 3100-DISPLACE-TABLE-CASES.                         00042802
       3100-EXIT.                                                       00042902
           EXIT.                                                        00043000
      **********************************                                00043102
       3101-DISPLACE-TABLE-DEATHS.                                      00043202
      **********************************                                00043302
      * Move values in table from WS-TABLE-SUB to WS-TABLE-SUB+1,       00043402
      * and continue to do it until reach bottom of the table           00043502
      * which is defined by COUNTER-TAB-OCCURS                          00043602
           MOVE WS-TAB-DEATHS-CCODE (WS-MOVE-SUB-ORIG)                  00043706
                TO WS-TAB-DEATHS-CCODE (WS-MOVE-SUB-DEST).              00043806
           MOVE WS-TAB-DEATHS-CNAME (WS-MOVE-SUB-ORIG)                  00043902
                TO WS-TAB-DEATHS-CNAME (WS-MOVE-SUB-DEST).              00044002
           MOVE WS-TAB-DEATHS-CASES (WS-MOVE-SUB-ORIG)                  00044102
                TO WS-TAB-DEATHS-CASES (WS-MOVE-SUB-DEST).              00044202
           MOVE WS-TAB-DEATHS-DEATHS (WS-MOVE-SUB-ORIG)                 00044302
                TO WS-TAB-DEATHS-DEATHS (WS-MOVE-SUB-DEST).             00044402
           SUBTRACT 1 FROM WS-MOVE-SUB-ORIG.                            00044502
           IF WS-MOVE-SUB-ORIG > WS-TABLE-SUB                           00044602
             OR WS-MOVE-SUB-ORIG = WS-TABLE-SUB THEN                    00044702
               SUBTRACT 1 FROM WS-MOVE-SUB-DEST                         00044802
               GO TO 3101-DISPLACE-TABLE-DEATHS.                        00044902
       3101-EXIT.                                                       00045002
           EXIT.                                                        00045102
      **********************************                                00045200
       4000-PRINT-TOP10-CASES.                                          00045302
      **********************************                                00045402
           MOVE WS-TAB-CASES-CCODE (WS-TABLE-SUB) TO WS-CTR-COUNTRYCODE.00045506
           MOVE WS-TAB-CASES-CNAME (WS-TABLE-SUB) TO WS-CTR-COUNTRYNAME.00045606
           MOVE WS-TAB-CASES-CASES (WS-TABLE-SUB)   TO WS-CTR-CASES.    00045702
           MOVE WS-TAB-CASES-DEATHS (WS-TABLE-SUB)  TO WS-CTR-DEATHS.   00045802
           PERFORM 5000-GET-CTRY-DELTAS THRU 5000-EXIT.                 00045906
           GENERATE TOP10-DETAIL.                                       00046002
           ADD 1 TO WS-TABLE-SUB.                                       00046102
           IF WS-TABLE-SUB < COUNTER-TAB-OCCURS                         00046202
             OR WS-TABLE-SUB = COUNTER-TAB-OCCURS THEN                  00046302
               GO TO 4000-PRINT-TOP10-CASES.                            00046402
       4000-EXIT.                                                       00046502
           EXIT.                                                        00046602
      **********************************                                00046702
       4001-PRINT-TOP10-DEATHS.                                         00046802
      **********************************                                00046902
           MOVE WS-TAB-DEATHS-CCODE (WS-TABLE-SUB)                      00047006
                                                  TO WS-CTR-COUNTRYCODE.00047106
           MOVE WS-TAB-DEATHS-CNAME (WS-TABLE-SUB)                      00047202
                                                  TO WS-CTR-COUNTRYNAME.00047302
           MOVE WS-TAB-DEATHS-CASES (WS-TABLE-SUB)  TO WS-CTR-CASES.    00047402
           MOVE WS-TAB-DEATHS-DEATHS (WS-TABLE-SUB) TO WS-CTR-DEATHS.   00047502
           PERFORM 5000-GET-CTRY-DELTAS THRU 5000-EXIT.                 00047606
           GENERATE TOP10-DETAIL.                                       00047702
           ADD 1 TO WS-TABLE-SUB.                                       00047802
           IF WS-TABLE-SUB < COUNTER-TAB-OCCURS                         00047902
             OR WS-TABLE-SUB = COUNTER-TAB-OCCURS THEN                  00048002
               GO TO 4001-PRINT-TOP10-DEATHS.                           00048102
       4001-EXIT.                                                       00048202
           EXIT.                                                        00048302
      **********************************                                00048402
       4100-PROCESS-FAVOURITES.                                         00048503
      **********************************                                00048602
           IF WS-FAV-CC-1 IS ALPHABETIC THEN                            00048703
               MOVE 1 TO WS-TABLE-SUB-FAVS                              00048803
               PERFORM 4101-PRINT-FAV THRU 4101-EXIT.                   00048903
           IF WS-FAV-CC-2 IS ALPHABETIC THEN                            00049003
               MOVE 2 TO WS-TABLE-SUB-FAVS                              00049103
               PERFORM 4101-PRINT-FAV THRU 4101-EXIT.                   00049203
           IF WS-FAV-CC-3 IS ALPHABETIC THEN                            00049303
               MOVE 3 TO WS-TABLE-SUB-FAVS                              00049403
               PERFORM 4101-PRINT-FAV THRU 4101-EXIT.                   00049503
           IF WS-FAV-CC-4 IS ALPHABETIC THEN                            00049603
               MOVE 4 TO WS-TABLE-SUB-FAVS                              00049703
               PERFORM 4101-PRINT-FAV THRU 4101-EXIT.                   00049803
           IF WS-FAV-CC-5 IS ALPHABETIC THEN                            00049903
               MOVE 5 TO WS-TABLE-SUB-FAVS                              00050003
               PERFORM 4101-PRINT-FAV THRU 4101-EXIT.                   00050103
       4100-EXIT.                                                       00050203
           EXIT.                                                        00050303
      **********************************                                00050403
       4101-PRINT-FAV.                                                  00050503
      **********************************                                00050603
           MOVE WS-TAB-FAVS-CCODE (WS-TABLE-SUB-FAVS)                   00050706
                TO WS-CTR-COUNTRYCODE.                                  00050806
           MOVE WS-TAB-FAVS-CNAME (WS-TABLE-SUB-FAVS)                   00050903
                TO WS-CTR-COUNTRYNAME.                                  00051003
           MOVE WS-TAB-FAVS-CASES (WS-TABLE-SUB-FAVS)                   00051103
                TO WS-CTR-CASES.                                        00051203
           MOVE WS-TAB-FAVS-DEATHS (WS-TABLE-SUB-FAVS)                  00051303
                TO WS-CTR-DEATHS.                                       00051403
           PERFORM 5000-GET-CTRY-DELTAS THRU 5000-EXIT.                 00051506
           GENERATE TOP10-DETAIL.                                       00051602
       4101-EXIT.                                                       00051703
           EXIT.                                                        00051802
      **********************************                                00051906
       5000-GET-CTRY-DELTAS.                                            00052006
      **********************************                                00052106
           OPEN INPUT TOTCPREV-FILE.                                    00052206
           MOVE 'N' TO END-OF-FILE.                                     00052306
           PERFORM 1001-READ-COUNTRY-PREV-TOTALS THRU 1001-EXIT         00052406
               UNTIL EOF.                                               00052506
           CLOSE TOTCPREV-FILE.                                         00052606
       5000-EXIT.                                                       00052706
           EXIT.                                                        00052806
      ******************************************************************00052900
/*                                                                      00053000
//LKED.SYSLIB  DD DISP=SHR,DSNAME=SYS1.COBLIB                           00053100
//             DD DISP=SHR,DSNAME=SYS1.LINKLIB                          00053200
//             DD DISP=SHR,DSNAME=COVID19.LINKLIB                       00053300
//LKED.SYSLMOD DD DISP=SHR,DSNAME=COVID19.LINKLIB(REPCNTRY)             00053400
//                                                                      00053500
