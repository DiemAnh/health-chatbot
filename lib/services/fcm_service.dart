// lib/services/fcm_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_chatbot/main.dart';
import 'package:health_chatbot/services/api_service.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiService _api = ApiService();

  Future<void> init() async {
    await _messaging.requestPermission();

    final token = await _messaging.getToken();
    if (token != null) {
      print("FCM Token: $token");
      await updateFcmToken(token);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message.notification?.title, message.notification?.body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification clicked: ${message.notification?.title}");
    });
  }

  void showNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'default_channel',
      'Default',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title ?? 'Thông báo mới',
      body ?? 'Đã đến giờ uống thuốc',
      platformChannelSpecifics,
    );
  }

  Future<void> updateFcmToken(String fcmToken) async {
    final res = await _api.post(
      '/api/v1/user/fcm-token?token=$fcmToken',
      auth: true,
    );

    if (res.statusCode == 200) {
      print("FCM token cập nhật thành công");
    } else {
      throw Exception("Update FCM token thất bại: ${res.statusCode}");
    }
  }
}
