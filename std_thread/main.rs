// std::thread benchmark — plain thread pool over a shared deadline table
// (built with rustc only, no external crates).
//
// All 100k tasks are registered from t=0 with the same absolute deadline
// (start + 10s). 1000 std::threads claim tasks and sleep_until() each
// task's deadline — the first wait blocks until t+10s, later waits
// return immediately.
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::thread;
use std::time::{Duration, Instant};

const NUM_THREADS: usize = 1000;

fn main() {
    let num_tasks: usize = std::env::args()
        .nth(1)
        .and_then(|s| s.parse().ok())
        .unwrap_or(100_000);

    let deadline = Instant::now() + Duration::from_secs(10);

    // Task table: every task pending from t=0, due at start + 10s.
    let tasks = Arc::new(vec![deadline; num_tasks]);
    let next_task = Arc::new(AtomicUsize::new(0));

    let mut handles = Vec::with_capacity(NUM_THREADS);
    for _ in 0..NUM_THREADS {
        let tasks = Arc::clone(&tasks);
        let next_task = Arc::clone(&next_task);
        handles.push(thread::spawn(move || loop {
            let i = next_task.fetch_add(1, Ordering::Relaxed);
            if i >= num_tasks {
                break;
            }
            let now = Instant::now();
            if now < tasks[i] {
                thread::sleep(tasks[i] - now);
            }
        }));
    }

    for handle in handles {
        handle.join().unwrap();
    }
    println!("All tasks completed");
}
