// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'faq_screen.dart';
import 'inquiry_chat_screen.dart';
import 'widgets/faq_section.dart';

class CustomerCenterScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const CustomerCenterScreen({Key? key, this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed:
              () => onBack != null ? onBack!() : Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = MediaQuery.of(context).size.width;
          final isMobile = width < 600;
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : constraints.maxWidth * 0.2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: isMobile ? 70 : 140),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      '고객센터',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      '운영시간  09:00~18:00',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      '주말 및 공휴일은 휴무 입니다',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildMenuButton(
                    context,
                    icon: Icons.receipt_long,
                    label: '자주 묻는 질문',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const FaqScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildMenuButton(
                    context,
                    icon: Icons.chat_bubble_outline,
                    label: '문의 내역 조회 및 작성',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const InquiryChatScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildMenuButton(
                    context,
                    icon: Icons.headset_mic,
                    label: '전화 문의',
                    onTap: () {},
                  ),
                  SizedBox(height: isMobile ? 60 : 120),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 28 : 36,
          horizontal: isMobile ? 20 : 32,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: isMobile ? 32 : 40, color: Colors.black54),
            SizedBox(width: isMobile ? 20 : 32),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.black38,
              size: isMobile ? 28 : 32,
            ),
          ],
        ),
      ),
    );
  }
}
