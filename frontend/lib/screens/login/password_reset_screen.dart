import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:provider/provider.dart';
import 'package:buds/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';

/// 비밀번호 재설정 화면 (토큰 + 새 비밀번호 입력)
class PasswordResetScreen extends StatefulWidget {
  final String email;

  const PasswordResetScreen({Key? key, required this.email}) : super(key: key);

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

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('비밀번호가 성공적으로 변경되었습니다.')));

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
    if (_success) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 상단 여백
                const SizedBox(height: 40),

                // 성공 아이콘
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 100,
                ),
                const SizedBox(height: 40),

                // 성공 메시지
                const Text(
                  '비밀번호 변경 완료',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                const Text(
                  '새 비밀번호로 로그인해주세요.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 50),

                // 버튼
                SizedBox(
                  width: 240,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        () => Navigator.popUntil(
                          context,
                          (route) => route.isFirst,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.brown[800],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '로그인하러 가기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 여백 추가
                  const SizedBox(height: 40),

                  // 설명 텍스트
                  Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    child: Text(
                      '${widget.email}로 전송된\n인증 코드와 새 비밀번호를 입력해주세요.',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 토큰 입력 필드
                  TextFormField(
                    controller: _tokenController,
                    decoration: InputDecoration(
                      labelText: '인증 코드',
                      labelStyle: TextStyle(color: Colors.brown[600]),
                      prefixIcon: Icon(Icons.vpn_key, color: Colors.brown[400]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.brown[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.brown[400]!),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '인증 코드를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 새 비밀번호 입력 필드
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: '새 비밀번호',
                      labelStyle: TextStyle(color: Colors.brown[600]),
                      prefixIcon: Icon(Icons.lock, color: Colors.brown[400]),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.brown[400],
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.brown[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.brown[400]!),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '새 비밀번호를 입력해주세요';
                      }
                      if (value.length < 6) {
                        return '비밀번호는 최소 6자 이상이어야 합니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 비밀번호 확인 필드
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: '비밀번호 확인',
                      labelStyle: TextStyle(color: Colors.brown[600]),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.brown[400],
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.brown[400],
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.brown[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.brown[400]!),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: !_isConfirmPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 다시 입력해주세요';
                      }
                      if (value != _passwordController.text) {
                        return '비밀번호가 일치하지 않습니다';
                      }
                      return null;
                    },
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.brown[800],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                '비밀번호 변경하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
