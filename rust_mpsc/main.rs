use std::thread;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::mpsc;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let num_tasks: usize = args.get(1).and_then(|s| s.parse().ok()).unwrap_or(100_000);
    let remaining = AtomicUsize::new(num_tasks);
    let (tx, rx) = mpsc::channel();

    let mut handles = Vec::with_capacity(num_tasks);
    for _ in 0..num_tasks {
        let tx = tx.clone();
        handles.push(std::thread::spawn(move || {
            std::thread::sleep(std::time::Duration::from_secs(10));
            if remaining.fetch_sub(1, Ordering::SeqCst) == 1 {
                let _ = tx.send(());
            }
        }));
    }

    drop(tx);
    let _ = rx.recv();
    println!("All tasks completed");
}
