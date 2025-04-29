/// 캐릭터 데이터를 관리하는 클래스
class CharacterData {
  // 캐릭터 총 개수
  static const int characterCount = 6;

  // 캐릭터 이미지 경로 가져오기
  static String getImage(int index) {
    switch (index) {
      case 0:
        return 'assets/images/duck.png'; // 오리
      case 1:
        return 'assets/images/fox.png'; // 여우
      case 2:
        return 'assets/images/frog.png'; // 개구리
      case 3:
        return 'assets/images/lizard.png'; // 도마뱀
      case 4:
        return 'assets/images/newmarmet.png'; // 마멋
      case 5:
        return 'assets/images/rabit.png'; // 토끼
      default:
        return 'assets/images/duck.png';
    }
  }

  // 캐릭터 이름 가져오기
  static String getName(int index) {
    switch (index) {
      case 0:
        return '오리'; // 오리
      case 1:
        return '여우'; // 여우
      case 2:
        return '개구리'; // 개구리
      case 3:
        return '도마뱀'; // 도마뱀
      case 4:
        return '마멋'; // 마멋
      case 5:
        return '토끼'; // 토끼
      default:
        return '캐릭터';
    }
  }

  // 캐릭터 설명 가져오기
  static String getDescription(int index) {
    switch (index) {
      case 0:
        return '귀엽고 친근한 오리와 함께 섬에서 새로운 모험을 시작해보세요!';
      case 1:
        return '영리하고 따뜻한 여우와 함께 특별한 이야기를 만들어보세요!';
      case 2:
        return '활발하고 즐거운 개구리와 함께라면 매일이 신나는 일로 가득할 거예요!';
      case 3:
        return '호기심 많고 재치있는 도마뱀이 당신의 일상을 더 풍요롭게 만들어줄 거예요!';
      case 4:
        return '다정하고 사려깊은 마멋이 당신에게 따뜻한 위로를 전해줄 거예요!';
      case 5:
        return '귀엽고 상냥한 토끼와 함께 당신의 섬을 꾸며보세요!';
      default:
        return '당신과 함께할 특별한 친구입니다.';
    }
  }
}
