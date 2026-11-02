import flutter/dart:async';

Future<void> main() async {
  final numTasks = 100000;
  final tasks = List.generate(numTasks, (_) => Future.delayed(const Duration(seconds: 10)));
  await Future.wait(tasks);
  print('All tasks completed');
}
