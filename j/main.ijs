load 'general/misc'
load 'threads'

num_tasks =: 100000
remaining =: num_tasks

worker =: 3 : 0
   TMOUT =: 10000
   remaining =: remaining - 1
   if. remaining = 0 do.
      'All tasks completed'
   end.
)

NB. J: run workers in threads
threads =: worker &> i.num_tasks
wait threads
