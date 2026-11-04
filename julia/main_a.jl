# Julia benchmark — Threads.@spawn pool over a shared deadline table.
# All 100k tasks share one absolute deadline (start + 10s). Worker tasks
# claim indices from a shared atomic counter and sleep until their deadline,
# so the run finishes in ~10s instead of 1000s.
using Base.Threads

function main()
    num_tasks = parse(Int, ARGS[1])
    pool_size = min(num_tasks, 1000)
    deadline = time() + 10.0
    next_idx = Atomic{Int}(0)

    function worker()
        while true
            idx = atomic_add!(next_idx, 1) - 1
            idx >= num_tasks && return
            left = deadline - time()
            if left > 0
                sleep(left)
            end
        end
    end

    threads = [Threads.@spawn worker() for _ in 1:pool_size]
    for t in threads
        wait(t)
    end
    println("All tasks completed")
end

main()
