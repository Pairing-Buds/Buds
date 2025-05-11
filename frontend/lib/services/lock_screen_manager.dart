import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 잠금화면 바이패스 설정을 관리하는 서비스 클래스
class LockScreenManager {
  // 싱글톤 패턴 구현
  static final LockScreenManager _instance = LockScreenManager._internal();
  factory LockScreenManager() => _instance;
  LockScreenManager._internal();

  // 네이티브 코드와 통신하기 위한 메서드 채널
  static const platform = MethodChannel('com.buds.app/lock_screen_settings');

  /// 잠금화면 바이패스 비활성화 (일반 앱 사용 시)
  Future<bool> disableLockScreenBypass() async {
    try {
      final bool result = await platform.invokeMethod(
        'disableLockScreenBypass',
      );
      debugPrint('잠금화면 바이패스 비활성화: $result');
      return result;
    } catch (e) {
      debugPrint('잠금화면 바이패스 비활성화 오류: $e');
      return false;
    }
  }

  /// 잠금화면 바이패스 활성화 (알람 화면 표시 시)
  Future<bool> enableLockScreenBypass() async {
    try {
      final bool result = await platform.invokeMethod('enableLockScreenBypass');
      debugPrint('잠금화면 바이패스 활성화: $result');
      return result;
    } catch (e) {
      debugPrint('잠금화면 바이패스 활성화 오류: $e');
      return false;
    }
  }

  /// 현재 잠금화면 바이패스 상태 확인
  Future<bool> getLockScreenBypassStatus() async {
    try {
      final bool result = await platform.invokeMethod(
        'getLockScreenBypassStatus',
      );
      debugPrint('잠금화면 바이패스 상태: $result');
      return result;
    } catch (e) {
      debugPrint('잠금화면 바이패스 상태 확인 오류: $e');
      return false;
    }
  }
}
