// GTK (Rust, gtk_rs) benchmark — GLib main loop with 100k one-shot timers.
//
// Every task is registered on the default GLib main context from t=0
// with a 10s timeout. GLib dispatches all of them when they expire
// (~t+10s) and main exits when the last one fires.
use std::rc::Rc;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::time::Duration;

fn main() {
    let num_tasks: usize = std::env::args()
        .nth(1)
        .and_then(|s| s.parse().ok())
        .unwrap_or(100_000);

    let loop_ = Rc::new(glib::MainLoop::new(None, false));
    let done = Rc::new(AtomicUsize::new(0));

    for _ in 0..num_tasks {
        let done = Rc::clone(&done);
        let loop_ = Rc::clone(&loop_);
        glib::timeout_add_local(Duration::from_secs(10), move || {
            if done.fetch_add(1, Ordering::SeqCst) + 1 == num_tasks {
                loop_.quit();
            }
            glib::ControlFlow::Break // one-shot timer
        });
    }

    loop_.run();
    println!("All tasks completed");
}
