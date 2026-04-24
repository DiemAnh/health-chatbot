import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health_chatbot/screens/medication_screen.dart';
import 'package:health_chatbot/services/fcm_service.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();

  String? avatarFileName;
  String? token;
  Map? userData;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
    Fcm();
  }

  Future<void> Fcm() async {
    await FcmService().init();
  }

  String buildAvatarUrl(String path) {
    if (path.startsWith("http")) return path;
    return "${ApiConstants.baseUrl}${ApiConstants.avatar(path)}";
  }

  Future<void> loadProfile() async {
    setState(() => loading = true);

    final res = await _api.get(
      ApiConstants.profile,
      auth: true,
    );

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

  @override
  Widget build(BuildContext context) {
    final avatarUrl =
        avatarFileName != null ? buildAvatarUrl(avatarFileName!) : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/mascot.png',
                    width: 150,
                    height: 150,
                  ),
                  const Spacer(),
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
                                headers: {
                                  "Authorization": "Bearer $token",
                                },
                              ),
                            )
                          : const CircleAvatar(
                              radius: 40,
                              child: Icon(Icons.person),
                            ),
                      const SizedBox(height: 8),
                      Text(
                        "Xin chào, ${userData?['fullName'] ?? ''}!",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Image.asset(
              'assets/images/banner.png',
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    widget.onNavigate(1);
                  },
                  icon: Image.asset(
                    'assets/icons/drug_main.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    widget.onNavigate(3);
                  },
                  icon: Image.asset(
                    'assets/icons/noti_main.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    widget.onNavigate(4);
                  },
                  icon: Image.asset(
                    'assets/icons/profile_main.png',
                    width: 100,
                    height: 100,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
