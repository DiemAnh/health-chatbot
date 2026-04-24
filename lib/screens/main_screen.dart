import 'package:flutter/material.dart';
import 'package:health_chatbot/screens/chat_screen.dart';
import 'package:health_chatbot/screens/dashboard_screen.dart';
import 'package:health_chatbot/screens/medication_screen.dart';
import 'package:health_chatbot/screens/noti_screen.dart';
import 'package:health_chatbot/screens/profile_screen.dart';
import 'package:health_chatbot/services/auth_service.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  void navigate(int i) {
    setState(() => _index = i);
  }

  late final List<Widget> _screens = [
    DashboardScreen(onNavigate: navigate),
    const MedicationScreen(),
    const ChatScreen(),
    const NotiScreen(),
    const ProfileScreen(),
  ];

  Future<void> logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          IndexedStack(
            index: _index,
            children: _screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(child: _centerButton()),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        color: Color(0xFFE6EEF5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          _navItem(0, 'assets/icons/dashboard.png', "Trang chủ"),
          _navItem(1, 'assets/icons/drug.png', "Tủ thuốc"),
          const SizedBox(width: 60),
          _navItem(3, 'assets/icons/noti.png', "Thông báo"),
          _navItem(4, 'assets/icons/profile.png', "Hồ sơ"),
        ],
      ),
    );
  }

  Widget _navItem(int i, String icon, String label) {
    final isSelected = _index == i;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _index = i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              width: 40,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Transform.scale(
                scale: 2.2,
                child: Image.asset(
                  icon,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: 70,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.black : Colors.grey,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _centerButton() {
    final isSelected = _index == 2;

    return GestureDetector(
      onTap: () => setState(() => _index = 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : const Color(0xE365AFE3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Transform.scale(
                scale: 1.8,
                child: Image.asset(
                  'assets/icons/add.png',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Tư vấn",
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}