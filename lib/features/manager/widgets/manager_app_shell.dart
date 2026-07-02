import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../account/manager_account_screen.dart';
import '../approvals/manager_approvals_screen.dart';
import '../dashboard/manager_dashboard_screen.dart';
import '../progress/manager_progress_screen.dart';

class ManagerAppShell extends StatefulWidget {
  const ManagerAppShell({super.key});

  @override
  State<ManagerAppShell> createState() => _ManagerAppShellState();
}

class _ManagerAppShellState extends State<ManagerAppShell> {
  int _currentIndex = 0;
  bool _resolvedInitialIndex = false;

  final List<Widget> _pages = const [
    ManagerDashboardScreen(),
    ManagerProgressScreen(),
    NotificationsScreen(),
    ManagerApprovalsScreen(),
    ManagerAccountScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_resolvedInitialIndex) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && args >= 0 && args < _pages.length) {
      _currentIndex = args;
    }
    _resolvedInitialIndex = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        height: 78,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primaryLight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon:
                Icon(Icons.dashboard_rounded, color: AppColors.primary),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon:
                Icon(Icons.timeline_rounded, color: AppColors.primary),
            label: 'Tiến độ',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(
              Icons.notifications_active_rounded,
              color: AppColors.primary,
            ),
            label: 'Thông báo',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon:
                Icon(Icons.fact_check_rounded, color: AppColors.primary),
            label: 'Duyệt nhanh',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
