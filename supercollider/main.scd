(
    var numTasks = 100000;
    var remaining = numTasks;
    var semaphore = Semaphore("main", 0);

    for (i in 1..numTasks) {
        fork {
            (10).wait;
            remaining = remaining - 1;
            if (remaining == 0) {
                semaphore.signal;
            };
        };
    };

    semaphore.wait;
    "All tasks completed".postln;
)
