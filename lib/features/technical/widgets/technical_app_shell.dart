import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../dashboard/technical_dashboard_screen.dart';
import '../tasks/technical_task_list_screen.dart';
import '../tasks/technical_task_detail_screen.dart';
import '../tasks/technical_evidence_upload_screen.dart';

class TechnicalAppShell extends StatefulWidget {
  const TechnicalAppShell({super.key});

  @override
  State<TechnicalAppShell> createState() => _TechnicalAppShellState();
}

class _TechnicalAppShellState extends State<TechnicalAppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TechnicalDashboardScreen(),
    TechnicalTaskListScreen(),
    TechnicalTaskDetailScreen(),
    TechnicalEvidenceUploadScreen(),
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
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt_rounded, color: AppColors.primary),
            label: 'My Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_add_check_outlined),
            activeIcon: Icon(Icons.playlist_add_check_rounded, color: AppColors.primary),
            label: 'Checklist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file_outlined),
            activeIcon: Icon(Icons.upload_file_rounded, color: AppColors.primary),
            label: 'Minh chứng',
          ),
        ],
      ),
    );
  }
}
