def numTasks = (args.size() > 0 ? args[0] as int : 100000)
def threads = []

numTasks.times {
    threads << Thread.start {
        Thread.sleep(10000)
    }
}

threads*.join()

println "All tasks completed"
