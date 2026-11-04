// Deno benchmark — setTimeout timers registered concurrently on the event loop.
// All 100k tasks are pending from t=0 and fire at t+10s — each task waits
// a full 10 seconds, no OS threads needed.
const numTasks = parseInt(Deno.args[0]) || 100_000;

const tasks = Array.from({ length: numTasks }, () =>
    new Promise<void>((resolve) => setTimeout(resolve, 10_000))
);

await Promise.all(tasks);

console.log("All tasks completed");
