#!/usr/bin/env perl
# Perl benchmark — ithreads pool (real OS threads, no fork()).
#
# 1000 ithreads share one absolute deadline (start + 10s): each thread's
# first wait blocks until t+10s, later waits return immediately (timer
# aggregation for identical expiries). Tasks are claimed via a shared
# atomic counter under a lock.
use strict;
use warnings;
use threads;
use threads::shared;
use Time::HiRes qw(time sleep);

my $num_tasks   = ($ARGV[0] // 100_000);
my $max_threads = 1000;    # Thread pool size (ithreads clone the interpreter)
my $deadline    = time() + 10;   # shared absolute deadline

my $next : shared = 0;     # task counter shared across threads

sub worker {
    while (1) {
        my $i;
        {
            lock($next);           # claim a task index atomically
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
