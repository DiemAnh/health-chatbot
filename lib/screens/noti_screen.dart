import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import 'package:intl/intl.dart';

class NotiScreen extends StatefulWidget {
  const NotiScreen({super.key});

  @override
  State<NotiScreen> createState() => _NotiScreenState();
}

class _NotiScreenState extends State<NotiScreen> {
  final ApiService _api = ApiService();

  List<dynamic> notifications = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    setState(() => isLoading = true);

    try {
      final res = await _api.get(ApiConstants.notificationsAll, auth: true);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['code'] == "200" && data['data'] != null) {
          setState(() {
            notifications = data['data'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> markAsRead(int id) async {
    final res = await _api.post(ApiConstants.markReadNotification(id), auth: true);
    if (res.statusCode == 200) {
      loadNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    final res = await _api.post(ApiConstants.markAllReadNotifications, auth: true);
    if (res.statusCode == 200) {
      loadNotifications();
    }
  }

  Future<void> deleteNotification(int id) async {
    final res = await _api.delete(ApiConstants.deleteNotification(id), auth: true);
    if (res.statusCode == 200) {
      loadNotifications();
    }
  }

  Future<void> deleteAllNotifications() async {
    final res = await _api.delete(ApiConstants.deleteAllNotifications, auth: true);
    if (res.statusCode == 200) {
      loadNotifications();
    }
  }

  void confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa tất cả thông báo?"),
        content: const Text("Bạn có chắc chắn muốn xóa tất cả thông báo không?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteAllNotifications();
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String formatSentTime(String? dateTimeString) {
    if (dateTimeString == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông báo"),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: "Đánh dấu tất cả là đã đọc",
            onPressed: notifications.isNotEmpty ? markAllAsRead : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: "Xóa tất cả",
            onPressed: notifications.isNotEmpty ? confirmDeleteAll : null,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text("Không có thông báo nào."))
              : Padding(
                padding: const EdgeInsets.only(bottom: 80.0),
                child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (_, i) {
                      final noti = notifications[i];
                      final isRead = noti['isRead'] == true;
                
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isRead ? Colors.grey.shade300 : Colors.blue.shade200,
                          ),
                        ),
                        color: isRead ? Colors.white : Colors.blue.shade50,
                        child: ListTile(
                          onTap: () {
                            if (!isRead) {
                              markAsRead(noti['id']);
                            }
                          },
                          title: Text(
                            noti['title'] ?? '',
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(noti['message'] ?? ''),
                              const SizedBox(height: 8),
                              Text(
                                formatSentTime(noti['sentTime']),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => deleteNotification(noti['id']),
                          ),
                        ),
                      );
                    },
                  ),
              ),
    );
  }
}