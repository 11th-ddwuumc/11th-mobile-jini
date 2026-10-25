import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _nicknameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isAgreed = false;

  bool get _isFormValid {
    final nickname = _nicknameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    return nickname.length >= 2 &&
        emailRegex.hasMatch(email) &&
        password.length >= 8 &&
        _isAgreed;
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid || !_isAgreed) {
      return;
    }

    debugPrint('회원가입 완료');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    _nicknameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6750A4),
            fontFamily: 'Manrope',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            final formWidth = isWide ? 560.0 : constraints.maxWidth - 48;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Align(
                alignment: isWide ? Alignment.topCenter : Alignment.topLeft,
                child: SizedBox(
                  width: formWidth,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SignupIntro(),
                        const SizedBox(height: 32),
                        SignupFormFields(
                          nicknameController: _nicknameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          nicknameFocusNode: _nicknameFocusNode,
                          emailFocusNode: _emailFocusNode,
                          passwordFocusNode: _passwordFocusNode,
                          onChanged: () {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 120),
                        TermsAgreement(
                          isAgreed: _isAgreed,
                          onChanged: (value) {
                            setState(() {
                              _isAgreed = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        SignupActions(
                          isFormValid: _isFormValid,
                          onSubmit: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SignupIntro extends StatelessWidget {
  const SignupIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          Text(
            '환영합니다!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            '간단한 정보만 입력하고 시작해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class SignupFormFields extends StatefulWidget {
  const SignupFormFields({
    super.key,
    required this.nicknameController,
    required this.emailController,
    required this.passwordController,
    required this.nicknameFocusNode,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.onChanged,
  });

  final TextEditingController nicknameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode nicknameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final VoidCallback onChanged;

  @override
  State<SignupFormFields> createState() => _SignupFormFieldsState();
}

class _SignupFormFieldsState extends State<SignupFormFields> {
  bool _nicknameTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;

  String? _validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '닉네임을 입력해주세요.';
    }

    if (value.trim().length < 2) {
      return '닉네임은 2자 이상이어야 합니다.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이메일을 입력해주세요.';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return '올바른 이메일 형식을 입력해주세요.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }

    if (value.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다.';
    }

    return null;
  }

  Widget _buildStatusIcon({required bool isError}) {
    const purple = Color(0xFF6750A4);
    const errorRed = Color(0xFFD32F2F);

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isError ? Colors.transparent : purple,
        border: Border.all(color: isError ? errorRed : purple, width: 2),
      ),
      child: Center(
        child: Text(
          isError ? '!' : '✓',
          style: TextStyle(
            color: isError ? errorRed : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText, {required bool isError}) {
    const purple = Color(0xFF6750A4);
    const lightPurple = Color(0xFFD8CFE8);
    const errorRed = Color(0xFFD32F2F);

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF7A7582),
        fontWeight: FontWeight.bold,
      ),
      filled: true,
      fillColor: isError ? const Color(0xFFFFF1F1) : const Color(0xFFF7F5F8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      errorStyle: const TextStyle(
        color: errorRed,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightPurple),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: isError ? errorRed : lightPurple),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: isError ? errorRed : purple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorRed, width: 1.5),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String? errorText,
    required bool valid,
    required ValueChanged<String> onChanged,
    required TextInputAction textInputAction,
    required VoidCallback onSubmitted,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    final showStatus = errorText != null || valid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            TextFormField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              obscureText: obscureText,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: _inputDecoration(
                hintText,
                isError: errorText != null,
              ),
              validator: (value) {
                return errorText;
              },
              onChanged: onChanged,
              onFieldSubmitted: (_) {
                onSubmitted();
              },
            ),
            if (showStatus)
              Positioned(
                right: 12,
                top: 0,
                bottom: errorText != null ? 24 : 0,
                child: Center(
                  child: _buildStatusIcon(isError: errorText != null),
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final nicknameError = _nicknameTouched
        ? _validateNickname(widget.nicknameController.text)
        : null;

    final emailError = _emailTouched
        ? _validateEmail(widget.emailController.text)
        : null;

    final passwordError = _passwordTouched
        ? _validatePassword(widget.passwordController.text)
        : null;

    final nicknameValid = _nicknameTouched && nicknameError == null;

    final emailValid = _emailTouched && emailError == null;

    final passwordValid = _passwordTouched && passwordError == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField(
          label: '닉네임',
          hintText: '닉네임을 입력해주세요',
          controller: widget.nicknameController,
          focusNode: widget.nicknameFocusNode,
          errorText: nicknameError,
          valid: nicknameValid,
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            setState(() {
              _nicknameTouched = true;
            });
            widget.onChanged();
          },
          onSubmitted: () {
            widget.emailFocusNode.requestFocus();
          },
        ),
        const SizedBox(height: 20),
        _buildField(
          label: '이메일',
          hintText: '이메일을 입력해주세요',
          controller: widget.emailController,
          focusNode: widget.emailFocusNode,
          errorText: emailError,
          valid: emailValid,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            setState(() {
              _emailTouched = true;
            });
            widget.onChanged();
          },
          onSubmitted: () {
            widget.passwordFocusNode.requestFocus();
          },
        ),
        const SizedBox(height: 20),
        _buildField(
          label: '비밀번호',
          hintText: '비밀번호를 입력해주세요',
          controller: widget.passwordController,
          focusNode: widget.passwordFocusNode,
          errorText: passwordError,
          valid: passwordValid,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            setState(() {
              _passwordTouched = true;
            });
            widget.onChanged();
          },
          onSubmitted: () {
            FocusScope.of(context).unfocus();
          },
        ),
      ],
    );
  }
}

class TermsAgreement extends StatelessWidget {
  const TermsAgreement({
    super.key,
    required this.isAgreed,
    required this.onChanged,
  });

  final bool isAgreed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isAgreed,
          activeColor: const Color(0xFF6750A4),
          onChanged: (value) {
            onChanged(value ?? false);
          },
        ),
        const Expanded(
          child: Text(
            '필수 약관에 동의합니다',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class SignupActions extends StatelessWidget {
  const SignupActions({
    super.key,
    required this.isFormValid,
    required this.onSubmit,
  });

  final bool isFormValid;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isFormValid ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isFormValid
                  ? const Color(0xFF6750A4)
                  : const Color(0xFFD9D5DE),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFD9D5DE),
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '가입하기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '이미 계정이 있나요?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6750A4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
