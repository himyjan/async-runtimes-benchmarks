use vlang.sync;

fn main() {
    mut num_tasks := 100000
    if len(os.args) > 1 {
        num_tasks = os.args[1].int()
    }
    
    mut remaining := num_tasks
    mut wg := sync.NewWaitGroup()
    wg.add(num_tasks)
    
    for i in 0..num_tasks {
        go sleep_task(&mut remaining, &wg)
    }
    wg.wait()
    println('All tasks completed')
}

fn sleep_task(remaining &mut int, wg &sync.WaitGroup) {
    time.sleep(1_000_000_000 * 10)
    atomic_dec(remaining)
    wg.task_done()
}
