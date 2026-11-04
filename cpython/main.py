#!/usr/bin/env python
import sys
import threading
from time import sleep, time

num_tasks = int(sys.argv[1]) if len(sys.argv) > 1 else 100000
pool_size = min(num_tasks, 1000)
deadline = time() + 10
task_iter = iter(range(num_tasks))
lock = threading.Lock()
done = [0]
sem = threading.Semaphore(0)

def worker():
    while True:
        with lock:
            try:
                i = next(task_iter)
            except StopIteration:
                sem.release()
                return
        left = deadline - time()
        if left > 0:
            sleep(left)
        with lock:
            done[0] += 1

threads = [threading.Thread(target=worker) for _ in range(pool_size)]
for t in threads:
    t.start()
for t in threads:
    t.join()
sem.acquire()
print("All tasks completed")
