import 'dart:isolate';
import 'dart:async';

/// Worker isolate — handles a static subset of tasks, sleeps until each
/// deadline (start + 10s), then signals completion.
Future<void> worker(SendPort port, int start, int step, int numTasks,
                    int deadlineMs) async {
  for (var i = start; i < numTasks; i += step) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final left = deadlineMs - now;
    if (left > 0) await Future.delayed(Duration(milliseconds: left));
  }
  port.send(null);
}

Future<void> main() async {
  final numTasks =
      int.fromEnvironment('num_tasks', defaultValue: 100000);
  final poolSize = numTasks.clamp(1, 1000);
  final deadlineMs = DateTime.now().millisecondsSinceEpoch + 10_000;

  final receivePort = ReceivePort();
  int completed = 0;
  final completer = Completer<void>();

  receivePort.listen((_) {
    completed++;
    if (completed == poolSize) completer.complete();
  });

  for (var w = 0; w < poolSize; w++) {
    await Isolate.spawn(worker, [w, poolSize, numTasks, deadlineMs],
        errorsAreFatal: true);
  }

  await completer.future;
  print('All tasks completed');
}
