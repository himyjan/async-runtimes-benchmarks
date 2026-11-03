// Crossbeam benchmark — crossbeam::channel feeding a std::thread pool.
//
// The channel is pre-loaded with one message per task (each message
// carries the task's absolute deadline, start + 10s), so all 100k tasks
// are pending in the channel from t=0. 1000 worker threads receive
// deadlines and sleep_until() them — the first wait blocks until t+10s,
// later waits return immediately.
use crossbeam::channel;
use std::thread;
use std::time::{Duration, Instant};

const NUM_THREADS: usize = 1000;

fn sleep_until(deadline: Instant) {
    let now = Instant::now();
    if now < deadline {
        thread::sleep(deadline - now);
    }
}

fn main() {
    let num_tasks: usize = std::env::args()
        .nth(1)
        .and_then(|s| s.parse().ok())
        .unwrap_or(100_000);

    let deadline = Instant::now() + Duration::from_secs(10);

    // Pre-load the channel: one pending task message per task.
    let (tx, rx) = channel::unbounded::<Instant>();
    for _ in 0..num_tasks {
        tx.send(deadline).expect("send failed");
    }
    drop(tx);

    let mut handles = Vec::with_capacity(NUM_THREADS);
    for _ in 0..NUM_THREADS {
        let rx = rx.clone();
        handles.push(thread::spawn(move || {
            while let Ok(deadline) = rx.recv() {
                sleep_until(deadline);
            }
        }));
    }

    for handle in handles {
        handle.join().unwrap();
    }
    println!("All tasks completed");
}
