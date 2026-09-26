import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        backgroundColor: AppColors.warmWhite,
        elevation: 0,
        title: const Text('MovieLog', style: AppTextStyles.movieLog),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Color(0xFF4F378A)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            const Text(
              '오늘은 어떤\n영화를 볼까요?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),

            const SizedBox(height: 24),

            _buildRecommendedMovie(),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '인기 영화',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '전체보기',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.violet,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.violet),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            _buildPopularMovies(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedMovie() {
    return SizedBox(
      width: 356,
      height: 534,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/hero_under_the_starlight.jpg',
                fit: BoxFit.cover,
              ),
            ),

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.violet,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '추천 신작',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    '별빛 아래 우리',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    '로맨스 · 드라마 · 120분',
                    style: TextStyle(fontSize: 14, color: AppColors.white),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text(
                        '상세보기',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.violet,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularMovies() {
    return SizedBox(
      height: 230,
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
          },
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildPopularMovie(
              image: 'assets/images/poster_abyss_walker.jpg',
              title: '어비스 워커',
              rating: '9.6',
            ),
            _buildPopularMovie(
              image: 'assets/images/poster_echoes_of_the_void.jpg',
              title: '공허의 메아리',
              rating: '9.2',
            ),
            _buildPopularMovie(
              image: 'assets/images/poster_fourth_afternoon.jpg',
              title: '네 번째 오후',
              rating: '8.9',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularMovie({
    required String image,
    required String title,
    required String rating,
  }) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              image,
              width: 120,
              height: 170,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 3),
              Text(rating, style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
