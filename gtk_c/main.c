#include <gtk/gtk.h>
#include <pthread.h>
#include <semaphore.h>
#include <atomic>

#define NUM_THREADS 1000

static std::atomic<int> remaining;
static sem_t sem;

static void *worker(void *arg) {
    (void)arg;
    sleep(10);
    if (remaining.fetch_sub(1) == 1) {
        sem_post(&sem);
    }
    return NULL;
}

int main(int argc, char **argv) {
    gtk_init(&argc, &argv);
    long num_tasks = 100000;
    if (argc > 1) {
        num_tasks = strtol(argv[1], NULL, 10);
    }
    remaining.store(num_tasks);
    sem_init(&sem, 0, 0);

    pthread_t threads[NUM_THREADS];
    for (long i = 0; i < NUM_THREADS; i++) {
        pthread_create(&threads[i], NULL, worker, NULL);
    }
    for (long i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }
    sem_wait(&sem);
    printf("All tasks completed\n");
    return 0;
}
