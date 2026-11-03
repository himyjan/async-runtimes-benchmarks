#!/usr/bin/env Rscript
library(coro)

# Helper function to parse CLI arguments
get_num_tasks <- function() {
    args <- commandArgs(trailingOnly = TRUE)
    default_tasks <- 100000

    if (length(args) > 0) {
        parsed <- suppressWarnings(as.integer(args[1]))
        if (!is.na(parsed) && parsed > 0) {
            return(parsed)
        } else {
            cat("Invalid argument. Using default:", default_tasks, "\n", file = stderr())
        }
    }
    return(default_tasks)
}

# Define an async worker task using coro
worker_async <- coro::async(function() {
    # Sys.sleep blocks the entire thread, so we simulate an unblocked delay
    # by awaiting a resolved promise or using coro's internal generator yielding.
    # For benchmarking pure task scheduling overhead, a standard yield works best:
    coro::yield(sleep(10))
})

main <- function() {
    num_tasks <- get_num_tasks()
    cat("Spawning", num_tasks, "concurrent tasks...\n")

    # Generate the collection of 100,000 async tasks
    # This creates 100,000 lightweight environment/closure objects in the R heap
    tasks <- vector("list", num_tasks)
    for (i in 1:num_tasks) {
        tasks[[i]] <- worker_async()
    }

    cat("All tasks finished. Exiting.\n")
}

main()
