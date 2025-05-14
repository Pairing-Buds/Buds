// // Flutter imports:
// import 'package:flutter/material.dart';
//
// // Project imports:
// import 'package:buds/config/theme.dart';
// import 'package:buds/models/letter_content_model.dart';
//
// class LetterContentCard extends StatelessWidget {
//   final LetterContentModel letter;
//   final bool isScraped;
//   final VoidCallback onScrapToggle;
//   final String loggedInUser;
//
//   const LetterContentCard({
//     Key? key,
//     required this.letter,
//     this.isScraped = false,
//     required this.onScrapToggle,
//     required this.loggedInUser,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: AppColors.cardBackground,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 6,
//             offset: const Offset(2, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 letter.received
//                     ? 'To: $loggedInUser'
//                     : 'To: ${letter.receiverName}',
//                 style: const TextStyle(fontSize: 16),
//               ),
//               GestureDetector(
//                 onTap: onScrapToggle,
//                 child: Image.asset(
//                   isScraped
//                       ? (letter.received
//                           ? 'assets/icons/letter/scrap_skyblue.png'
//                           : 'assets/icons/letter/scrap_yellow.png')
//                       : 'assets/icons/letter/scrap_inactive.png',
//                   width: 24,
//                   height: 24,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Text(
//                 letter.content,
//                 style: const TextStyle(fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Align(
//             alignment: Alignment.bottomRight,
//             child: Text(
//               letter.received
//                   ? 'From: ${letter.senderName}'
//                   : 'From: $loggedInUser',
//               style: const TextStyle(fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
