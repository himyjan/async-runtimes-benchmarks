⎕IO ← 1
numTasks ← 100000
remaining ← numTasks

∇ worker
[1]   ⎕DL 10
[2]   remaining ← remaining - 1
[3]   → (0 = remaining) ⍴ done
[4]   → 0
[5]   done: 'All tasks completed'
∇

⍝ Dyalog APL: run each worker in a separate thread
⎕threads ← numTasks
worker¨ ⍳numTasks
