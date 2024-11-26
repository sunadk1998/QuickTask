import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import 'add_edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService taskService = TaskService();
  List<Map<String, dynamic>> tasks = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    return userId;
  }

  void fetchTasks() async {
    String? userId = await getUserId();
    if (userId != null) {
      final fetchedTasks = await taskService.fetchTasks(userId);
      setState(() {
        tasks = fetchedTasks;
      });
    } else {
      print('User ID not found!');
    }
  }

  void toggleTaskStatus(String taskId, bool newStatus) async {
    final success = await taskService.toggleTaskStatus(taskId, newStatus);
    if (success) fetchTasks();
  }

  void deleteTask(String taskId) async {
    final success = await taskService.deleteTask(taskId);
    if (success) fetchTasks();
  }

  void logout() async {
    final authService = AuthService();
    await authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 30),
            SizedBox(width: 10),
            Text('QuickTask'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Text(
                'No tasks available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: tasks.length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      task['title'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Due: ${task['dueDate']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: task['status'],
                          onChanged: (value) {
                            toggleTaskStatus(task['objectId'], value);
                          },
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.red,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            deleteTask(task['objectId']);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditTaskScreen(
                            task: task,
                            userId: userId!,
                            refreshTasks: fetchTasks,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditTaskScreen(
                userId: userId!,
                refreshTasks: fetchTasks,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
