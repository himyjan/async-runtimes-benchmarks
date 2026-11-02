| numTasks remaining semaphore |

numTasks := (Smalltalk commandLine at: 2) ifNotNil: [ :a | a asNumber ] ifNil: [ 100000 ].
remaining := numTasks.
semaphore := Semaphore new.

numTasks timesRepeat: [
    [ Delay waitForSeconds: 10.
      remaining := remaining - 1.
      remaining = 0 ifTrue: [ semaphore signal ] ] fork
].

semaphore wait.
'ALL TASKS COMPLETED' printNl.
