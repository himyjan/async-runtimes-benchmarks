#!/usr/bin/env julia
using Base.Threads

num_tasks = parse(Int, ARGS[1])
remaining = Atomic{Int}(num_tasks)
sem = Condition()

for _ in 1:num_tasks
    Threads.@spawn begin
        sleep(10)
        old = atomic_add!(remaining, -1)
        if old == 1
            notify(sem)
        end
    end
end

wait(sem)
println("All tasks completed")
