// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/providers/auth_provider.dart';
import 'package:buds/screens/character/character_select_screen.dart';
import 'package:buds/screens/login/password_reset_email_screen.dart';
import 'package:buds/screens/admin/admin_screen.dart';
import 'package:buds/widgets/toast_bar.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _passwordController.text.length >= 6 &&
          _emailController.text.contains('@');
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // 관리자 계정 체크
      if (email == dotenv.env['ADMIN_EMAIL']) {
        // AuthProvider를 통한 로그인
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider
            .login(email, password)
            .then((success) {
              if (success) {
                // 로그인 성공
                Toast(context, '관리자 로그인 성공');
                // 관리자 페이지로 이동
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AdminScreen()),
                );
              } else {
                // 로그인 실패
                Toast(
                  context,
                  '로그인 실패: 이메일 또는 비밀번호가 올바르지 않습니다',
                  icon: const Icon(Icons.error, color: Colors.red),
                );
              }
            })
            .catchError((error) {
              _handleLoginError(error);
            })
            .whenComplete(() {
              setState(() {
                _isLoading = false;
              });
            });
      } else {
        // 일반 사용자 로그인
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider
            .login(email, password)
            .then((success) {
              if (success) {
                // 로그인 성공
                Toast(context, '로그인 성공');

                // 내 정보 조회 API 호출
                authProvider
                    .refreshUserData()
                    .then((_) {
                      // 익명 사용자인지 확인
                      if (authProvider.isAnonymousUser) {
                        // 익명 사용자이면 캐릭터 선택 화면으로 이동
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const CharacterSelectScreen(),
                          ),
                        );
                      } else {
                        // 일반 사용자는 메인 화면으로 이동
                        Navigator.pushReplacementNamed(context, '/main');
                      }
                    })
                    .catchError((e) {
                      // 정보 조회 실패해도 일단 메인 화면으로 이동
                      Navigator.pushReplacementNamed(context, '/main');
                    });
              } else {
                // 로그인 실패
                Toast(
                  context,
                  '로그인 실패: 이메일 또는 비밀번호가 올바르지 않습니다',
                  icon: const Icon(Icons.error, color: Colors.red),
                );
              }
            })
            .catchError((error) {
              _handleLoginError(error);
            })
            .whenComplete(() {
              setState(() {
                _isLoading = false;
              });
            });
      }
    }
  }

  void _handleLoginError(dynamic error) {
    // 오류 메시지 추출 및 표시
    String errorMessage = '로그인 실패: 서버 연결 오류';

    if (error.toString().contains('401')) {
      errorMessage = '로그인 실패: 이메일 또는 비밀번호가 올바르지 않습니다';
    } else if (error.toString().contains('500')) {
      errorMessage = '로그인 실패: 서버 내부 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    } else if (error.toString().contains('인증 쿠키 없음')) {
      errorMessage = '로그인 실패: 인증 정보를 저장할 수 없습니다.';
    }

    Toast(
      context,
      errorMessage,
      icon: const Icon(Icons.error, color: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: '이메일',
              labelStyle: TextStyle(color: Colors.brown[600]),
              prefixIcon: Icon(Icons.email, color: Colors.brown[400]),
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
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일을 입력해주세요';
              }
              if (!value.contains('@')) {
                return '유효한 이메일 주소를 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: '비밀번호',
              labelStyle: TextStyle(color: Colors.brown[600]),
              prefixIcon: Icon(Icons.lock, color: Colors.brown[400]),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
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
                return '비밀번호를 입력해주세요';
              }
              if (value.length < 6) {
                return '비밀번호는 최소 6자 이상이어야 합니다';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isLoading || !_isFormValid) ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.brown[800],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                disabledBackgroundColor: Colors.grey[300],
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
                        '로그인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 8),

          TextButton(
            onPressed: () {
              // 비밀번호 재설정 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PasswordResetEmailScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.brown[600]),
            child: const Text('비밀번호를 잊으셨나요?'),
          ),
        ],
      ),
    );
  }
}
