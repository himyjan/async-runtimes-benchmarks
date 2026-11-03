// Nim (alt) benchmark — thread pool over a shared deadline table (--threads:on).
// All 100k tasks share one absolute deadline (start + 10s); 1000 worker
// threads claim tasks via a shared counter and sleep until each deadline.
import times, os, threads, locks

let num_tasks = if paramCount() > 0: parseInt(paramStr(1)) else: 100_000
let pool_size = min(num_tasks, 1000)
let deadline = cpuTime() + 10.0
var next_task = 0
var done = 0
let lock = initLock()

proc worker() =
    while true:
        acquire(lock)
        let i = next_task
        if i >= num_tasks:
            release(lock)
            return
        next_task = i + 1
        release(lock)
        let now = cpuTime()
        if now < deadline:
            sleep((deadline - now) * 1000)  # sleep takes milliseconds
        acquire(lock)
        done = done + 1
        release(lock)

var threads: array[pool_size, Thread[void]]
for i in 0 ..< pool_size:
    createThread(threads[i], worker)
for i in 0 ..< pool_size:
    joinThread(threads[i])

echo "All tasks completed"
