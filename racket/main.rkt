#lang racket

(define num-tasks
  (or (string->number (car (command-line-arguments))) 100000))

;; Racket benchmark — thread pool over a shared deadline table.
;; All 100k tasks share one absolute deadline (start + 10s); 1000 worker
;; threads claim tasks and sleep until each task's deadline.
(define pool-size 1000)
(define deadline (+ (current-seconds) 10))
(define next-task (box 0))
(define lock (make-mutex))
(define remaining (box num-tasks))

(define (sleep-until d)
  (let loop ()
    (let ((now (current-seconds)))
      (when (< now d)
        (sleep (- d now))
        (loop)))))

(define (worker)
  (let loop ()
    (mutex-lock lock)
    (let ((i (unbox next-task)))
      (if (>= i num-tasks)
          (begin (mutex-unlock lock) #f)
          (begin
            (set-box! next-task (+ i 1))
            (mutex-unlock lock)
            (sleep-until deadline)
            (mutex-lock lock)
            (set-box! remaining (- (unbox remaining) 1))
            (mutex-unlock lock)
            (loop))))))

(define threads
  (for/list ([i (in-range pool-size)])
    (thread worker)))

(for ([t threads])
  (thread-wait! t))

(displayln "All tasks completed")
