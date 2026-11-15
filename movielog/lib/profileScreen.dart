import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'CommonAppBar.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'view_models/auth_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('로그아웃하시겠어요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                '로그아웃',
                style: TextStyle(color: AppColors.violet),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) return;

    await context.read<AuthViewModel>().logout();

    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: CommonAppBar(
        title: '내 프로필',
        actions: [
          TextButton(
            onPressed: () => _logout(context),
            child: const Text(
              '로그아웃',
              style: TextStyle(color: AppColors.violet, fontSize: 12),
            ),
          ),
        ],
      ),
      body: const ProfileBody(),
    );
  }
}

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final member = auth.member;

    if (member == null) {
      return Center(
        child: auth.memberStatus == MemberLoadStatus.error
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('내 정보를 불러오지 못했어요.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      auth.loadMember(force: true);
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              const ProfileHeader(),

              const SizedBox(height: 20),

              const EditProfileButton(),

              const SizedBox(height: 24),

              const ProfileStats(),

              const SizedBox(height: 24),

              InkWell(
                onTap: () {
                  context.push('/my/ratings');
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightViolet),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('내가 등록한 평점', style: AppTextStyles.bodyMedium),
                      const Icon(Icons.chevron_right, color: AppColors.violet),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const FavoriteGenres(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final member = context.watch<AuthViewModel>().member;

    final createdAt = member?.createdAt;
    final formattedDate = createdAt == null
        ? ''
        : '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.'
              '${createdAt.day.toString().padLeft(2, '0')} 가입';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 112,
          height: 112,
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: AppColors.violet,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile_movielog.jpg',
              width: 108,
              height: 108,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Text(member?.nickname ?? '회원', style: AppTextStyles.titleMedium),

        const SizedBox(height: 6),

        Text(formattedDate, style: AppTextStyles.bodySmall),

        const SizedBox(height: 4),

        Text(member?.email ?? '', style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Expanded(
          child: StatItem(label: '본 영화', value: '342'),
        ),
        SizedBox(width: 6),
        Expanded(
          child: StatItem(label: '평점', value: '4.2'),
        ),
        SizedBox(width: 6),
        Expanded(
          child: StatItem(label: '즐겨찾기', value: '58'),
        ),
      ],
    );
  }
}

class StatItem extends StatelessWidget {
  const StatItem({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.lightViolet),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.violet,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class FavoriteGenres extends StatelessWidget {
  const FavoriteGenres({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '선호하는 장르',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            GenreChip(label: '드라마'),
            SizedBox(width: 8),
            GenreChip(label: 'SF'),
            SizedBox(width: 8),
            GenreChip(label: '애니메이션'),
          ],
        ),
      ],
    );
  }
}

class GenreChip extends StatelessWidget {
  const GenreChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.violet),
      ),
      backgroundColor: AppColors.lightViolet,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.push('/my/profile/edit');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.warmWhite,
        foregroundColor: AppColors.violet,
        elevation: 0,
        side: const BorderSide(color: AppColors.violet),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        '프로필 수정',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
