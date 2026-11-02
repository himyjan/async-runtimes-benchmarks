use tokio::time;
use tokio::task;
use std::time::Duration;

#[tokio::main]
async fn main() {
    let num_tasks: usize = std::env::args().nth(1)
        .and_then(|s| s.parse().ok())
        .unwrap_or(100_000);
    let mut tasks = Vec::with_capacity(num_tasks);
    for _ in 0..num_tasks {
        tasks.push(task::spawn(async {
            task::sleep(Duration::from_secs(10)).await;
        }));
    }
    for task in tasks {
        task.await.unwrap();
    }
    println!("All tasks completed");
}
