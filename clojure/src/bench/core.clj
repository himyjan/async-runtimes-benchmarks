(ns bench.core
  (:gen-class))

(defn -main [& args]
  (let [num-tasks (if (seq args)
                    (Integer/parseInt (first args))
                    100000)
        futures (repeatedly num-tasks
                     #(future (Thread/sleep 10000)))]
    (doseq [f futures] @f)
    (println "All tasks completed")))
