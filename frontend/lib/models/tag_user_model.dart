class TagUserModel {
  final List<TagModel> tags;

  TagUserModel({required this.tags});

  // JSON 데이터를 Dart 객체로 변환하는 팩토리 생성자
  factory TagUserModel.fromJson(Map<String, dynamic> json) {
    return TagUserModel(
      tags:
          (json['resMsg'] as List<dynamic>)
              .map((tag) => TagModel.fromJson(tag))
              .toList(),
    );
  }

  // Dart 객체를 JSON 형식으로 변환
  Map<String, dynamic> toJson() {
    return {'resMsg': tags.map((tag) => tag.toJson()).toList()};
  }
}

// 개별 태그를 저장하는 TagModel 클래스
class TagModel {
  final String tagType;
  final String displayName;

  TagModel({required this.tagType, required this.displayName});

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      tagType: json['tagType'] ?? '',
      displayName: json['displayName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'tagType': tagType, 'displayName': displayName};
  }
}
