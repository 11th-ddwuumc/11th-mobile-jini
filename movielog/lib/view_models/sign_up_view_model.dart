import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../data/services/sign_up_service.dart';
import '../data/models/create_member_request.dart';

import 'learning_member_session.dart';

// 중복 확인 상태
enum CheckStatus { idle, checking, available, duplicated, error }

// 회원가입 제출 상태
enum SubmitStatus { idle, submitting, success, error }

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._service, this._session);

  final SignUpService _service;
  final LearningMemberSession _session;

  // 닉네임 중복 확인
  CheckStatus nicknameCheckStatus = CheckStatus.idle;
  String? nicknameErrorText;
  String? _duplicatedNickname;
  String _currentNickname = '';
  int _requestVersion = 0;

  // 이메일 중복 확인
  CheckStatus emailCheckStatus = CheckStatus.idle;
  String? emailErrorText;
  String? _duplicatedEmail;
  String _currentEmail = '';
  int _emailRequestVersion = 0;

  // 회원가입 제출
  SubmitStatus submitStatus = SubmitStatus.idle;
  int? createdMemberId;
  String? passwordErrorText;
  String? snackbarMessage;

  bool _disposed = false;

  // 두 중복 확인이 모두 통과해야 회원가입 가능
  bool get canSubmit =>
      nicknameCheckStatus == CheckStatus.available &&
      emailCheckStatus == CheckStatus.available &&
      submitStatus != SubmitStatus.submitting;

  bool get canCheckNickname =>
      nicknameCheckStatus != CheckStatus.checking &&
      nicknameCheckStatus != CheckStatus.duplicated;

  bool get canCheckEmail =>
      emailCheckStatus != CheckStatus.checking &&
      emailCheckStatus != CheckStatus.duplicated;

  // 닉네임 변경
  void onNicknameChanged(String value) {
    final trimmed = value.trim();
    _currentNickname = trimmed;
    _requestVersion++;

    // 입력이 바뀌면 이전 회원가입 서버 오류 무효화
    _clearSubmitErrors();

    if (_duplicatedNickname != null && trimmed == _duplicatedNickname) {
      nicknameCheckStatus = CheckStatus.duplicated;
      nicknameErrorText = '이미 사용 중인 닉네임입니다.';
    } else {
      nicknameCheckStatus = CheckStatus.idle;
      nicknameErrorText = null;
    }

    _notify();
  }

  // 이메일 변경
  void onEmailChanged(String value) {
    final trimmed = value.trim();
    _currentEmail = trimmed;
    _emailRequestVersion++;

    // 입력이 바뀌면 이전 회원가입 서버 오류 무효화
    _clearSubmitErrors();

    if (_duplicatedEmail != null && trimmed == _duplicatedEmail) {
      emailCheckStatus = CheckStatus.duplicated;
      emailErrorText = '이미 사용 중인 이메일입니다.';
    } else {
      emailCheckStatus = CheckStatus.idle;
      emailErrorText = null;
    }

    _notify();
  }

  // 비밀번호 변경
  void onPasswordChanged() {
    passwordErrorText = null;
    snackbarMessage = null;
    if (submitStatus == SubmitStatus.error) {
      submitStatus = SubmitStatus.idle;
    }
    _notify();
  }

  void _clearSubmitErrors() {
    passwordErrorText = null;
    snackbarMessage = null;
    if (submitStatus == SubmitStatus.error) {
      submitStatus = SubmitStatus.idle;
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // 닉네임 중복 확인
  Future<void> checkNickname(String value) async {
    final requested = value.trim();

    if (requested.isEmpty ||
        requested != _currentNickname ||
        !canCheckNickname) {
      return;
    }

    final version = ++_requestVersion;
    nicknameCheckStatus = CheckStatus.checking;
    nicknameErrorText = null;
    _notify();

    try {
      final available = await _service.checkNickname(requested);

      if (_disposed ||
          version != _requestVersion ||
          _currentNickname != requested) {
        return;
      }

      nicknameCheckStatus = available
          ? CheckStatus.available
          : CheckStatus.duplicated;
      nicknameErrorText = available ? null : '이미 사용 중인 닉네임입니다.';

      if (!available) _duplicatedNickname = requested;
    } on DioException {
      if (_disposed ||
          version != _requestVersion ||
          _currentNickname != requested) {
        return;
      }

      nicknameCheckStatus = CheckStatus.error;
      nicknameErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    } catch (_) {
      if (_disposed ||
          version != _requestVersion ||
          _currentNickname != requested) {
        return;
      }

      nicknameCheckStatus = CheckStatus.error;
      nicknameErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }

    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  // 이메일 중복 확인
  Future<void> checkEmail(String value) async {
    final requested = value.trim();

    if (requested.isEmpty || requested != _currentEmail || !canCheckEmail) {
      return;
    }

    final version = ++_emailRequestVersion;
    emailCheckStatus = CheckStatus.checking;
    emailErrorText = null;
    _notify();

    try {
      final available = await _service.checkEmail(requested);

      if (_disposed ||
          version != _emailRequestVersion ||
          _currentEmail != requested) {
        return;
      }

      emailCheckStatus = available
          ? CheckStatus.available
          : CheckStatus.duplicated;
      emailErrorText = available ? null : '이미 사용 중인 이메일입니다.';

      if (!available) _duplicatedEmail = requested;
    } on DioException {
      if (_disposed ||
          version != _emailRequestVersion ||
          _currentEmail != requested) {
        return;
      }

      emailCheckStatus = CheckStatus.error;
      emailErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    } catch (_) {
      if (_disposed ||
          version != _emailRequestVersion ||
          _currentEmail != requested) {
        return;
      }

      emailCheckStatus = CheckStatus.error;
      emailErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }

    if (!_disposed && version == _emailRequestVersion) notifyListeners();
  }

  // 회원가입 제출
  Future<void> submit(CreateMemberRequest request) async {
    if (submitStatus == SubmitStatus.submitting) return;

    // 버튼 UI와 별개로 ViewModel에서도 중복 확인 통과를 강제
    if (nicknameCheckStatus != CheckStatus.available ||
        emailCheckStatus != CheckStatus.available ||
        request.nickname.trim() != _currentNickname ||
        request.email.trim() != _currentEmail) {
      snackbarMessage = '닉네임과 이메일 중복 확인을 완료해 주세요.';
      submitStatus = SubmitStatus.error;
      _notify();
      return;
    }

    submitStatus = SubmitStatus.submitting;
    createdMemberId = null;
    passwordErrorText = null;
    snackbarMessage = null;
    _notify();

    try {
      final response = await _service.signUp(request);
      if (_disposed) return;

      final id = response.result?.memberId;
      if (id == null) {
        throw StateError('회원가입 결과에 memberId가 없습니다.');
      }

      createdMemberId = id;
      _session.setMemberId(id);
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_disposed) return;

      submitStatus = SubmitStatus.error;
      final message = writeSignUpErrorMessage(error);
      final statusCode = error.response?.statusCode;

      // 비밀번호 형식 오류로 확인된 400만 비밀번호 입력창에 표시
      if (statusCode == 400 && _isPasswordFormatError(message)) {
        passwordErrorText = message;
      } else {
        // 그 외 400, 409(중복) 및 기타 오류는 Snackbar로 표시
        snackbarMessage = message;
      }
    } on StateError catch (error) {
      if (_disposed) return;
      submitStatus = SubmitStatus.error;
      snackbarMessage = error.message;
    }

    _notify();
  }

  bool _isPasswordFormatError(String message) {
    final normalized = message.replaceAll(' ', '');
    return normalized.contains('비밀번호') &&
        (normalized.contains('대문자') ||
            normalized.contains('소문자') ||
            normalized.contains('특수문자') ||
            normalized.contains('8자이상'));
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    _emailRequestVersion++;
    super.dispose();
  }
}
