// TypeScript benchmark — worker_threads pool over a shared deadline table.
import { Worker, isMainThread, parentPort } from 'worker_threads';

const numTasks = parseInt(process.argv[2]) || 100_000;
const POOL_SIZE = 1000;

if (isMainThread) {
    const deadline = Date.now() + 10_000;
    let next = 0;
    let done = 0;
    const lock = { busy: false };

    function lockIt(): Promise<void> {
        return new Promise(res => {
            const c = () => { if (!lock.busy) { lock.busy = true; res(); } else setTimeout(c, 1); };
            c();
        });
    }
    function unlock() { lock.busy = false; }

    async function workerLoop() {
        while (true) {
            let i: number;
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

    const workers: Promise<void>[] = [];
    for (let w = 0; w < POOL_SIZE; w++) workers.push(workerLoop());

    Promise.all(workers).then(() => {
        console.log('All tasks completed');
        process.exit(0);
    });
}
