// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/providers/auth_provider.dart';
import 'widgets/password_reset_widgets.dart';
import 'package:buds/widgets/toast_bar.dart';

/// 비밀번호 재설정 화면 (토큰 + 새 비밀번호 입력)
class PasswordResetScreen extends StatefulWidget {
  final String email;

  const PasswordResetScreen({super.key, required this.email});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;
  bool _success = false;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final token = _tokenController.text.trim();
      final password = _passwordController.text;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        final success = await authProvider.resetPassword(token, password);

        if (!mounted) return;

        if (success) {
          setState(() {
            _success = true;
          });

          Toast(
            context,
            '비밀번호가 성공적으로 변경되었습니다.',
            icon: const Icon(Icons.check_circle, color: Colors.green),
          );

          // 3초 후 로그인 화면으로 돌아가기
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          });
        } else {
          setState(() {
            _errorMessage = '비밀번호 재설정에 실패했습니다. 토큰을 확인해주세요.';
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('비밀번호 재설정 실패: $e');
        }
        setState(() {
          _errorMessage = '오류가 발생했습니다. 다시 시도해주세요.';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.brown[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('비밀번호 재설정', style: TextStyle(color: Colors.brown[800])),
        centerTitle: true,
      ),
      body: SafeArea(
        child:
            _success
                ? PasswordResetSuccess(
                  onGoToLogin:
                      () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                )
                : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: PasswordResetForm(
                      formKey: _formKey,
                      tokenController: _tokenController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      isPasswordVisible: _isPasswordVisible,
                      isConfirmPasswordVisible: _isConfirmPasswordVisible,
                      onTogglePassword:
                          () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                      onToggleConfirmPassword:
                          () => setState(
                            () =>
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible,
                          ),
                      errorMessage: _errorMessage,
                      isLoading: _isLoading,
                      onSubmit: _resetPassword,
                      email: widget.email,
                    ),
                  ),
                ),
      ),
    );
  }
}
