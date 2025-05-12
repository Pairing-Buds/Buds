// Flutter imports:
import 'package:flutter/material.dart';

class WithdrawConfirmDialog extends StatefulWidget {
  final Future<void> Function(String password) onWithdraw;
  const WithdrawConfirmDialog({super.key, required this.onWithdraw});

  @override
  State<WithdrawConfirmDialog> createState() => _WithdrawConfirmDialogState();
}

class _WithdrawConfirmDialogState extends State<WithdrawConfirmDialog> {
  final TextEditingController _pwController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/sadmarmet.png', width: 80, height: 80),
          const SizedBox(height: 12),
          const Text(
            '정말 탈퇴하시겠어요?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text('탈퇴 후에는 계정 정보가 모두 삭제됩니다.', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextField(
            controller: _pwController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: '비밀번호 입력',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed:
              _isLoading
                  ? null
                  : () async {
                    final password = _pwController.text.trim();
                    if (password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('비밀번호를 입력해주세요.')),
                      );
                      return;
                    }
                    setState(() => _isLoading = true);
                    await widget.onWithdraw(password);
                    setState(() => _isLoading = false);
                  },
          child:
              _isLoading
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('탈퇴하기', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
