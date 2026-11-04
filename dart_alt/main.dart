import 'dart:isolate';
import 'dart:async';

/// Worker isolate entry point — Isolate.spawn passes exactly one argument,
/// so we receive a list and destructure it.
Future<void> worker(List<dynamic> args) async {
  final int workerId = args[0];
  final int poolSize = args[1];
  final int numTasks = args[2];
  final int deadlineMs = args[3];
  final SendPort port = args[4];

  for (var i = workerId; i < numTasks; i += poolSize) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final left = deadlineMs - now;
    if (left > 0) await Future.delayed(Duration(milliseconds: left));
  }
  port.send(null);
}

Future<void> main() async {
  final numTasks = int.tryParse(const String.fromEnvironment('num_tasks',
      defaultValue: '100000')) ?? 100000;
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
    await Isolate.spawn(worker, [w, poolSize, numTasks, deadlineMs, receivePort.sendPort],
        errorsAreFatal: true);
  }

  await completer.future;
  print('All tasks completed');
}
