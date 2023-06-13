use async_std::task;
use std::time::Duration;

#[async_std::main]
async fn main() {
    let num_tasks = 100000;
    let mut tasks = Vec::new();
    for _ in 0..num_tasks {
        tasks.push(task::spawn(async {
            task::sleep(Duration::from_secs(10)).await;
        }));
    }
    for task in tasks {
        task.await.unwrap();
    }
}
