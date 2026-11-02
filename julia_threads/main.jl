#!/usr/bin/env julia
using Base.Threads

num_tasks = parse(Int, ARGS[1])

@sync begin
    for _ in 1:num_tasks
        Threads.@spawn begin
            sleep(10)
        end
    end
end

println("All tasks completed")
