import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking

fun main() = runBlocking {
    val numTasks = args.firstOrNull()?.toIntOrNull() ?: 100_000

    val jobs = List(numTasks) {
        launch {
            delay(10_000L)
        }
    }

    jobs.forEach { it.join() }

    println("All tasks completed")
}
