import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class Threads {

    public static void main(String[] args) throws InterruptedException {
        int numTasks = 100000;
        if (args.length > 0) {
            numTasks = Integer.parseInt(args[0]);
        }

        // Fixed thread pool — all 100k tasks pending simultaneously,
        // 1000 worker threads execute them (not one OS thread per task).
        int poolSize = Math.min(numTasks, 1000);
        ExecutorService pool = Executors.newFixedThreadPool(poolSize);
        java.util.concurrent.CountDownLatch latch = new java.util.concurrent.CountDownLatch(numTasks);

        long start = System.nanoTime();
        for (int i = 0; i < numTasks; i++) {
            pool.submit(() -> {
                try {
                    Thread.sleep(10_000);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                } finally {
                    latch.countDown();
                }
            });
        }

        latch.await();
        pool.shutdown();
        pool.awaitTermination(1, TimeUnit.MINUTES);

        System.out.println("All tasks completed");
    }
}
