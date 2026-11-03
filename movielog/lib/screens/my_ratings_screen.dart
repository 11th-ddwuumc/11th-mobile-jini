import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/my_ratings_view_model.dart';
import '../../data/models/rating_with_movie.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          '내가 등록한 평점',
          style: AppTextStyles.titleMedium.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.violet,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<MyRatingsViewModel>(
        builder: (context, viewModel, child) {
          switch (viewModel.status) {
            case MyRatingsLoadStatus.idle:
            case MyRatingsLoadStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case MyRatingsLoadStatus.empty:
              return const Center(child: Text('등록한 평점이 없습니다.'));

            case MyRatingsLoadStatus.error:
              return Center(
                child: Text(viewModel.message ?? '평점을 불러오지 못했습니다.'),
              );

            case MyRatingsLoadStatus.success:
              return _buildRatingList(viewModel.ratings);
          }
        },
      ),
    );
  }

  Widget _buildRatingList(List<RatingWithMovie> ratings) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: ratings.length,
      itemBuilder: (context, index) {
        final entry = ratings[index];
        final rating = entry.rating;
        final movie = entry.movie;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.lightViolet),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // 영화 포스터
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: movie?.posterPath != null
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w200${movie!.posterPath}',
                        width: 72,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _posterPlaceholder();
                        },
                      )
                    : _posterPlaceholder(),
              ),

              const SizedBox(width: 12),

              // 영화 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      movie?.title ?? '영화 #${rating.movieId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '별점 ${rating.score} / 5',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.violet,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    if (rating.comment != null && rating.comment!.isNotEmpty)
                      Text(
                        rating.comment!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall,
                      )
                    else
                      const Text('포스트 정보 없음', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      width: 72,
      height: 100,
      color: AppColors.lightViolet,
      child: const Icon(Icons.movie, color: AppColors.violet),
    );
  }
}
