sub MAIN(Int $num-tasks = 100_000) {
    my @promises = (^$num-tasks).map: {
        Promise.in(10);  # Non-blocking timer via event loop
    };
    await @promises;
    say "All tasks completed";
}
