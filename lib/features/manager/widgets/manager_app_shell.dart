import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../dashboard/manager_dashboard_screen.dart';
import '../today/manager_today_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../evidence/screens/evidence_gallery_screen.dart';

class ManagerAppShell extends StatefulWidget {
  const ManagerAppShell({super.key});

  @override
  State<ManagerAppShell> createState() => _ManagerAppShellState();
}

class _ManagerAppShellState extends State<ManagerAppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ManagerDashboardScreen(),
    ManagerTodayScreen(),
    NotificationsScreen(),
    EvidenceGalleryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            activeIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today_rounded),
            activeIcon: Icon(Icons.today_rounded, color: AppColors.primary),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_rounded),
            activeIcon: Icon(Icons.notifications_rounded, color: AppColors.primary),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_rounded),
            activeIcon: Icon(Icons.photo_library_rounded, color: AppColors.primary),
            label: 'Minh chứng',
          ),
        ],
      ),
    );
  }
}
