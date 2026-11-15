import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../view_models/auth_view_model.dart';
import '../view_models/edit_profile_view_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    final member = context.read<AuthViewModel>().member;
    _controller = TextEditingController(text: member?.nickname ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final viewModel = context.read<EditProfileViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final success = await viewModel.save(_controller.text);

    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(const SnackBar(content: Text('프로필을 수정했어요.')));

      router.pop();
    } else if (viewModel.message != null) {
      messenger.showSnackBar(SnackBar(content: Text(viewModel.message!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = context.select<AuthViewModel, String?>(
      (auth) => auth.member?.email,
    );

    return Consumer<EditProfileViewModel>(
      builder: (context, viewModel, child) {
        final saving = viewModel.status == EditProfileStatus.saving;

        return PopScope(
          canPop: !saving,
          child: Scaffold(
            backgroundColor: const Color(0xFFFBF9F5),
            appBar: AppBar(
              backgroundColor: const Color(0xFFFBF9F5),
              centerTitle: true,
              title: const Text(
                '프로필 수정',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  const Text(
                    '이메일 (변경할 수 없습니다)',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    initialValue: email ?? '',
                    enabled: false,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFEDEAF0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text('닉네임', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),

                  TextField(
                    controller: _controller,
                    enabled: !saving,
                    maxLength: 12,
                    onChanged: (_) {
                      setState(() {});

                      if (viewModel.nicknameError != null) {
                        viewModel.nicknameError = null;
                      }
                    },
                    decoration: InputDecoration(
                      errorText: viewModel.nicknameError,
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_controller.text.length}/12',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6950A5),
                        disabledBackgroundColor: const Color(0xFF817D84),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('저장'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
