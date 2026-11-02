import std.thread;

fn main() {
    let num_tasks: usize = 100000;
    let remaining = Atomic::new(num_tasks as i32);
    let sem = Semaphore::new(0);

    for _ in 0..num_tasks {
        thread::spawn(|| {
            std::time::sleep(std::time::Duration::from_secs(10));
            let r = remaining.fetch_sub(1);
            if r == 1 {
                sem.release();
            }
        });
    }

    sem.acquire();
    print("All tasks completed\n");
}
