#!/usr/local/bin/pike
// Pike benchmark - threads

int num_tasks = 100000;
int remaining = num_tasks;
mapping sem = ([]);

void worker() {
    sleep(10);
    remaining--;
    if (remaining == 0) {
        // signal
    }
}

int main() {
    array threads = ({});
    for (int i = 0; i < num_tasks; i++) {
        threads += ({ Thread.Thread(worker) });
    }
    foreach (threads; object t) {
        t.wait();
    }
    write("All tasks completed\n");
    return 0;
}
