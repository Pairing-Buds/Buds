import 'package:flutter/material.dart';
import 'package:buds/config/theme.dart';
import 'package:buds/screens/character/character_select_screen.dart';
import 'package:buds/services/dio_auth_service.dart';
import 'package:buds/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    // 한국어 로케일 초기화
    initializeDateFormatting('ko_KR', null);
  }

  // 컨트롤러 해제
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  // 생년월일 선택 다이얼로그
  Future<void> _selectDate(BuildContext context) async {
    // 한국어 로케일 초기화 확인
    debugPrint('날짜 선택 다이얼로그 시작');
    try {
      await initializeDateFormatting('ko_KR', null);
      debugPrint('한국어 로케일 초기화 완료');

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().subtract(
          const Duration(days: 365 * 20),
        ), // 기본값 20살
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        helpText: '생년월일을 선택해주세요',
        cancelText: '취소',
        confirmText: '선택',
        locale: const Locale('ko', 'KR'),
      );
      debugPrint('선택된 날짜: $picked');

      if (picked != null) {
        setState(() {
          // yyyy-MM-dd 형식으로 저장
          _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'BUDS와 함께 대화해봐요!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),

                  // 이메일 입력 필드
                  _buildInputLabel('이메일'),
                  _buildEmailField(),
                  const SizedBox(height: 24),

                  // 생년월일 입력 필드
                  _buildInputLabel('생년월일'),
                  _buildBirthDateField(),
                  const SizedBox(height: 24),

                  // 비밀번호 입력 필드
                  _buildInputLabel('비밀번호'),
                  _buildPasswordField(),
                  const SizedBox(height: 24),

                  // 비밀번호 확인 필드
                  _buildInputLabel('비밀번호 확인'),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 40),

                  // 회원가입 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                '회원가입',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 입력 필드 라벨 위젯
  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  // 이메일 입력 필드
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: '이메일을 입력해주세요',
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '이메일을 입력해주세요';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return '올바른 이메일 형식이 아닙니다';
        }
        return null;
      },
    );
  }

  // 생년월일 입력 필드
  Widget _buildBirthDateField() {
    return TextFormField(
      controller: _birthDateController,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        hintText: '생년월일을 선택해주세요',
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '생년월일을 선택해주세요';
        }
        return null;
      },
    );
  }

  // 비밀번호 입력 필드
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: '비밀번호를 입력해주세요',
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '비밀번호를 입력해주세요';
        }
        if (value.length < 8) {
          return '비밀번호는 8자 이상이어야 합니다';
        }
        return null;
      },
    );
  }

  // 비밀번호 확인 필드
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        hintText: '비밀번호를 다시 입력해주세요',
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '비밀번호를 다시 입력해주세요';
        }
        if (value != _passwordController.text) {
          return '비밀번호가 일치하지 않습니다';
        }
        return null;
      },
    );
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
        debugPrint('회원가입 API 호출 시작');
        debugPrint(
          '요청 데이터: 이메일=${_emailController.text}, 생년월일=${_birthDateController.text}',
        );

        // 회원가입 API 호출
        final user = await _authService.register(
          '', // name 파라미터는 API에서 사용하지 않음
          _emailController.text,
          _passwordController.text,
          birthDate: _birthDateController.text,
        );

        debugPrint('회원가입 API 응답: $user');

        if (!mounted) return;

        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입이 완료되었습니다.'),
            backgroundColor: AppColors.primary,
          ),
        );

        debugPrint('캐릭터 선택 화면으로 이동');

        // 회원가입 후 바로 로그인 시도
        try {
          debugPrint('자동 로그인 시도');
          await _authService.login(
            _emailController.text,
            _passwordController.text,
          );
          debugPrint('자동 로그인 성공');
        } catch (loginError) {
          debugPrint('자동 로그인 실패: $loginError');
          // 로그인 실패해도 계속 진행 (사용자는 나중에 로그인 가능)
        }

        // 캐릭터 선택 화면으로 이동
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CharacterSelectScreen(),
          ),
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
}
