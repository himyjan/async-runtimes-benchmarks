;; Scheme (Guile) — POSIX threads
(use-modules (system threads))

(define num-tasks
  (let ((args (command-line)))
    (if (> (length args) 1)
        (string->number (cadr args))
        100000)))

(define remaining (make-thread-local num-tasks))
(define lock (make-mutex))
(define cond (make-condition-variable))

(for-each
 (lambda (_)
   (make-thread
    (lambda ()
      (sleep 10)
      (mutex-lock! lock)
      (set! remaining (- remaining 1))
      (condition-variable-signal! cond)
      (mutex-unlock! lock))))
 (iota num-tasks))

(mutex-lock! lock)
(let loop ()
  (if (> remaining 0)
      (begin
        (condition-variable-wait! cond lock)
        (loop))
      (mutex-unlock! lock)))

(display "All tasks completed\n")
