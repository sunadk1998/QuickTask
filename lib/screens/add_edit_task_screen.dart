import 'package:flutter/material.dart';
import '../services/task_service.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Map<String, dynamic>? task;
  final String userId;
  final VoidCallback refreshTasks;

  AddEditTaskScreen({this.task, required this.userId, required this.refreshTasks});

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  DateTime? dueDate;
  TimeOfDay? dueTime;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      isEditing = true;
      titleController.text = widget.task!['title'];
      // Parse dueDate if necessary
      final dueDateField = widget.task!['dueDate'];
      if (dueDateField is Map && dueDateField['iso'] != null) {
        dueDate = DateTime.parse(dueDateField['iso']);
        dueTime = TimeOfDay.fromDateTime(dueDate!);
      } else if (dueDateField is DateTime) {
        dueDate = dueDateField;
        dueTime = TimeOfDay.fromDateTime(dueDate!);
      }
    }
  }

  void saveTask() async {
    if (titleController.text.isEmpty || dueDate == null || dueTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title, date, and time are required.')),
      );
      return;
    }

    // Combine the selected date and time into a single DateTime object
    final combinedDateTime = DateTime(
      dueDate!.year,
      dueDate!.month,
      dueDate!.day,
      dueTime!.hour,
      dueTime!.minute,
    );

    final taskService = TaskService();
    bool success;
    if (isEditing) {
      success = await taskService.updateTask(
        widget.task!['objectId'],
        titleController.text,
        combinedDateTime,
      );
    } else {
      success = await taskService.addTask(
        titleController.text,
        combinedDateTime,
        widget.userId,
      );
    }

    if (success) {
      widget.refreshTasks();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save task.')),
      );
    }
  }

  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        dueDate = pickedDate;
      });
    }
  }

  Future<void> pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: dueTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        dueTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 30),
            SizedBox(width: 10),
            Text(isEditing ? 'Edit Task' : 'Add Task'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(fontSize: 18, color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Task Title',
                labelStyle: TextStyle(fontSize: 16, color: Colors.grey[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  dueDate == null
                      ? 'No date chosen'
                      : 'Date: ${dueDate!.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: pickDate,
                  style: ElevatedButton.styleFrom(
                    // primary: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Select Date',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  dueTime == null
                      ? 'No time chosen'
                      : 'Time: ${dueTime!.format(context)}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: pickTime,
                  style: ElevatedButton.styleFrom(
                    // primary: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Select Time',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: saveTask,
              style: ElevatedButton.styleFrom(
                // primary: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                isEditing ? 'Update Task' : 'Add Task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
