<<<Hack>>>

use HH\Lib\Async;
use HH\Lib\Async\Poll;
use HH\Lib\Async\WaitHandle;

async function sleepWorker(): Awaitable<void> {
    await Async\usleep(10_000_000); // 10 seconds in microseconds
}

async function main(): Awaitable<void> {
    $numTasks = $_SERVER['argv'][1] ?? 100000;
    $numTasks = (int)$numTasks;

    $handles = Vector {};
    for ($i = 0; $i < $numTasks; $i++) {
        $handles[] = sleepWorker();
    }

    await WaitHandle\all($handles);
    echo "All tasks completed\n";
}

\HH\Asio\join(main());
