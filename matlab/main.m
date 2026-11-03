#!/usr/bin/env matlab
% MATLAB benchmark - parallel.forEach (parfeval with backgroundPool)
% parfeval submits tasks to MATLAB's background pool without blocking
% the main MATLAB session, allowing lightweight concurrent execution

num_tasks = str2double(argv{1});
if isempty(num_tasks) || ~isfinite(num_tasks) || num_tasks <= 0
    num_tasks = 100000;
end

fprintf('Spawning %d concurrent tasks...\n', num_tasks);

% Use backgroundPool (lightweight threads introduced in R2021b)
% parfeval submits tasks without blocking, allowing concurrent execution
futures = parallel.Future.empty(num_tasks, 1);

for i = 1:num_tasks
    futures(i) = parfeval(backgroundPool, @pause, 0, 10);
end

% Block until all tasks complete
wait(futures);

fprintf('All tasks finished. Exiting.\n');
exit(0);
