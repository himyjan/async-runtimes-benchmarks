require "channel"

num_tasks = (ARGV[0] || 100_000).to_i

done = Channel(Int).new(num_tasks)

num_tasks.times do
  spawn do
    sleep(10)
    done.send(1)
  end
end

num_tasks.times { done.receive }

puts "All tasks completed"
