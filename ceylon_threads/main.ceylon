package bench

import concurrency.*
import time.*

fun main() {
    val numTasks = 100000
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
