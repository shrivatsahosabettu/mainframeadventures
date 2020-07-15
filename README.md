# Mainframe Adventures

This are just some examples I'm putting together meanwhile I re-learn COBOL.

I'm by no means an expert on COBOL or mainframes, so use it with caution. My experience with COBOL was circa 1997-2006 on OS/390 and AS/400.

If you have any snippets you would like to share or you think my code can be improved, please fill free to create a Pull Request.

---

## MVS 3.8j TOOLBOX

Useful (at least to me) JCLs for MVS 3.8j

---

## COVID-19 Report

In this project I created a series of programs for Linux and MVS 3.8j TK4- to get daily COVID-19 data and generates reports.

---

## OS/VS COBOL V1R2M4 (Prod# 5740-CB1) for MVS 3.8

* **TEMPLATE**: Template with (almost) all DIVISION and SECTION.
* **CONDITIO**: Example of use of conditional statements (IF/ELSE, IF NOT, SIGN, CLASS, CONDITION-NAME, AND).
* **ARITHMET**: Example of arithmetic operations (ADD, SUBTRACT, MULTIPLY, DIVIDE, COMPUTE).
* **ACCEPT**: Accept (receive) a value from SYSIN.
* **TABLES**: Examples of tables (arrays).
* **EXAMIN**: Some usages of EXAMINE (similar to INSPECT in z/OS COBOL).
* **CALLSUB1**: Example of calling by REFERENCE a COBOL subroutine.
* **CALLSUB3**: Subroutine to be called (cannot be executed independently).
* **STRUSTR**: This COBOL does not have STRING/UNSTRING. Here is how to do it instead.
* **DAYOWEEK**: Calculate which day of the week, using [Zeller's congruence algorithm](https://en.wikipedia.org/wiki/Zeller%27s_congruence).
* **SEQAPPND**: Example of use of WRITE and DISP=MOD to append to a Sequential file.
* **SEQREAD**: Example of use of READ and DISPLAY with a Sequential file.
* **SEQREWRT**: Example of use REWRITE to change a record on a Sequential file.
* **SEQWRITE**: Example of use WRITE and DISP=SHR to write (overwritting) records to a Sequential file.
* **TRANSFRM**: Example of TRANSFORM statement to alter characters.

Many thanks to the folks at [https://groups.io/g/H390-MVS](https://groups.io/g/H390-MVS) that helped me to finish READSEQ.

---

## IBM Enterprise COBOL for zOS

I had a brief access to an IBM Z mainframe, but now it's gone so do not expect much more to come here.

* **TEMPLATE**: Template with (almost) all DIVISION and SECTION.
* **CONDITIO**: Example of use of conditional statements (IF/ELSE, IF NOT, SIGN, CLASS, CONDITION-NAME, EVALUATE, AND/OR).
* **ARITHMET**: Example of arithmetic operations (ADD, SUBTRACT, MULTIPLY, DIVIDE, COMPUTE).
* **ACCEPT**: Accept (receive) a value from SYSIN.
* **ARRAYS**: Example of arrays (TABLE).
* **STRINGS**: Example of string manipulation.
* **WRITESEQ**: Example of use WRITE to add records to a Sequential file.
* **READSEQ**: Example of use of READ and DISPLAY with a Sequential file.
* **READSEQ2**: Example of use of READ, DISPLAY and STRING with a Sequential file.
* **REWRTSEQ**: Example of use REWRITE to change a record on a Sequential file.
* **CALLSUB1**: Example of calling by REFERENCE a COBOL subroutine.
* **CALLSUB2**: Example of calling by CONTENT a COBOL subroutine.
* **CALLSUB3**: Subroutine to be called (cannot be executed independently).
* **SUBMIJCL**: Submit a JCL via Internal Reader (INTRDR).
* **$EXECSUB**: JCL to execute SUBMIJCL.
