public class Benchmark {
    static int numTasks = 100000;
    static int remaining;
    static CountDownLatch latch;

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
        
        Thread[] threads = new Thread[numTasks];
        for (int i = 0; i < numTasks; i++) {
            threads[i] = new Thread(Benchmark::worker);
            threads[i].start();
        }
        for (Thread t : threads) t.join();
        latch.await();
        System.out.println("All tasks completed");
    }
}
