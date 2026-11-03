// Browser JS benchmark — worker_threads pool (runs under Node in CI).
// All 100k tasks registered from t=0 with deadline start+10s; 1000 worker
// threads claim tasks and sleep until each deadline.
const { Worker, isMainThread } = require('worker_threads');
const numTasks = 100_000;
const POOL_SIZE = 1000;

if (isMainThread) {
    const deadline = Date.now() + 10_000;
    let next = 0;
    let done = 0;
    const lock = { busy: false };

    function lockIt() { return new Promise(res => { const c = () => { if (!lock.busy) { lock.busy = true; res(); } else setTimeout(c, 1); }; c(); }); }
    function unlock() { lock.busy = false; }

    async function workerLoop() {
        while (true) {
            let i;
            await lockIt();
            i = next++;
            unlock();
            if (i >= numTasks) break;
            const left = deadline - Date.now();
            if (left > 0) await new Promise(r => setTimeout(r, left));
            await lockIt();
            done++;
            unlock();
        }
    }

    const workers = [];
    for (let w = 0; w < POOL_SIZE; w++) workers.push(workerLoop());

    Promise.all(workers).then(() => {
        console.log('All tasks completed');
        process.exit(0);
    });
}
