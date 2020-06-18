# Mainframe Adventures

This are just some examples I'm putting together meanwhile I re-learn COBOL.

I'm by no means an expert on COBOL or mainframes, so use it with caution. My experience with COBOL was circa 1997-2006 in OS/390 and AS/400

## OS/VS COBOL V1R2M4 (Prod# 5740-CB1) for MVS 3.8

* **TEMPLATE**: Template with (almost) all DIVISION and SECTION.
* **CONDITIO**: Example of use of conditional statements (IF/ELSE, IF NOT, SIGN, CLASS, CONDITION-NAME, AND).
* **ARITHMET**: Example of arithmetic operations (ADD, SUBTRACT, MULTIPLY, DIVIDE, COMPUTE).
* **ACCEPT**: Accept (receive) a value from SYSIN.
* **ARRAYS**: Example of arrays (TABLE).
* **EXAMIN**: Some usages of EXAMINE (similar to INSPECT in z/OS COBOL).
* **READSEQ**: Example of use of READ and DISPLAY with a Sequential file.
* **REWRTSEQ**: Example of use REWRITE to change a record on a Sequential file.
* **CALLSUB1**: Example of calling by REFERENCE a COBOL subroutine.
* **CALLSUB3**: Subroutine to be called (cannot be executed independently).
* **STRUSTR**: This COBOL does not have STRING/UNSTRING. Here is how to do it instead.

## IBM Enterprise COBOL for zOS

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

## MVS 3.8j TOOLBOX

Useful JCLs for MVS 3.8j

---

More to come... *soon*

Many thanks to the folks at [https://groups.io/g/H390-MVS](https://groups.io/g/H390-MVS) that helped me to finish READSEQ for MVS 3.8

If you have any snippets or you think my code can be improved, please fill free to create a Pull Request.
