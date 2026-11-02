using fan.sys.*;
using fan.concurrent.*;

class Main {
  static Void main() {
    Int numTasks := 100000;
    Int remaining := numTasks;
    Semaphore sem := Semaphore(0);

    numTasks.times |Int i| {
      Fan.fork {
        Duration(10000).sleep;
        Atomic.dec(ref remaining);
        if (remaining == 0) {
          sem.post;
        }
      }
    }

    sem.wait;
    Echo.print("All tasks completed");
  }
}
