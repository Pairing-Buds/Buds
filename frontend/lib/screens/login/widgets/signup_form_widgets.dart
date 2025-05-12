// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/widgets/form_widgets.dart';

/// 이메일 입력 필드
class EmailInputField extends StatelessWidget {
  final TextEditingController controller;
  final Widget? suffixIcon;

  const EmailInputField({Key? key, required this.controller, this.suffixIcon})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonTextField(
      controller: controller,
      hintText: '이메일을 입력해주세요',
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '이메일을 입력해주세요';
        }
        if (!RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        ).hasMatch(value)) {
          return '올바른 이메일 형식이 아닙니다';
        }
        return null;
      },
      suffixIcon: suffixIcon,
    );
  }
}

/// 생년월일 입력 필드
class BirthDateInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(BuildContext) onSelectDate;

  const BirthDateInputField({
    Key? key,
    required this.controller,
    required this.onSelectDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonTextField(
      controller: controller,
      hintText: '생년월일을 선택해주세요',
      readOnly: true,
      onTap: () => onSelectDate(context),
      suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '생년월일을 선택해주세요';
        }
        return null;
      },
    );
  }
}

/// 비밀번호 입력 필드
class SignupPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscurePassword;
  final VoidCallback onToggleVisibility;

  const SignupPasswordField({
    Key? key,
    required this.controller,
    required this.obscurePassword,
    required this.onToggleVisibility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PasswordTextField(
      controller: controller,
      hintText: '비밀번호를 입력해주세요',
      obscureText: obscurePassword,
      onToggleVisibility: onToggleVisibility,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '비밀번호를 입력해주세요';
        }
        if (value.length < 6) {
          return '비밀번호는 6자 이상이어야 합니다';
        }
        return null;
      },
    );
  }
}

/// 비밀번호 확인 필드
class ConfirmPasswordField extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool obscurePassword;
  final VoidCallback onToggleVisibility;

  const ConfirmPasswordField({
    Key? key,
    required this.passwordController,
    required this.confirmController,
    required this.obscurePassword,
    required this.onToggleVisibility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PasswordTextField(
      controller: confirmController,
      hintText: '비밀번호를 다시 입력해주세요',
      obscureText: obscurePassword,
      onToggleVisibility: onToggleVisibility,
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

/// 회원가입 폼
class SignupForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController birthDateController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isLoading;
  final Function(BuildContext) onSelectDate;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onSubmit;
  final Widget? emailSuffixIcon;
  final bool showEmailTokenField;
  final TextEditingController? emailTokenController;
  final VoidCallback? onVerifyToken;
  final String? emailAuthMsg;
  final bool isEmailVerified;

  const SignupForm({
    Key? key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.birthDateController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.isLoading,
    required this.onSelectDate,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onSubmit,
    this.emailSuffixIcon,
    this.showEmailTokenField = false,
    this.emailTokenController,
    this.onVerifyToken,
    this.emailAuthMsg,
    this.isEmailVerified = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'BUDS와 함께 대화해봐요!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),

          // 이메일 입력 필드
          const InputLabel(label: '이메일'),
          EmailInputField(
            controller: emailController,
            suffixIcon: emailSuffixIcon,
          ),
          if (showEmailTokenField && emailTokenController != null) ...[
            const SizedBox(height: 12),
            CommonTextField(
              controller: emailTokenController!,
              hintText: '이메일로 받은 토큰 입력',
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onVerifyToken,
                child: const Text('인증 확인'),
              ),
            ),
          ],
          if (emailAuthMsg != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                emailAuthMsg!,
                style: TextStyle(
                  color: isEmailVerified ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 24),

          // 생년월일 입력 필드
          const InputLabel(label: '생년월일'),
          BirthDateInputField(
            controller: birthDateController,
            onSelectDate: onSelectDate,
          ),
          const SizedBox(height: 24),

          // 비밀번호 입력 필드
          const InputLabel(label: '비밀번호'),
          SignupPasswordField(
            controller: passwordController,
            obscurePassword: obscurePassword,
            onToggleVisibility: onTogglePassword,
          ),
          const SizedBox(height: 24),

          // 비밀번호 확인 필드
          const InputLabel(label: '비밀번호 확인'),
          ConfirmPasswordField(
            passwordController: passwordController,
            confirmController: confirmPasswordController,
            obscurePassword: obscureConfirmPassword,
            onToggleVisibility: onToggleConfirmPassword,
          ),
          const SizedBox(height: 40),

          // 회원가입 버튼
          SubmitButton(text: '회원가입', onPressed: onSubmit, isLoading: isLoading),
        ],
      ),
    );
  }
}

/// 날짜 선택 관련 유틸리티 함수
class DatePickerUtil {
  static Future<DateTime?> showBirthDatePicker(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: '생년월일을 선택해주세요',
      cancelText: '취소',
      confirmText: '선택',
      locale: const Locale('ko', 'KR'),
    );
  }

  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
