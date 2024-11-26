import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Task {
  String title;
  DateTime dueDate;
  bool status;
  ParseUser user;

  Task({required this.title, required this.dueDate, required this.status, required this.user});

  // Convert Task to ParseObject for database interaction
  ParseObject toParseObject() {
    var task = ParseObject('Task');
    task.set<String>('title', title);
    task.set<DateTime>('dueDate', dueDate);
    task.set<bool>('status', status);
    task.set<ParseUser>('user', user);
    return task;
  }

  // ParseObject to Task
  static Task fromParseObject(ParseObject parseObject) {
    return Task(
      title: parseObject.get<String>('title')!,
      dueDate: parseObject.get<DateTime>('dueDate')!,
      status: parseObject.get<bool>('status')!,
      user: parseObject.get<ParseUser>('userId')!,
    );
  }
}
