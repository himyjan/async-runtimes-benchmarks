// Deno (alt) benchmark — setTimeout timers registered concurrently on the event loop.
const numTasks = parseInt(Deno.args[0]) || 100_000;

const tasks = Array.from({ length: numTasks }, () =>
    new Promise<void>((resolve) => setTimeout(resolve, 10_000))
);
await Promise.all(tasks);
console.log("All tasks completed");
