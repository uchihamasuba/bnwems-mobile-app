import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../dashboard/leader_dashboard_screen.dart';
import '../tasks/leader_task_list_screen.dart';
import '../progress_update/leader_progress_update_screen.dart';
import '../../evidence/screens/evidence_gallery_screen.dart';

class LeaderAppShell extends StatefulWidget {
  const LeaderAppShell({super.key});

  @override
  State<LeaderAppShell> createState() => _LeaderAppShellState();
}

class _LeaderAppShellState extends State<LeaderAppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    LeaderDashboardScreen(),
    LeaderTaskListScreen(),
    LeaderProgressUpdateScreen(),
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
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon:
                Icon(Icons.assignment_rounded, color: AppColors.primary),
            label: 'Nhiệm vụ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes_outlined),
            activeIcon:
                Icon(Icons.track_changes_rounded, color: AppColors.primary),
            label: 'Tiến độ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_outlined),
            activeIcon:
                Icon(Icons.photo_library_rounded, color: AppColors.primary),
            label: 'Ảnh minh chứng',
          ),
        ],
      ),
    );
  }
}
