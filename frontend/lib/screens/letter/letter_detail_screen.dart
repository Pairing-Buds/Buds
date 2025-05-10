import 'package:buds/models/letter_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:buds/models/letter_detail_model.dart';
import 'package:buds/services/letter_service.dart';
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

      if (response.isNotEmpty) {
        setState(() {
          letters = response;
          totalPages = (response.length == 5) ? currentPage + 2 : currentPage + 1;
        });
      } else {
        setState(() {
          letters = [];
        });
      }
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

  void goToPage(int page) {
    if (page < 0 || page >= totalPages) return;
    setState(() {
      currentPage = page;
    });
    fetchLetters();
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Text('${widget.opponentName}와(과)의 편지',
                    style: const TextStyle(color: Colors.grey, fontSize: 16)),
                const Spacer(),
                if (letters.isNotEmpty)
                  Text('총 ${letters.length}개의 편지',
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : buildLetterList(),
          ),
          buildPagination(),
        ],
      ),
    );
  }

  Widget buildLetterList() {
    return ListView.builder(
      itemCount: letters.length,
      itemBuilder: (context, index) {
        final letter = letters[index];
        return ListTile(
          title: Text(letter.content, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(letter.createdAt),
          trailing: Icon(letter.received ? Icons.mail : Icons.send),
        );
      },
    );
  }

  Widget buildPagination() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: currentPage > 0 ? () => goToPage(currentPage - 1) : null,
          ),
          Text('${currentPage + 1} / $totalPages'),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: currentPage < totalPages - 1 ? () => goToPage(currentPage + 1) : null,
          ),
        ],
      ),
    );
  }
}
