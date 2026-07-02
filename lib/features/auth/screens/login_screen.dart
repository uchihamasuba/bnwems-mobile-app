import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  late final AnimationController _heroAnimationController;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotateAnimation;
  late final Animation<double> _sparkleAnimation;

  static const Color _ivory = Color(0xFFFBF8F3);
  static const Color _warmIvory = Color(0xFFF6EFE7);
  static const Color _champagne = Color(0xFFEDE0CE);
  static const Color _dustyRose = Color(0xFFA05A66);
  static const Color _deepRose = Color(0xFF894D58);
  static const Color _gold = Color(0xFFC2A15D);
  static const Color _textDark = Color(0xFF2F2A28);
  static const Color _textMuted = Color(0xFF786D68);
  static const Color _borderSoft = Color(0xFFE4D5CC);

  @override
  void initState() {
    super.initState();

    _heroAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -4,
      end: 4,
    ).animate(
      CurvedAnimation(
        parent: _heroAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.035,
    ).animate(
      CurvedAnimation(
        parent: _heroAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(
      CurvedAnimation(
        parent: _heroAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _sparkleAnimation = Tween<double>(
      begin: 0.45,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _heroAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      final user = result['user'] as UserModel;
      Navigator.pushReplacementNamed(context, AppRoutes.forRole(user.role));
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() {
        _errorMessage = 'Không thể kết nối tới máy chủ. Vui lòng thử lại.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ivory,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -90,
              child: _buildBlurCircle(
                size: 230,
                color: _champagne,
                opacity: 0.48,
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: _buildBlurCircle(
                size: 210,
                color: _borderSoft,
                opacity: 0.36,
              ),
            ),
            Column(
              children: [
                _buildHero(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildWelcomeCard(),
                          const SizedBox(height: 20),
                          _buildSectionLabel('Thông tin đăng nhập'),
                          const SizedBox(height: 12),
                          _buildUsernameField(),
                          const SizedBox(height: 12),
                          _buildPasswordField(),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 14),
                            _buildErrorBanner(),
                          ],
                          const SizedBox(height: 22),
                          _buildLoginButton(),
                          const SizedBox(height: 24),
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurCircle({
    required double size,
    required Color color,
    required double opacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 58, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _ivory,
            _warmIvory,
            _champagne,
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14894D58),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAnimatedWeddingIcon(),
          const SizedBox(height: 18),
          Text(
            AppStrings.appName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textDark,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Quản lý dịch vụ cưới hỏi & sự kiện',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _textMuted,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedWeddingIcon() {
    return AnimatedBuilder(
      animation: _heroAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 94,
                    height: 94,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.46),
                      boxShadow: [
                        BoxShadow(
                          color: _deepRose.withOpacity(0.08),
                          blurRadius: 30,
                          spreadRadius: 6,
                        ),
                        BoxShadow(
                          color: _gold.withOpacity(0.10),
                          blurRadius: 22,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          _ivory,
                          _champagne,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: _borderSoft,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _deepRose.withOpacity(0.12),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.diamond_rounded,
                      size: 34,
                      color: _gold,
                    ),
                  ),
                  Positioned(
                    top: -7,
                    right: 4,
                    child: _buildSparkle(
                      size: 20,
                      color: _gold,
                    ),
                  ),
                  Positioned(
                    bottom: 3,
                    left: -7,
                    child: _buildSparkle(
                      size: 15,
                      color: _dustyRose,
                    ),
                  ),
                  Positioned(
                    right: -10,
                    bottom: 11,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: _gold,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _gold.withOpacity(0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 13,
                        color: _deepRose,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSparkle({
    required double size,
    required Color color,
  }) {
    return Opacity(
      opacity: _sparkleAnimation.value,
      child: Icon(
        Icons.auto_awesome_rounded,
        size: size,
        color: color,
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _borderSoft,
        ),
        boxShadow: [
          BoxShadow(
            color: _deepRose.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(
            Icons.event_available_rounded,
            color: _gold,
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Đăng nhập để theo dõi lịch sự kiện, công việc và tiến độ phục vụ.',
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: _textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: _deepRose,
        letterSpacing: 0.9,
      ),
    );
  }

  Widget _buildUsernameField() {
    return _FieldCard(
      child: TextFormField(
        controller: _usernameController,
        textInputAction: TextInputAction.next,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _textDark,
        ),
        decoration: const InputDecoration(
          labelText: 'Tên đăng nhập',
          labelStyle: TextStyle(
            fontSize: 13,
            color: _textMuted,
          ),
          prefixIcon: Icon(
            Icons.person_outline_rounded,
            size: 20,
            color: _deepRose,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) {
            return 'Vui lòng nhập tên đăng nhập';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return _FieldCard(
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _handleLogin(),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _textDark,
        ),
        decoration: InputDecoration(
          labelText: AppStrings.passwordLabel,
          labelStyle: const TextStyle(
            fontSize: 13,
            color: _textMuted,
          ),
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            size: 20,
            color: _deepRose,
          ),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: _textMuted,
            ),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        validator: (v) {
          if (v == null || v.isEmpty) {
            return 'Vui lòng nhập mật khẩu';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFDA4AF),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: Color(0xFFE11D48),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFE11D48),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _deepRose,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _deepRose.withOpacity(0.45),
          elevation: 0,
          shadowColor: _deepRose.withOpacity(0.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Text(
      AppStrings.copyright,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        color: Color(0xFFA99A92),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  final Widget child;

  const _FieldCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE4D5CC),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF894D58).withOpacity(0.045),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}
