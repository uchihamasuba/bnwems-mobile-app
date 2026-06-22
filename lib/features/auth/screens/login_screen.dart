import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'manager@test.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _handleLogin() {
    final email = _emailController.text.trim().toLowerCase();
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (email.contains('manager')) {
        Navigator.pushReplacementNamed(context, AppRoutes.managerDashboard);
      } else if (email.contains('leader')) {
        Navigator.pushReplacementNamed(context, AppRoutes.leaderDashboard);
      } else if (email.contains('technical')) {
        Navigator.pushReplacementNamed(context, AppRoutes.technicalDashboard);
      } else {
        // Fallback to manager
        Navigator.pushReplacementNamed(context, AppRoutes.managerDashboard);
      }
    });
  }

  void _selectQuickRole(String email) {
    setState(() {
      _emailController.text = email;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isKeyboardOpen = mq.viewInsets.bottom > 0;

    return AppScaffold(
      useSafeArea: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.l, vertical: AppSizes.m),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: mq.size.height - mq.padding.top - mq.padding.bottom - AppSizes.l,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isKeyboardOpen) ...[
                    const SizedBox(height: AppSizes.xl),
                    // Elegant App Logo
                    Center(
                      child: Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.celebration_rounded,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.l),
                    const Text(
                      AppStrings.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    const Text(
                      'Mobile Operational Application',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),
                  ],

                  // Credentials Form
                  const Text(
                    'Đăng nhập tài khoản điều hành',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.m),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email tài khoản',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSizes.m),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: AppStrings.passwordLabel,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.l),

                  // Login Button
                  PrimaryButton(
                    text: 'Đăng Nhập Vận Hành',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                    icon: Icons.login_rounded,
                  ),
                  const SizedBox(height: AppSizes.l),

                  // Quick test details card with 3 role selections
                  Container(
                    padding: const EdgeInsets.all(AppSizes.m),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                      border: Border.all(color: AppColors.primaryLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đăng nhập nhanh vai trò:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                        ),
                        const SizedBox(height: 8),
                        _buildQuickSelectButton('Manager', 'manager@test.com'),
                        const SizedBox(height: 6),
                        _buildQuickSelectButton('Leader Staff', 'leader@test.com'),
                        const SizedBox(height: 6),
                        _buildQuickSelectButton('Technical Staff', 'technical@test.com'),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSizes.m),
                child: Text(
                  AppStrings.copyright,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSelectButton(String roleName, String email) {
    final isSelected = _emailController.text == email;
    return InkWell(
      onTap: () => _selectQuickRole(email),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              roleName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            Text(
              email,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
