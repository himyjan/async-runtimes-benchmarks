(defun main ()
  (let ((num-tasks (or (parse-integer (nth 1 sb-ext:*posix-argv*) :junk-allowed t) 100000))
        (remaining num-tasks))
    (sb-thread:make-thread
     (lambda ()
       (sleep 10)
       (decf remaining)
       (when (= remaining 0)
         (format t "All tasks completed~%"))))
    ;; Actually spawn N threads
    (loop repeat num-tasks
          do (sb-thread:make-thread
              (lambda ()
                (sleep 10)
                (decf remaining)
                (when (= remaining 0)
                  (format t "All tasks completed~%"))))))
