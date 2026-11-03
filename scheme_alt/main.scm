;; Scheme (Guile) (alt) benchmark — POSIX thread pool over a shared deadline table.
;; All 100k tasks share one absolute deadline (start + 10s); 1000 worker threads
;; claim tasks via a shared counter and sleep until each task's deadline.
(use-modules (system threads))

(define num-tasks
  (let ((args (command-line)))
    (if (> (length args) 1)
        (string->number (cadr args))
        100000)))

(define pool-size 1000)
(define start-time (current-time))
(define deadline (+ start-time 10))  ; seconds
(define next-task (make-thread-local 0))
(define lock (make-mutex))
(define cond (make-condition-variable))
(define remaining (make-thread-local num-tasks))

(define (sleep-until d)
  (let loop ()
    (let ((now (current-time)))
      (if (< now d)
          (begin
            (sleep (- d now))
            (loop))
          #t))))

(define (worker)
  (let loop ()
    (mutex-lock! lock)
    (let ((i next-task))
      (if (>= i num-tasks)
          (begin (mutex-unlock! lock) #f)
          (begin
            (set! next-task (+ i 1))
            (mutex-unlock! lock)
            (sleep-until deadline)
            (mutex-lock! lock)
            (set! remaining (- remaining 1))
            (when (= remaining 0) (condition-variable-signal! cond))
            (mutex-unlock! lock)
            (loop))))))

(define threads
  (for/list ([i (in-range pool-size)])
    (make-thread worker)))

(for ([t threads])
  (thread-wait! t))

(mutex-lock! lock)
(when (> remaining 0) (condition-variable-wait! cond lock))
(mutex-unlock! lock)

(display "All tasks completed\n")
