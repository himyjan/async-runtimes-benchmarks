package main

import "core:threads"
import "core:time"
import "core:os"
import "core:strings"
import "fmt"

main :: proc() {
    args := os.args
    num_tasks := 100000
    if args.len > 1 {
        num_tasks = strings.parse_int(args[1], 10, 64) or { num_tasks = 100000 }
    }

    remaining := num_tasks
    event := threads.NewEvent()

    for i := 0; i < num_tasks; i++ {
        threads.Spawn(proc (data: ^int) {
            time.sleep(time.Second * 10)
            atomic_decrement(remaining)
            if remaining <= 0 {
                event.signal()
            }
        }, nil)
    }

    event.wait()
    fmt.println("All tasks completed")
}
