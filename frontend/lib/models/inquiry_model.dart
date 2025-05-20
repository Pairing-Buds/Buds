class InquiryResponse {
  final String statusCode;
  final InquiryResMsg resMsg;

  InquiryResponse({required this.statusCode, required this.resMsg});

  factory InquiryResponse.fromJson(Map<String, dynamic> json) {
    return InquiryResponse(
      statusCode: json['statusCode'],
      resMsg: InquiryResMsg.fromJson(json['resMsg']),
    );
  }
}

class InquiryResMsg {
  final List<Question> questions;

  InquiryResMsg({required this.questions});

  factory InquiryResMsg.fromJson(Map<String, dynamic> json) {
    return InquiryResMsg(
      questions:
          (json['questions'] as List).map((q) => Question.fromJson(q)).toList(),
    );
  }
}

class Question {
  final int id;
  final User user;
  final String subject;
  final String content;
  final Answer? answer;
  final String status;
  final String createdAt;
  final String updatedAt;

  Question({
    required this.id,
    required this.user,
    required this.subject,
    required this.content,
    this.answer,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      user: User.fromJson(json['user']),
      subject: json['subject'],
      content: json['content'],
      answer: json['answer'] != null ? Answer.fromJson(json['answer']) : null,
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class User {
  final int userId;
  final String userEmail;
  final String birthDate;
  final String role;
  final bool isActive;
  final int letterCnt;
  final String userName;

  User({
    required this.userId,
    required this.userEmail,
    required this.birthDate,
    required this.role,
    required this.isActive,
    required this.letterCnt,
    required this.userName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      userEmail: json['userEmail'],
      birthDate: json['birthDate'],
      role: json['role'],
      isActive: json['isActive'],
      letterCnt: json['letterCnt'],
      userName: json['userName'],
    );
  }
}

class Answer {
  final int id;
  final String content;
  final String createdAt;
  final String updatedAt;

  Answer({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      content: json['content'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

// 문의 수정 응답 모델
class InquiryUpdateResponse {
  final String statusCode;
  final String resMsg;

  InquiryUpdateResponse({required this.statusCode, required this.resMsg});

  factory InquiryUpdateResponse.fromJson(Map<String, dynamic> json) {
    return InquiryUpdateResponse(
      statusCode: json['statusCode'],
      resMsg: json['resMsg'],
    );
  }
}

// 문의 삭제 응답 모델
class InquiryDeleteResponse {
  final String statusCode;
  final String resMsg;

  InquiryDeleteResponse({required this.statusCode, required this.resMsg});

  factory InquiryDeleteResponse.fromJson(Map<String, dynamic> json) {
    return InquiryDeleteResponse(
      statusCode: json['statusCode'],
      resMsg: json['resMsg'],
    );
  }
}
