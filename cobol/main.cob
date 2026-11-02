       IDENTIFICATION DIVISION.
       PROGRAM-ID. Bench.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. GnuCOBOL.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  Num-Tasks      PIC 9(9) VALUE 100000.
       01  I              PIC 9(9).
       01  Arg-Count      PIC 9(9).
       01  Arg-String     PIC X(32).

       PROCEDURE DIVISION.
       Main.
           ACCEPT Arg-Count FROM COMMAND-LINE.
           IF Arg-Count > 0 THEN
               ACCEPT Arg-String FROM COMMAND-LINE-ARGUMENT 1.
               MOVE Arg-String TO Num-Tasks.
           END-IF.

           PERFORM VARYING I FROM 1 BY 1 UNTIL I > Num-Tasks
               CALL "C$THREAD" USING BY VALUE 0, BY VALUE 0,
                   BY REFERENCE Worker-Function, BY VALUE 0
               END-CALL
           END-PERFORM.

           *> Wait long enough for all 10-second threads to finish
           CALL "sleep" USING BY VALUE 11.

           DISPLAY "All tasks completed".
           STOP RUN.

       WORKER-FUNCTION.
           CALL "sleep" USING BY VALUE 10.
           EXIT PROGRAM.
