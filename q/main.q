num_tasks: 100000
remaining: num_tasks

spawn{do
    .z.T: {0N!x} /[10000] /[10000] /[10000] /[10000] /[10000] /[10000] /[10000] /[10000] /[10000] /[10000]
    remaining -: 1
    $[remaining = 0; `done`; ()]
} each til num_tasks

"All tasks completed"
