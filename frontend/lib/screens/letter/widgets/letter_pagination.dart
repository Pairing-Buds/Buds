// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/providers/letter_provider.dart';

class LetterPagination extends StatelessWidget {
  final LetterProvider provider;
  final int opponentId;
  final Function(LetterProvider) buildPageDots;

  const LetterPagination({
    super.key,
    required this.provider,
    required this.opponentId,
    required this.buildPageDots,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (provider.currentPage <
                      provider.letterPage!.totalPages - 1) {
                    provider.fetchLetterDetails(
                      opponentId: opponentId,
                      page: provider.currentPage + 1,
                    );
                  }
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
              Text(
                '페이지: ${provider.currentPage + 1} / ${provider.letterPage?.totalPages ?? 1}',
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                onPressed: () {
                  if (provider.currentPage > 0) {
                    provider.fetchLetterDetails(
                      opponentId: opponentId,
                      page: provider.currentPage - 1,
                    );
                  }
                },
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buildPageDots(provider),
          ),
        ],
      ),
    );
  }
}
