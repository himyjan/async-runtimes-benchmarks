import ballerina/io;
import ballerina/lang.concurrent;

public type Worker record {
    int id;
};

public function main() returns error? {
    int numTasks = 100000;
    int remaining = numTasks;
    final var sem = concurrent:Semaphore(0);

    foreach int i in 1..numTasks => {
        spawn worker(i, &remaining, sem);
    }

    sem.acquire();
    io:println("All tasks completed");
}

public isolated function worker(int id, ref int remaining, Semaphore sem) {
    sleep(10000);
    remaining = remaining - 1;
    if remaining == 0 {
        sem.release();
    }
}
