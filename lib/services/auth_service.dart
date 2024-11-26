import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AuthService {
  static const String appId = "Fx14hfpW0QX2hU1i19m3atfg5I6IWAcbuE2ru9Qm";
  static const String restApiKey = "HDWymZL5I9uNZTBHRAwvuMH5YdpcDvMSOUbrO6If";
  static const String serverUrl = "https://parseapi.back4app.com/";

  Future<bool> signUp(String username, String password) async {
    final url = Uri.parse('${serverUrl}users');
    final response = await http.post(
      url,
      headers: {
        'X-Parse-Application-Id': appId,
        'X-Parse-REST-API-Key': restApiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );
    return response.statusCode == 201;
  }

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('${serverUrl}login');
    final response = await http.get(
      url.replace(queryParameters: {
        'username': username,
        'password': password,
      }),
      headers: {
        'X-Parse-Application-Id': appId,
        'X-Parse-REST-API-Key': restApiKey,
      },
    );
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('sessionToken', jsonDecode(response.body)['sessionToken']);
      prefs.setString('userId', jsonDecode(response.body)['objectId']);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('sessionToken');
    prefs.remove('userId');
  }

  Future<bool> register(String username, String password, String email) async {
    try {
      final user = ParseUser(username, password, email); // Add email
      final response = await user.signUp();

      if (response.success) {
        print('User registered successfully');
        return true;
      } else {
        print('Signup Error: ${response.error?.message}');
        return false;
      }
    } catch (e) {
      print('Exception during signup: $e');
      return false;
    }
  }
}
