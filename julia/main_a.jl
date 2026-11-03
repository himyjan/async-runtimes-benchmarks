# Julia benchmark — Threads.@spawn with a bounded task queue.
# All 100k tasks share one absolute deadline (start + 10s). Worker tasks
# claim indices from a shared atomic counter and sleep until their deadline,
# so the run finishes in ~10s instead of 1000s.
using Base.Threads

function main()
    num_tasks = parse(Int, ARGS[1])
    pool_size = min(num_tasks, 1000)
    deadline = time() + 10.0
    next_idx = Atomic{Int}(0)
    done = Atomic{Int}(0)
    all_done = Condition()

    function worker()
        while true
            lock(all_done)
            i = next_idx[]
            if i >= num_tasks
                unlock(all_done)
                return
            end
            next_idx[] = i + 1
            unlock(all_done)
            left = deadline - time()
            if left > 0 sleep(left) end
            lock(all_done)
            done[] += 1
            if done[] >= num_tasks
                notify(all_done)
            end
            unlock(all_done)
        end
    end

    threads = [Threads.@spawn worker() for _ in 1:pool_size]
    for t in threads wait(t) end
    println("All tasks completed")
end

main()
