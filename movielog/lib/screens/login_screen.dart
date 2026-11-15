import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../view_models/auth_view_model.dart';

import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AuthViewModel _auth;

  static const Color _backgroundColor = Color(0xFFFBF9F5);
  static const Color _primaryColor = Color(0xFF6950A5);
  static const Color _borderColor = Color(0xFFE4E0E8);

  @override
  void initState() {
    super.initState();

    _auth = context.read<AuthViewModel>();
    _auth.addListener(_showSessionExpired);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSessionExpired();
    });
  }

  void _showSessionExpired() {
    if (!mounted || !_auth.sessionExpired) return;

    _auth.consumeSessionExpired();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('로그인이 만료됐어요. 다시 로그인해 주세요.')));
  }

  @override
  void dispose() {
    _auth.removeListener(_showSessionExpired);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    await _auth.login(_emailController.text.trim(), _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    final isLoading = auth.status == AuthStatus.authenticating;
    final enabled = !isLoading && !auth.storageCleanupInProgress;

    final loginFailed =
        auth.status == AuthStatus.signedOut && auth.message != null;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),

                          const Text(
                            '로그인',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: _primaryColor,
                            ),
                          ),

                          const SizedBox(height: 104),

                          SvgPicture.asset(
                            'assets/logos/movielog_logo.svg',
                            width: 72,
                            height: 72,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'MovieLog에 로그인',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF29252F),
                            ),
                          ),

                          const SizedBox(height: 32),

                          const Text(
                            '이메일',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF77717C),
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _emailController,
                            enabled: enabled,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              hintText: 'movie@example.com',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '이메일을 입력해 주세요.';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            '비밀번호',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF77717C),
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _passwordController,
                            enabled: enabled,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              if (enabled) _login();
                            },
                            decoration: _inputDecoration(
                              hintText: '비밀번호를 입력해 주세요.',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '비밀번호를 입력해 주세요.';
                              }
                              return null;
                            },
                          ),

                          if (loginFailed) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                auth.message ?? '이메일 또는 비밀번호를 확인해 주세요.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ],

                          const Spacer(),

                          const SizedBox(height: 32),

                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: enabled ? _login : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                disabledBackgroundColor: const Color(
                                  0xFF817D84,
                                ),
                                foregroundColor: Colors.white,
                                disabledForegroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      '로그인',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '계정이 없나요? ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF77717C),
                                ),
                              ),
                              GestureDetector(
                                onTap: enabled
                                    ? () => context.push('/signup')
                                    : null,
                                child: const Text(
                                  '회원가입',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
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

  InputDecoration _inputDecoration({
    required String hintText,
    String? errorText,
    bool hasError = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      errorText: errorText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _primaryColor, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.3),
      ),
    );
  }
}
