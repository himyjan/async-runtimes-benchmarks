(use-modules (system threads))

(define num-tasks
  (let ((args (command-line)))
    (if (> (length args) 1)
        (string->number (cadr args))
        100000)))

(define pool-size 1000)
(define deadline (+ (current-time) 10))
(define next-task 0)
(define lock (make-mutex))

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
            (loop))))))

(define threads
  (map (lambda (_) (make-thread worker)) (make-list pool-size)))

(for-each thread-join! threads)

(display "All tasks completed\n")
