import 'package:dio/dio.dart';

import '../data/models/member_info.dart';

class MemberApiService {
  MemberApiService(this._authDio);

  final Dio _authDio;

  // 내 정보 조회
  Future<MemberInfo> fetchMe() async {
    final response = await _authDio.get('/v7/members/me');
    return parseMemberInfo(response.data);
  }

  // 닉네임 수정
  Future<MemberInfo> updateNickname(String nickname) async {
    final response = await _authDio.patch(
      '/v7/members/me',
      data: {'nickname': nickname},
    );

    return parseMemberInfo(response.data);
  }
}
