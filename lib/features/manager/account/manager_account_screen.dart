import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/info_card.dart';
import '../../../services/auth_service.dart';
import '../../../shared/mock/mock_data.dart';
import '../widgets/manager_app_header.dart';
import '../widgets/manager_section_header.dart';

class ManagerAccountScreen extends StatelessWidget {
  const ManagerAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.managerUser;

    return AppScaffold(
      useSafeArea: true,
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.m),
        children: [
          ManagerAppHeader(
            title: 'Tài khoản',
            subtitle: 'Quản lý phiên đăng nhập và truy cập nhanh tới các tác vụ thường dùng.',
            trailing: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withOpacity(0.16),
              child: Text(
                user.fullName.substring(0, 1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.l),
          const ManagerSectionHeader(
            title: 'Thông tin Manager',
            subtitle: 'Thông tin hiển thị phục vụ trải nghiệm giao diện mobile.',
          ),
          const SizedBox(height: AppSizes.m),
          InfoCard(
            child: Column(
              children: [
                _InfoTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Họ và tên',
                  value: user.fullName,
                ),
                const Divider(height: 24, color: AppColors.divider),
                _InfoTile(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: user.email,
                ),
                const Divider(height: 24, color: AppColors.divider),
                _InfoTile(
                  icon: Icons.badge_outlined,
                  label: 'Vai trò',
                  value: 'Manager',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.l),
          const ManagerSectionHeader(
            title: 'Tác vụ nhanh',
            subtitle: 'Điều hướng một chạm tới các khu vực thường dùng.',
          ),
          const SizedBox(height: AppSizes.m),
          _ActionRow(
            icon: Icons.today_rounded,
            title: 'Đơn hàng hôm nay',
            onTap: () => Navigator.pushNamed(context, AppRoutes.managerToday),
          ),
          _ActionRow(
            icon: Icons.notifications_active_outlined,
            title: 'Thông báo khẩn',
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.managerNotifications,
            ),
          ),
          _ActionRow(
            icon: Icons.photo_library_outlined,
            title: 'Minh chứng hiện trường',
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.managerEvidenceGallery,
            ),
          ),
          const SizedBox(height: AppSizes.l),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                ),
              ),
              onPressed: () async {
                await AuthService.logout();
                if (!context.mounted) {
                  return;
                }
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Đăng xuất'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: AppSizes.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.s),
      child: InfoCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: AppSizes.m),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
