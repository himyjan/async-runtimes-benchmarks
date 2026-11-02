import gleam/io
import gleam/task

pub fn main() {
  let num_tasks = 100_000

  let tasks =
    list.range(1, num_tasks)
    |> list.map(fn(_) {
      task.spawn(fn() { task.sleep(10_000) })
    })
    |> list.map(task.await)

  io.println("All tasks completed")
}
