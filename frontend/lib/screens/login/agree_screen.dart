import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/agree_provider.dart';
import 'package:buds/config/theme.dart';
import 'widgets/Terms_of_Use/agreement_widgets.dart';


class AgreeScreen extends StatelessWidget {
  const AgreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider 인스턴스를 한 번만 가져와서 사용
    final agreementProvider = Provider.of<AgreementProvider>(
      context,
      listen: false,
    );

    // WillPopScope를 사용하여 뒤로가기 버튼 처리
    return WillPopScope(
      onWillPop: () async {
        // 뒤로가기 시 상태 초기화
        agreementProvider.resetAllAgreements();
        return true; // true를 반환하여 뒤로가기 진행
      },
      child: Consumer<AgreementProvider>(
        builder: (context, agreementProvider, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  // 뒤로가기 아이콘 클릭 시 상태 초기화 후 화면 이동
                  agreementProvider.resetAllAgreements();
                  Navigator.of(context).pop();
                },
              ),
              title: const Text('회원 가입', style: TextStyle(color: Colors.black)),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '약관 동의',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '필수항목 및 선택항목 약관에 동의해 주세요',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // 전체 동의 위젯
                          AllAgreementItem(
                            isChecked: agreementProvider.allAgreed,
                            onChanged:
                                (value) =>
                                    agreementProvider.setAllAgreements(value),
                          ),
                          const SizedBox(height: 30),
                          // 서비스 이용약관
                          AgreementItem(
                            title: '서비스 이용약관',
                            isChecked: agreementProvider.serviceAgreed,
                            onChanged:
                                (value) => agreementProvider
                                    .setServiceAgreement(value),
                          ),
                          // 개인정보수집/이용 동의
                          AgreementItem(
                            title: '개인정보수집/이용 동의',
                            isChecked: agreementProvider.privacyAgreed,
                            onChanged:
                                (value) => agreementProvider
                                    .setPrivacyAgreement(value),
                          ),
                          // 개인정보 제3자 정보제공 동의
                          AgreementItem(
                            title: '개인정보 제3자 정보제공 동의',
                            isChecked: agreementProvider.thirdPartyAgreed,
                            onChanged:
                                (value) => agreementProvider
                                    .setThirdPartyAgreement(value),
                          ),
                          // 위치 기반 서비스 이용약관 동의
                          AgreementItem(
                            title: '위치 기반 서비스 이용약관 동의',
                            isChecked: agreementProvider.locationAgreed,
                            onChanged:
                                (value) => agreementProvider
                                    .setLocationAgreement(value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // 다음 버튼
                  NextButton(
                    isEnabled: agreementProvider.isAllRequiredAgreed,
                    onPressed: () {
                      // 다음 화면으로 Navigator.push 등을 사용하여 이동할 수 있습니다.
                    
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
