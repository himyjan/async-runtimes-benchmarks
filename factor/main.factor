USING: kernel io kernel.math threads ;
IN: bench

100000 :> num-tasks
num-tasks :> remaining

: worker ( -- )
    10 seconds sleep
    remaining 1 swap - remaining ! ;

num-tasks [ worker ] replicate
[ thread-join ] each

"All tasks completed" print
