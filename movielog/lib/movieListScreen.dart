import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'emptyMovieWidget.dart';
import 'errorMovieWidget.dart';
import 'model/tmdb_movie_dto.dart';
import 'provider/discover_provider.dart';
import 'preference/genrePreference.dart';
import 'theme/app_colors.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final GenrePreference genrePreference = GenrePreference();

  String selectedGenre = '전체';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    final provider = context.read<DiscoverProvider>();
    final savedGenre = await genrePreference.loadGenre();

    if (!mounted) return;

    await provider.loadInitial();

    if (!mounted || provider.hasError) return;

    if (savedGenre != null &&
        savedGenre != '전체' &&
        provider.genres.any((genre) => genre.name == savedGenre)) {
      final genre = provider.genres.firstWhere(
        (genre) => genre.name == savedGenre,
      );

      setState(() {
        selectedGenre = genre.name;
      });

      await provider.selectGenre(genre.id);
    } else if (savedGenre != null && savedGenre != '전체') {
      await genrePreference.saveGenre('전체');
    }
  }

  Future<void> _selectGenre(
    DiscoverProvider provider,
    String genreName,
    int? genreId,
  ) async {
    if (provider.isLoading) return;

    setState(() {
      selectedGenre = genreName;
    });

    await genrePreference.saveGenre(genreName);
    await provider.selectGenre(genreId);
  }

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
      body: Consumer<DiscoverProvider>(
        builder: (context, provider, child) {
          final genres = provider.genres;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: genres.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final genreName = isAll ? '전체' : genres[index - 1].name;
                    final genreId = isAll ? null : genres[index - 1].id;
                    final isSelected = selectedGenre == genreName;

                    return GestureDetector(
                      onTap: provider.isLoading
                          ? null
                          : () => _selectGenre(provider, genreName, genreId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.violet
                              : const Color(0xFFE6E0E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          genreName,
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
              ),

              const SizedBox(height: 12),

              Expanded(child: _buildMovieContent(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMovieContent(DiscoverProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasError) {
      return ErrorMovieWidget(
        onRetry: () {
          provider.retry();
        },
      );
    }

    if (provider.movies.isEmpty) {
      return const EmptyMovieWidget();
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.50,
      ),
      itemCount: provider.movies.length,
      itemBuilder: (context, index) {
        return _buildMovieCard(provider.movies[index]);
      },
    );
  }

  Widget _buildMovieCard(TmdbMovieDto movie) {
    final posterPath = movie.posterPath;
    final releaseDate = movie.releaseDate ?? '';
    final year = releaseDate.length >= 4
        ? releaseDate.substring(0, 4)
        : '개봉일 미정';

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
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: posterPath == null || posterPath.isEmpty
                        ? _buildPosterPlaceholder()
                        : Image.network(
                            'https://image.tmdb.org/t/p/w500$posterPath',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPosterPlaceholder();
                            },
                          ),
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
                      '★ ${movie.voteAverage.toStringAsFixed(1)}',
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
            year,
            style: const TextStyle(fontSize: 14, color: AppColors.gray),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterPlaceholder() {
    return Container(
      color: const Color(0xFFE6E0E9),
      alignment: Alignment.center,
      child: const Icon(Icons.movie_outlined, size: 48, color: AppColors.gray),
    );
  }
}
