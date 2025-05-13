// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'terms_contents.dart';

/// 동의 항목 위젯
class AgreementItem extends StatelessWidget {
  final String title;
  final bool isChecked;
  final Function(bool) onChanged;

  const AgreementItem({
    super.key,
    required this.title,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Row(
          children: [
            AnimatedCheckboxButton(isChecked: isChecked, onChanged: onChanged),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // 약관 상세 페이지로 이동
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => Scaffold(
                              appBar: AppBar(
                                title: Text(title),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                elevation: 0,
                              ),
                              body: SingleChildScrollView(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(getTermsContent(title)),
                              ),
                            ),
                      ),
                    );
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.only(left: 10),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '필수',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(title, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 약관 제목에 따라 적절한 약관 내용을 반환하는 함수
  String getTermsContent(String title) {
    switch (title) {
      case '서비스 이용약관':
        return TermsContents.serviceTerms;
      case '개인정보수집/이용 동의':
        return TermsContents.privacyTerms;
      case '개인정보 제3자 정보제공 동의':
        return TermsContents.thirdPartyTerms;
      case '위치 기반 서비스 이용약관 동의':
        return TermsContents.locationTerms;
      default:
        return '약관 내용이 준비되지 않았습니다.';
    }
  }
}

/// 전체 동의 위젯
class AllAgreementItem extends StatelessWidget {
  final bool isChecked;
  final Function(bool) onChanged;

  const AllAgreementItem({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!isChecked),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: ListTile(
            leading: AnimatedCheckboxButton(
              isChecked: isChecked,
              onChanged: onChanged,
            ),
            title: const Text(
              '전체 동의',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

/// 다음 버튼 위젯
class NextButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onPressed;

  const NextButton({super.key, required this.isEnabled, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        width: double.infinity,
        height: 60,
        color: isEnabled ? AppColors.primary : Colors.grey.shade300,
        child: Center(
          child: Text(
            '다음',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isEnabled ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

/// 애니메이션 체크박스 버튼
class AnimatedCheckboxButton extends StatefulWidget {
  final bool isChecked;
  final Function(bool) onChanged;

  const AnimatedCheckboxButton({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  State<AnimatedCheckboxButton> createState() => _AnimatedCheckboxButtonState();
}

class _AnimatedCheckboxButtonState extends State<AnimatedCheckboxButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onChanged(!widget.isChecked);
      },
      onTapCancel: () => _controller.reverse(),
      behavior: HitTestBehavior.translucent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isChecked ? AppColors.primary : Colors.grey.shade400,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
