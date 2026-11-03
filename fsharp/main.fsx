(* F# benchmark — thread pool over a shared deadline table.
   All 100k tasks share one absolute deadline (start + 10s); 1000 worker
   threads claim tasks and sleep until each task's deadline. *)
open System
open System.Threading

let numTasks =
    match System.Environment.GetCommandLineArgs() with
    | [| _; s |] -> System.Int32.Parse(s)
    | _ -> 100000

let poolSize = min numTasks 1000
let deadline = DateTimeOffset.UtcNow.ToUnixTimeSeconds() + 10L
let next = ref 0
let done = ref 0
let allDone = new ManualResetEventSlim(false)
let lockObj = new Object()

let worker () =
    while true do
        let i =
            lock lockObj (fun () ->
                if !next >= numTasks then
                    allDone.Set() |> ignore
                    -1
                else
                    let i = !next
                    next := i + 1
                    i)
        if i < 0 then return ()
        let now = DateTimeOffset.UtcNow.ToUnixTimeSeconds()
        if now < deadline then Thread.Sleep(int (deadline - now) * 1000)
        lock lockObj (fun () ->
            done := !done + 1
            if !done >= numTasks then allDone.Set() |> ignore)

let threads = [ for t in 1 .. poolSize -> new Thread(new ThreadStart(worker)) ]
for t in threads do t.Start()
allDone.Wait()
printfn "All tasks completed"
