(* OCaml benchmark — native thread pool over a shared deadline table.
   All 100k tasks share one absolute deadline (start + 10s); a pool of
   1000 OS threads claims tasks via a shared counter and sleeps until
   each task's deadline. Workers exit cleanly when all tasks are claimed. *)
let () =
  let num_tasks =
    match Array.length Sys.argv with
    | n when n > 1 -> int_of_string Sys.argv.(1)
    | _ -> 100_000
  in
  let pool_size = 1000 in
  let start = Unix.gettimeofday () in
  let deadline = start + 10.0 in
  let next = ref 0 in
  let lock = Mutex.create () in
  let remaining = ref num_tasks in
  let done = ref false in
  let cond = Condition.create () in
  let worker () =
    while not !done do
      Mutex.lock lock;
      let i = !next in
      if i >= num_tasks then begin
        if !remaining = 1 then begin
          remaining := 0;
          done := true;
          Condition.broadcast cond;
        end;
        Mutex.unlock lock;
        return
      end;
      next := i + 1;
      Mutex.unlock lock;
      (* Sleep until this task's shared deadline *)
      let now = Unix.gettimeofday () in
      if now < deadline then
        Unix.sleep (int_of_float (deadline -. now));
      Mutex.lock lock;
      remaining := !remaining - 1;
      if !remaining = 0 then begin
        done := true;
        Condition.broadcast cond;
      end;
      Mutex.unlock lock
    done
  in
  let threads = Array.init pool_size (fun _ -> Thread.create worker ()) in
  Mutex.lock lock;
  while not !done do Condition.wait cond lock done;
  Mutex.unlock lock;
  Array.iter Thread.join threads;
  print_endline "All tasks completed"
