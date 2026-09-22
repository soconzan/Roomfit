import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';
import 'package:roomfit_client/core/router/app_router.dart';
import 'package:roomfit_client/features/auth/presentation/provider/auth_provider.dart';
import 'package:roomfit_client/features/auth/presentation/widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_idController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      debugPrint('[login] request: username=${_idController.text.trim()}');
      await ref
          .read(authProvider.notifier)
          .login(_idController.text.trim(), _passwordController.text);
      debugPrint('[login] success');
      if (mounted) context.go(AppPaths.home);
    } catch (e, st) {
      debugPrint('[login] error: $e\n$st');
      setState(() => _errorMessage = AppStrings.kLoginError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap:
                    () =>
                        context.canPop()
                            ? context.pop()
                            : context.go(AppPaths.home),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.kBlack,
                  size: 24,
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 30,
                      children: [
                        const Text(
                          AppStrings.kLoginTitle,
                          style: TextStyle(
                            fontFamily: 'A2Z',
                            color: AppColors.kAuthTitle,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push(AppPaths.signup),
                          child: const Text(
                            AppStrings.kLoginSignupPrompt,
                            style: TextStyle(
                              color: AppColors.kBlack,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Column(
                          spacing: 15,
                          children: [
                            AuthTextField(
                              label: AppStrings.kLoginId,
                              hint: AppStrings.kLoginIdHint,
                              controller: _idController,
                            ),
                            AuthTextField(
                              label: AppStrings.kLoginPassword,
                              hint: AppStrings.kLoginPasswordHint,
                              controller: _passwordController,
                              obscureText: true,
                            ),
                          ],
                        ),
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        GestureDetector(
                          onTap: _isLoading ? null : _login,
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.kBlack,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.kAuthButtonShadow,
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child:
                                  _isLoading
                                      ? LoadingAnimationWidget.horizontalRotatingDots(
                                        color: AppColors.kWhite,
                                        size: 40,
                                      )
                                      : const Text(
                                        AppStrings.kLoginButton,
                                        style: TextStyle(
                                          color: AppColors.kWhite,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
