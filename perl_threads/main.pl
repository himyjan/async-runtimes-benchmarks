#!/usr/bin/env perl
# Perl threads benchmark — ithreads pool fed by a shared task counter.
#
# Same design as perl/: 1000 ithreads, all 100k tasks pending from t=0
# with one absolute deadline (start + 10s). Each thread claims task
# indices via a threads::shared counter and awaits the deadline — the
# first wait blocks until t+10s, later waits return immediately.
use strict;
use warnings;
use threads;
use threads::shared;
use Time::HiRes qw(time sleep);

my $num_tasks   = ($ARGV[0] // 100_000);
my $max_threads = 1000;
my $deadline    = time() + 10;

my $next : shared = 0;

sub worker {
    while (1) {
        my $i;
        {
            lock($next);
            $i = $next++;
        }
        last if $i >= $num_tasks;
        my $left = $deadline - time();
        sleep($left) if $left > 0;
    }
}

my @threads = map { threads->create(\&worker) } 1 .. $max_threads;
$_->join for @threads;

print "All tasks completed\n";
