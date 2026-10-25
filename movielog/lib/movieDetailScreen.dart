import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import 'model/tmdb_movie_detail_dto.dart';
import 'service/tmdb_movie_service.dart';
import 'theme/app_colors.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final int? movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final TmdbMovieService _service = TmdbMovieService();

  late Future<TmdbMovieDetailDto> _movieFuture;
  bool isFavorite = false;
  double myRating = 0;

  @override
  void initState() {
    super.initState();
    _movieFuture = _loadMovie();
  }

  Future<TmdbMovieDetailDto> _loadMovie() {
    final id = widget.movieId;

    if (id == null) {
      return Future.error(Exception('잘못된 영화 ID입니다.'));
    }

    return _service.fetchMovieDetails(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        backgroundColor: AppColors.warmWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Cinema Archive',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.violet,
          ),
        ),
      ),
      body: FutureBuilder<TmdbMovieDetailDto>(
        future: _movieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('영화 정보를 불러오지 못했습니다.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _movieFuture = _loadMovie();
                      });
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final movie = snapshot.data!;
          final year =
              movie.releaseDate != null && movie.releaseDate!.length >= 4
              ? movie.releaseDate!.substring(0, 4)
              : '개봉일 미정';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPoster(movie.posterPath),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$year · ${movie.runtime != null ? '${movie.runtime}분' : '상영 시간 미정'}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.violet,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${movie.voteAverage.toStringAsFixed(1)} / 10',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${movie.voteCount}개 평가)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: movie.genres.map((genre) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6E0E9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              genre,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.gray,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 36,
                  indent: 20,
                  endIndent: 20,
                  color: Color(0xFFE0E0E0),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    '시놉시스',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Text(
                    movie.overview.isNotEmpty
                        ? movie.overview
                        : '등록된 줄거리가 없습니다.',
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.7,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: Color(0xFFE0E0E0),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              isFavorite = !isFavorite;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isFavorite
                                      ? '즐겨찾기에 추가했습니다.'
                                      : '즐겨찾기에서 삭제했습니다.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: Icon(
                            isFavorite ? Icons.bookmark : Icons.bookmark_border,
                            size: 16,
                          ),
                          label: Text(isFavorite ? '즐겨찾기 삭제' : '즐겨찾기'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.violet,
                            side: const BorderSide(color: AppColors.violet),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showRatingDialog,
                          icon: const Icon(Icons.star_outline, size: 16),
                          label: Text(
                            myRating == 0
                                ? '평점 남기기'
                                : '${myRating.toStringAsFixed(1)}점',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.violet,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPoster(String? posterPath) {
    if (posterPath == null || posterPath.isEmpty) {
      return _posterPlaceholder();
    }

    return Image.network(
      'https://image.tmdb.org/t/p/w500$posterPath',
      width: double.infinity,
      height: 430,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _posterPlaceholder();
      },
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      width: double.infinity,
      height: 430,
      color: const Color(0xFFE6E0E9),
      alignment: Alignment.center,
      child: const Icon(Icons.movie_outlined, size: 64, color: AppColors.gray),
    );
  }

  Future<void> _showRatingDialog() async {
    final movieId = widget.movieId;

    if (movieId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('영화 정보를 확인할 수 없습니다.')));
      return;
    }

    final rating = await showDialog<double>(
      context: context,
      builder: (context) => RatingDialog(movieId: movieId),
    );

    if (rating != null && mounted) {
      setState(() {
        myRating = rating;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${rating.toStringAsFixed(1)}점으로 평가했습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key, required this.movieId});

  final int movieId;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double rating = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.warmWhite,
      title: const Center(
        child: Text(
          '영화는 어땠나요?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
      ),
      content: RatingBar.builder(
        initialRating: rating,
        minRating: 0.5,
        allowHalfRating: true,
        itemCount: 5,
        itemSize: 32,
        itemBuilder: (context, index) {
          return const Icon(Icons.star, color: AppColors.violet);
        },
        onRatingUpdate: (value) {
          setState(() {
            rating = value;
          });
        },
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: rating == 0
                ? null
                : () => Navigator.pop(context, rating),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.violet,
              foregroundColor: Colors.white,
            ),
            child: const Text('확인'),
          ),
        ),
      ],
    );
  }
}
