import 'package:flutter/material.dart';
import 'dart:convert';

class Task {
  String title;
  bool isDone;
  DateTime date;
  TimeOfDay time;

  Task({
    required this.title,
    this.isDone = false,
    required this.date,
    required this.time,
  });

  // Convert Task to Map for JSON encoding
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
      'date': date.toIso8601String(),
      'timeHour': time.hour,
      'timeMinute': time.minute,
    };
  }

  // Create Task from Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      isDone: map['isDone'],
      date: DateTime.parse(map['date']),
      time: TimeOfDay(hour: map['timeHour'], minute: map['timeMinute']),
    );
  }

  // Encode Task to JSON string
  String toJson() => json.encode(toMap());

  // Decode Task from JSON string
  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));
}
