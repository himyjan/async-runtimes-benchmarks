use async_std::task;
use std::time::Duration;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let num_tasks: usize = args.get(1).and_then(|s| s.parse().ok()).unwrap_or(100_000);
    
    async_std::task::block_on(async {
        let mut handles = Vec::with_capacity(num_tasks);
        for _ in 0..num_tasks {
            handles.push(task::spawn(async {
                task::sleep(Duration::from_secs(10)).await;
            }));
        }
        for handle in handles {
            handle.await;
        }
        println!("All tasks completed");
    });
}
