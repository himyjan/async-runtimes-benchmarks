import * as fs from 'fs';

const numTasks = parseInt(process.argv[2]) || 100_000;

const delay = (ms: number) => new Promise<void>((resolve) =>
    setTimeout(resolve, ms)
);

async function main() {
    const tasks = Array.from({ length: numTasks }, () => delay(10_000));
    await Promise.all(tasks);
    console.log('All tasks completed');
}

main().catch((err) => {
    console.error(err);
    process.exit(1);
});
