import flix.concurrent.Par
import flix.concurrent.Par.Task

def main(): Unit \ IO = {
  val numTasks = 100000
  val tasks = List.tabulate(numTasks, _ => Par.delay {
    Thread.sleep(10000)
    ()
  })
  Par.sequence(tasks).run()
  println("All tasks completed")
}
