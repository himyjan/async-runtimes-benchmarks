// Node.js benchmark — worker_threads pool over a shared deadline table.
// All 100k tasks are registered from t=0 with deadline start+10s; a pool
// of 1000 worker threads claims tasks and sleeps until each deadline.
const { Worker, isMainThread, parentPort, workerData } = require('worker_threads');
const numTasks = parseInt(process.argv[2]) || 100_000;
const POOL_SIZE = 1000;

if (isMainThread) {
    const deadline = Date.now() + 10_000;
    const taskIter = (function* () { for (let i = 0; i < numTasks; i++) yield i; })();
    let done = 0;
    const lock = { busy: false };
    const workers = [];

    function acquireLock() { return new Promise(resolve => { const check = () => { if (!lock.busy) { lock.busy = true; resolve(); } else setTimeout(check, 0); }; check(); }); }
    function releaseLock() { lock.busy = false; }

    function nextTask() {
        const r = taskIter.next();
        return r.done ? null : r.value;
    }

    async function workerLoop(worker) {
        while (true) {
            let i;
            await acquireLock();
            i = nextTask();
            releaseLock();
            if (i === null) break;
            const left = deadline - Date.now();
            if (left > 0) await new Promise(r => setTimeout(r, left));
            await acquireLock();
            done++;
            releaseLock();
        }
    }

    for (let w = 0; w < POOL_SIZE; w++) {
        const worker = new Worker(__filename, { workerData: null });
        workers.push(workerLoop(worker));
    }

    Promise.all(workers).then(() => {
        console.log('All tasks completed');
        process.exit(0);
    });
}
