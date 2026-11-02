#!/usr/bin/env perl
# Perl benchmark — fork-based process pool (not ithreads)
# Perl ithreads clone the entire interpreter per thread, which is too heavy.
# fork() with copy-on-write is much more memory-efficient on Unix-like systems.

use strict;
use warnings;
use POSIX qw(:sys_wait_h);

my $num_tasks = ($ARGV[0] // 100_000);
my $max_procs = 1000;  # Max concurrent processes to avoid OOM
my %pids;

# Fork workers in bounded batches
for my $i (1 .. $num_tasks) {
    # Reap finished children to keep process count bounded
    while (scalar keys %pids >= $max_procs) {
        my $pid = waitpid(-1, 0);
        delete $pids{$pid} if $pid > 0;
    }

    my $pid = fork();
    if (!defined $pid) {
        die "fork failed: $!";
    } elsif ($pid == 0) {
        # Child process
        sleep(10);
        exit(0);
    }
    $pids{$pid} = 1;
}

# Wait for remaining children
while (scalar keys %pids) {
    my $pid = waitpid(-1, 0);
    delete $pids{$pid} if $pid > 0;
}

print "All tasks completed\n";
