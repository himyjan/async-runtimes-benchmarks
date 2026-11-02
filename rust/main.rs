use std::thread;
use std::time::Duration;

fn main() {
    let num_threads = 100000;
    let mut handles = Vec::new();
    for _ in 0..num_threads {
        let handle = thread::spawn(|| {
            thread::sleep(Duration::from_secs(10));
        });
        handles.push(handle);
    }
    for handle in handles {
        handle.join().unwrap();
    }
}
