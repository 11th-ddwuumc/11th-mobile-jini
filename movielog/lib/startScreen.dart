import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'profileScreen.dart';

void main() {
  final movies = <Movie>[
    const Movie(id: 1, title: '벌새'),
    const Movie(id: 2, title: '콜럼버스'),
    const Movie(id: 3, title: '사도'),
  ];

  for (final movie in movies) {
    print(movie.title);
  }

  String? nickname = null;
  final displayName = nickname ?? '이름 없음';
  print(displayName);

  runApp(const MovieLogApp());
}

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: ThemeData(useMaterial3: true),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 45),

              const Text(
                'FLUTTER 0주차',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 40),

              SvgPicture.asset(
                'assets/logos/movielog_logo.svg',
                width: 72,
                height: 72,
                semanticsLabel: 'MovieLog 로고',
              ),

              const SizedBox(height: 40),

              const Text(
                '영화의 순간을\n기록하세요',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              const Text(
                '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF50378B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('시작하기'),
                ),
              ),

              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }
}

class Movie {
  const Movie({required this.id, required this.title});

  final int id;
  final String title;
}
