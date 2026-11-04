structure Bench =
struct
  val numTasks = ref 100000
  val poolSize = 1000
  val remaining = ref !numTasks
  val lock = Sync.newMutex ()

  fun worker () =
    (OS.Process.delay (10.0 * 1000.0);
     Sync.mutexLock lock;
     remaining := !remaining - 1;
     Sync.mutexUnlock lock)

  fun main () =
    (Array.app (fn _ => Thread.fork (fn () => worker ())) (Vector.tabulate (poolSize, fn i => i));
     (* Wait for all tasks *)
     (let fun wait_loop () =
           Sync.mutexLock lock;
           if !remaining > 0 then
             (Sync.mutexUnlock lock;
              OS.Process.delay (0.1 * 1000.0);
              wait_loop())
             else
             (Sync.mutexUnlock lock))
     wait_loop ();
     print "All tasks completed\n")

end

Bench.main ()
