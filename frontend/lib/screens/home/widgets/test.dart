import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ThreeDViewerScreen extends StatelessWidget {
  const ThreeDViewerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        appBar: AppBar(title: const Text('3D 모델 뷰어')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ModelViewer(
                  src: 'assets/models/flog_texture.glb',
                  alt: '3D 모델',
                  autoRotate: true,
                  cameraControls: true,
                  debugLogging: true, // 디버그 로깅 활성화
                  backgroundColor: const Color.fromARGB(255, 230, 230, 230), // 배경색 변경으로 렌더링 확인
                  ar: false, // AR 기능 비활성화
                  loading: Loading.eager, // 즉시 로딩 시도
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  '모델이 보이지 않으면 로딩 중이거나 오류가 발생했을 수 있습니다',
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // 콘솔에 로그 출력
                  print('모델 로드 상태 확인 버튼 클릭됨');
                },
                child: const Text('모델 로드 상태 확인'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      // 예외 발생 시 오류 화면 표시
      return Scaffold(
        appBar: AppBar(title: const Text('3D 모델 뷰어 오류')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  '오류 발생: $e',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('뒤로 가기'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}