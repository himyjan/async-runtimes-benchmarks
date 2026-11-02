#!/usr/local/bin/io

numTasks := (System args size > 1) ? System args at(1) asNumber : 100000
remaining := numTasks
semaphore := Semaphore clone

numTasks times(
    Object clone do(
        sleep(10)
        remaining = remaining - 1
        if(remaining == 0, semaphore signal)
    ) asFuture start
)

semaphore wait
"All tasks completed" println
