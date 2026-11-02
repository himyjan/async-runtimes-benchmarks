var numTasks = 100000;
var remaining = numTasks;
var semaphore = new Semaphore(0);

for (let i = 0; i < numTasks; i++) {
    setTimeout(() => {
        remaining--;
        if (remaining === 0) {
            semaphore.release();
        }
    }, 10000);
}

semaphore.acquire().then(() => {
    console.log('All tasks completed');
});
