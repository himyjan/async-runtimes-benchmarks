sub MAIN(Int $num-tasks = 100_000) {
    my $pool-size = min($num-tasks, 1000);
    my $deadline = time + 10;
    my $next = 0;
    my $lock = Lock.new;

    sub claim {
        $lock.protect: {
            return $next++ if $next < $num-tasks;
            return Nil;
        }
    }

    sub worker {
        while True {
            my $i = claim();
            last unless $i.defined;
            my $left = $deadline - time;
            sleep($left) if $left > 0;
        }
    }

    my @threads = (^$pool-size).map: { start { worker() } };
    await @threads;
    say "All tasks completed";
}
