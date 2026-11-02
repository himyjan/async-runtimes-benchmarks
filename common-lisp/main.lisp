;; Common Lisp (SBCL) — native OS threads via sb-thread
(require :sb-thread)

(defparameter *num-tasks* 100000)
(let ((arg (car (last sb-ext:*posix-argv*))))
  (when arg
    (setf *num-tasks* (parse-integer arg))))

(defparameter *remaining* *num-tasks*)
(defparameter *lock* (sb-thread:make-mutex))
(defparameter *cond* (sb-thread:make-condition-variable))

(dotimes (_ *num-tasks*)
  (sb-thread:make-thread
   (lambda ()
     (sleep 10)
     (sb-thread:with-mutex (*lock*)
       (decf *remaining*)
       (sb-thread:condition-notify *cond*)))
   :name "worker"))

(sb-thread:with-mutex (*lock*)
  (loop while (plusp *remaining*) do
    (sb-thread:condition-wait *cond* *lock*)))

(format t "All tasks completed~%")
