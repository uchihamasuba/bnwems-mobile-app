import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../widgets/manager_app_header.dart';
import '../widgets/manager_section_header.dart';

class ManagerAccountScreen extends StatefulWidget {
  const ManagerAccountScreen({super.key});

  @override
  State<ManagerAccountScreen> createState() => _ManagerAccountScreenState();
}

class _ManagerAccountScreenState extends State<ManagerAccountScreen> {
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = AuthService.getStoredUser();
  }

  void _reload() {
    setState(() {
      _userFuture = AuthService.getStoredUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AppScaffold(
            useSafeArea: true,
            body: LoadingState(),
          );
        }

        if (snapshot.hasError) {
          return AppScaffold(
            useSafeArea: true,
            body: ErrorState(
              message: snapshot.error.toString(),
              onRetry: _reload,
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return AppScaffold(
            useSafeArea: true,
            body: ErrorState(
              title: 'Khong tim thay phien dang nhap',
              message: 'Hay dang nhap lai de tai thong tin quan ly.',
              onRetry: _reload,
            ),
          );
        }

        return AppScaffold(
          useSafeArea: true,
          body: ListView(
            padding: const EdgeInsets.all(AppSizes.m),
            children: [
              ManagerAppHeader(
                title: 'Tai khoan',
                subtitle:
                    'Quan ly phien dang nhap va truy cap nhanh toi cac tac vu thuong dung.',
                trailing: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  child: Text(
                    user.fullName.isEmpty ? 'M' : user.fullName.substring(0, 1),
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
                title: 'Thong tin quan ly',
                subtitle: 'Thong tin hien thi phuc vu trai nghiem giao dien mobile.',
              ),
              const SizedBox(height: AppSizes.m),
              InfoCard(
                child: Column(
                  children: [
                    _InfoTile(
                      icon: Icons.person_outline_rounded,
                      label: 'Ho va ten',
                      value: user.fullName,
                    ),
                    const Divider(height: 24, color: AppColors.divider),
                    _InfoTile(
                      icon: Icons.badge_outlined,
                      label: 'Ten dang nhap',
                      value: user.username,
                    ),
                    const Divider(height: 24, color: AppColors.divider),
                    _InfoTile(
                      icon: Icons.shield_outlined,
                      label: 'Vai tro',
                      value: user.displayRole,
                    ),
                    const Divider(height: 24, color: AppColors.divider),
                    _InfoTile(
                      icon: Icons.verified_user_outlined,
                      label: 'Trang thai',
                      value: user.displayStatus,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.l),
              const ManagerSectionHeader(
                title: 'Tac vu nhanh',
                subtitle: 'Dieu huong mot cham toi cac khu vuc thuong dung.',
              ),
              const SizedBox(height: AppSizes.m),
              _ActionRow(
                icon: Icons.today_rounded,
                title: 'Don hang hom nay',
                onTap: () => Navigator.pushNamed(context, AppRoutes.managerToday),
              ),
              _ActionRow(
                icon: Icons.notifications_active_outlined,
                title: 'Thong bao khan',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.managerNotifications),
              ),
              _ActionRow(
                icon: Icons.timeline_rounded,
                title: 'Tien do hien truong',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.managerFieldProgress),
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
                  label: const Text('Dang xuat'),
                ),
              ),
            ],
          ),
        );
      },
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
                value.isEmpty ? '--' : value,
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
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
