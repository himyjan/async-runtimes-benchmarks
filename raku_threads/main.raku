sub MAIN(Int $num-tasks = 100_000) {
    my @promises = (^$num-tasks).map: {
        start { sleep(10); }
    };
    await @promises;
    say "All tasks completed";
}
