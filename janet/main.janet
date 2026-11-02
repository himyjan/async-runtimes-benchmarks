(import fiber)
(import io/print)

(defn worker []
  (fiber/sleep 10000))

(defn main []
  (let [num-tasks (or (integer (get (program-arguments) 0)) 100000)
        fibers (array)]
    (for [i (range 0 num-tasks)]
      (array/push fibers (fiber/new worker)))
    (for [f fibers]
      (fiber/join f))
    (print "All tasks completed")))

(main)
