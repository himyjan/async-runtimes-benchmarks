structure Bench =
struct
  val numTasks = ref 100000
  val poolSize = 1000
  val start = Time.now ()
  val deadline = Time.+(start, Time.fromReal 10.0)
  val next = ref 0
  val lock = Sync.newMutex ()

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
                   loop ()
                 )
         end)
     in
       loop ()
     end)

  fun main () =
    (Array.app (fn _ => Thread.fork (fn () => worker ())) (Vector.tabulate (poolSize, fn i => i));
     print "All tasks completed\n")

end

Bench.main ()
