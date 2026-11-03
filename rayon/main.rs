use std::sync::atomic::{AtomicUsize, Ordering};
use std::thread;
use std::time::Duration;

#define NUM_THREADS 1000

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let num_tasks: usize = args.get(1).and_then(|s| s.parse().ok()).unwrap_or(100_000);
    let remaining = AtomicUsize::new(num_tasks);

    let mut handles = Vec::with_capacity(NUM_THREADS);
    for _ in 0..NUM_THREADS {
        let remaining = remaining.clone();
        handles.push(thread::spawn(move || {
            loop {
                let i = remaining.fetch_sub(1, Ordering::SeqCst);
                if i == 0 {
                    break;
                }
                thread::sleep(Duration::from_secs(10));
            }
        }));
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("All tasks completed");
}
