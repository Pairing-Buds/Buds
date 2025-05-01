import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/widgets/custom_app_bar.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: '행운의 조개',
        centerTitle: true,
        showBackButton: true,
      ),
      body: Column(
        children: [
          // 회색 밑줄
          Container(
            height: 1,
            color: const Color(0xFFD7D7D7),
          ),

          const SizedBox(height: 5),

          // 조개 이미지
          Image.asset(
            'assets/icons/lucky_shell.png',
            width: 310,
            height: 310,
          ),

          const SizedBox(height: 20),

          // 흰 박스
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.27,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 10.4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18.0), // 위쪽에서 18 내려오기
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center, // 가로 중앙
                        children: [
                          const Text(
                            '오늘의 한마디',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.0),
                            child: Text(
                              '"운과 유머가 세상을 지배하다."',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '하비 콕스',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // 박스 하단 아이콘 + 버튼
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // 곰 아이콘
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            'assets/images/marmet_cutting_head.png',
                            width: 80,
                            height: 80,
                          ),
                        ),
                        const SizedBox(width: 20),
                        // 마이크 아이콘
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            'assets/icons/stand_mic.png',
                            width: 40,
                            height: 40,
                          ),
                        ),
                        const SizedBox(width: 20),
                        // 따라 읽기 버튼
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5DEB3), // 연한 베이지
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              elevation: 2,
                            ),
                            onPressed: () {
                              // TODO: 따라 읽기 기능 추가
                            },
                            child: const Text(
                              '따라 읽기',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
