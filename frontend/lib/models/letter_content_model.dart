// Package imports:
import 'package:intl/intl.dart';

class LetterContentModel {
  final int    letterId;
  final String senderName;
  final String receiverName;
  final String content;
  final String status;       // READ / UNREAD
  final String createdAt;    // yyyy.MM.dd 형식

  LetterContentModel({
    required this.letterId,
    required this.senderName,
    required this.receiverName,
    required this.content,
    required this.status,
    required this.createdAt,
  });

  factory LetterContentModel.fromJson(Map<String, dynamic> json) {
    // ISO-8601 → yyyy.MM.dd
    final iso = json['createdAt'] as String;
    final dt  = DateTime.parse(iso);
    final formatted = DateFormat('yyyy.MM.dd').format(dt);

    return LetterContentModel(
      letterId    : json['letterId'],
      senderName  : json['senderName'],
      receiverName: json['receiverName'],
      content     : json['content'],
      status      : json['status'],
      createdAt   : formatted,
    );
  }
}
