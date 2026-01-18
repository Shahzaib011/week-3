import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'login.dart';
import 'profile.dart';
import 'setting.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showTaskDialog(BuildContext context, {Task? task}) {
    final provider = context.read<TaskProvider>();
    final titleController = TextEditingController(text: task?.title ?? '');
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
                if (picked != null) taskDate = picked;
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Task Time: ${taskTime.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: taskTime,
                );
                if (picked != null) taskTime = picked;
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
              provider.addOrEditTask(newTask, oldTask: task);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks;

    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: provider.selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) provider.pickDate(picked);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showTaskDialog(context),
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('No tasks for this date.'))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (_, index) {
          final task = tasks[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            child: ListTile(
              leading: Checkbox(
                value: task.isDone,
                onChanged: (_) => provider.toggleComplete(task),
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
                    onPressed: () => _showTaskDialog(context, task: task),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => provider.deleteTask(task),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
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
}
