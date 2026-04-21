import 'dart:convert';
import 'package:health_chatbot/services/secure_storage_service.dart';
import 'package:health_chatbot/utils/api_host.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final _client = http.Client();
  final _storage = SecureStorageService();

Future<Map<String, String>> _headers({bool auth = false}) async {
  final headers = {'Content-Type': 'application/json'};

  if (auth) {
    final token = await _storage.readToken();
    print("TOKEN SEND: $token"); 
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
  }

  return headers;
}

  Uri _uri(String path) => Uri.parse('${getApiHost()}$path');

  Future<http.Response> get(String path, {bool auth = false}) async {
    final res = await _client.get(
      _uri(path),
      headers: await _headers(auth: auth),
    );

    print('GET ${_uri(path)} => ${res.statusCode}');
    return res;
  }

  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final res = await _client.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: jsonEncode(body ?? {}),
    );

    print('POST ${_uri(path)} => ${res.statusCode}');
    print('BODY: ${res.body}');
    return res;
  }

  Future<http.Response> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final res = await _client.put(
      _uri(path),
      headers: await _headers(auth: auth),
      body: jsonEncode(body ?? {}),
    );

    print('PUT ${_uri(path)} => ${res.statusCode}');
    print('BODY: ${res.body}');
    return res;
  }

  Future<http.Response> delete(String path, {bool auth = true}) async {
    final res = await _client.delete(
      _uri(path),
      headers: await _headers(auth: auth),
    );

    print('DELETE ${_uri(path)} => ${res.statusCode}');
    return res;
  }

Future<http.Response> postMultipart(
  String path, {
  Map<String, String>? fields,
  String? filePath,
  String fieldName = 'file',
  bool auth = false,
}) async {
  final uri = _uri(path);

  final request = http.MultipartRequest('POST', uri);

  request.headers.addAll(await _headers(auth: auth));
  request.fields.addAll(fields ?? {});

  if (filePath != null) {
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
  }

  final streamed = await request.send();
  final res = await http.Response.fromStream(streamed);

  print('POST $uri => ${res.statusCode}');
  print('BODY: ${res.body}');
  return res;
}

Future<String?> getToken() async {
  return await _storage.readToken();
}
}