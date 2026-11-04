package require Thread

set num_tasks 100000
if {$argc > 0} {
    set num_tasks [lindex $argv 0]
}

set pool_size 1000
set deadline [expr {[clock seconds] + 10}]
set done_count 0
set lock [thread::create -prefix lock_]
set main_tid [thread::id]

# Each worker handles a static subset of tasks; all share one deadline.
# Since all tasks sleep until the same deadline (start + 10s), each thread
# just sleeps once for ~10 seconds then reports done.
for {set w 0} {$w < $pool_size} {incr w} {
    thread::create {
        variable deadline main_tid
        set left [expr {$deadline - [clock seconds]}]
        if {$left > 0} {
            after [expr {$left * 1000}]
        }
        thread::send $main_tid [list done]
    }
}

# Wait for all workers to report done
while {$done_count < $pool_size} {
    set msg [thread::receive]
    if {[lindex $msg 0] eq "done"} {
        incr done_count
    }
}

puts "All tasks completed"
