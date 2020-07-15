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
      *   Favourites countries are ACCEPTed from JCL in the form of     00001403
      *    3 character each country codes.                              00001503
      *                                                                 00001603
      *   I guess this program could have been done with SORT,          00001703
      *    but as I yet have to learn how to do it, I did it manually   00001803
      *    with tables.                                                 00001903
      ******************************************************************00002000
       IDENTIFICATION DIVISION.                                         00002100
       PROGRAM-ID.   'REPCNTRY'.                                        00002200
       AUTHOR.       'DAVID ASTA'.                                      00002300
       INSTALLATION. 'MVS 3.8J TK4-'.                                   00002400
       DATE-WRITTEN. '14/07/2020'.                                      00002500
       DATE-COMPILED.                                                   00002600
       REMARKS.      'V1R1M0'.                                          00002700
      ******************************************************************00002800
       ENVIRONMENT DIVISION.                                            00002900
      ******************************************************************00003000
       INPUT-OUTPUT SECTION.                                            00003100
       FILE-CONTROL.                                                    00003200
           SELECT TOTCNTRY-FILE  ASSIGN DA-S-TOTCTR.                    00003300
           SELECT REPORT-PRINT   ASSIGN UR-S-SYSPRINT.                  00003400
      ******************************************************************00003500
       DATA DIVISION.                                                   00003600
      ******************************************************************00003700
       FILE SECTION.                                                    00003800
      **********************************                                00003900
       FD  TOTCNTRY-FILE                                                00004000
      *******************                                               00004100
           RECORDING MODE F                                             00004200
           LABEL RECORDS ARE STANDARD                                   00004300
           BLOCK CONTAINS 0 RECORDS                                     00004400
           RECORD CONTAINS 59 CHARACTERS.                               00004500
       01  TOT-RECORD.                                                  00004600
           05 TOT-COUNTRYCODE         PIC A(03).                        00004700
           05 TOT-CASES               PIC 9(08).                        00004800
           05 TOT-DEATHS              PIC 9(08).                        00004900
           05 TOT-COUNTRYNAME         PIC X(40).                        00005000
      *******************                                               00005100
       FD  REPORT-PRINT                                                 00005200
      *******************                                               00005300
           LABEL RECORDS ARE OMITTED                                    00005400
           REPORT IS TOP10-REPORT.                                      00005500
      **********************************                                00005600
       WORKING-STORAGE SECTION.                                         00005700
      **********************************                                00005800
       77  WS-YEAR-CC                 PIC 99     VALUE 20.              00005903
       77  WS-CASES                   PIC 9(08).                        00006003
       77  WS-DEATHS                  PIC 9(08).                        00006102
       01  SWITCHES.                                                    00006200
           05 END-OF-FILE             PIC X      VALUE 'N'.             00006300
              88 EOF                             VALUE 'Y'.             00006400
       01  COUNTERS.                                                    00006500
           05 COUNTER-TAB-OCCURS      PIC 99     VALUE 10.              00006600
       01  SUBSCRIPTS.                                                  00006700
           05 WS-TABLE-SUB            PIC S99.                          00006800
           05 WS-TABLE-SUB-FAVS       PIC S99.                          00006903
           05 WS-MOVE-SUB-ORIG        PIC S99.                          00007000
           05 WS-MOVE-SUB-DEST        PIC S99.                          00007100
       01  TABLES.                                                      00007200
           05 WS-TAB-TOP10-CASES  OCCURS 10 TIMES.                      00007303
              10 WS-TAB-CASES-CNAME   PIC X(40).                        00007400
              10 WS-TAB-CASES-CASES   PIC 9(08).                        00007500
              10 WS-TAB-CASES-DEATHS  PIC 9(08).                        00007602
           05 WS-TAB-TOP10-DEATHS OCCURS 10 TIMES.                      00007700
              10 WS-TAB-DEATHS-CNAME  PIC X(40).                        00007800
              10 WS-TAB-DEATHS-CASES  PIC 9(08).                        00007902
              10 WS-TAB-DEATHS-DEATHS PIC 9(08).                        00008002
           05 WS-TAB-FAVOURITES   OCCURS 5 TIMES.                       00008103
              10 WS-TAB-FAVS-CNAME    PIC X(40).                        00008203
              10 WS-TAB-FAVS-CASES    PIC 9(08).                        00008303
              10 WS-TAB-FAVS-DEATHS   PIC 9(08).                        00008403
       01  COUNTRY-DATA.                                                00008500
           05 WS-CTR-COUNTRYNAME      PIC X(40).                        00008600
           05 WS-CTR-CASES            PIC 9(08).                        00008700
           05 WS-CTR-DEATHS           PIC 9(08).                        00008800
       01  MYFAVCOUNTRY-DATA.                                           00008900
           05 WS-FAV-COUNTRYCODE.                                       00009003
              10 WS-FAV-CC-1          PIC A(03).                        00009103
              10 WS-FAV-CC-2          PIC A(03).                        00009203
              10 WS-FAV-CC-3          PIC A(03).                        00009303
              10 WS-FAV-CC-4          PIC A(03).                        00009403
              10 WS-FAV-CC-5          PIC A(03).                        00009503
           05 WS-FAV-COUNTRYNAME      PIC X(40).                        00009600
           05 WS-FAV-CASES            PIC 9(08).                        00009700
           05 WS-FAV-DEATHS           PIC 9(08).                        00009800
       01  WS-TODAYS-DATE.                                              00009900
           05 TD-MONTH                PIC X(02).                        00010000
           05 FILLER                  PIC X.                            00010100
           05 TD-DAY                  PIC X(02).                        00010200
           05 FILLER                  PIC X.                            00010300
           05 TD-YEAR                 PIC X(02).                        00010400
       01  WS-TODAYS-TIME.                                              00010500
           05 TT-HOURS                PIC X(02).                        00010600
           05 TT-MINUTES              PIC X(02).                        00010700
           05 TT-SECONDS              PIC X(02).                        00010800
      **********************************                                00010900
       REPORT SECTION.                                                  00011000
      **********************************                                00011100
       RD  TOP10-REPORT                                                 00011200
           PAGE LIMIT IS 66 LINES                                       00011300
           HEADING 1                                                    00011400
           FIRST DETAIL 5                                               00011500
           LAST DETAIL 58.                                              00011600
       01  PAGE-HEAD-GROUP TYPE PAGE HEADING.                           00011700
           05 LINE 1.                                                   00011800
              10 COLUMN 01        PIC X(05)  VALUE 'DATE:'.             00011900
              10 COLUMN 07        PIC 99     SOURCE TD-DAY.             00012000
              10 COLUMN 09        PIC X      VALUE '/'.                 00012100
              10 COLUMN 10        PIC 99     SOURCE TD-MONTH.           00012200
              10 COLUMN 12        PIC X      VALUE '/'.                 00012300
              10 COLUMN 13        PIC 99     SOURCE WS-YEAR-CC.         00012403
              10 COLUMN 15        PIC 99     SOURCE TD-YEAR.            00012503
              10 COLUMN 35        PIC A(49)  VALUE                      00012604
                    'COVID-19 TOP10 BY CASES AND DEATHS + MY FAVORITES'.00012704
              10 COLUMN 121       PIC X(05)  VALUE 'PAGE:'.             00012800
              10 COLUMN 127       PIC ZZ,ZZ9 SOURCE PAGE-COUNTER.       00012900
           05 LINE PLUS 1.                                              00013000
              10 COLUMN 01        PIC X(05)  VALUE 'TIME:'.             00013100
              10 COLUMN 07        PIC 99     SOURCE TT-HOURS.           00013200
              10 COLUMN 09        PIC X      VALUE ':'.                 00013300
              10 COLUMN 10        PIC 99     SOURCE TT-MINUTES.         00013400
              10 COLUMN 12        PIC X      VALUE ':'.                 00013500
              10 COLUMN 13        PIC 99     SOURCE TT-SECONDS.         00013600
       01  TOP10-CASES-HEADER TYPE DETAIL.                              00013702
           05 LINE PLUS 2.                                              00013802
              10 COLUMN 01        PIC A(24)  VALUE                      00013902
                                             'TOP10 by number of Cases'.00014002
              10 COLUMN 50        PIC A(05)  VALUE 'Cases'.             00014102
              10 COLUMN 65        PIC A(06)  VALUE 'Deaths'.            00014202
           05 LINE PLUS 1.                                              00014302
              10 COLUMN 01        PIC A(25)  VALUE                      00014402
                                            '-------------------------'.00014502
              10 COLUMN 47        PIC A(11)  VALUE '-----------'.       00014602
              10 COLUMN 62        PIC A(11)  VALUE '-----------'.       00014702
       01  TOP10-DEATHS-HEADER TYPE DETAIL.                             00014802
           05 LINE PLUS 2.                                              00014902
              10 COLUMN 01        PIC A(25)  VALUE                      00015002
                                            'TOP10 by number of Deaths'.00015102
              10 COLUMN 50        PIC A(05)  VALUE 'Cases'.             00015202
              10 COLUMN 65        PIC A(06)  VALUE 'Deaths'.            00015302
           05 LINE PLUS 1.                                              00015402
              10 COLUMN 01        PIC A(25)  VALUE                      00015502
                                            '-------------------------'.00015602
              10 COLUMN 47        PIC A(11)  VALUE '-----------'.       00015702
              10 COLUMN 62        PIC A(11)  VALUE '-----------'.       00015802
       01  FAVOURITE-HEADER TYPE DETAIL.                                00015902
           05 LINE PLUS 2.                                              00016002
              10 COLUMN 01        PIC A(10)  VALUE 'FAVOURITES'.        00016104
              10 COLUMN 50        PIC A(05)  VALUE 'Cases'.             00016202
              10 COLUMN 65        PIC A(06)  VALUE 'Deaths'.            00016302
           05 LINE PLUS 1.                                              00016402
              10 COLUMN 01        PIC A(25)  VALUE                      00016502
                                            '-------------------------'.00016602
              10 COLUMN 47        PIC A(11)  VALUE '-----------'.       00016702
              10 COLUMN 62        PIC A(11)  VALUE '-----------'.       00016802
       01  TOP10-DETAIL TYPE DETAIL.                                    00016900
           05 LINE PLUS 1.                                              00017000
              10 COLUMN 01        PIC X(40)  SOURCE WS-CTR-COUNTRYNAME. 00017100
              10 COLUMN 47        PIC ZZZ,ZZZ,ZZZ SOURCE WS-CTR-CASES.  00017200
              10 COLUMN 62        PIC ZZZ,ZZZ,ZZZ SOURCE WS-CTR-DEATHS. 00017300
      ******************************************************************00017400
       PROCEDURE DIVISION.                                              00017500
      ******************************************************************00017600
       0000-MAIN.                                                       00017700
      **********************************                                00017800
           PERFORM 0001-INITIALISE THRU 0001-EXIT.                      00017900
           PERFORM 1000-READ-COUNTRY-TOTALS THRU 1000-EXIT              00018001
               UNTIL EOF.                                               00018101
      * TOP10 by number of cases                                        00018203
           MOVE 1 TO WS-TABLE-SUB.                                      00018300
           GENERATE TOP10-CASES-HEADER.                                 00018402
           PERFORM 4000-PRINT-TOP10-CASES  THRU 4000-EXIT.              00018502
      * TOP10 by number of deaths                                       00018603
           MOVE 1 TO WS-TABLE-SUB.                                      00018702
           GENERATE TOP10-DEATHS-HEADER.                                00018802
           PERFORM 4001-PRINT-TOP10-DEATHS THRU 4001-EXIT.              00018902
      * 5 FAVOURITES                                                    00019003
           GENERATE FAVOURITE-HEADER.                                   00019102
           PERFORM 4100-PROCESS-FAVOURITES THRU 4100-EXIT.              00019203
           TERMINATE TOP10-REPORT.                                      00019303
           CLOSE TOTCNTRY-FILE.                                         00019400
       0000-EXIT.                                                       00019500
           STOP RUN.                                                    00019600
      **********************************                                00019700
       0001-INITIALISE.                                                 00019800
      **********************************                                00019900
           ACCEPT WS-FAV-COUNTRYCODE.                                   00020000
           MOVE CURRENT-DATE TO WS-TODAYS-DATE.                         00020100
           MOVE TIME-OF-DAY  TO WS-TODAYS-TIME.                         00020200
           OPEN INPUT TOTCNTRY-FILE,                                    00020300
                OUTPUT REPORT-PRINT.                                    00020400
           INITIATE TOP10-REPORT.                                       00020502
       0001-EXIT.                                                       00020600
           EXIT.                                                        00020700
      **********************************                                00020800
       1000-READ-COUNTRY-TOTALS.                                        00020900
      **********************************                                00021000
           READ TOTCNTRY-FILE                                           00021100
               AT END MOVE 'Y' TO END-OF-FILE.                          00021200
           IF NOT EOF THEN                                              00021300
               PERFORM 2000-PROCESS-COUNTRY-DATA THRU 2000-EXIT.        00021400
       1000-EXIT.                                                       00021500
           EXIT.                                                        00021600
      **********************************                                00021700
       2000-PROCESS-COUNTRY-DATA.                                       00021800
      **********************************                                00021900
      * If it is a Favorite Country, store the data to show in report   00022002
           PERFORM 2001-CHECK-IF-FAVOURITE THRU 2001-EXIT.              00022103
      * For each value, we want to check if the value is one of         00022200
      *  the TOP10, so that we can print it later on the report.        00022300
      *  To do so, we start by checking subscript 1 and go up,          00022400
      *  until either a TOP10 is found or we reached 10.                00022500
           MOVE 1 TO WS-TABLE-SUB.                                      00022600
           PERFORM 3000-UPDATE-TABLE-CASES THRU 3000-EXIT               00022702
               UNTIL WS-TABLE-SUB > COUNTER-TAB-OCCURS.                 00022800
           MOVE 1 TO WS-TABLE-SUB.                                      00022901
           PERFORM 3001-UPDATE-TABLE-DEATHS THRU 3001-EXIT              00023002
               UNTIL WS-TABLE-SUB > COUNTER-TAB-OCCURS.                 00023102
           MOVE 1 TO WS-TABLE-SUB.                                      00023202
       2000-EXIT.                                                       00023300
           EXIT.                                                        00023400
      **********************************                                00023500
       2001-CHECK-IF-FAVOURITE.                                         00023603
      **********************************                                00023703
           IF TOT-COUNTRYCODE = WS-FAV-CC-1 THEN                        00023803
               MOVE 1 TO WS-TABLE-SUB-FAVS                              00023903
               PERFORM 2002-ADD-TO-FAV THRU 2002-EXIT                   00024003
               GO TO 2001-EXIT.                                         00024103
           IF TOT-COUNTRYCODE = WS-FAV-CC-2 THEN                        00024203
               MOVE 2 TO WS-TABLE-SUB-FAVS                              00024303
               PERFORM 2002-ADD-TO-FAV THRU 2002-EXIT                   00024403
               GO TO 2001-EXIT.                                         00024503
           IF TOT-COUNTRYCODE = WS-FAV-CC-3 THEN                        00024603
               MOVE 3 TO WS-TABLE-SUB-FAVS                              00024703
               PERFORM 2002-ADD-TO-FAV THRU 2002-EXIT                   00024803
               GO TO 2001-EXIT.                                         00024903
           IF TOT-COUNTRYCODE = WS-FAV-CC-4 THEN                        00025003
               MOVE 4 TO WS-TABLE-SUB-FAVS                              00025103
               PERFORM 2002-ADD-TO-FAV THRU 2002-EXIT                   00025203
               GO TO 2001-EXIT.                                         00025303
           IF TOT-COUNTRYCODE = WS-FAV-CC-5 THEN                        00025403
               MOVE 5 TO WS-TABLE-SUB-FAVS                              00025503
               PERFORM 2002-ADD-TO-FAV THRU 2002-EXIT                   00025603
               PERFORM 2002-ADD-TO-FAV.                                 00025703
       2001-EXIT.                                                       00025803
           EXIT.                                                        00025903
      **********************************                                00026003
       2002-ADD-TO-FAV.                                                 00026103
      **********************************                                00026203
           MOVE TOT-COUNTRYNAME                                         00026303
                TO WS-TAB-FAVS-CNAME (WS-TABLE-SUB-FAVS).               00026403
           MOVE TOT-CASES                                               00026503
                TO WS-TAB-FAVS-CASES (WS-TABLE-SUB-FAVS).               00026603
           MOVE TOT-DEATHS                                              00026703
                TO WS-TAB-FAVS-DEATHS (WS-TABLE-SUB-FAVS).              00026803
       2002-EXIT.                                                       00026903
           EXIT.                                                        00027003
      **********************************                                00027103
       3000-UPDATE-TABLE-CASES.                                         00027202
      **********************************                                00027300
      * If the total cases is greater than the one stored               00027400
      *  at the table(subscript), then we want to store it.             00027500
      *  To do so, we need to displace all values to the right          00027600
      *  (i.e. 1 to 2, 2 to 3 and so on).                               00027700
           MOVE WS-TAB-CASES-CASES (WS-TABLE-SUB) TO WS-CASES.          00027801
           IF TOT-CASES > WS-CASES THEN                                 00027901
               MOVE COUNTER-TAB-OCCURS TO WS-MOVE-SUB-DEST              00028001
               MOVE COUNTER-TAB-OCCURS TO WS-MOVE-SUB-ORIG              00028101
               SUBTRACT 1 FROM WS-MOVE-SUB-ORIG                         00028201
               PERFORM 3100-DISPLACE-TABLE-CASES THRU 3100-EXIT         00028302
               MOVE TOT-COUNTRYNAME                                     00028400
                    TO WS-TAB-CASES-CNAME (WS-TABLE-SUB)                00028500
               MOVE TOT-CASES                                           00028600
                    TO WS-TAB-CASES-CASES (WS-TABLE-SUB)                00028700
               MOVE TOT-DEATHS                                          00028802
                    TO WS-TAB-CASES-DEATHS (WS-TABLE-SUB)               00028902
      *        If value was stored, we do not need to continue          00029000
      *          checking the table. Therefore, we make                 00029100
      *          WS-TABLE-SUB greater than COUNTER-TAB-OCCURS           00029200
      *          to stop 2000 calling here.                             00029300
               MOVE COUNTER-TAB-OCCURS TO WS-TABLE-SUB.                 00029400
           ADD 1 TO WS-TABLE-SUB.                                       00029500
       3000-EXIT.                                                       00029600
           EXIT.                                                        00029700
      **********************************                                00029802
       3001-UPDATE-TABLE-DEATHS.                                        00029902
      **********************************                                00030002
      * If the total deaths is greater than the one stored              00030102
      *  at the table(subscript), then we want to store it.             00030202
      *  To do so, we need to displace all values to the right          00030302
      *  (i.e. 1 to 2, 2 to 3 and so on).                               00030402
           MOVE WS-TAB-DEATHS-DEATHS (WS-TABLE-SUB) TO WS-DEATHS.       00030502
           IF TOT-DEATHS > WS-DEATHS THEN                               00030602
               MOVE COUNTER-TAB-OCCURS TO WS-MOVE-SUB-DEST              00030702
               MOVE COUNTER-TAB-OCCURS TO WS-MOVE-SUB-ORIG              00030802
               SUBTRACT 1 FROM WS-MOVE-SUB-ORIG                         00030902
               PERFORM 3101-DISPLACE-TABLE-DEATHS THRU 3101-EXIT        00031002
               MOVE TOT-COUNTRYNAME                                     00031102
                    TO WS-TAB-DEATHS-CNAME (WS-TABLE-SUB)               00031202
               MOVE TOT-CASES                                           00031302
                    TO WS-TAB-DEATHS-CASES (WS-TABLE-SUB)               00031402
               MOVE TOT-DEATHS                                          00031502
                    TO WS-TAB-DEATHS-DEATHS (WS-TABLE-SUB)              00031602
      *        If value was stored, we do not need to continue          00031702
      *          checking the table. Therefore, we make                 00031802
      *          WS-TABLE-SUB greater than COUNTER-TAB-OCCURS           00031902
      *          to stop 2000 calling here.                             00032002
               MOVE COUNTER-TAB-OCCURS TO WS-TABLE-SUB.                 00032102
           ADD 1 TO WS-TABLE-SUB.                                       00032202
       3001-EXIT.                                                       00032302
           EXIT.                                                        00032402
      **********************************                                00032500
       3100-DISPLACE-TABLE-CASES.                                       00032602
      **********************************                                00032700
      * Move values in table from WS-TABLE-SUB to WS-TABLE-SUB+1,       00032800
      * and continue to do it until reach bottom of the table           00032900
      * which is defined by COUNTER-TAB-OCCURS                          00033000
           MOVE WS-TAB-CASES-CNAME (WS-MOVE-SUB-ORIG)                   00033100
                TO WS-TAB-CASES-CNAME (WS-MOVE-SUB-DEST).               00033200
           MOVE WS-TAB-CASES-CASES (WS-MOVE-SUB-ORIG)                   00033300
                TO WS-TAB-CASES-CASES (WS-MOVE-SUB-DEST).               00033400
           MOVE WS-TAB-CASES-DEATHS (WS-MOVE-SUB-ORIG)                  00033502
                TO WS-TAB-CASES-DEATHS (WS-MOVE-SUB-DEST).              00033602
           SUBTRACT 1 FROM WS-MOVE-SUB-ORIG.                            00033700
           IF WS-MOVE-SUB-ORIG > WS-TABLE-SUB                           00033801
             OR WS-MOVE-SUB-ORIG = WS-TABLE-SUB THEN                    00033902
               SUBTRACT 1 FROM WS-MOVE-SUB-DEST                         00034000
               GO TO 3100-DISPLACE-TABLE-CASES.                         00034102
       3100-EXIT.                                                       00034202
           EXIT.                                                        00034300
      **********************************                                00034402
       3101-DISPLACE-TABLE-DEATHS.                                      00034502
      **********************************                                00034602
      * Move values in table from WS-TABLE-SUB to WS-TABLE-SUB+1,       00034702
      * and continue to do it until reach bottom of the table           00034802
      * which is defined by COUNTER-TAB-OCCURS                          00034902
           MOVE WS-TAB-DEATHS-CNAME (WS-MOVE-SUB-ORIG)                  00035002
                TO WS-TAB-DEATHS-CNAME (WS-MOVE-SUB-DEST).              00035102
           MOVE WS-TAB-DEATHS-CASES (WS-MOVE-SUB-ORIG)                  00035202
                TO WS-TAB-DEATHS-CASES (WS-MOVE-SUB-DEST).              00035302
           MOVE WS-TAB-DEATHS-DEATHS (WS-MOVE-SUB-ORIG)                 00035402
                TO WS-TAB-DEATHS-DEATHS (WS-MOVE-SUB-DEST).             00035502
           SUBTRACT 1 FROM WS-MOVE-SUB-ORIG.                            00035602
           IF WS-MOVE-SUB-ORIG > WS-TABLE-SUB                           00035702
             OR WS-MOVE-SUB-ORIG = WS-TABLE-SUB THEN                    00035802
               SUBTRACT 1 FROM WS-MOVE-SUB-DEST                         00035902
               GO TO 3101-DISPLACE-TABLE-DEATHS.                        00036002
       3101-EXIT.                                                       00036102
           EXIT.                                                        00036202
      **********************************                                00036300
       4000-PRINT-TOP10-CASES.                                          00036402
      **********************************                                00036502
           MOVE WS-TAB-CASES-CNAME (WS-TABLE-SUB) TO WS-CTR-COUNTRYNAME.00036602
           MOVE WS-TAB-CASES-CASES (WS-TABLE-SUB)   TO WS-CTR-CASES.    00036702
           MOVE WS-TAB-CASES-DEATHS (WS-TABLE-SUB)  TO WS-CTR-DEATHS.   00036802
           GENERATE TOP10-DETAIL.                                       00036902
           ADD 1 TO WS-TABLE-SUB.                                       00037002
           IF WS-TABLE-SUB < COUNTER-TAB-OCCURS                         00037102
             OR WS-TABLE-SUB = COUNTER-TAB-OCCURS THEN                  00037202
               GO TO 4000-PRINT-TOP10-CASES.                            00037302
       4000-EXIT.                                                       00037402
           EXIT.                                                        00037502
      **********************************                                00037602
       4001-PRINT-TOP10-DEATHS.                                         00037702
      **********************************                                00037802
           MOVE WS-TAB-DEATHS-CNAME (WS-TABLE-SUB)                      00037902
                                                  TO WS-CTR-COUNTRYNAME.00038002
           MOVE WS-TAB-DEATHS-CASES (WS-TABLE-SUB)  TO WS-CTR-CASES.    00038102
           MOVE WS-TAB-DEATHS-DEATHS (WS-TABLE-SUB) TO WS-CTR-DEATHS.   00038202
           GENERATE TOP10-DETAIL.                                       00038302
           ADD 1 TO WS-TABLE-SUB.                                       00038402
           IF WS-TABLE-SUB < COUNTER-TAB-OCCURS                         00038502
             OR WS-TABLE-SUB = COUNTER-TAB-OCCURS THEN                  00038602
               GO TO 4001-PRINT-TOP10-DEATHS.                           00038702
       4001-EXIT.                                                       00038802
           EXIT.                                                        00038902
      **********************************                                00039002
       4100-PROCESS-FAVOURITES.                                         00039103
      **********************************                                00039202
           IF WS-FAV-CC-1 IS ALPHABETIC THEN                            00039303
               DISPLAY 'WS-FAV-CC-1: ' WS-FAV-CC-1                      00039403
               MOVE 1 TO WS-TABLE-SUB-FAVS                              00039503
               PERFORM 4101-PRINT-FAV THRU 4101-EXIT.                   00039603
           IF WS-FAV-CC-2 IS ALPHABETIC THEN                            00039703
               DISPLAY 'WS-FAV-CC-2: ' WS-FAV-CC-2                      00039803
               MOVE 2 TO WS-TABLE-SUB-FAVS                              00039903
               PERFORM 4101-PRINT-FAV THRU 4101-EXIT.                   00040003
           IF WS-FAV-CC-3 IS ALPHABETIC THEN                            00040103
               DISPLAY 'WS-FAV-CC-3: ' WS-FAV-CC-3                      00040203
               MOVE 3 TO WS-TABLE-SUB-FAVS                              00040303
               PERFORM 4101-PRINT-FAV THRU 4101-EXIT.                   00040403
           IF WS-FAV-CC-4 IS ALPHABETIC THEN                            00040503
               DISPLAY 'WS-FAV-CC-4: ' WS-FAV-CC-4                      00040603
               MOVE 4 TO WS-TABLE-SUB-FAVS                              00040703
               PERFORM 4101-PRINT-FAV THRU 4101-EXIT.                   00040803
           IF WS-FAV-CC-5 IS ALPHABETIC THEN                            00040903
               DISPLAY 'WS-FAV-CC-5: ' WS-FAV-CC-5                      00041003
               MOVE 5 TO WS-TABLE-SUB-FAVS                              00041103
               PERFORM 4101-PRINT-FAV THRU 4101-EXIT.                   00041203
       4100-EXIT.                                                       00041303
           EXIT.                                                        00041403
      **********************************                                00041503
       4101-PRINT-FAV.                                                  00041603
      **********************************                                00041703
           MOVE WS-TAB-FAVS-CNAME (WS-TABLE-SUB-FAVS)                   00041803
                TO WS-CTR-COUNTRYNAME.                                  00041903
           MOVE WS-TAB-FAVS-CASES (WS-TABLE-SUB-FAVS)                   00042003
                TO WS-CTR-CASES.                                        00042103
           MOVE WS-TAB-FAVS-DEATHS (WS-TABLE-SUB-FAVS)                  00042203
                TO WS-CTR-DEATHS.                                       00042303
           GENERATE TOP10-DETAIL.                                       00042402
       4101-EXIT.                                                       00042503
           EXIT.                                                        00042602
      ******************************************************************00042700
/*                                                                      00042800
//LKED.SYSLIB  DD DISP=SHR,DSNAME=SYS1.COBLIB                           00042900
//             DD DISP=SHR,DSNAME=SYS1.LINKLIB                          00043000
//             DD DISP=SHR,DSNAME=COVID19.LINKLIB                       00043100
//LKED.SYSLMOD DD DISP=SHR,DSNAME=COVID19.LINKLIB(REPCNTRY)             00043200
//                                                                      00043300
