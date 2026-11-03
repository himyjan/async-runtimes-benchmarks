// Rust channels (variant 2) benchmark — every tokio task sends a message
// after its 10s sleep; main counts all messages over a bounded
// tokio::sync::mpsc channel.
use std::time::Duration;
use tokio::sync::mpsc;
use tokio::task;

#[tokio::main]
async fn main() {
    let num_tasks: usize = std::env::args()
        .nth(1)
        .and_then(|s| s.parse().ok())
        .unwrap_or(100_000);

    let (tx, mut rx) = mpsc::channel::<()>(num_tasks);

    for _ in 0..num_tasks {
        let tx = tx.clone();
        task::spawn(async move {
            tokio::time::sleep(Duration::from_secs(10)).await;
            let _ = tx.send(()).await;
        });
    }
    drop(tx);

    for _ in 0..num_tasks {
        rx.recv().await.expect("channel closed early");
    }
    println!("All tasks completed");
}
