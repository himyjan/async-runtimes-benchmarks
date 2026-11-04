defmodule Bench do
  def start(num_tasks \\ 100_000) do
    remaining = Agent.start_link(fn -> num_tasks end, name: __MODULE__)

    for _ <- 1..num_tasks do
      Task.start(fn ->
        :timer.sleep(10000)
        Agent.get_and_update(remaining, fn n -> {n, n - 1} end)
      end)
    end

    # Wait for all tasks to complete
    Process.sleep(15000)

    IO.puts("All tasks completed")
  end
end

Bench.start()
