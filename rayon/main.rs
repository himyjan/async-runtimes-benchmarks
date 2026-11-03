// Rayon benchmark — rayon::scope with per-task deadline jobs.
//
// All 100k jobs are spawned from t=0 and share one absolute deadline
// (start + 10s). Each rayon worker's first job blocks until t+10s;
// the remaining jobs return immediately (timer aggregation for
// identical expiries).
use std::thread;
use std::time::{Duration, Instant};

fn main() {
    let num_tasks: usize = std::env::args()
        .nth(1)
        .and_then(|s| s.parse().ok())
        .unwrap_or(100_000);

    let deadline = Instant::now() + Duration::from_secs(10);

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

    println!("All tasks completed");
}
