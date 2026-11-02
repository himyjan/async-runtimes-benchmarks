import neko.vm.Thread;

class Main {
    static var numTasks:Int = 100000;
    static var remaining:Int = numTasks;
    static var sem:neko.vm.Semaphore = neko.vm.Semaphore.create(0);

    static function worker() {
        neko.vm.Sys.sleep(10.0);
        remaining = remaining - 1;
        if (remaining == 0) {
            sem.signal();
        }
    }

    static function main() {
        for (i in 0...numTasks) {
            Thread.create(worker);
        }
        sem.wait();
        Sys.println("All tasks completed");
    }
}
