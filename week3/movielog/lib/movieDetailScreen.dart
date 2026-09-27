import 'package:flutter/material.dart';

import 'movie.dart';
import 'theme/app_colors.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final int? movieId;

  @override
  Widget build(BuildContext context) {
    final movie = findMovieById(movieId);

    if (movie == null) {
      return const Scaffold(body: Center(child: Text('영화를 찾을 수 없습니다.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('영화 상세')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              movie.posterAsset,
              width: double.infinity,
              height: 450,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${movie.genre} · ${movie.year}',
                    style: const TextStyle(fontSize: 16, color: AppColors.gray),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    '평점',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    movie.rating.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
