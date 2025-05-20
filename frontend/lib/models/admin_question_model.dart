import 'package:buds/models/admin_model.dart';
import 'package:buds/models/admin_answer_model.dart';

class Question {
  final int questionId;
  final String subject;
  final String content;
  final String status;
  final String createdAt;
  final UserModel user;
  final Answer? answer;

  Question({
    required this.questionId,
    required this.subject,
    required this.content,
    required this.status,
    required this.createdAt,
    required this.user,
    this.answer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionId: json['id'],
      subject: json['subject'] ?? '',
      content: json['content'] ?? '',
      status: json['status'] ?? 'UNANSWERED',
      createdAt: json['createdAt'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
      answer: json['answer'] != null ? Answer.fromJson(json['answer']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': questionId,
      'subject': subject,
      'content': content,
      'status': status,
      'createdAt': createdAt,
      'user': user.toJson(),
      'answer': answer?.toJson(),
    };
  }
}

class UserModel {
  final int userId;
  final String userName;
  final String userEmail;
  final List<String>? tagTypes;

  UserModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.tagTypes,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String>? tags;
    if (json['tagTypes'] != null) {
      tags = List<String>.from(json['tagTypes']);
    }

    return UserModel(
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      tagTypes: tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'tagTypes': tagTypes,
    };
  }
}

class Answer {
  final int? answerId;
  final String content;
  final String createdAt;

  Answer({
    this.answerId,
    required this.content,
    required this.createdAt,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      answerId: json['id'],
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': answerId,
      'content': content,
      'createdAt': createdAt,
    };
  }
} 