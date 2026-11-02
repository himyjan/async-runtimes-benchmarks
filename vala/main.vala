using GLib;

int num_tasks = 100000;
int remaining = num_tasks;
GLib.Thread[] threads = new GLib.Thread[num_tasks];
GLib.Private sem = new GLib.Private((destroy) => {});

static int worker(gpointer data) {
    g_usleep(10 * 1000 * 1000);
    __sync_fetch_and_sub(&remaining, 1);
    if (remaining == 0) {
        // signal main
    }
    return 0;
}

int main(string[] args) {
    if (args.length > 1) {
        num_tasks = args[1].to_int();
        remaining = num_tasks;
    }

    for (int i = 0; i < num_tasks; i++) {
        threads[i] = GLib.Thread.create("worker", worker, null, GLib.ThreadPriority.NORMAL, 0, null);
    }

    // Wait using a condition variable approach
    GLib.Mutex mutex = new GLib.Mutex();
    GLib.Cond cond = new GLib.Cond();
    mutex.lock();
    while (remaining > 0) {
        cond.wait(mutex, -1);
    }
    mutex.unlock();

    print("All tasks completed\n");
    return 0;
}
