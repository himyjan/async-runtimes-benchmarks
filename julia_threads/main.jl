#!/usr/bin/env julia
using Base.Threads

num_tasks = parse(Int, ARGS[1])

# @threads :greedy uses an optimized work-stealing queue
# Lower allocation overhead than @spawn per task
# Best for uniform workloads where every task does the same thing
Threads.@threads :greedy for _ in 1:num_tasks
    sleep(10)
end

println("All tasks completed")
