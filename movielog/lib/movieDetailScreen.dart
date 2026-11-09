import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'model/tmdb_movie_detail_dto.dart';
import 'service/tmdb_movie_service.dart';
import 'theme/app_colors.dart';
import 'widgets/movie_rating_input.dart';

import 'view_models/movie_detail_view_model.dart';
import 'view_models/sign_up_view_model.dart';
import 'data/models/rating_request.dart';

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

  // 평점 등록 Dialog
  // 평점 등록 Dialog
  Future<void> _showRatingDialog() async {
    int? savedScore;

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        onSubmit: (score, comment) async {
          final viewModel = context.read<MovieDetailViewModel>();

          await viewModel.createRating(score: score, comment: comment);

          if (viewModel.submitStatus != SubmitStatus.success) {
            throw StateError(viewModel.submitMessage ?? '저장에 실패했습니다.');
          }

          savedScore = score;
        },
      ),
    );

    if (!mounted || saved != true) return;

    setState(() {
      myRating = (savedScore ?? 0).toDouble();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('평점을 등록했습니다. 마이페이지의 "내가 등록한 평점"에서 확인할 수 있습니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// 평점 등록 Dialog
class RatingDialog extends StatefulWidget {
  const RatingDialog({
    super.key,
    this.initialScore = 0,
    this.initialComment,
    required this.onSubmit,
  });

  final int initialScore;
  final String? initialComment;
  final Future<void> Function(int score, String? comment) onSubmit;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late int _score = widget.initialScore;

  late final _commentController = TextEditingController(
    text: widget.initialComment ?? '',
  );

  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '평점을 남겨주세요',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MovieRatingInput(
              rating: _score.toDouble(),
              enabled: !_isSubmitting,
              onChanged: (value) {
                setState(() {
                  _score = validateServerScore(value);
                });
              },
            ),
            const SizedBox(height: 12),

            // 코멘트 입력
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '코멘트 (선택, 최대 500자)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7654B5),
                  ),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  maxLength: 500,
                  enabled: !_isSubmitting,
                  decoration: InputDecoration(
                    hintText: '이 영화의 인상적인 장면은...',
                    hintStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFFAF8FC),
                    contentPadding: const EdgeInsets.all(12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFDED5EA)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF7654B5)),
                    ),
                  ),
                ),
              ],
            ),

            if (_errorText != null) ...[
              const SizedBox(height: 8),
              Text(_errorText!, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 12),

            // 취소 / 확인 버튼
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFF0EAF8),
                        foregroundColor: const Color(0xFF7654B5),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: _score > 0 && !_isSubmitting
                          ? _onConfirm
                          : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF7654B5),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF7654B5)
                            .withValues(alpha: 0.4),
                        shape: const StadiumBorder(),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              '확인',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final trimmed = _commentController.text.trim();

    if (trimmed.length > 500) {
      setState(() {
        _isSubmitting = false;
        _errorText = '코멘트는 500자 이하로 입력해 주세요.';
      });
      return;
    }

    try {
      await widget.onSubmit(_score, trimmed.isEmpty ? null : trimmed);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _errorText = error.toString().replaceFirst('Bad state: ', '');
      });
    }
  }
}
