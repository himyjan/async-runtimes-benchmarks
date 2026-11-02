#lang racket

(define num-tasks
  (or (string->number (car (command-line-arguments))) 100000))

(define threads
  (for/list ([i (in-range num-tasks)])
    (thread (lambda () (sleep 10)))))

(for ([t threads])
  (thread-wait! t))

(displayln "All tasks completed")
