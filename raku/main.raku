# Raku benchmark — start blocks (thread pool) over a shared deadline table.
# All 100k tasks share one absolute deadline (start + 10s); a pool of 1000
# start tasks claims indices and sleeps until each task's deadline.
sub MAIN(Int $num-tasks = 100_000) {
    my $pool-size = min($num-tasks, 1000);
    my $deadline = time + 10;
    my @next = 0;
    my @done = 0;
    my $lock = Lock.new;

    sub claim {
        $lock.protect: {
            return @next[]++ if @next[] < $num-tasks;
            return Nil;
        }
    }

    sub worker {
        while True {
            my $i = claim();
            last unless $i.defined;
            my $left = $deadline - time;
            sleep($left) if $left > 0;
            $lock.protect: { @done[]++; }
        }
    }

    my @threads = (^$pool-size).map: { start { worker() } };
    await @threads;
    say "All tasks completed";
}
