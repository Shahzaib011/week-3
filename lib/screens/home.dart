import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage.dart';
import '../models/task_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'profile.dart';
import 'setting.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> allTasks = [];
  List<Task> tasks = [];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    allTasks = await StorageService.loadTasks();
    _filterTasksForDate();
  }

  void _filterTasksForDate() {
    setState(() {
      tasks = allTasks.where((t) =>
      t.date.year == selectedDate.year &&
          t.date.month == selectedDate.month &&
          t.date.day == selectedDate.day
      ).toList();
    });
  }

  Future<void> _saveTasks() async {
    await StorageService.saveTasks(allTasks);
  }

  void _addOrEditTask({Task? task, int? index}) {
    final TextEditingController titleController =
    TextEditingController(text: task?.title ?? '');

    DateTime taskDate = task?.date ?? DateTime.now();
    TimeOfDay taskTime = task?.time ?? TimeOfDay.now();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(task == null ? 'Add Task' : 'Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Task Date: ${DateFormat('yyyy-MM-dd').format(taskDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: taskDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => taskDate = picked);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Task Time: ${taskTime.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                    context: context, initialTime: taskTime
                );
                if (picked != null) setState(() => taskTime = picked);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty) return;

              Task newTask = Task(
                title: titleController.text,
                isDone: task?.isDone ?? false,
                date: DateTime(
                  taskDate.year,
                  taskDate.month,
                  taskDate.day,
                  taskTime.hour,
                  taskTime.minute,
                ),
                time: taskTime,
              );

              setState(() {
                if (task == null) {
                  allTasks.add(newTask);
                } else {
                  int globalIndex = allTasks.indexOf(task);
                  allTasks[globalIndex] = newTask;
                }
                _filterTasksForDate();
              });

              _saveTasks();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _toggleComplete(int index) {
    setState(() {
      tasks[index].isDone = !tasks[index].isDone;
      int globalIndex = allTasks.indexOf(tasks[index]);
      allTasks[globalIndex] = tasks[index];
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      Task taskToDelete = tasks[index];
      tasks.removeAt(index);
      allTasks.remove(taskToDelete);
    });
    _saveTasks();
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
      _filterTasksForDate();
    }
  }

  Drawer _buildDrawer() {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? 'User'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addOrEditTask(),
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('No tasks for this date.'))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (_, index) {
          Task task = tasks[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            child: ListTile(
              leading: Checkbox(
                value: task.isDone,
                onChanged: (_) => _toggleComplete(index),
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                  '${DateFormat('yyyy-MM-dd').format(task.date)} • ${task.time.format(context)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _addOrEditTask(task: task, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteTask(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
