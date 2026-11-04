# Julia threads benchmark — Threads.@spawn tasks.
# All 100k tasks spawned concurrently, each sleeps 10 seconds.
using Base.Threads

function main()
    num_tasks = parse(Int, ARGS[1])
    remaining = Atomic{Int}(num_tasks)

    for _ in 1:num_tasks
        Threads.@spawn begin
            sleep(10)
            atomic_sub!(remaining, 1)
        end
    end

    while atomic_load(remaining) > 0
        sleep(0.1)
    end

    println("All tasks completed")
end

main()
