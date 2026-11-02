use IO

proc main() {
    config numTasks = 100000
    config remaining = numTasks
    var sem = newSemaphore(0)

    coforall i in 1..numTasks do
        sleep(10.0)
        with (lock remaining) do
            remaining = remaining - 1
        end
        if remaining == 0 then
            signal(sem)
        end
    end

    wait(sem)
    writeln("All tasks completed")
}
