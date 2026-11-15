import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'model/movie.dart';
import 'model/tmdb_movie_dto.dart';
import 'provider/popular_movie_provider.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PopularMovieProvider>().loadPopular();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recommendedMovie = movies[0];

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        backgroundColor: AppColors.warmWhite,
        elevation: 0,
        title: const Text('MovieLog', style: AppTextStyles.movieLog),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                '오늘은 어떤\n영화를 볼까요?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 24),
              _buildRecommendedMovie(context, recommendedMovie),
              const SizedBox(height: 36),
              _buildPopularMovies(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedMovie(BuildContext context, Movie movie) {
    return GestureDetector(
      onTap: () {
        context.push('/movies/${movie.id}');
      },
      child: SizedBox(
        width: 356,
        height: 534,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(movie.posterAsset, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
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
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${movie.genre} · ${movie.year}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push('/movies/${movie.id}');
                        },
                        icon: const Icon(Icons.info_outline),
                        label: const Text('상세 보기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.violet,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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
      ),
    );
  }

  Widget _buildPopularMovies() {
    return Consumer<PopularMovieProvider>(
      builder: (context, provider, child) {
        Widget content;

        if (provider.isLoading) {
          content = const SizedBox(
            height: 270,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (provider.hasError) {
          content = SizedBox(
            height: 270,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('인기 영화를 불러오지 못했어요.'),
                  TextButton(
                    onPressed: provider.retry,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
        } else if (provider.movies.isEmpty) {
          content = const SizedBox(
            height: 270,
            child: Center(child: Text('표시할 인기 영화가 없습니다.')),
          );
        } else {
          content = SizedBox(
            height: 270,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.movies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _buildPopularMovie(context, provider.movies[index]);
              },
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  child: const Text(
                    '전체보기 >',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        );
      },
    );
  }

  Widget _buildPopularMovie(BuildContext context, TmdbMovieDto movie) {
    final posterPath = movie.posterPath;
    final posterUrl = posterPath == null || posterPath.isEmpty
        ? null
        : 'https://image.tmdb.org/t/p/w500$posterPath';

    return GestureDetector(
      onTap: () {
        context.push('/movies/${movie.id}');
      },
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 150,
                height: 200,
                child: posterUrl == null
                    ? _buildPosterPlaceholder()
                    : Image.network(
                        posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return _buildPosterPlaceholder();
                        },
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title.isEmpty ? '제목 없음' : movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  movie.voteAverage.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 14, color: AppColors.gray),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterPlaceholder() {
    return Container(
      color: AppColors.gray.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_outlined, size: 36, color: AppColors.gray),
          SizedBox(height: 8),
          Text('포스터 없음', style: TextStyle(color: AppColors.gray)),
        ],
      ),
    );
  }
}
