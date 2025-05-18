// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/widgets/form_widgets.dart';

/// 비밀번호 재설정 이메일 입력 폼
class PasswordResetEmailForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;

  const PasswordResetEmailForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    this.errorMessage,
    required this.onSubmit,
  });

  @override
  State<PasswordResetEmailForm> createState() => _PasswordResetEmailFormState();
}

class _PasswordResetEmailFormState extends State<PasswordResetEmailForm> {
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    widget.emailController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          widget.emailController.text.isNotEmpty &&
          widget.emailController.text.contains('@');
    });
  }

  @override
  void dispose() {
    widget.emailController.removeListener(_validateForm);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          Container(
            margin: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '가입하신 이메일 주소를 입력해주세요.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 10),
                Text(
                  '비밀번호 재설정을 위한 링크가 전송됩니다.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          ResetEmailField(controller: widget.emailController),

          if (widget.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],

          const SizedBox(height: 32),

          SubmitButton(
            text: '비밀번호 재설정 링크 받기',
            onPressed:
                widget.isLoading || !_isFormValid ? null : widget.onSubmit,
            isLoading: widget.isLoading,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
    );
  }
}

/// 비밀번호 재설정용 이메일 입력 필드
class ResetEmailField extends StatelessWidget {
  final TextEditingController controller;

  const ResetEmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CommonTextField(
      controller: controller,
      hintText: '이메일',
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icon(Icons.email, color: Colors.brown[400]),
      labelText: '이메일',
      labelStyle: TextStyle(color: Colors.brown[600]),
      borderRadius: BorderRadius.circular(12),
      filled: true,
      fillColor: Colors.white,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '이메일을 입력해주세요';
        }
        if (!value.contains('@')) {
          return '유효한 이메일 주소를 입력해주세요';
        }
        return null;
      },
    );
  }
}

/// 재설정 비밀번호 입력 폼
class PasswordResetForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController tokenController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final String? errorMessage;
  final bool isLoading;
  final VoidCallback onSubmit;
  final String email;

  const PasswordResetForm({
    super.key,
    required this.formKey,
    required this.tokenController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isPasswordVisible,
    required this.isConfirmPasswordVisible,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    this.errorMessage,
    required this.isLoading,
    required this.onSubmit,
    required this.email,
  });

  @override
  State<PasswordResetForm> createState() => _PasswordResetFormState();
}

class _PasswordResetFormState extends State<PasswordResetForm> {
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    widget.tokenController.addListener(_validateForm);
    widget.passwordController.addListener(_validateForm);
    widget.confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          widget.tokenController.text.isNotEmpty &&
          widget.passwordController.text.isNotEmpty &&
          widget.confirmPasswordController.text.isNotEmpty &&
          widget.passwordController.text.length >= 6 &&
          widget.passwordController.text ==
              widget.confirmPasswordController.text;
    });
  }

  @override
  void dispose() {
    widget.tokenController.removeListener(_validateForm);
    widget.passwordController.removeListener(_validateForm);
    widget.confirmPasswordController.removeListener(_validateForm);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
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
          ResetTokenField(controller: widget.tokenController),
          const SizedBox(height: 16),

          // 새 비밀번호 입력 필드
          ResetPasswordField(
            controller: widget.passwordController,
            isVisible: widget.isPasswordVisible,
            onToggleVisibility: widget.onTogglePassword,
          ),
          const SizedBox(height: 16),

          // 비밀번호 확인 필드
          ResetConfirmPasswordField(
            controller: widget.confirmPasswordController,
            passwordController: widget.passwordController,
            isVisible: widget.isConfirmPasswordVisible,
            onToggleVisibility: widget.onToggleConfirmPassword,
          ),

          if (widget.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],

          const SizedBox(height: 32),

          SubmitButton(
            text: '비밀번호 변경하기',
            onPressed:
                widget.isLoading || !_isFormValid ? null : widget.onSubmit,
            isLoading: widget.isLoading,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
    );
  }
}

/// 토큰 입력 필드
class ResetTokenField extends StatelessWidget {
  final TextEditingController controller;

  const ResetTokenField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CommonTextField(
      controller: controller,
      hintText: '인증 코드를 입력해주세요',
      keyboardType: TextInputType.text,
      labelText: '인증 코드',
      labelStyle: TextStyle(color: Colors.brown[600]),
      prefixIcon: Icon(Icons.vpn_key, color: Colors.brown[400]),
      borderRadius: BorderRadius.circular(12),
      filled: true,
      fillColor: Colors.white,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '인증 코드를 입력해주세요';
        }
        return null;
      },
    );
  }
}

/// 새 비밀번호 입력 필드
class ResetPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  const ResetPasswordField({
    super.key,
    required this.controller,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: '새 비밀번호',
        labelStyle: TextStyle(color: Colors.brown[600]),
        prefixIcon: Icon(Icons.lock, color: Colors.brown[400]),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.brown[400],
          ),
          onPressed: onToggleVisibility,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '새 비밀번호를 입력해주세요';
        }
        if (value.length < 6) {
          return '비밀번호는 최소 6자 이상이어야 합니다';
        }
        return null;
      },
    );
  }
}

/// 비밀번호 확인 필드
class ResetConfirmPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController passwordController;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  const ResetConfirmPasswordField({
    super.key,
    required this.controller,
    required this.passwordController,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: '비밀번호 확인',
        labelStyle: TextStyle(color: Colors.brown[600]),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.brown[400]),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.brown[400],
          ),
          onPressed: onToggleVisibility,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '비밀번호를 다시 입력해주세요';
        }
        if (value != passwordController.text) {
          return '비밀번호가 일치하지 않습니다';
        }
        return null;
      },
    );
  }
}

/// 비밀번호 재설정 완료 화면
