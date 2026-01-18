import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/storage.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _allTasks = [];
  DateTime selectedDate = DateTime.now();

  List<Task> get tasks => _allTasks
      .where((t) =>
  t.date.year == selectedDate.year &&
      t.date.month == selectedDate.month &&
      t.date.day == selectedDate.day)
      .toList();

  Future<void> loadTasks() async {
    _allTasks = await StorageService.loadTasks();
    notifyListeners();
  }

  Future<void> saveTasks() async {
    await StorageService.saveTasks(_allTasks);
  }

  void addOrEditTask(Task task, {Task? oldTask}) {
    if (oldTask == null) {
      _allTasks.add(task);
    } else {
      int index = _allTasks.indexOf(oldTask);
      _allTasks[index] = task;
    }
    notifyListeners();
    saveTasks();
  }

  void deleteTask(Task task) {
    _allTasks.remove(task);
    notifyListeners();
    saveTasks();
  }

  void toggleComplete(Task task) {
    task.isDone = !task.isDone;
    notifyListeners();
    saveTasks();
  }

  void pickDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }
}
