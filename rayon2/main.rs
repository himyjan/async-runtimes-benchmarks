// Rayon (variant 2) benchmark — explicit rayon::ThreadPool + scope jobs.
//
// A dedicated 1000-thread rayon pool runs all 100k jobs. Every job
// shares one absolute deadline (start + 10s): each worker's first job
// blocks until t+10s, the rest return immediately.
use std::thread;
use std::time::{Duration, Instant};

fn main() {
    let num_tasks: usize = std::env::args()
        .nth(1)
        .and_then(|s| s.parse().ok())
        .unwrap_or(100_000);

    let deadline = Instant::now() + Duration::from_secs(10);

    let pool = rayon::ThreadPoolBuilder::new()
        .num_threads(1000)
        .build()
        .expect("failed to build rayon pool");

    pool.install(|| {
        rayon::scope(|s| {
            for _ in 0..num_tasks {
                s.spawn(move |_| {
                    let now = Instant::now();
                    if now < deadline {
                        thread::sleep(deadline - now);
                    }
                });
            }
        });
    });

    println!("All tasks completed");
}
