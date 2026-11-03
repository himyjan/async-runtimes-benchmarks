// Rust channels benchmark — tokio tasks signalling completion over a
// tokio::sync::mpsc channel guarded by an atomic counter.
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::mpsc;
use tokio::task;

#[tokio::main]
async fn main() {
    let num_tasks: usize = std::env::args()
        .nth(1)
        .and_then(|s| s.parse().ok())
        .unwrap_or(100_000);

    let remaining = Arc::new(AtomicUsize::new(num_tasks));
    let (tx, mut rx) = mpsc::unbounded_channel::<()>();

    for _ in 0..num_tasks {
        let tx = tx.clone();
        let remaining = Arc::clone(&remaining);
        task::spawn(async move {
            tokio::time::sleep(Duration::from_secs(10)).await;
            if remaining.fetch_sub(1, Ordering::SeqCst) == 1 {
                let _ = tx.send(()); // last task to finish notifies main (unbounded = sync)
            }
        });
    }
    drop(tx);

    let _ = rx.recv().await;
    println!("All tasks completed");
}
