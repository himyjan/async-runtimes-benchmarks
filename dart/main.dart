import 'dart:async';

Future<void> worker() async {
  await Future.delayed(const Duration(seconds: 10));
}

Future<void> main() async {
  final numTasks = const int.fromEnvironment('num_tasks', defaultValue: 100000);

  final tasks = List.generate(numTasks, (_) => worker());
  await Future.wait(tasks);

  print('All tasks completed');
}
