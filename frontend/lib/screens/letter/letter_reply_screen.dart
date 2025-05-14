// // Flutter imports:
// import 'package:flutter/material.dart';
//
// // Project imports:
// import 'package:buds/config/theme.dart';
// import 'package:buds/models/letter_content_model.dart';
// import 'package:buds/screens/letter/letter_answer_screen.dart';
// import 'package:buds/services/letter_service.dart';
// import 'package:buds/widgets/custom_app_bar.dart';
//
// class LetterReplyScreen extends StatefulWidget {
//   final int letterId;
//   final bool isScraped;
//
//   const LetterReplyScreen({
//     Key? key,
//     required this.letterId,
//     this.isScraped = false,
//   }) : super(key: key);
//
//   @override
//   State<LetterReplyScreen> createState() => _LetterReplyScreenState();
// }
//
// class _LetterReplyScreenState extends State<LetterReplyScreen> {
//   LetterContentModel? _letterDetail;
//   bool _isLoading = true;
//   bool _isScraped = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _isScraped = widget.isScraped;
//     fetchLetterContent();
//   }
//
//   Future<void> fetchLetterContent() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final detail = await LetterService().fetchSingleLetter(widget.letterId);
//       setState(() {
//         _letterDetail = detail;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('편지 내용을 불러올 수 없습니다: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   /// 스크랩 토글
//   Future<void> _toggleScrap() async {
//     if (_isLoading || _letterDetail == null) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final success = await LetterService().toggleScrap(widget.letterId);
//       if (success) {
//         setState(() {
//           _isScraped = !_isScraped;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('스크랩 상태 변경에 실패했습니다.')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('오류가 발생했습니다: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: const CustomAppBar(
//         title: '편지함',
//         leftIconPath: 'assets/icons/bottle_icon.png',
//         centerTitle: true,
//         showBackButton: true,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _letterDetail == null
//           ? const Center(child: Text('편지 내용을 불러올 수 없습니다.'))
//           : Column(
//         children: [
//           // 상단 탭
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   '받은 편지',
//                   style: TextStyle(color: Colors.grey, fontSize: 16),
//                 ),
//                 Text(
//                   '편지 번호: ${widget.letterId}',
//                   style: const TextStyle(color: Colors.grey, fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//
//           // 편지 카드
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.65,
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//               child: Stack(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: AppColors.cardBackground,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 6,
//                           offset: const Offset(2, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         const SizedBox(height: 34),
//                         // 1. 유저명, 하늘색 발신 아이콘
//                         Row(
//                           children: [
//                             const Expanded(child: SizedBox()), // 왼쪽 빈 공간
//                             Expanded(
//                               flex: 5,
//                               child: Center(
//                                 child: Text(
//                                   'To: ${_letterDetail?.receiverName ?? '알 수 없음'}',
//                                   style: const TextStyle(fontSize: 16),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: Align(
//                                 alignment: Alignment.topRight,
//                                 child: Image.asset(
//                                   'assets/icons/letter/reply.png',
//                                   width: 40,
//                                   height: 40,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         Align(
//                           alignment: Alignment.bottomLeft,
//                           child: Text(
//                             'Date: ${_letterDetail?.createdAt ?? '알 수 없음'}',
//                             style: const TextStyle(fontSize: 13, color: Colors.grey),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//
//                         // 편지 내용 (스크롤 가능)
//                         Expanded(
//                           child: SingleChildScrollView(
//                             child: Text(
//                               _letterDetail?.content ?? '',
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                           ),
//                         ),
//
//                         // 송신자 정보
//                         const SizedBox(height: 16),
//                         Align(
//                           alignment: Alignment.bottomRight,
//                           child: Text(
//                             'From: ${_letterDetail?.senderName ?? '알 수 없음'}',
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // 스크랩 아이콘 (왼쪽 상단)
//                   Positioned(
//                     top: 0,
//                     left: 10,
//                     child: GestureDetector(
//                       onTap: _toggleScrap,
//                       child: Image.asset(
//                         _isScraped
//                             ? 'assets/icons/letter/scrap_active.png'
//                             : 'assets/icons/letter/scrap_inactive.png',
//                         width: 30,
//                         height: 30,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // 답장 버튼
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 minimumSize: const Size(140, 44),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => LetterAnswerScreen(
//                         letterId: widget.letterId,
//                         receiverName: _letterDetail?.receiverName ?? '상대방',
//                         senderName: _letterDetail?.senderName ?? '나')
//                   ),
//                 );
//               },
//               child: const Text(
//                 '답장하기',
//                 style: TextStyle(color: Colors.black, fontSize: 16),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
