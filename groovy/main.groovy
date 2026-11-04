def numTasks = (args.size() > 0 ? args[0] as int : 100000)
def poolSize = Math.min(numTasks, 1000)
def remaining = new java.util.concurrent.AtomicInteger(numTasks)
def latch = new java.util.concurrent.CountDownLatch(1)
def executor = java.util.concurrent.Executors.newFixedThreadPool(poolSize)

numTasks.times {
    executor.submit {
        Thread.sleep(10000)
        if (remaining.decrementAndGet() == 0) {
            latch.countDown()
        }
    }
}

executor.shutdown()
latch.await()

println "All tasks completed"
