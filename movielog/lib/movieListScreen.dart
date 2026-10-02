import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'model/movie.dart';
import 'theme/app_colors.dart';
import 'service/fakeMovieService.dart';
import 'emptyMovieWidget.dart';
import 'errorMovieWidget.dart';
import 'preference/genrePreference.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late Future<List<Movie>> _moviesFuture;

  final FakeMovieService movieService = FakeMovieService();
  final GenrePreference genrePreference = GenrePreference();

  @override
  void initState() {
    super.initState();
    // TODO(5주차 유저별 평점 조회 API)
    _moviesFuture = movieService.fetchMovies();
    _loadSelectedGenre();
  }

  Future<void> _loadSelectedGenre() async {
    final savedGenre = await genrePreference.loadGenre();

    if (!mounted || savedGenre == null) {
      return;
    }

    setState(() {
      selectedGenre = savedGenre;
    });
  }

  String selectedGenre = '전체';

  final genres = const ['전체', '드라마', 'SF', '미스터리', '스릴러'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        backgroundColor: AppColors.warmWhite,
        elevation: 0,
        title: const Text(
          '영화',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.violet,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.black),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildGenreButtons(),
          const SizedBox(height: 12),

          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return ErrorMovieWidget(
                    onRetry: () {
                      setState(() {
                        _moviesFuture = movieService.fetchMovies();
                      });
                    },
                  );
                }

                final loadedMovies = snapshot.data ?? [];

                if (loadedMovies.isEmpty) {
                  return const EmptyMovieWidget();
                }

                final filteredMovies = selectedGenre == '전체'
                    ? loadedMovies
                    : loadedMovies
                          .where((movie) => movie.genre == selectedGenre)
                          .toList();

                if (filteredMovies.isEmpty) {
                  return const EmptyMovieWidget();
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 24,
                    childAspectRatio: 0.50,
                  ),
                  itemCount: filteredMovies.length,
                  itemBuilder: (context, index) {
                    final movie = filteredMovies[index];

                    return _buildMovieCard(movie);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreButtons() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: genres.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = selectedGenre == genre;

          return GestureDetector(
            onTap: () async {
              setState(() {
                selectedGenre = genre;
              });

              await genrePreference.saveGenre(genre);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.violet : const Color(0xFFE6E0E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                genre,
                style: TextStyle(
                  fontSize: 12,
                  height: 3,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        context.push('/movies/${movie.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    movie.posterAsset,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '★ ${movie.rating}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 7),

          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            '${movie.year} · ${movie.genre}',
            style: const TextStyle(fontSize: 14, color: AppColors.gray),
          ),
        ],
      ),
    );
  }
}
