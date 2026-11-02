# Modula-3 benchmark
MODULE Main EXPORTS Main;

IMPORT Thread, Fmt, ThreadState;

VAR
    numTasks := 100000;
    remaining := numTasks;
    sem := NEW(Thread.Sema).init(0);

PROCEDURE Worker = PROC Thread.T =
    BEGIN
        Thread.Sleep(10 * 1000);
        DEC(remaining);
        IF remaining = 0 THEN sem.signal() END;
    END Worker;

BEGIN
    FOR i := 1 TO numTasks DO
        Thread.Fork(Worker, NIL);
    END;
    sem.wait();
    Fmt.Print("All tasks completed\n");
END Main.
