# Nim benchmark — asyncdispatch with sleepAsync.
# All 100k async tasks registered concurrently, each sleeping 10 seconds.
# The event loop aggregates all timers — they all fire at t+10s.
import asyncdispatch, times, os

let num_tasks = if paramCount() > 0:
                  parseInt(paramStr(1))
                else:
                  100_000

async proc main() =
    var tasks: seq[Future[void]] = @[]
    for _ in 0 ..< num_tasks:
        tasks.add(sleepAsync(10_000))
    for task in tasks:
        await task

runBlocking(main)
echo "All tasks completed"
