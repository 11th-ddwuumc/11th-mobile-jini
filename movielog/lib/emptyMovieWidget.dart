import 'package:flutter/material.dart';

class EmptyMovieWidget extends StatelessWidget {
  const EmptyMovieWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('영화가 없습니다.', style: TextStyle(fontSize: 16)),
    );
  }
}
