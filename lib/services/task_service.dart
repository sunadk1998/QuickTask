import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskService {
  static const String appId = "Fx14hfpW0QX2hU1i19m3atfg5I6IWAcbuE2ru9Qm";
  static const String restApiKey = "HDWymZL5I9uNZTBHRAwvuMH5YdpcDvMSOUbrO6If";
  static const String serverUrl = "https://parseapi.back4app.com/";

  Future<List<Map<String, dynamic>>> fetchTasks(String userId) async {
    final url = Uri.parse('${serverUrl}classes/Task');

    final response = await http.get(
      url.replace(queryParameters: {
        'where': jsonEncode({
          'user': {'__type': 'Pointer', 'className': '_User', 'objectId': userId}
        }),
      }),
      headers: {
        'X-Parse-Application-Id': appId,
        'X-Parse-REST-API-Key': restApiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Process each task and extract the dueDate
      List<Map<String, dynamic>> tasks = (data['results'] as List)
          .map((task) {
            Map<String, dynamic> taskData = task as Map<String, dynamic>;

            // Extract the 'dueDate' field and convert to DateTime
            if (taskData['dueDate'] != null) {
              String isoDate = taskData['dueDate']['iso'];
              taskData['dueDate'] = DateTime.parse(isoDate); // Convert ISO date string to DateTime
            }

            return taskData;
          })
          .toList();

      return tasks;
    }

    // Handle non-200 response
    print("Error: ${response.statusCode}");
    print("Response Body: ${response.body}");
    return [];
  }

  Future<bool> addTask(String title, DateTime dueDate, String userId) async {
    final url = Uri.parse('${serverUrl}classes/Task');
    
    // Convert DateTime to ISO 8601 string
    String dueDateString = dueDate.toIso8601String();
    
    final response = await http.post(
      url,
      headers: {
        'X-Parse-Application-Id': appId,
        'X-Parse-REST-API-Key': restApiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'dueDate': {
          '__type': 'Date',  // Indicating the type as 'Date'
          'iso': dueDateString,  // Sending the ISO string
        },
        'status': false,
        'user': {
          '__type': 'Pointer',
          'className': '_User',
          'objectId': userId,
        },
      }),
    );

    if (response.statusCode == 201) {
      print('Task added successfully');
      return true;  // Return true if task creation is successful
    } else {
      print('Failed to add task: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;  // Return false if there was an error
    }
  }

  Future<bool> toggleTaskStatus(String taskId, bool newStatus) async {
    final url = Uri.parse('${serverUrl}classes/Task/$taskId');
    final response = await http.put(
      url,
      headers: {
        'X-Parse-Application-Id': appId,
        'X-Parse-REST-API-Key': restApiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': newStatus}),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteTask(String taskId) async {
    final url = Uri.parse('${serverUrl}classes/Task/$taskId');
    final response = await http.delete(
      url,
      headers: {
        'X-Parse-Application-Id': appId,
        'X-Parse-REST-API-Key': restApiKey,
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> updateTask(String taskId, String title, DateTime dueDate) async {
  final url = Uri.parse('${serverUrl}classes/Task/$taskId');
    final response = await http.put(
      url,
      headers: {
        'X-Parse-Application-Id': appId,
        'X-Parse-REST-API-Key': restApiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'dueDate': {
          '__type': 'Date',
          'iso': dueDate.toIso8601String(),
        },
      }),
    );

    return response.statusCode == 200;
  }
}
