import core.thread;
import core.time;
import std.conv;
import std.stdio;

void worker() {
    Thread.sleep(10.seconds);
}

void main(string[] args) {
    int numTasks = 100_000;
    if (args.length > 1) {
        numTasks = to!int(args[1]);
    }

    auto threads = new Thread[](numTasks);
    foreach (i; 0 .. numTasks) {
        threads[i] = new Thread(&worker);
        threads[i].start();
    }
    foreach (t; threads) {
        t.join();
    }

    writeln("All tasks completed");
}
