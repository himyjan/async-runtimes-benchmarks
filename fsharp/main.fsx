(* F# benchmark — async workflows with Async.Parallel.
   All 100k async tasks are registered concurrently and each awaits
   a 10-second delay. The async runtime schedules them cooperatively;
   all 100k tasks wait 10 seconds and finish at ~t+10s. *)
open System

let numTasks =
    match System.Environment.GetCommandLineArgs() with
    | [| _; s |] -> System.Int32.Parse(s)
    | _ -> 100000

let worker () = async {
    do! System.Threading.Tasks.Task.Delay 10000 |> Async.AwaitTask
}

let tasks = [ for _ in 1 .. numTasks -> worker () ]
Async.RunSynchronously (Async.Parallel tasks)

printfn "All tasks completed"
