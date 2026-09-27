import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import 'movie.dart';
import 'theme/app_colors.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final int? movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isFavorite = false;
  double myRating = 0;

  @override
  Widget build(BuildContext context) {
    final movie = findMovieById(widget.movieId);

    if (movie == null) {
      return const Scaffold(body: Center(child: Text('영화를 찾을 수 없습니다.')));
    }

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
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.share_outlined,
              size: 20,
              color: AppColors.black,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MovieDetailPoster(movie: movie),
            MovieDetailInfo(movie: movie),
            MovieDetailRating(movie: movie),
            MovieDetailTags(tags: movie.tags),
            const MovieDivider(),
            const MovieSynopsis(),
            const MovieDivider(),
            MovieDetailActions(
              isFavorite: isFavorite,
              onFavoritePressed: _toggleFavorite,
              onRatingPressed: _showRatingDialog,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showRatingDialog() async {
    final rating = await showDialog<double>(
      context: context,
      builder: (context) {
        return const RatingDialog();
      },
    );

    if (rating != null) {
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

class MovieDetailPoster extends StatelessWidget {
  const MovieDetailPoster({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      movie.posterAsset,
      width: double.infinity,
      height: 430,
      fit: BoxFit.cover,
    );
  }
}

class MovieDetailInfo extends StatelessWidget {
  const MovieDetailInfo({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            '${movie.year} · ${movie.genre} · ${movie.runtime}분',
            style: const TextStyle(fontSize: 13, color: AppColors.gray),
          ),
        ],
      ),
    );
  }
}

class MovieDetailRating extends StatelessWidget {
  const MovieDetailRating({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          RatingBarIndicator(
            rating: movie.rating,
            itemBuilder: (context, index) {
              return const Icon(Icons.star, color: AppColors.violet);
            },
            itemCount: 5,
            itemSize: 18,
          ),
          const SizedBox(width: 8),
          Text(
            movie.rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            '(1,245)',
            style: TextStyle(fontSize: 12, color: AppColors.gray),
          ),
        ],
      ),
    );
  }
}

class MovieDetailTags extends StatelessWidget {
  const MovieDetailTags({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: tags.map((tag) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE6E0E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.gray,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MovieDivider extends StatelessWidget {
  const MovieDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFE0E0E0),
      indent: 20,
      endIndent: 20,
    );
  }
}

class MovieSynopsis extends StatelessWidget {
  const MovieSynopsis({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '시놉시스',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 만나게 됩니다. '
            '매일 밤 같은 장소에서 마주치며 서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시금 깨닫게 되는 이야기입니다.',
            style: TextStyle(fontSize: 13, height: 1.7, color: AppColors.black),
          ),
        ],
      ),
    );
  }
}

class MovieDetailActions extends StatelessWidget {
  const MovieDetailActions({
    super.key,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onRatingPressed,
  });

  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback onRatingPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onFavoritePressed,
              icon: Icon(
                isFavorite ? Icons.bookmark : Icons.bookmark_border,
                size: 16,
              ),
              label: Text(isFavorite ? '즐겨찾기 삭제' : '즐겨찾기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.violet,
                side: const BorderSide(color: AppColors.violet),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onRatingPressed,
              icon: const Icon(Icons.comment_outlined, size: 16),
              label: const Text('평점 남기기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.violet,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  final double rating;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 0.5,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: 32,
      itemBuilder: (context, index) {
        return const Icon(Icons.star, color: AppColors.violet);
      },
      onRatingUpdate: onChanged,
    );
  }
}

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double rating = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.warmWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MovieRatingInput(
            rating: rating,
            onChanged: (value) {
              setState(() {
                rating = value;
              });
            },
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: rating == 0
                ? null
                : () {
                    Navigator.pop(context, rating);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.violet,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.lightViolet,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '확인',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
