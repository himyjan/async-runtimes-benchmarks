# Raku benchmark — Promise.in timers on the event loop.
# All 100k promises are created at t=0 and fire at t+10s concurrently.
sub MAIN(Int $num-tasks = 100_000) {
    my @promises = (^$num-tasks).map: {
        Promise.in(10);  # Non-blocking timer via event loop
    };
    await @promises;
    say "All tasks completed";
}
