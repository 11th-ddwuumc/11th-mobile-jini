import 'package:flutter/material.dart';

import 'CommonAppBar.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: '내 프로필'),
      body: const ProfileBody(),
    );
  }
}

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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

          const FavoriteGenres(),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
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

        const Text('무비러버', style: AppTextStyles.titleMedium),

        const SizedBox(height: 4),

        const Text(
          '매주 주말에 영화관으로 출근하는 프로 관람객. 좋은\n'
          '영화를 보고 기록하는 것을 좋아합니다.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
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
        StatItem(label: '본 영화', value: '342'),
        SizedBox(width: 6),
        StatItem(label: '평점', value: '4.2'),
        SizedBox(width: 6),
        StatItem(label: '즐겨찾기', value: '58'),
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
      width: 99,
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
      onPressed: () {},
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
