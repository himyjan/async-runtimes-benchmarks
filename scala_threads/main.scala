import scala.concurrent.{Future, Await}
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration.Duration.Inf

@main def run(numTasks: Int = 100000): Unit =
  val futures = List.fill(numTasks)(Future {
    Thread.sleep(10000)
  })
  Await.result(Future.sequence(futures), Inf)
  println("All tasks completed")
