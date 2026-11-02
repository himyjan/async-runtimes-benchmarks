use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::thread;
use std::time::Duration;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let num_tasks: usize = args.get(1).and_then(|s| s.parse().ok()).unwrap_or(100_000);
    let remaining = Arc::new(AtomicUsize::new(num_tasks));
    let sem = Arc::new(std::sync::Barrier::new(num_tasks));
    
    let mut handles = Vec::with_capacity(num_tasks);
    for _ in 0..num_tasks {
        let remaining = remaining.clone();
        let sem = sem.clone();
        handles.push(thread::spawn(move || {
            thread::sleep(Duration::from_secs(10));
            remaining.fetch_sub(1, Ordering::SeqCst);
            sem.wait();
        }));
    }
    
    for handle in handles {
        handle.join().unwrap();
    }
    println!("All tasks completed");
}
