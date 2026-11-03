use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

#define NUM_THREADS 1000

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let num_tasks: usize = args.get(1).and_then(|s| s.parse().ok()).unwrap_or(100_000);
    let remaining = AtomicUsize::new(num_tasks);
    let (tx, rx) = mpsc::channel();

    let mut handles = Vec::with_capacity(NUM_THREADS);
    for _ in 0..NUM_THREADS {
        let tx = tx.clone();
        let remaining = remaining.clone();
        handles.push(std::thread::spawn(move || {
            loop {
                let i = remaining.fetch_sub(1, Ordering::SeqCst);
                if i == 0 {
                    break;
                }
                thread::sleep(Duration::from_secs(10));
            }
        }));
    }

    drop(tx);
    let _ = rx.recv();
    println!("All tasks completed");
}
