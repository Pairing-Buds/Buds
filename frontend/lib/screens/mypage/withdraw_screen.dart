// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/screens/login/login_main.dart';
import 'package:buds/services/auth_service.dart';
import 'package:buds/widgets/toast_bar.dart';
import 'widgets/withdraw_confirm_dialog.dart';
import 'widgets/withdraw_reason_selector.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  int? _selectedReason;
  final List<String> _reasons = [
    '앱 사용을 잘 안하게 되어서요',
    '컨텐츠가 없어요',
    '디자인이 벌로예요',
    '캐릭터가 다양하지 않아요',
    '개인정보 보호를 위해 삭제할 정보가 있어요',
    '다른 계정이 있어요',
    '기타',
  ];

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder:
          (context) => WithdrawConfirmDialog(
            onWithdraw: (password) async {
              try {
                final result = await DioAuthService().withdrawUser(password);
                if (result) {
                  await DioAuthService().clearCookies();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LoginMainScreen(),
                      ),
                      (route) => false,
                    );
                    Toast(context, '탈퇴가 완료되었습니다.');
                  }
                }
              } catch (e) {
                Toast(
                  context, 
                  '탈퇴 실패: ${e.toString()}',
                  icon: const Icon(Icons.error, color: Colors.red),
                );
              }
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('회원 탈퇴', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(text: '왜 떠나시려는지\n'),
                          TextSpan(
                            text: '이유',
                            style: TextStyle(color: Color(0xFF00B8C5)),
                          ),
                          TextSpan(text: '가 있을까요?'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              WithdrawReasonSelector(
                reasons: _reasons,
                selected: _selectedReason,
                onChanged: (idx) => setState(() => _selectedReason = idx),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '더 써볼래요',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _selectedReason == null ? null : _showWithdrawDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEEEEEE),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('탈퇴하기', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
