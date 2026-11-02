import asyncdispatch
import times
import os

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
