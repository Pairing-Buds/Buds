// 사용자 모델
import 'package:flutter/foundation.dart';

class User {
  final int id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    required this.createdAt,
  });

  // JSON 변환 메서드 - 더 유연하게 만들기
  factory User.fromJson(Map<String, dynamic> json) {
    // 디버그 로그 출력
    if (kDebugMode) {
      print('User JSON 파싱 시작: $json');
    }

    try {
      // 필드가 존재하는지 확인하고 올바른 필드명 사용
      int userId = json['id'] ?? json['userId'] ?? 0;
      String userEmail = json['email'] ?? json['userEmail'] ?? '';
      String userName = json['name'] ?? json['userName'] ?? '';
      String? profileImage =
          json['profile_image_url'] ?? json['profileImageUrl'];

      // 날짜 문자열이 있는 경우만 파싱
      DateTime createdDate;
      final createdAtStr = json['created_at'] ?? json['createdAt'];
      if (createdAtStr != null && createdAtStr is String) {
        try {
          createdDate = DateTime.parse(createdAtStr);
        } catch (e) {
          if (kDebugMode) {
            print('날짜 파싱 오류: $e, 현재 시간으로 기본 설정');
          }
          createdDate = DateTime.now();
        }
      } else {
        createdDate = DateTime.now();
      }

      return User(
        id: userId,
        email: userEmail,
        name: userName,
        profileImageUrl: profileImage,
        createdAt: createdDate,
      );
    } catch (e) {
      if (kDebugMode) {
        print('User 모델 파싱 오류: $e');
        print('원본 JSON: $json');
      }
      // 파싱 실패 시 기본값으로 생성
      return User(
        id: 0,
        email: '',
        name: '',
        profileImageUrl: null,
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
