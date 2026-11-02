import x10.lang.*;
import x10.util.concurrent.*;

public class Main {
    public static def main(self: Array[String]) {
        val numTasks = self.size > 1 ? Integer.parseInt(self(1)) : 100000;
        val remaining = new AtomicInteger(numTasks);
        val finish = new Finish();
        
        finish {
            for (i in 0..numTasks) {
                async at (here) {
                    Duration.sleep(Duration.seconds(10));
                    remaining.decrementAndGet();
                    if (remaining.get() == 0) {
                        finish.signal();
                    }
                }
            }
        }
        
        Console.OUT.println("All tasks completed");
    }
}
