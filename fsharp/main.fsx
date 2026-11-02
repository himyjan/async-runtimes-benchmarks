(* F# async workflows — lightweight, cooperatively scheduled tasks *)
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
