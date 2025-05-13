// Flutter imports:
import 'package:flutter/material.dart';

class FaqSection extends StatefulWidget {
  final String characterImagePath;
  const FaqSection({super.key, required this.characterImagePath});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  // 예시 FAQ 데이터
  final List<_FaqItem> _faqList = [
    _FaqItem(
      question: '만보기가 제대로 작동이 안돼요.',
      answer:
          '휴대폰 권한 설정이 허용되어야 정상적으로 이용이 가능합니다.\n설정 > 앱 > 권한에서 활동/건강 관련 권한을 허용해주세요.',
      showTip: true,
      tip: '휴대폰 권한 설정이 허용을 해주셔야 정상적인 이용이 가능합니다',
    ),
    _FaqItem(
      question: '캐릭터가 변경이 안돼요.',
      answer: '마이페이지에서 캐릭터 변경 버튼을 눌러주세요. 문제가 계속된다면 앱을 재시작 해보세요.',
    ),
    _FaqItem(
      question: '편지 내용 일부가 사라졌어요.',
      answer: '네트워크 연결 상태를 확인해 주세요. 문제가 지속되면 고객센터로 문의해 주세요.',
    ),
    _FaqItem(
      question: '일기장에 아무 내용도 안적혀있어요.',
      answer: '일기 저장 버튼을 눌렀는지 확인해 주세요. 저장 후에도 문제가 있으면 앱을 재시작 해보세요.',
    ),
    _FaqItem(
      question: '알림이 제대로 소리가 안들려요.',
      answer: '기기 음량 설정과 앱 알림 권한을 확인해 주세요.',
    ),
    _FaqItem(
      question: '편지가 안보내져요.',
      answer: '인터넷 연결 상태를 확인하고, 문제가 계속되면 앱을 재설치 해보세요.',
    ),
  ];

  int? _openedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // const Center(
        //   child: Text(
        //     '자주 묻는 질문',
        //     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        //   ),
        // ),
        const SizedBox(height: 16),
        ...List.generate(_faqList.length, (index) {
          final item = _faqList[index];
          final isOpen = _openedIndex == index;
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _openedIndex = isOpen ? null : index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        widget.characterImagePath,
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item.question,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        isOpen ? Icons.expand_less : Icons.expand_more,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
              ),
              if (isOpen)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.showTip)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.chat, color: Colors.black54),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.tip ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(item.answer, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  final bool showTip;
  final String? tip;
  _FaqItem({
    required this.question,
    required this.answer,
    this.showTip = false,
    this.tip,
  });
}
