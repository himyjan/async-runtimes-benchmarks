fn main() {
    let args: Vec<String> = std::env::args().collect();
    let num_tasks: usize = args.get(1).and_then(|s| s.parse().ok()).unwrap_or(100_000);
    let remaining = std::sync::atomic::AtomicUsize::new(num_tasks);
    let sem = std::sync::Arc::new(std::sync::Barrier::new(num_tasks));
    
    let mut handles = Vec::with_capacity(num_tasks);
    for _ in 0..num_tasks {
        let sem = sem.clone();
        handles.push(std::thread::spawn(move || {
            std::thread::sleep(std::time::Duration::from_secs(10));
            remaining.fetch_sub(1, std::sync::atomic::Ordering::SeqCst);
            sem.wait();
        }));
    }
    
    for handle in handles {
        handle.join().unwrap();
    }
    println!("All tasks completed");
}
