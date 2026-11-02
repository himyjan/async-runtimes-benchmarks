package require Thread

set num_tasks 100000
if {$argc > 0} {
    set num_tasks [lindex $argv 0]
}

set main_tid [thread::id]
set ::remaining $num_tasks

for {set i 0} {$i < $num_tasks} {incr i} {
    thread::create "after 10000 {set done 1}; vwait done; thread::send $main_tid {incr ::remaining -1}"
}

while {$::remaining > 0} {
    vwait ::remaining
}

puts "All tasks completed"
