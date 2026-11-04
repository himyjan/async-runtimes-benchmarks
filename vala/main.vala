using GLib;

int num_tasks = 100000;
int remaining = num_tasks;
const int POOL_SIZE = 1000;
GLib.Thread[] threads = new GLib.Thread[POOL_SIZE];
GLib.Mutex mutex = new GLib.Mutex();
GLib.Cond cond = new GLib.Cond();
bool done = false;

static int worker(gpointer data) {
    while (!done) {
        mutex.lock();
        if (remaining <= 0) {
            done = true;
            cond.broadcast();
            mutex.unlock();
            return 0;
        }
        remaining--;
        int my_remaining = remaining;
        mutex.unlock();

        g_usleep(10 * 1000 * 1000); // sleep 10 seconds

        mutex.lock();
        if (my_remaining == 0) {
            done = true;
            cond.broadcast();
        }
        mutex.unlock();
    }
    return 0;
}

int main(string[] args) {
    if (args.length > 1) {
        num_tasks = args[1].to_int();
        remaining = num_tasks;
    }

    for (int i = 0; i < POOL_SIZE; i++) {
        threads[i] = GLib.Thread.create("worker", worker, null);
    }

    mutex.lock();
    while (!done) {
        cond.wait(mutex, -1);
    }
    mutex.unlock();

    for (int i = 0; i < POOL_SIZE; i++) {
        threads[i].join();
    }

    print("All tasks completed\n");
    return 0;
}
