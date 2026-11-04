(use-modules (system threads))

(define num-tasks
  (let ((args (command-line)))
    (if (> (length args) 1)
        (string->number (cadr args))
        100000)))

(define pool-size 1000)
(define remaining (make-thread-local num-tasks))
(define lock (make-mutex))
(define cond (make-condition-variable))

(define (worker)
  (sleep 10)
  (mutex-lock! lock)
  (set! remaining (- remaining 1))
  (when (= remaining 0)
    (condition-variable-signal! cond))
  (mutex-unlock! lock))

(define threads
  (map (lambda (_) (make-thread worker)) (make-list pool-size)))

(for-each thread-join! threads)

(mutex-lock! lock)
(when (> remaining 0)
  (condition-variable-wait! cond lock))
(mutex-unlock! lock)

(display "All tasks completed\n")
