import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/task_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const String applicationId = 'Fx14hfpW0QX2hU1i19m3atfg5I6IWAcbuE2ru9Qm';
  const String clientKey = 'O7hRtL4okF8uf7FtaJU2YDljw0B5Vv99CPDckw6D';
  const String serverUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(
    applicationId,
    serverUrl,
    clientKey: clientKey,
    autoSendSessionId: true,
  );

  // Check if the user is already logged in by checking session token in SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final sessionToken = prefs.getString('sessionToken');
  runApp(MyApp(sessionToken: sessionToken));
}

class MyApp extends StatelessWidget {
  final String? sessionToken;

  MyApp({this.sessionToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickTask',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',  // Make sure this is set correctly
      routes: {
        '/login': (context) => LoginScreen(),  // Define the login screen route
        '/tasks': (context) => TaskListScreen(),
      },
    );
  }
}
