structure Bench
val numTasks = ref 100000
val remaining = ref !numTasks
val sem = Sync.newSemaphore 0

fun worker () = (
    OS.Process.delay (10.0 * 1000.0);
    remaining := !remaining - 1;
    if !remaining = 0 then Sync.semaphorePost sem
)

fun main () = (
    Array.tabulate (fn i => Thread.fork (fn () => worker ())) (Vector.tabulate (!numTasks, fn i => i));
    Array.app (fn _ => Thread.join) (Vector.tabulate (!numTasks, fn i => i));
    print "All tasks completed"
)

end
