sub MAIN(Int $num-tasks = 100_000) {
    my $pool-size = min($num-tasks, 1000);
    my $remaining = $num-tasks;
    my $lock = Lock.new;
    my $cond = Cond.new;

    sub worker {
        sleep(10);
        $lock.protect: {
            $remaining--;
            if ($remaining == 0) {
                $cond.signal;
            }
        }
    }

    my @threads = (^$pool-size).map: { start { worker() } };

    $lock.protect: {
        $cond.wait($lock) unless $remaining == 0;
    }

    await @threads;
    say "All tasks completed";
}
