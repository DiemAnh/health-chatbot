import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health_chatbot/screens/edit_profile_screen/edit_profile_screen.dart';
import 'package:health_chatbot/screens/login_screen.dart';
import 'package:health_chatbot/services/secure_storage_service.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();
  final SecureStorageService _storage = SecureStorageService();

  String? avatarFileName;
  String? token;
  bool loading = false;
  Map? userData;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  String buildAvatarUrl(String path) {
    if (path.startsWith("http")) return path;
    return "${ApiConstants.baseUrl}${ApiConstants.avatar(path)}";
  }

  Future<void> loadProfile() async {
    setState(() => loading = true);
    final res = await _api.get(ApiConstants.profile, auth: true);

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final t = await _api.getToken();
      setState(() {
        userData = body['data'];
        avatarFileName = body['data']['imageProfile'];
        token = t;
      });
    }
    setState(() => loading = false);
  }

   Future<void> logout() async {
    await _storage.deleteToken();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen.routeName,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = avatarFileName != null ? buildAvatarUrl(avatarFileName!) : null;

    return SafeArea(
      child: loading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          avatarUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    avatarUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    headers: {"Authorization": "Bearer $token"},
                                  ),
                                )
                              : const CircleAvatar(
                                  radius: 40,
                                  child: Icon(Icons.person),
                                ),
                          const SizedBox(height: 8),
                          Text(
                            "Xin chào, ${userData?['fullName'] ?? 'người dùng'}!",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.person_outline, color: Colors.black),
                  title: const Text("Thông tin tài khoản"),
                  onTap: () async {
                    if (userData != null) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(initialData: userData!),
                        ),
                      );
                      if (result == true) loadProfile();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout_outlined, color: Colors.black),
                  title: const Text("Đăng xuất"),
                  onTap: logout,
                ),
              ],
            ),
          ),
    );
  }
}