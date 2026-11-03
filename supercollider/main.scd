(
    var numTasks = 100000;
    var remaining = numTasks;
    var semaphore = Semaphore("main", 0);

    numTasks.do { |i|
        Routine({
            10.wait;
            remaining = remaining - 1;
            if (remaining == 0) {
                semaphore.signal;
            };
        }).play;
    };

    semaphore.wait;
    "All tasks completed".postln;
)
