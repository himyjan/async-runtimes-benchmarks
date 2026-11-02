import java.util.concurrent.*

fun main(args: Array<String>) {
    val numTasks = if (args.size > 0) args[0].toInt() else 100000
    val remaining = AtomicInteger(numTasks)
    val latch = CountDownLatch(1)
    val executor = Executors.newFixedThreadPool(numTasks)

    for (i in 1..numTasks) {
        executor.submit {
            Thread.sleep(10000)
            if (remaining.decrementAndGet() == 0) {
                latch.countDown()
            }
        }
    }

    executor.shutdown()
    latch.await()
    println("All tasks completed")
}
