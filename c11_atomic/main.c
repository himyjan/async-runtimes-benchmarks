/* C11 atomic benchmark — pthread pool using stdatomic.h atomics.
 *
 * Same deadline-table design as c/: all 100k tasks share one absolute
 * deadline (start + 10s); 1000 threads claim tasks with relaxed C11
 * atomics and await the task's deadline. */
#include <pthread.h>
#include <stdatomic.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define NUM_THREADS 1000

static atomic_int next_task;
static long num_tasks;

static void sleep_until(const struct timespec *deadline) {
    struct timespec now;
    clock_gettime(CLOCK_MONOTONIC, &now);
    if (now.tv_sec > deadline->tv_sec ||
        (now.tv_sec == deadline->tv_sec && now.tv_nsec >= deadline->tv_nsec)) {
        return; /* deadline already passed */
    }
    struct timespec dur;
    dur.tv_sec = deadline->tv_sec - now.tv_sec;
    dur.tv_nsec = deadline->tv_nsec - now.tv_nsec;
    if (dur.tv_nsec < 0) {
        dur.tv_sec -= 1;
        dur.tv_nsec += 1000000000L;
    }
    nanosleep(&dur, NULL);
}

static void *worker(void *arg) {
    const struct timespec *tasks = arg;
    for (;;) {
        int i = atomic_fetch_add_explicit(&next_task, 1, memory_order_relaxed);
        if (i >= num_tasks) break;
        sleep_until(&tasks[i]);
    }
    return NULL;
}

int main(int argc, char **argv) {
    num_tasks = 100000;
    if (argc > 1) num_tasks = strtol(argv[1], NULL, 10);
    if (num_tasks <= 0) {
        fprintf(stderr, "bad task count\n");
        return 1;
    }

    struct timespec deadline;
    clock_gettime(CLOCK_MONOTONIC, &deadline);
    deadline.tv_sec += 10;

    /* Task table: every task pending from t=0, due at start + 10s. */
    struct timespec *tasks = malloc((size_t)num_tasks * sizeof(*tasks));
    if (!tasks) {
        perror("malloc");
        return 1;
    }
    for (long i = 0; i < num_tasks; i++) tasks[i] = deadline;

    pthread_t threads[NUM_THREADS];
    for (int i = 0; i < NUM_THREADS; i++) {
        if (pthread_create(&threads[i], NULL, worker, tasks) != 0) {
            perror("pthread_create");
            return 1;
        }
    }
    for (int i = 0; i < NUM_THREADS; i++) pthread_join(threads[i], NULL);

    free(tasks);
    printf("All tasks completed\n");
    return 0;
}
