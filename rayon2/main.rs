fn main() {
    let args: Vec<String> = std::env::args().collect();
    let num_tasks: usize = args.get(1).and_then(|s| s.parse().ok()).unwrap_or(100_000);
    let remaining = std::sync::atomic::AtomicUsize::new(num_tasks);
    
    rayon::scope(|s| {
        for _ in 0..num_tasks {
            s.spawn(|_| {
                std::thread::sleep(std::time::Duration::from_secs(10));
                remaining.fetch_sub(1, std::sync::atomic::Ordering::SeqCst);
            });
        }
    });
    
    println!("All tasks completed");
}
