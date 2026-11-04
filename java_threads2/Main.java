public class Benchmark {
    static int numTasks = 100000;
    static int remaining;
    static CountDownLatch latch;
    static final int POOL_SIZE = 1000;

    static void worker() {
        try { Thread.sleep(10000); } catch (InterruptedException e) {}
        if (remaining.decrementAndGet() == 0) {
            latch.countDown();
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length > 0) numTasks = Integer.parseInt(args[0]);
        remaining = numTasks;
        latch = new CountDownLatch(1);

        // Fixed thread pool — 1000 workers, not one OS thread per task.
        ExecutorService pool = Executors.newFixedThreadPool(POOL_SIZE);
        for (int i = 0; i < numTasks; i++) {
            pool.submit(Benchmark::worker);
        }
        pool.shutdown();
        latch.await();
        pool.awaitTermination(1, TimeUnit.MINUTES);
        System.out.println("All tasks completed");
    }
}
