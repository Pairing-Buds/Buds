class BadgeModel {
  final String imagePath;

  BadgeModel({required this.imagePath});

  static BadgeModel fromDiaryType(String diaryType) {
    switch (diaryType.toUpperCase()) {
      case 'EMOTION':
        return BadgeModel(imagePath: 'assets/icons/badges/wake.png');
        default:
        return BadgeModel(imagePath: 'assets/icons/badges/TEXT.png');
    }
  }
}
