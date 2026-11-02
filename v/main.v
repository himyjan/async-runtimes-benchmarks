import time
import sync

fn main() {
    mut args := os.args
    mut num_tasks := 100_000
    if args.len > 1 {
        num_tasks = args[1].int()
    }

    mut wg := sync.NewWaitGroup()
    wg.add(num_tasks)
    for i in 0..num_tasks {
        go sleep_task(wg)
    }
    wg.wait()
    println('All tasks completed')
}

fn sleep_task(wg &sync.WaitGroup) {
    time.sleep(1_000_000_000 * 10) // 10 seconds in nanoseconds
    wg.task_done()
}
