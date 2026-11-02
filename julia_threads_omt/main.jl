#!/usr/bin/env julia
using OhMyThreads

num_tasks = parse(Int, ARGS[1])

# OhMyThreads.tmap: fastest multi-threaded map with automatic chunking
# Better than raw @threads :greedy for CPU-heavy uniform workloads
# Uses chunking to minimize scheduler overhead per task
tmap(1:num_tasks) do _
    sleep(10)
end

println("All tasks completed")
