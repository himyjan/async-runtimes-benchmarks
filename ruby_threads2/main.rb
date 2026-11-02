#!/usr/bin/env ruby
# Ruby benchmark — Async Fibers (green threads)
# Ruby Fibers are lightweight VM-level coroutines, not OS threads.
# With the Async gem scheduler, they can handle 100k concurrent tasks.

require 'async'

num_tasks = (ARGV[0] || 100_000).to_i

Async do |task|
  num_tasks.times.map do
    task.async do
      sleep(10)
    end
  end.each(&:wait)
end

puts "All tasks completed"
