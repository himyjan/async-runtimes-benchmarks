(defpackage :bench
  (:use :cl :sb-thread))

(in-package :bench)

(defparameter *num-tasks* 100000)
(defparameter *remaining* *num-tasks*)
(defparameter *lock* (make-mutex))
(defparameter *cond* (make-condition-variable))

(defun worker ()
  (sleep 10)
  (with-mutex (*lock*)
    (decf *remaining*)
    (when (= *remaining* 0)
      (condition-notify *cond*))))

(defun main ()
  (let ((args sb-ext:*posix-argv*))
    (when (> (length args) 1)
      (setf *num-tasks* (parse-integer (second args)))
      (setf *remaining* *num-tasks*))
    (dotimes (i *num-tasks*)
      (make-thread #'worker))
    (with-mutex (*lock*)
      (loop while (plusp *remaining*) do
        (condition-wait *cond* *lock*)))
    (format t "All tasks completed~%")))

(main)
