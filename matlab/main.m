% MATLAB benchmark - parfor
num_tasks = str2double(argv{1});
if isempty(num_tasks)
    num_tasks = 100000;
end

remaining = num_tasks;

parfor i = 1:num_tasks
    pause(10);
    remaining = remaining - 1;
end

fprintf('All tasks completed\n');
