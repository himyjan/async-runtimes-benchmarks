import Lean.System.Thread
import Lean.System

def main : IO Unit := do
  let numTasks := match getArgs with
    | [_, s, ..] => Nat.ofString s.getOrDefault 100_000
    | _ => 100_000
  let remaining := IORef.mk numTasks
  let sem := Semaphore.mk 0

  for _ in [1..numTasks] do
    Thread.fork (fun _ => do
      Thread.sleep (10 * 1000)
      let r := IORef.getAndUpdate remaining (fun n => n - 1)
      if r - 1 = 0 then
        Semaphore.post sem
    ) []

  Semaphore.wait sem
  IO.println "All tasks completed"
