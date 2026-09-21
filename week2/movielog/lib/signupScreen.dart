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

    // 회원가입 처리
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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

                SignupActions(isEnabled: _isFormValid, onSignup: _submit),
              ],
            ),
          ),
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

class SignupFormFields extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '닉네임',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        TextFormField(
          controller: nicknameController,
          focusNode: nicknameFocusNode,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            emailFocusNode.requestFocus();
          },
          decoration: _inputDecoration('닉네임을 입력해주세요'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '닉네임을 입력해주세요.';
            }

            if (value.length < 2) {
              return '닉네임은 2자 이상이어야 합니다.';
            }

            return null;
          },
          onChanged: (_) {
            onChanged();
          },
        ),

        const SizedBox(height: 20),

        const Text(
          '이메일',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        TextFormField(
          controller: emailController,
          focusNode: emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            passwordFocusNode.requestFocus();
          },
          decoration: _inputDecoration('이메일을 입력해주세요'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '이메일을 입력해주세요.';
            }

            final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

            if (!emailRegex.hasMatch(value)) {
              return '올바른 이메일 형식을 입력해주세요.';
            }

            return null;
          },
          onChanged: (_) {
            onChanged();
          },
        ),

        const SizedBox(height: 20),

        const Text(
          '비밀번호',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        TextFormField(
          controller: passwordController,
          focusNode: passwordFocusNode,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            FocusScope.of(context).unfocus();
          },
          obscureText: true,
          decoration: _inputDecoration('비밀번호를 입력해주세요'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '비밀번호를 입력해주세요.';
            }

            if (value.length < 8) {
              return '비밀번호는 8자 이상이어야 합니다.';
            }

            return null;
          },
          onChanged: (_) {
            onChanged();
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF7A7582),
        fontWeight: FontWeight.bold,
      ),
      filled: true,
      fillColor: const Color(0xFFF7F5F8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD8CFE8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD8CFE8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF6750A4)),
      ),
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
    required this.isEnabled,
    required this.onSignup,
  });

  final bool isEnabled;
  final VoidCallback onSignup;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isEnabled ? onSignup : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled
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

        Row(
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
      ],
    );
  }
}
