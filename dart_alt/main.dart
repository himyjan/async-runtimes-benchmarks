import 'dart:async';

Future<void> main() async {
  final numTasks = int.tryParse(const String.fromEnvironment('num_tasks', defaultValue: '100000')) ?? 100000;
  final tasks = List.generate(numTasks, (_) => Future.delayed(const Duration(seconds: 10)));
  await Future.wait(tasks);
  print('All tasks completed');
}
