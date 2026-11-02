using Base.Threads

num_tasks = parse(Int, ARGS[1])

# Use Julia's lightweight tasks with cooperative scheduling
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
