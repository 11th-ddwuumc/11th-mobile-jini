class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.runtime,
    required this.tags,
    required this.posterAsset,
    required this.rating,
  });

  final int id;
  final String title;
  final String genre;
  final int year;
  final int runtime;
  final List<String> tags;
  final String posterAsset;
  final double rating;
}

const movies = [
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    year: 2024,
    runtime: 124,
    tags: ['로맨스', '드라마', '감동적인'],
    posterAsset: 'assets/images/hero_under_the_starlight.jpg',
    rating: 4.5,
  ),

  Movie(
    id: 2,
    title: '어비스 워커',
    genre: 'SF',
    year: 2024,
    runtime: 118,
    tags: ['SF', '액션', '긴장감'],
    posterAsset: 'assets/images/poster_abyss_walker.jpg',
    rating: 4.5,
  ),

  Movie(
    id: 3,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    runtime: 121,
    tags: ['SF', '우주', '감성적'],
    posterAsset: 'assets/images/poster_echoes_of_the_void.jpg',
    rating: 4.3,
  ),

  Movie(
    id: 4,
    title: '네 번째 오후',
    genre: '드라마',
    year: 2024,
    runtime: 110,
    tags: ['드라마', '일상', '따뜻한'],
    posterAsset: 'assets/images/poster_fourth_afternoon.jpg',
    rating: 4.6,
  ),

  Movie(
    id: 5,
    title: '밤의 그림자',
    genre: '미스터리',
    year: 2023,
    runtime: 115,
    tags: ['미스터리', '스릴러', '긴장감'],
    posterAsset: 'assets/images/poster_night_shadows.jpg',
    rating: 4.4,
  ),

  Movie(
    id: 6,
    title: '숲의 속삭임',
    genre: '스릴러',
    year: 2024,
    runtime: 108,
    tags: ['스릴러', '미스터리', '어두운'],
    posterAsset: 'assets/images/poster_whispering_woods.jpg',
    rating: 4.7,
  ),
];

Movie? findMovieById(int? id) {
  for (final movie in movies) {
    if (movie.id == id) {
      return movie;
    }
  }

  return null;
}
