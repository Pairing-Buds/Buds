import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:buds/constants/api_constants.dart';
import 'package:buds/services/api_service.dart';

class LetterAnonymityScreen extends StatefulWidget {
  const LetterAnonymityScreen({Key? key}) : super(key: key);

  @override
  State<LetterAnonymityScreen> createState() => _LetterAnonymityScreenState();
}

class _LetterAnonymityScreenState extends State<LetterAnonymityScreen> {
  bool isInterest = true;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String today = DateFormat('yyyy.MM.dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: '편지함',
        leftIconPath: 'assets/icons/bottle_icon.png',
        centerTitle: true,
        showBackButton: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                const Text('보낼 편지', style: TextStyle(color: Colors.grey, fontSize: 16)),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isInterest = !isInterest;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isInterest ? const Color(0xFFE0F7F5) : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isInterest ? '관심' : '랜덤',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: SizedBox()),
                        const Expanded(
                          flex: 5,
                          child: Center(
                            child: Text(
                              '익명의 누군가에게',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        // 토글 버튼은 위에 있음
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        today,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: _controller,
                          expands: true,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            hintText: '클릭하고 편지를 입력해보세요',
                            hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Text('사랑스러운 카피바라가', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final content = _controller.text.trim();
                          if (content.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('편지 내용을 입력해주세요')),
                            );
                            return;
                          }

                          final requestBody = {
                            'content': content,
                            'isTagBased': isInterest,
                          };

                          try {
                            final response = await DioApiService().post(
                              ApiConstants.letterAnonymityUrl,
                              data: requestBody,
                            );

                            if (response.statusCode == 200 || response.statusCode == 201) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('편지를 성공적으로 보냈습니다')),
                              );
                              _controller.clear();
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('편지 전송에 실패했습니다')),
                            );
                          }
                        },
                        child: Container(
                          width: 140,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Center(
                            child: Text(
                              '편지보내기',
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.arrow_left, size: 32),
                SizedBox(width: 8),
                CircleAvatar(radius: 6, backgroundColor: Colors.grey),
                SizedBox(width: 4),
                CircleAvatar(radius: 6, backgroundColor: Colors.brown),
                SizedBox(width: 4),
                CircleAvatar(radius: 6, backgroundColor: Colors.grey),
                SizedBox(width: 8),
                Icon(Icons.arrow_right, size: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
