module bench;

import std.stdio;
import std.parallelism;
import core.thread;
import core.time;

void main(string[] args) {
    auto numTasks = args.length > 1 ? to!int(args[1]) : 100000;
    parallel(numTasks, (i) {
        sleep(10.seconds);
    });
    writeln("All tasks completed");
}
