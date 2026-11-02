actor Main
new create(env: Env) =>
    let numTasks = if env.args.size() > 1 then env.args[1].u64() else 100_000
    let remaining = U64(numTasks)
    let sem = Semaphore.new(0)

    for _ in Range.u64(0, numTasks) do
        actor Worker
            var r: U64 iso = remaining
            var s: Semaphore iso = sem
            be apply(r: U64 iso, s: Semaphore iso) =>
                Timer.sleep(Duration.seconds(10))
                r = r - 1
                if r == 0 then
                    s.signal()
                end
        end
    end

    sem.wait()
    env.out.print("All tasks completed")
