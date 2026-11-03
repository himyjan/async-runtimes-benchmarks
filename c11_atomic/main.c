#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdatomic.h>

#define NUM_THREADS 1000

static atomic_int remaining;
static atomic_int next_task;
int num_tasks;

void *worker(void *arg) {
    (void)arg;
    while (1) {
        int i = atomic_fetch_add(&next_task, 1);
        if (i >= num_tasks) break;
        sleep(10);
    }
    return NULL;
}

int main(int argc, char **argv) {
    num_tasks = 100000;
    if (argc > 1) {
        num_tasks = strtol(argv[1], NULL, 10);
    }
    remaining = num_tasks;
    next_task = 0;

    pthread_t threads[NUM_THREADS];
    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_create(&threads[i], NULL, worker, NULL);
    }
    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }

    printf("All tasks completed\n");
    return 0;
}
