import 'dart:convert';

import 'package:health_chatbot/services/api_service.dart';
import 'package:health_chatbot/services/secure_storage_service.dart';

import '../models/auth_response.dart';
import '../utils/api_host.dart';
import '../constants/api_constants.dart';

class AuthService {
  final _api = ApiService();
  final _storage = SecureStorageService();

 Future<void> login({
  required String name,
  required String password,
}) async {
  final res = await _api.post(
    '/api/v1/auth/authenticate',
    body: {
      "name": name,
      "password": password,
    },
  );

  if (res.statusCode == 200) {
    final json = jsonDecode(res.body);

    final token = json['data']['accessToken'];

    if (token == null) {
      throw Exception("Token null");
    }

    await _storage.writeToken(token);
  } else {
    throw Exception("Login failed");
  }
}

  Future<void> logout() async {
  await _storage.deleteToken(); 
}

Future<void> register({
  required String name,
  required String password,
  required String phoneNumber,
}) async {
  final res = await _api.post(
    '/api/v1/auth/register',
    body: {
      "name": name,
      "password": password,
      "phoneNumber": phoneNumber,
    },
  );

  print("REGISTER STATUS: ${res.statusCode}");
  print("REGISTER BODY: ${res.body}");

  if (res.statusCode == 200) {
    return;
  } else if (res.statusCode == 409) {
    throw Exception("User already exists");
  } else {
    throw Exception("Register failed");
  }
}
}
