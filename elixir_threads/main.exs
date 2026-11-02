defmodule Bench do
  def start(num_tasks \\ 100_000) do
    remaining = Agent.fn(fn -> num_tasks end)
    sem = :erlang.monitor(0)
    
    for _ <- 1..num_tasks do
      Task.start(fn ->
        :timer.sleep(10000)
        Agent.get_and_update(remaining, fn n -> {n, n - 1} end)
        |> case do
          {0, _} -> :ok
        end
      end)
    end
    
    IO.puts("All tasks completed")
  end
end

Bench.start()
