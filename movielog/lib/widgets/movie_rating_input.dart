import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.enabled = true,
  });

  final double rating;
  final ValueChanged<double> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isSelected = index < rating;

        return GestureDetector(
          onTap: enabled ? () => onChanged((index + 1).toDouble()) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(
              isSelected ? Icons.star : Icons.star_border,
              size: 25,
              color: AppColors.violet,
            ),
          ),
        );
      }),
    );
  }
}
