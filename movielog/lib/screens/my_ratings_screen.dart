import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/my_ratings_view_model.dart';
import '../../data/models/rating_dto.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../movieDetailScreen.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MyRatingsViewModel>(
      builder: (context, viewModel, child) {
        return PopScope(
          canPop: !viewModel.isDeletingSelected,
          child: LoadingOverlay(
            isLoading: viewModel.isDeletingSelected,
            child: Scaffold(
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
                actions: [
                  if (viewModel.selectedRatingIds.isNotEmpty)
                    TextButton(
                      onPressed: viewModel.isDeletingSelected
                          ? null
                          : () => onDeleteSelectedPressed(context),
                      child: Text(
                        '선택 삭제 (${viewModel.selectedRatingIds.length})',
                      ),
                    ),
                ],
              ),
              body: _buildBody(context, viewModel),
            ),
          ),
        );
      },
    );
  }

  // 화면 상태에 따라 표시할 내용
  Widget _buildBody(BuildContext context, MyRatingsViewModel viewModel) {
    switch (viewModel.status) {
      case MyRatingsLoadStatus.idle:
      case MyRatingsLoadStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case MyRatingsLoadStatus.empty:
        return const Center(child: Text('등록한 평점이 없습니다.'));

      case MyRatingsLoadStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                viewModel.refreshWarning ??
                    viewModel.message ??
                    '평점을 불러오지 못했습니다.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => viewModel.retryLoad(),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        );

      case MyRatingsLoadStatus.success:
        return Column(
          children: [
            if (viewModel.refreshWarning != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  viewModel.refreshWarning!,
                  textAlign: TextAlign.center,
                ),
              ),
            if (viewModel.message != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(viewModel.message!, textAlign: TextAlign.center),
              ),
            Expanded(child: _buildRatingList(context, viewModel)),
          ],
        );
    }
  }

  // 평점 목록
  Widget _buildRatingList(BuildContext context, MyRatingsViewModel viewModel) {
    final ratings = viewModel.ratings;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: ratings.length,
      itemBuilder: (context, index) {
        final entry = ratings[index];
        final rating = entry.rating;
        final movie = entry.movie;

        final isSelected = viewModel.selectedRatingIds.contains(
          rating.ratingId,
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minHeight: 100),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.violet : AppColors.lightViolet,
            ),
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
                        width: 52,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _posterPlaceholder();
                        },
                      )
                    : _posterPlaceholder(),
              ),

              const SizedBox(width: 8),

              // 영화 정보 및 수정·삭제 버튼
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
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '별점 ${rating.score} / 5',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.violet,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rating.comment?.isNotEmpty == true
                          ? rating.comment!
                          : '코멘트 없음',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 52,
                    height: 28,
                    child: TextButton(
                      onPressed: viewModel.isWriting
                          ? null
                          : () => onEditPressed(context, rating),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: const Color(0xFFF0EAF8),
                        foregroundColor: const Color(0xFF7654B5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '수정',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 52,
                    height: 28,
                    child: TextButton(
                      onPressed: viewModel.isWriting
                          ? null
                          : () => onDeletePressed(context, rating),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: const Color(0xFFFCEBEA),
                        foregroundColor: const Color(0xFFD45A5A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '삭제',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 평점 수정 Dialog
  Future<void> onEditPressed(BuildContext context, RatingDto rating) async {
    final viewModel = context.read<MyRatingsViewModel>();

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return RatingDialog(
          initialScore: rating.score,
          initialComment: rating.comment,
          onSubmit: (score, comment) {
            return viewModel.updateRating(
              ratingId: rating.ratingId,
              score: score,
              comment: comment,
            );
          },
        );
      },
    );
  }

  // 평점 단건 삭제 확인 Dialog
  Future<void> onDeletePressed(BuildContext context, RatingDto rating) async {
    final viewModel = context.read<MyRatingsViewModel>();

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _DeleteRatingDialog(
          onConfirm: () {
            return viewModel.deleteRating(rating.ratingId);
          },
        );
      },
    );
  }

  // 선택한 평점 다중 삭제
  Future<void> onDeleteSelectedPressed(BuildContext context) async {
    final viewModel = context.read<MyRatingsViewModel>();

    if (viewModel.selectedRatingIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('선택한 평점을 삭제할까요?'),
          content: Text('${viewModel.selectedRatingIds.length}개의 평점을 삭제합니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    await viewModel.deleteSelectedRatings();
  }

  // 포스터가 없을 때 표시할 이미지
  Widget _posterPlaceholder() {
    return Container(
      width: 52,
      height: 72,
      color: AppColors.lightViolet,
      child: const Icon(Icons.movie, color: AppColors.violet),
    );
  }
}

// 단건 삭제 확인 Dialog
class _DeleteRatingDialog extends StatefulWidget {
  const _DeleteRatingDialog({required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  State<_DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<_DeleteRatingDialog> {
  bool _isDeleting = false;

  @override
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '평점을 삭제할까요?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '선택한 평점은 복구할 수 없습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Color(0xFF999999)),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: _isDeleting
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
                      onPressed: _isDeleting ? null : _onConfirm,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF7654B5),
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      child: _isDeleting
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              '삭제',
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
      _isDeleting = true;
    });

    try {
      await widget.onConfirm();

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.')),
      );
    }
  }
}

// 다중 삭제 로딩 오버레이
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          const ModalBarrier(dismissible: false, color: Colors.black45),
        if (isLoading)
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      ],
    );
  }
}
