// 사용자 모델

// Flutter imports:
import 'package:flutter/foundation.dart';

class User {
  final int id;
  final String email;
  final String name;
  final DateTime createdAt;
  final String userCharacter;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    this.userCharacter = '',
  });

  // JSON 변환 메서드 - 더 유연하게 만들기
  factory User.fromJson(Map<String, dynamic> json) {
    try {
      int userId = json['id'] ?? json['userId'] ?? 0;
      String userEmail = json['email'] ?? json['userEmail'] ?? '';
      String userName = json['name'] ?? json['userName'] ?? '';
      String? userCharacter = json['userCharacter'];

      DateTime createdDate;
      final createdAtStr = json['created_at'] ?? json['createdAt'];
      if (createdAtStr != null && createdAtStr is String) {
        try {
          createdDate = DateTime.parse(createdAtStr);
        } catch (e) {
          createdDate = DateTime.now();
        }
      } else {
        createdDate = DateTime.now();
      }

      return User(
        id: userId,
        email: userEmail,
        name: userName,
        createdAt: createdDate,
        userCharacter: userCharacter ?? '',
      );
    } catch (e) {
      // 파싱 실패 시 기본값으로 생성
      return User(
        id: 0,
        email: '',
        name: '',
        createdAt: DateTime.now(),
        userCharacter: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'userCharacter': userCharacter,
    };
  }
}
