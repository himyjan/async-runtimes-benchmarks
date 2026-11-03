// C++ atomic benchmark — pthread workers + std::atomic counter + counting_semaphore.
//
// All 100k tasks are registered from t=0 with the same absolute deadline
// (start + 10s). 1000 pthread workers claim tasks with std::atomic and
// sleep_until() each task's deadline; the last task to complete releases
// the semaphore that main waits on.
#include <pthread.h>
#include <semaphore.h>
#include <time.h>
#include <atomic>
#include <chrono>
#include <iostream>
#include <vector>

#define NUM_THREADS 1000

using clk = std::chrono::steady_clock;

static std::atomic<long> remaining{0};
static sem_t sem;
static const struct timespec* g_tasks;
static long g_num_tasks;
static std::atomic<int> next_task{0};

static void* worker(void*) {
    for (;;) {
        int i = next_task.fetch_add(1, std::memory_order_relaxed);
        if (i >= g_num_tasks) break;

        // Await this task's absolute deadline (shared start + 10s).
        struct timespec now;
        clock_gettime(CLOCK_MONOTONIC, &now);
        const struct timespec* dl = &g_tasks[i];
        if (now.tv_sec < dl->tv_sec ||
            (now.tv_sec == dl->tv_sec && now.tv_nsec < dl->tv_nsec)) {
            struct timespec dur;
            dur.tv_sec = dl->tv_sec - now.tv_sec;
            dur.tv_nsec = dl->tv_nsec - now.tv_nsec;
            if (dur.tv_nsec < 0) {
                dur.tv_sec -= 1;
                dur.tv_nsec += 1000000000L;
            }
            nanosleep(&dur, NULL);
        }

        if (remaining.fetch_sub(1, std::memory_order_acq_rel) == 1) {
            sem_post(&sem);
        }
    }
    return nullptr;
}

int main(int argc, char** argv) {
    long num_tasks = 100000;
    if (argc > 1) num_tasks = std::stoi(argv[1]);

    struct timespec deadline;
    clock_gettime(CLOCK_MONOTONIC, &deadline);
    deadline.tv_sec += 10;

    // Task table: every task pending from t=0, due at start + 10s.
    std::vector<struct timespec> tasks(num_tasks, deadline);
    g_tasks = tasks.data();
    g_num_tasks = num_tasks;
    remaining.store(num_tasks);
    sem_init(&sem, 0, 0);

    std::vector<pthread_t> threads(NUM_THREADS);
    for (int i = 0; i < NUM_THREADS; i++) {
        if (pthread_create(&threads[i], NULL, worker, nullptr) != 0) {
            std::cerr << "pthread_create failed" << std::endl;
            return 1;
        }
    }

    sem_wait(&sem); /* blocks until the last task completes */
    for (int i = 0; i < NUM_THREADS; i++) pthread_join(threads[i], nullptr);
    sem_destroy(&sem);

    std::cout << "All tasks completed" << std::endl;
    return 0;
}
