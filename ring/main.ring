load "std/file.nsh"

numTasks = 100000
if (numargs() > 1) numTasks = str2num(argv[2])

remaining = numTasks

for (i = 1; i <= numTasks; i++) {
    thread {
        sleep(10000)
        remaining--
        if (remaining == 0) {
            print("All tasks completed\n")
        }
    }
}
