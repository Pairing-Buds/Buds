// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';

/// 닉네임 선택 다이얼로그 위젯
class NicknameDialog extends StatefulWidget {
  final String initialNickname;
  final Future<String> Function() onRefresh;
  final Function(String) onConfirm;

  const NicknameDialog({
    super.key,
    required this.initialNickname,
    required this.onRefresh,
    required this.onConfirm,
  });

  @override
  State<NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<NicknameDialog> {
  late String _currentNickname;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentNickname = widget.initialNickname;
  }

  Future<void> _refreshNickname() async {
    setState(() => _isLoading = true);
    try {
      final newNickname = await widget.onRefresh();
      setState(() => _currentNickname = newNickname);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '닉네임 선택',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '이 닉네임으로 활동하게 됩니다.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _currentNickname,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      )
                      : IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: AppColors.primary,
                        ),
                        onPressed: _refreshNickname,
                      ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onConfirm(_currentNickname),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
