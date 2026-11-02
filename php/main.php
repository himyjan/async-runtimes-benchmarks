<?php
declare(strict_types=1);

require __DIR__ . '/vendor/autoload.php';

use React\EventLoop\Factory;
use React\Promise\Promise;
use function React\Promise\all;

$numTasks = ($argc > 1) ? (int) $argv[1] : 100_000;

$loop = Factory::create();

$promises = [];
for ($i = 0; $i < $numTasks; $i++) {
    $promises[] = new Promise(function ($resolve) use ($loop) {
        $loop->addTimer(10.0, $resolve);
    });
}

all($promises)->then(function () use ($loop) {
    $loop->stop();
});

$loop->run();

echo "All tasks completed\n";
