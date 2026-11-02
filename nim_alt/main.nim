proc main(numTasks: int = 100000) =
    var remaining = numTasks
    var sem = newSemaphore(0)

    for i in 1..numTasks:
        spawn:
            sleep(10000)
            dec(remaining)
            if remaining == 0:
                sem.release()

    sem.acquire()
    echo "All tasks completed"
