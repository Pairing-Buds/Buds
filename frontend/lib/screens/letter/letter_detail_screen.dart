import 'package:flutter/material.dart';
import 'package:buds/models/letter_detail_model.dart';
import 'package:buds/services/letter_service.dart';
import 'package:buds/screens/letter/letter_reply_screen.dart';
import 'package:buds/screens/letter/letter_send_screen.dart';
import 'package:buds/widgets/custom_app_bar.dart';

class LetterDetailScreen extends StatefulWidget {
  final int opponentId;
  final String opponentName;

  const LetterDetailScreen({
    super.key,
    required this.opponentId,
    required this.opponentName,
  });

  @override
  State<LetterDetailScreen> createState() => _LetterDetailScreenState();
}

class _LetterDetailScreenState extends State<LetterDetailScreen> {
  List<LetterDetailModel> letters = [];
  bool isLoading = false;
  int currentPage = 0;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    fetchLetters();
  }

  Future<void> fetchLetters() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await LetterService().fetchLetterDetails(
        opponentId: widget.opponentId,
        page: currentPage,
        size: 5,
      );

      setState(() {
        letters = response;
        totalPages = (response.length == 5) ? currentPage + 2 : currentPage + 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('편지를 불러오는데 실패했습니다: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: '편지함',
        leftIconPath: 'assets/icons/bottle_icon.png',
        centerTitle: true,
        showBackButton: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildLetterList(),
    );
  }

  Widget buildLetterList() {
    return ListView.builder(
      itemCount: letters.length,
      itemBuilder: (context, index) {
        final letter = letters[index];
        print("✅ Letter ID (from list): ${letter.letterId}");

        return ListTile(
          title: Text(
            letter.status == "READ" ? "읽은 편지" : "읽지 않은 편지",
          ),
          subtitle: Text(letter.createdAt),
          onTap: () {
            if (letter.received) {
              print("✅ Navigating to ReplyScreen2 with letterId: ${letter.letterId}");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LetterReplyScreen(
                    letterId: letter.letterId,
                  ),
                ),
              );
            } else {
              print("✅ Navigating to SendScreen with letterId: ${letter.letterId}");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LetterSendScreen(
                    letterId: letter.letterId,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
