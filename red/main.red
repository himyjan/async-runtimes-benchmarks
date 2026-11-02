Red []

num-tasks: 100000
remaining: num-tasks

event-sem: make event!

actor worker [
    remaining: integer!
    sem: event!
] [
    on-created: func [][
        wait 10
        remaining: remaining - 1
        if remaining = 0 [ signal sem ]
    ]
]

actors: make block! num-tasks

repeat num-tasks [
    append actors: make worker [remaining: remaining, sem: event-sem]
]

wait sem

print "All tasks completed"
