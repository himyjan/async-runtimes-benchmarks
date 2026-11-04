// Browser JS benchmark — setTimeout + Promise.all (runs under Node in CI).
// All 100k timers are registered from t=0 and fire at t+10s concurrently
// on the event loop — no OS threads needed, all tasks wait 10 seconds.
var numTasks = 100000;
var tasks = [];

for (let i = 0; i < numTasks; i++) {
    tasks.push(new Promise(resolve => {
        setTimeout(resolve, 10000);
    }));
}

Promise.all(tasks).then(() => {
    console.log('All tasks completed');
});
