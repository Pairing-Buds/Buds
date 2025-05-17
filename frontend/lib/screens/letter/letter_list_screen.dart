// Flutter imports:
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:buds/providers/letter_provider.dart';
import 'package:buds/screens/letter/widgets/letter_container.dart';
import 'package:buds/screens/letter/widgets/letter_empty_state.dart';
import 'package:buds/screens/letter/widgets/letter_item.dart';
import 'package:buds/screens/letter/widgets/letter_write_button.dart';

// import 'package:buds/models/letter_list_model.dart';

class LetterList extends StatelessWidget {
  final VoidCallback onWritePressed;

  const LetterList({super.key, required this.onWritePressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<LetterProvider>(
      builder: (context, letterProvider, _) {
        // 첫 빌드시 데이터 로드가 안되었다면 로드
        if (letterProvider.letterResponse == null &&
            !letterProvider.isLoadingLetters) {
          letterProvider.fetchLetters();
        }

        if (letterProvider.isLoadingLetters) {
          return const Center(child: CircularProgressIndicator());
        }

        final letterResponse = letterProvider.letterResponse;
        if (letterResponse == null) {
          return const Center(child: Text('편지 목록을 불러올 수 없습니다.'));
        }

        final letters = letterResponse.letters;

        return LetterContainer(
          children: [
            Expanded(
              child:
                  letters.isEmpty
                      ? const LetterEmptyState()
                      : ListView.separated(
                        itemCount: letters.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          return LetterItem(letter: letters[index]);
                        },
                      ),
            ),
            LetterWriteButton(onPressed: onWritePressed),
          ],
        );
      },
    );
  }
}
