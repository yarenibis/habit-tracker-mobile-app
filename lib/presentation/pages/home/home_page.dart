import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/habit_providers.dart';
import '../../widgets/pixel_ui_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/habit.dart';
import '../add_habit/add_habit_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final progress = ref.watch(dailyProgressProvider);
    final scene = ref.watch(currentSceneProvider);
    final streak = ref.watch(streakProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: PixelColors.background,
      body: Stack(
        children: [
          // ── Arka plan PNG ──────────────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/ui/oyun2.jpg',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, __, ___) =>
                  Container(color: PixelColors.background),
            ),
          ),

          // ── İçerik ────────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _PixelAppBar(streak: streak),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        PixelSceneCard(
                          assetPath: scene.assetPath,
                          description: scene.description,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: PixelProgressBar(progress: progress),
                        ),
                        const SizedBox(height: 20),
                        habitsAsync.when(
                          data: (habits) {
                            final active = habits
                                .where((h) => h.status == HabitStatus.active)
                                .toList();
                            if (active.isEmpty) {
                              return _EmptyState(
                                  onAddTap: () => _navigateToAdd(context));
                            }
                            return Column(
                              children: active.map((habit) {
                                final isCompleted = ref
                                    .watch(isHabitCompletedProvider(habit.id));
                                return PixelHabitBar(
                                  title:
                                      '${habit.iconAsset ?? "⭐"}  ${habit.title}',
                                  isCompleted: isCompleted,
                                  onTap: () {},
                                  onToggle: () {
                                    HapticFeedback.mediumImpact();
                                    toggleHabitCompletion(ref, habit.id);
                                  },
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const _LoadingHabits(),
                          error: (e, _) => Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text('Hata: $e',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.red)),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 8),
        child: PixelAddButton(onTap: () => _navigateToAdd(context)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AddHabitPage()));
  }
}

class _PixelAppBar extends StatelessWidget {
  final int streak;
  const _PixelAppBar({required this.streak});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final months = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara'
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}',
            style: const TextStyle(fontSize: 12, color: PixelColors.textMedium),
          ),
          if (streak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: PixelColors.pink.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PixelColors.pink.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text('$streak gün',
                      style: const TextStyle(
                          fontSize: 11, color: PixelColors.pink)),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddTap;
  const _EmptyState({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text('✨', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('Henüz habit yok',
              style: TextStyle(fontSize: 13, color: PixelColors.textMedium)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onAddTap,
            child: const Text('İlk habitini ekle →',
                style: TextStyle(
                    fontSize: 12,
                    color: PixelColors.mint,
                    decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }
}

class _LoadingHabits extends StatelessWidget {
  const _LoadingHabits();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (i) => Container(
          height: 56,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
          decoration: BoxDecoration(
            color: PixelColors.mint.withOpacity(0.3),
            borderRadius: BorderRadius.circular(28),
          ),
        ).animate(onPlay: (c) => c.repeat()).shimmer(
              duration: 1200.ms,
              color: Colors.white38,
            ),
      ),
    );
  }
}
