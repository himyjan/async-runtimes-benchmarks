// Deno (alt) benchmark — Deno Worker pool over a shared deadline table.
// All 100k tasks registered from t=0 with deadline start+10s; 1000 Workers
// each handle a static subset of tasks and sleep until each task's deadline.
const numTasks = parseInt(Deno.args[0]) || 100_000;
const POOL_SIZE = 1000;
const deadline = Date.now() + 10_000;

const workerCode = `
  self.addEventListener('message', (e) => {
    const { workerId, numTasks, deadline, poolSize } = e.data;
    for (let i = workerId; i < numTasks; i += poolSize) {
      const left = deadline - Date.now();
      if (left > 0) {
        await new Promise(r => setTimeout(r, left));
      }
    }
    self.postMessage("done");
  });
`;

let completed = 0;
for (let w = 0; w < POOL_SIZE; w++) {
    const blob = new Blob([workerCode], { type: 'application/javascript' });
    const url = URL.createObjectURL(blob);
    const worker = new Worker(url, { type: 'module' });
    worker.postMessage({ workerId: w, numTasks, deadline, poolSize });
    worker.onmessage = () => {
        completed++;
        if (completed === POOL_SIZE) console.log("All tasks completed");
    };
}
