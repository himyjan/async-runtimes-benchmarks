;; Hy benchmark — thread pool over a shared deadline table.
;; All 100k tasks share one absolute deadline (start + 10s); 1000 worker
;; threads claim tasks and sleep until each task's deadline.
(import [threading [Thread Lock]]
        [itertools [count]]
        [time [sleep time]])

(setv num-tasks (if (> (len $process-argv) 1) (int (. $process-argv __getitem__ 1)) 100000))
(setv pool-size 1000)
(setv deadline (+ (time) 10))
(setv task-iter (count))
(setv lock (Lock))
(setv done [0])

(defn worker []
  (while True
    (with [lock]
      (setv i (next task-iter))
      (if (>= i num-tasks)
          (return None)))
    (let [left (- deadline (time))]
      (when (> left 0)
        (sleep left)))
    (with [lock]
      (. __setitem__ done 0 (+ (.__getitem__ done 0) 1))))

(setv threads [])
(for [_ (range pool-size)]
  (.append threads (Thread (target worker))))

(for [t threads]
  (.start t))

(while True
  (with [lock]
    (if (>= (.__getitem__ done 0) num-tasks)
        (break)))
  (sleep 0.1))

(print "All tasks completed")
