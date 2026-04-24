import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_chatbot/screens/login_screen.dart';
import 'package:health_chatbot/screens/main_screen.dart';
import 'package:health_chatbot/services/secure_storage_service.dart';
import 'package:health_chatbot/services/fcm_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  // initNotifications();

  // // Khởi tạo FCM service
  // await FcmService().init();

  print("Đã khởi tạo xong các dịch vụ, chuẩn bị chạy UI...");
  runApp(const MyApp());
}

void initNotifications() {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isLoggedIn() async {
    final token = await SecureStorageService().getToken();
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medication App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data! ? const MainScreen() : const LoginScreen();
        },
      ),
    );
  }
}
