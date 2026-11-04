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
