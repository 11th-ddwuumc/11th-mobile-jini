import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../core/storage/token_storage.dart';
import '../core/network/api_error.dart';

import '../data/models/login_models.dart';
import '../data/models/member_info.dart';
import '../data/services/auth_api_service.dart';
import '../data/services/member_api_service.dart';

enum AuthStatus {
  initializing,
  signedOut,
  authenticating,
  signedIn,
  retryRequired,
}

enum MemberLoadStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authApi, this._memberApi, this._storage);

  final AuthApiService _authApi;
  final MemberApiService _memberApi;
  final TokenStorage _storage;

  AuthStatus status = AuthStatus.initializing;
  MemberLoadStatus memberStatus = MemberLoadStatus.idle;

  MemberInfo? member;
  String? message;

  int _sessionVersion = 0;
  int get sessionVersion => _sessionVersion;

  bool sessionExpired = false;
  bool storageCleanupInProgress = false;
  bool _disposed = false;

  Future<void>? _tokenWrite;

  bool _isCurrent(int version) {
    return !_disposed && version == _sessionVersion;
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // 5번: 앱 재실행 시 저장된 토큰 확인
  Future<void> restoreSession() async {
    if (storageCleanupInProgress || _disposed) return;

    final version = ++_sessionVersion;

    status = AuthStatus.initializing;
    message = null;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    _notify();

    try {
      final token = await _storage.readAccessToken();

      if (!_isCurrent(version)) return;

      if (token == null || token.isEmpty) {
        status = AuthStatus.signedOut;
      } else {
        final verifiedMember = await _memberApi.fetchMe();

        if (!_isCurrent(version)) return;

        member = verifiedMember;
        memberStatus = MemberLoadStatus.success;
        status = AuthStatus.signedIn;
      }
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;

      final code = apiErrorCode(error);

      if (code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4') {
        await _clearCurrentSession(expired: true);
        return;
      }

      status = AuthStatus.retryRequired;
      message = '로그인 상태를 확인하지 못했어요. 다시 시도해 주세요.';
    } catch (_) {
      if (!_isCurrent(version)) return;

      status = AuthStatus.retryRequired;
      message = '인증 저장소를 읽지 못했어요. 다시 시도해 주세요.';
    }

    if (_isCurrent(version)) {
      _notify();
    }
  }

  // 6번: 로그인 요청 및 JWT 저장
  Future<void> login(String email, String password) async {
    if (_disposed ||
        storageCleanupInProgress ||
        status == AuthStatus.authenticating) {
      return;
    }

    status = AuthStatus.authenticating;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    sessionExpired = false;
    message = null;

    final version = ++_sessionVersion;
    _notify();

    try {
      final result = await _authApi.login(
        LoginRequest(email: email, password: password),
      );

      if (!_isCurrent(version)) return;

      final writing = _storage.saveAccessToken(result.accessToken);
      _tokenWrite = writing;

      try {
        await writing;
      } finally {
        if (identical(_tokenWrite, writing)) {
          _tokenWrite = null;
        }
      }

      if (!_isCurrent(version)) return;

      status = AuthStatus.signedIn;
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;

      status = AuthStatus.signedOut;

      message = '이메일 또는 비밀번호를 확인해 주세요.';
    } catch (_) {
      if (!_isCurrent(version)) return;

      status = AuthStatus.signedOut;
      message = '로그인 정보를 안전하게 저장하지 못했어요.';
    }

    _notify();
  }

  // 로그인 직후 MainScreen에서 내 정보 조회
  Future<void> loadMember({bool force = false}) async {
    if (status != AuthStatus.signedIn) return;
    if (memberStatus == MemberLoadStatus.loading) return;
    if (member != null && !force) return;

    final version = _sessionVersion;

    memberStatus = MemberLoadStatus.loading;
    _notify();

    try {
      final me = await _memberApi.fetchMe();

      if (!_isCurrent(version)) return;

      member = me;
      memberStatus = MemberLoadStatus.success;
      message = null;
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;

      final code = apiErrorCode(error);

      if (code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4') {
        await _clearCurrentSession(expired: true);
        return;
      }

      memberStatus = MemberLoadStatus.error;
      message = '내 정보를 불러오지 못했어요.';
    } catch (_) {
      if (!_isCurrent(version)) return;

      memberStatus = MemberLoadStatus.error;
      message = '내 정보를 불러오지 못했어요.';
    }

    _notify();
  }

  // 프로필 수정 성공 시 최신 회원 정보 반영
  void updateMember(MemberInfo updated) {
    if (_disposed || status != AuthStatus.signedIn) return;

    member = updated;
    notifyListeners();
  }

  // 다른 화면에서 인증 만료 처리를 요청할 때 사용
  Future<void> expireSession() {
    return _clearCurrentSession(expired: true);
  }

  Future<void> logout() => _clearCurrentSession(expired: false);

  // 토큰 만료 또는 로그아웃 시 현재 세션 정리
  Future<void> _clearCurrentSession({bool expired = true}) async {
    if (_disposed || storageCleanupInProgress) return;

    final version = ++_sessionVersion;

    storageCleanupInProgress = true;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    sessionExpired = expired;
    status = AuthStatus.signedOut;
    message = null;

    _notify();

    try {
      try {
        await _tokenWrite;
      } catch (_) {
        // 토큰 저장 실패 여부와 관계없이 삭제를 시도
      }

      await _storage.deleteAccessToken();
    } catch (_) {
      if (_isCurrent(version)) {
        message = '저장된 인증 정보를 지우지 못했어요.';
      }
    } finally {
      storageCleanupInProgress = false;

      if (_isCurrent(version)) {
        _notify();
      }
    }
  }

  void consumeSessionExpired() {
    sessionExpired = false;
  }

  @override
  void dispose() {
    _disposed = true;
    _sessionVersion++;
    super.dispose();
  }
}
