import std.parallelism;
import core.thread;
import core.time;
import std.stdio;

void main(string[] args) {
    auto numTasks = args.length > 1 ? to!int(args[1]) : 100000;
    auto remaining = atomic(numTasks);
    auto sem = new Semaphore(0);

    parallel(numTasks, (i) {
        sleep(10.seconds);
        if (atomicFetchSub!(remaining, 1) == 1) {
            sem.notify();
        }
    });

    sem.wait();
    writeln("All tasks completed");
}
