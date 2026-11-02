(* OCaml native threads — one OS thread per task *)
let () =
  let num_tasks =
    match Array.length Sys.argv with
    | n when n > 1 -> int_of_string Sys.argv.(1)
    | _ -> 100_000
  in
  let threads =
    Array.init num_tasks (fun _ ->
        Thread.create (fun () -> Unix.sleep 10) ())
  in
  Array.iter Thread.join threads;
  print_endline "All tasks completed"
