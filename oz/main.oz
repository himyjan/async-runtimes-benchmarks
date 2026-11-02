-- Oz benchmark - threads
declare
  NumTasks = 100000
  Remaining = {NewCell NumTasks}
  Sem = {NewCell 0}

  proc {Worker}
    {Delay 10000}
    Remaining := @Remaining - 1
    if @Remaining = 0 then
      {Signal Sem}
    end
  end

  thread
    for I in 1..NumTasks do
      {Spawn Worker}
    end
  end

  {Wait Sem}
  {System.showInfo "All tasks completed"}
