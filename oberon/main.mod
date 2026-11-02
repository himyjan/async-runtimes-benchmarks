MODULE Main;

IMPORT Out, Threads, Time;

VAR
    numTasks := 100000;
    remaining := numTasks;
    sem := Threads.Sema.New(0);

PROCEDURE Worker;
BEGIN
    Time.Sleep(10000);
    DEC(remaining);
    IF remaining = 0 THEN Threads.Sema.Signal(sem) END
END Worker;

BEGIN
    REPEAT numTasks DO Threads.Fork(Worker);
    Threads.Sema.Wait(sem);
    Out.String("All tasks completed"); Out.Ln
END Main.
