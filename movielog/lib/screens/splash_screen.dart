import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.message, this.onRetry});

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 32),
                          const Text('FLUTTER 8주차'),
                          const SizedBox(height: 40),

                          SvgPicture.asset(
                            'assets/logos/movielog_logo.svg',
                            width: 72,
                            height: 72,
                            semanticsLabel: 'MovieLog 로고',
                          ),

                          const SizedBox(height: 32),

                          Text(
                            '영화의 순간을\n기록하세요',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      if (onRetry == null)
                        const CircularProgressIndicator()
                      else
                        Column(
                          children: [
                            Text(
                              message ?? '로그인 상태를 확인하지 못했어요.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: onRetry,
                                child: const Text('다시 시도'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
