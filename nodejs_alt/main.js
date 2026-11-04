const numTasks = parseInt(process.argv[2]) || 100000;
const tasks = Array.from({ length: numTasks }, () =>
    new Promise<void>((resolve) => setTimeout(resolve, 10000))
);
await Promise.all(tasks);
console.log('All tasks completed');
