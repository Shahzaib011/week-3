import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class StorageService {
  static const String tasksKey = "tasks";

  // Save list of tasks as JSON strings
  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = tasks.map((t) => t.toJson()).toList();
    await prefs.setStringList(tasksKey, jsonList);
  }

  // Load tasks from JSON strings
  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(tasksKey);
    if (jsonList == null) return [];
    return jsonList.map((jsonStr) => Task.fromJson(jsonStr)).toList();
  }
}
