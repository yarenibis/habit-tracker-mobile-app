// lib/presentation/pages/habit_detail/habit_detail_page.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HabitDetailPage extends StatelessWidget {
  final String habitId;

  const HabitDetailPage({super.key, required this.habitId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PixelColors.background,
      appBar: AppBar(
        title: const Text('HABİT DETAY'),
        backgroundColor: PixelColors.background,
      ),
      body: const Center(
        child: Text(
          'Yakında...',
          style: TextStyle(
            // fontFamily: 'PixelFont',
            fontSize: 10,
            color: PixelColors.textMedium,
          ),
        ),
      ),
    );
  }
}
