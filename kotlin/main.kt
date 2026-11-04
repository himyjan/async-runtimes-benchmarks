import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicInteger

fun main() {
    val numTasks = args.firstOrNull()?.toIntOrNull() ?: 100_000
    val remaining = AtomicInteger(numTasks)
    val latch = java.util.concurrent.CountDownLatch(1)
    val executor = Executors.newFixedThreadPool(1000)

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
