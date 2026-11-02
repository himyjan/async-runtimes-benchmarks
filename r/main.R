library(parallel)

num_tasks <- as.integer(commandArgs(trailingOnly = TRUE)[1])
if (is.na(num_tasks)) num_tasks <- 100000

# Fork-based: all tasks in one mclapply call, distributed across cores
mclapply(1:num_tasks, function(x) {
    Sys.sleep(10)
    return(x)
}, mc.cores = detectCores())

cat("All tasks completed\n")
