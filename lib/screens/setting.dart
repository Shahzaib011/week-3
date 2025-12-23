import 'package:flutter/material.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    final appState = MyApp.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListTile(
        leading: const Icon(Icons.dark_mode),
        title: const Text("Dark Mode"),
        trailing: Switch(
          value: isDark,
          onChanged: (value) {
            setState(() => isDark = value);
            appState.toggleTheme(value);
          },
        ),
      ),
    );
  }
}
