# Julia benchmark — @async tasks with cooperative scheduling.
# All 100k tasks are spawned at t=0 and each sleeps 10 seconds.
# Julia's task scheduler runs them on available OS threads; all 100k
# tasks wait 10 seconds and finish at ~t+10s.
using Base.Threads

function main()
    num_tasks = parse(Int, ARGS[1])
    tasks = [Threads.@spawn sleep(10) for _ in 1:num_tasks]
    for t in tasks
        wait(t)
    end
    println("All tasks completed")
end

main()
