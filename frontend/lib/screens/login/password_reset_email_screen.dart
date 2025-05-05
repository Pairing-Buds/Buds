import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:provider/provider.dart';
import 'package:buds/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:buds/screens/login/password_reset_screen.dart';
import 'widgets/password_reset_widgets.dart';

/// 비밀번호 재설정 이메일 입력 화면
class PasswordResetEmailScreen extends StatefulWidget {
  const PasswordResetEmailScreen({Key? key}) : super(key: key);

  @override
  State<PasswordResetEmailScreen> createState() =>
      _PasswordResetEmailScreenState();
}

class _PasswordResetEmailScreenState extends State<PasswordResetEmailScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestPasswordReset() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final email = _emailController.text.trim();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        final success = await authProvider.requestPasswordReset(email);

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이메일로 비밀번호 재설정 링크가 발송되었습니다.')),
          );

          // 비밀번호 재설정 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PasswordResetScreen(email: email),
            ),
          );
        } else {
          setState(() {
            _errorMessage = '비밀번호 재설정 요청에 실패했습니다. 이메일을 확인해주세요.';
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('비밀번호 재설정 요청 실패: $e');
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
        title: Text('비밀번호 찾기', style: TextStyle(color: Colors.brown[800])),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: PasswordResetEmailForm(
              formKey: _formKey,
              emailController: _emailController,
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              onSubmit: _requestPasswordReset,
            ),
          ),
        ),
      ),
    );
  }
}
