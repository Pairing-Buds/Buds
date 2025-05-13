// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:buds/config/theme.dart';
import 'package:buds/models/user_model.dart';
import 'package:buds/screens/character/character_select_screen.dart';
import 'package:buds/services/auth_service.dart';
import 'login_screen.dart';
import 'widgets/signup_form_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 텍스트 필드 컨트롤러
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  // 폼 키
  final _formKey = GlobalKey<FormState>();

  // 인증 서비스
  final _authService = DioAuthService();

  // 로딩 상태
  bool _isLoading = false;

  // 비밀번호 표시 여부 상태
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // 이메일 인증 관련 상태 변수 및 컨트롤러
  final TextEditingController _emailTokenController = TextEditingController();
  bool _isEmailRequested = false;
  bool _isEmailVerified = false;
  String? _emailAuthMsg;

  // 이메일 입력값이 유효한지 체크
  bool get _isEmailValid => RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  ).hasMatch(_emailController.text.trim());

  // 이메일 입력값 변경 시 setState
  void _onEmailChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // 한국어 로케일 초기화
    initializeDateFormatting('ko_KR', null);
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthDateController.dispose();
    _emailTokenController.dispose();
    super.dispose();
  }

  // 생년월일 선택 다이얼로그
  Future<void> _selectDate(BuildContext context) async {
    // 한국어 로케일 초기화 확인
    debugPrint('날짜 선택 다이얼로그 시작');
    try {
      await initializeDateFormatting('ko_KR', null);
      debugPrint('한국어 로케일 초기화 완료');

      final DateTime? picked = await DatePickerUtil.showBirthDatePicker(
        context,
      );
      debugPrint('선택된 날짜: $picked');

      if (picked != null) {
        setState(() {
          // yyyy-MM-dd 형식으로 저장
          _birthDateController.text = DatePickerUtil.formatDate(picked);
          debugPrint('설정된 생년월일: ${_birthDateController.text}');
        });
      }
    } catch (e) {
      debugPrint('날짜 선택 다이얼로그 오류: $e');
      // 오류 발생 시 기본 형식으로 시도
      try {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          helpText: '생년월일을 선택해주세요',
          cancelText: '취소',
          confirmText: '선택',
          // locale 매개변수 제거
        );

        debugPrint('기본 다이얼로그 선택된 날짜: $picked');

        if (picked != null) {
          setState(() {
            _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
            debugPrint('기본 다이얼로그로 설정된 생년월일: ${_birthDateController.text}');
          });
        }
      } catch (fallbackError) {
        debugPrint('기본 날짜 다이얼로그도 실패: $fallbackError');
      }
    }
  }

  // 회원가입 폼 제출
  void _submitForm() async {
    debugPrint('회원가입 폼 제출 시작');
    if (_formKey.currentState!.validate()) {
      debugPrint('폼 유효성 검사 통과');
      setState(() {
        _isLoading = true;
      });

      try {
        debugPrint('이메일, 비밀번호 유효성 확인 완료');
        debugPrint('캐릭터 선택 화면으로 이동');

        if (!mounted) return;

        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입이 완료되었습니다. 로그인해주세요.'),
            backgroundColor: AppColors.primary,
          ),
        );

        // 회원 가입 처리 (나중에 로그인 시 캐릭터 선택으로 넘어감)
        await _authService.register(
          '', // 이름은 비워두고
          _emailController.text,
          _passwordController.text,
          birthDate: _birthDateController.text,
        );

        // 로그인 화면으로 이동
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } catch (e) {
        debugPrint('회원가입 실패 오류: $e');
        // 오류 메시지 표시
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        debugPrint('회원가입 프로세스 종료');
      }
    } else {
      debugPrint('폼 유효성 검사 실패');
    }
  }

  // 이메일 인증 요청 함수
  Future<void> _requestEmailVerification() async {
    setState(() {
      _emailAuthMsg = null;
    });
    try {
      final result = await _authService.requestEmailVerification(
        _emailController.text.trim(),
      );
      setState(() {
        _isEmailRequested = result;
        _emailAuthMsg = result ? '이메일로 인증 토큰이 발송되었습니다.' : '이메일 인증 요청에 실패했습니다.';
      });
    } catch (e) {
      setState(() {
        _emailAuthMsg = '이메일 인증 요청 중 오류가 발생했습니다.';
      });
    }
  }

  // 이메일 토큰 인증 함수
  Future<void> _verifyEmailToken() async {
    setState(() {
      _emailAuthMsg = null;
    });
    try {
      final result = await _authService.verifyEmailToken(
        _emailTokenController.text.trim(),
      );
      setState(() {
        _isEmailVerified = result;
        _emailAuthMsg = result ? '이메일 인증이 완료되었습니다.' : '토큰 인증에 실패했습니다.';
      });
    } catch (e) {
      setState(() {
        _emailAuthMsg = '토큰 인증 중 오류가 발생했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('회원 가입', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                SignupForm(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  birthDateController: _birthDateController,
                  obscurePassword: _obscurePassword,
                  obscureConfirmPassword: _obscureConfirmPassword,
                  isLoading: _isLoading,
                  onSelectDate: _selectDate,
                  onTogglePassword:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                  onToggleConfirmPassword:
                      () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                  onSubmit: _submitForm,
                  emailSuffixIcon:
                      (_isEmailVerified || !_isEmailValid)
                          ? null
                          : SizedBox(
                            width: 90,
                            height: 36,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed:
                                  _isEmailValid && !_isEmailVerified
                                      ? _requestEmailVerification
                                      : null,
                              child: const Text(
                                '인증하기',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                  showEmailTokenField: _isEmailRequested && !_isEmailVerified,
                  emailTokenController: _emailTokenController,
                  onVerifyToken: _verifyEmailToken,
                  emailAuthMsg: _emailAuthMsg,
                  isEmailVerified: _isEmailVerified,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
