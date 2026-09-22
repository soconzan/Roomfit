import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';
import 'package:roomfit_client/core/router/app_router.dart';
import 'package:roomfit_client/features/auth/presentation/provider/auth_provider.dart';
import 'package:roomfit_client/features/auth/presentation/widgets/auth_text_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _idController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  Timer? _idDebounce;
  Timer? _nameDebounce;

  CheckStatus _idCheckStatus = CheckStatus.idle;
  CheckStatus _nameCheckStatus = CheckStatus.idle;
  String? _idErrorText;
  String? _nameErrorText;

  bool _isLoading = false;
  String? _errorMessage;

  bool get _canSubmit {
    return _idCheckStatus == CheckStatus.success &&
        _nameCheckStatus == CheckStatus.success &&
        _passwordController.text.isNotEmpty &&
        _confirmController.text.isNotEmpty &&
        _passwordController.text == _confirmController.text &&
        !_isLoading;
  }

  @override
  void initState() {
    super.initState();
    _idController.addListener(_onIdChanged);
    _nicknameController.addListener(_onNameChanged);
    _passwordController.addListener(() => setState(() {}));
    _confirmController.addListener(() => setState(() {}));
  }

  void _onIdChanged() {
    final value = _idController.text.trim();
    _idDebounce?.cancel();
    if (value.isEmpty) {
      setState(() {
        _idCheckStatus = CheckStatus.idle;
        _idErrorText = null;
      });
      return;
    }
    setState(() {
      _idCheckStatus = CheckStatus.loading;
      _idErrorText = null;
    });
    _idDebounce = Timer(
      const Duration(milliseconds: 500),
      () => _checkId(value),
    );
  }

  void _onNameChanged() {
    final value = _nicknameController.text.trim();
    _nameDebounce?.cancel();
    if (value.isEmpty) {
      setState(() {
        _nameCheckStatus = CheckStatus.idle;
        _nameErrorText = null;
      });
      return;
    }
    setState(() {
      _nameCheckStatus = CheckStatus.loading;
      _nameErrorText = null;
    });
    _nameDebounce = Timer(
      const Duration(milliseconds: 500),
      () => _checkName(value),
    );
  }

  Future<void> _checkId(String username) async {
    try {
      final result = await ref.read(authRepositoryProvider).checkId(username);
      if (!mounted) return;
      setState(() {
        _idCheckStatus =
            result.success ? CheckStatus.success : CheckStatus.failure;
        _idErrorText = result.success ? null : result.message;
      });
    } catch (e) {
      if (mounted) setState(() => _idCheckStatus = CheckStatus.idle);
    }
  }

  Future<void> _checkName(String name) async {
    try {
      final result = await ref.read(authRepositoryProvider).checkName(name);
      if (!mounted) return;
      setState(() {
        _nameCheckStatus =
            result.success ? CheckStatus.success : CheckStatus.failure;
        _nameErrorText = result.success ? null : result.message;
      });
    } catch (e) {
      if (mounted) setState(() => _nameCheckStatus = CheckStatus.idle);
    }
  }

  Future<void> _signup() async {
    if (!_canSubmit) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(authProvider.notifier)
          .register(
            _idController.text.trim(),
            _passwordController.text,
            _nicknameController.text.trim(),
          );
      if (mounted) context.go(AppPaths.login);
    } catch (_) {
      setState(() => _errorMessage = AppStrings.kSignupError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _idDebounce?.cancel();
    _nameDebounce?.cancel();
    _idController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
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
                onTap: () => context.pop(),
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
                      spacing: 40,
                      children: [
                        const Text(
                          AppStrings.kSignupTitle,
                          style: TextStyle(
                            fontFamily: 'A2Z',
                            color: AppColors.kAuthTitle,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Column(
                          spacing: 15,
                          children: [
                            AuthTextField(
                              label: AppStrings.kLoginId,
                              hint: AppStrings.kLoginIdHint,
                              controller: _idController,
                              checkStatus: _idCheckStatus,
                              errorText: _idErrorText,
                            ),
                            AuthTextField(
                              label: AppStrings.kSignupNickname,
                              hint: AppStrings.kSignupNicknameHint,
                              controller: _nicknameController,
                              checkStatus: _nameCheckStatus,
                              errorText: _nameErrorText,
                            ),
                            AuthTextField(
                              label: AppStrings.kLoginPassword,
                              hint: AppStrings.kLoginPasswordHint,
                              controller: _passwordController,
                              obscureText: true,
                            ),
                            AuthTextField(
                              label: AppStrings.kSignupConfirmPassword,
                              hint: AppStrings.kSignupConfirmPasswordHint,
                              controller: _confirmController,
                              obscureText: true,
                              errorText:
                                  _confirmController.text.isNotEmpty &&
                                          _passwordController.text !=
                                              _confirmController.text
                                      ? AppStrings.kSignupPasswordMismatch
                                      : null,
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
                          onTap: _canSubmit ? _signup : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: 65,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color:
                                  _canSubmit
                                      ? AppColors.kBlack
                                      : AppColors.kBlack.withAlpha(60),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow:
                                  _canSubmit
                                      ? const [
                                        BoxShadow(
                                          color: AppColors.kAuthButtonShadow,
                                          blurRadius: 12,
                                          offset: Offset(0, 4),
                                        ),
                                      ]
                                      : null,
                            ),
                            child: Center(
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: AppColors.kWhite,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(
                                        AppStrings.kSignupButton,
                                        style: TextStyle(
                                          color: AppColors.kWhite,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            child: const Text(
                              AppStrings.kSignupLoginPrompt,
                              style: TextStyle(
                                color: AppColors.kBlack,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline,
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
