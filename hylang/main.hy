from hypy import *
from threading import Thread
from time import sleep
import sys

num_tasks = int(sys.argv[1]) if len(sys.argv) > 1 else 100000
remaining = num_tasks
import threading
sem = threading.Semaphore(0)

def worker():
    global remaining
    sleep(10)
    remaining -= 1
    if remaining == 0:
        sem.release()

threads = [Thread(target=worker) for _ in range(num_tasks)]
for t in threads:
    t.start()
for t in threads:
    t.join()
sem.acquire()
print("All tasks completed")
