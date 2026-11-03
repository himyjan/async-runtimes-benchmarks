(* SML/NJ benchmark — Thread.fork pool over a shared deadline table.
   All 100k tasks share one absolute deadline; 1000 worker threads claim
   tasks via a shared counter and sleep until each task's deadline. *)
structure Bench =
struct
  val numTasks = ref 100000
  val poolSize = 1000
  val start = Time.now ()
  val deadline = Time.+(start, Time.fromReal 10.0)
  val next = ref 0
  val lock = Sync.newMutex ()
  val cond = Sync.newCondition ()
  val remaining = ref !numTasks

  fun worker () =
    (let
       fun loop () =
         Sync.mutexLock lock;
         (case !next of
            i => if i >= !numTasks then (
                   Sync.mutexUnlock lock;
                   ()
                 ) else (
                   next := !i + 1;
                   Sync.mutexUnlock lock;
                   let val now = Time.now () in
                   if Time.<(now, !deadline) then
                     (OS.Process.delay (Time.!(!deadline - now)));
                   Sync.mutexLock lock;
                   remaining := !remaining - 1;
                   if !remaining = 0 then Sync.conditionSignal cond;
                   Sync.mutexUnlock lock;
                   loop ()
                 )
         end)
     in
       loop ()
     end)

  fun main () =
    (Array.array (poolSize, NONE);
     Array.app (fn _ => Thread.fork (fn () => worker ())) (Array.array (poolSize, NONE));
     (* wait for all tasks *)
     Sync.mutexLock lock;
     (while !remaining > 0 do Sync.conditionWait (cond, lock));
     Sync.mutexUnlock lock;
     print "All tasks completed\n")

end

Bench.main ()
