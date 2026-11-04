package require Thread

set num_tasks 100000
if {$argc > 0} {
    set num_tasks [lindex $argv 0]
}

set pool_size 1000
set done 0
set main_tid [thread::id]

# Each worker handles a static slice of tasks; all sleep 10 seconds.
set tasks_per_worker [expr {$num_tasks / $pool_size}]
set remainder [expr {$num_tasks % $pool_size}]

set start 0
for {set w 0} {$w < $pool_size} {incr w} {
    set count $tasks_per_worker
    if {$w < $remainder} { incr count }
    set end [expr {$start + $count - 1}]
    
    thread::create {
        variable start end main_tid
        for {set i $start} {$i <= $end} {incr i} {
            after 10000
        }
        thread::send $main_tid [list done]
    }
    
    set start [expr {$end + 1}]
}

# Wait for all workers to report done
while {$done < $pool_size} {
    set msg [thread::receive]
    if {[lindex $msg 0] eq "done"} {
        incr done
    }
}

puts "All tasks completed"
