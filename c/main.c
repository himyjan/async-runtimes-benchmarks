#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

static void *worker(void *arg) {
    (void)arg;
    sleep(10);
    return NULL;
}

int main(int argc, char **argv) {
    long num_tasks = 100000;
    if (argc > 1) {
        num_tasks = strtol(argv[1], NULL, 10);
    }

    pthread_t *threads = calloc((size_t)num_tasks, sizeof(pthread_t));
    if (!threads) {
        fprintf(stderr, "out of memory allocating %ld threads\n", num_tasks);
        return 1;
    }

    for (long i = 0; i < num_tasks; i++) {
        if (pthread_create(&threads[i], NULL, worker, NULL) != 0) {
            fprintf(stderr, "failed to create thread %ld\n", i);
            return 1;
        }
    }

    for (long i = 0; i < num_tasks; i++) {
        pthread_join(threads[i], NULL);
    }

    free(threads);
    printf("All tasks completed\n");
    return 0;
}
