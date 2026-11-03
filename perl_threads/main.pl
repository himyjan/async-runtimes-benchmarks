#!/usr/bin/env perl
# Perl benchmark — fork-based process pool (not ithreads)
# Perl ithreads clone the entire interpreter per thread — too heavy for 100k tasks.
# fork() with copy-on-write is memory-efficient on Unix-like systems.
# Non-blocking waitpid(WNOHANG) keeps ~1000 processes running continuously.

use strict;
use warnings;
use POSIX qw(:sys_wait_h);
use Time::HiRes qw(usleep);

my $num_tasks = ($ARGV[0] // 100_000);
my $max_procs = 1000;    # Max concurrent processes to avoid OOM
my %pids;

for my $i (1 .. $num_tasks) {
    # Non-blocking: reap finished child processes immediately
    while (1) {
        my $pid = waitpid(-1, WNOHANG); # WNOHANG = non-blocking
        if ($pid > 0) {
            delete $pids{$pid};
        } else {
            last;  # No more dead children to clean up
        }
    }

    # If at max processes, wait briefly for one to finish
    while (scalar keys %pids >= $max_procs) {
        my $pid = waitpid(-1, WNOHANG);
        if ($pid > 0) {
            delete $pids{$pid};
        } else {
            usleep(10_000);  # Throttle: sleep 10ms to avoid CPU spinning
        }
    }

    my $pid = fork();
    if (!defined $pid) {
        die "fork failed: $!";
    } elsif ($pid == 0) {
        # Child process — sleeps 10 seconds then exits
        sleep(10);
        exit(0);
    }
    $pids{$pid} = 1;
}

# Wait for remaining children to finish
while (scalar keys %pids) {
    my $pid = waitpid(-1, 0);
    delete $pids{$pid} if $pid > 0;
}

print "All tasks completed\n";
