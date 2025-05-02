# iOS 알람 사운드 추가 방법

iOS에서 알람 사운드를 사용하기 위해서는 다음 단계를 따라야 합니다:

1. `alarm_sound.wav` 파일을 이 디렉토리에 추가합니다.
2. Xcode에서 프로젝트를 열고 Runner 타겟에 해당 파일을 추가합니다:
   - Xcode에서 Runner 프로젝트 열기
   - 파일 네비게이터에서 Runner 선택
   - 파일 추가 (마우스 오른쪽 버튼 클릭 → Add Files to "Runner"...)
   - `alarm_sound.wav` 선택 후 "Add" 버튼 클릭
   - "Copy items if needed" 옵션 체크
   - "Create groups" 옵션 선택
   - Target Membership에서 "Runner" 체크

## 주의사항
- 파일 이름은 정확히 `alarm_sound.wav`로 해야 합니다.
- 만약 다른 이름을 사용하고 싶다면, `NotificationService` 클래스의 `scheduleWakeUpAlarm` 메소드에서 iOS 설정 부분의 사운드 이름을 변경해야 합니다.
- 파일 형식은 반드시 `.wav`여야 합니다. iOS는 알림 사운드로 MP3를 지원하지 않습니다.
- 파일 크기는 가능한 작게 유지하세요 (30초 이하 권장).
- 앱이 완전히 종료된 상태에서는 알림 사운드가 재생되지 않을 수 있습니다.

## 백그라운드 알림 처리
- Flutter 앱에서 백그라운드 알림 응답을 처리하려면 AppDelegate.swift 파일에 `FlutterLocalNotificationsPlugin.setPluginRegistrantCallback` 호출이 필요합니다.
- 이는 이미 설정되어 있으며, main.dart에서 `@pragma('vm:entry-point')` 어노테이션으로 표시된 백그라운드 핸들러 함수와 함께 작동합니다.

## iOS 알림 카테고리
- iOS에서는 알림에 액션 버튼을 추가하기 위해 카테고리를 사용합니다.
- `wakeUpCategory`는 '알람 끄기'와 '5분 후 다시 알림' 액션을 포함합니다.
- 이 카테고리는 앱 초기화 시 `NotificationService.initialize()` 메서드에서 설정됩니다. 