-- Eiffel benchmark - threads
class
    BENCH
create
    make

feature {NONE} -- Initialization

    make
        local
            l_num_tasks: INTEGER := 100000
            l_threads: ARRAY[THREAD[WORKER]]
        do
            create l_threads.make_filled (0, 1, l_num_tasks)
            across 1 |..| l_num_tasks as i loop
                create Result.make (agent worker)
                Result.start
                l_threads [i.item] := Result
            end
            across l_threads as t loop
                t.item.join
            end
            print ("All tasks completed%N")
        end

feature {NONE} -- Implementation

    worker
        do
            Thread.sleep (10_000)
        end

end

class
    WORKER
inherit
    THREAD[WORKER]

create
    make_default

feature {NONE} -- Implementation

    run
        do
            Thread.sleep (10_000)
        end

end
