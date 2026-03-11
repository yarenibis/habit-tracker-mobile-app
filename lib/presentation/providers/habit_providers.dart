// lib/presentation/providers/habit_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/app_database.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../core/constants/scene_assets.dart';
import 'progress_providers.dart';

const _uuid = Uuid();

// ── Database (singleton) ──────────────────────────────────────────────────────
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// ── Repository ────────────────────────────────────────────────────────────────
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return HabitRepositoryImpl(db);
});

// ── Habit listesi ─────────────────────────────────────────────────────────────
final habitsProvider = StreamProvider<List<Habit>>((ref) {
  return ref.watch(habitRepositoryProvider).watchAllHabits();
});

// ── Bugünkü tamamlamalar ──────────────────────────────────────────────────────
final todayCompletionsProvider = StreamProvider<List<HabitCompletion>>((ref) {
  return ref
      .watch(habitRepositoryProvider)
      .watchCompletionsForDate(DateTime.now());
});

// ── Tüm habitler bugün tamamlandı mı? ────────────────────────────────────────
final allHabitsCompletedTodayProvider = Provider<bool>((ref) {
  final habits = ref.watch(habitsProvider).valueOrNull ?? [];
  final completions = ref.watch(todayCompletionsProvider).valueOrNull ?? [];
  if (habits.isEmpty) return false;
  final active = habits.where((h) => h.status == HabitStatus.active).toList();
  final completedIds = completions.map((c) => c.habitId).toSet();
  return active.every((h) => completedIds.contains(h.id));
});

// ── Günlük ilerleme 0.0 → 1.0 ────────────────────────────────────────────────
final dailyProgressProvider = Provider<double>((ref) {
  final habits = ref.watch(habitsProvider).valueOrNull ?? [];
  final completions = ref.watch(todayCompletionsProvider).valueOrNull ?? [];
  final active = habits.where((h) => h.status == HabitStatus.active).toList();
  if (active.isEmpty) return 0.0;
  final completedIds = completions.map((c) => c.habitId).toSet();
  final done = active.where((h) => completedIds.contains(h.id)).length;
  return done / active.length;
});

// ── Streak — completions değişince yeniden hesaplanır ────────────────────────
final streakProvider = FutureProvider<int>((ref) async {
  // todayCompletionsProvider'ı izle → değişince bu provider da yeniden çalışır
  ref.watch(todayCompletionsProvider);
  return ref
      .read(habitRepositoryProvider)
      .getConsecutiveFullDays(lookbackDays: 60);
});

// ── Mevcut sahne ──────────────────────────────────────────────────────────────
final currentSceneProvider = Provider<SceneLevel>((ref) {
  final streak = ref.watch(streakProvider).valueOrNull ?? 0;
  return SceneAssets.getCurrentScene(SceneType.fountain, streak);
});

// ── Belirli habit bugün tamamlandı mı? ───────────────────────────────────────
final isHabitCompletedProvider = Provider.family<bool, String>((ref, habitId) {
  final completions = ref.watch(todayCompletionsProvider).valueOrNull ?? [];
  return completions.any((c) => c.habitId == habitId);
});

// ── Completion ID'si (unmark için) ───────────────────────────────────────────
final habitCompletionIdProvider =
    Provider.family<String?, String>((ref, habitId) {
  final completions = ref.watch(todayCompletionsProvider).valueOrNull ?? [];
  try {
    return completions.firstWhere((c) => c.habitId == habitId).id;
  } catch (_) {
    return null;
  }
});

// ── Actions ───────────────────────────────────────────────────────────────────

/// Habit tamamla / geri al
Future<void> toggleHabitCompletion(WidgetRef ref, String habitId) async {
  final repo = ref.read(habitRepositoryProvider);
  final completionId = ref.read(habitCompletionIdProvider(habitId));

  if (completionId != null) {
    await repo.unmarkComplete(completionId);
  } else {
    final now = DateTime.now();
    await repo.markComplete(HabitCompletion(
      id: _uuid.v4(),
      habitId: habitId,
      completedAt: now,
      date: DateTime(now.year, now.month, now.day),
    ));
  }
  // Takvimi de yenile
  ref.invalidate(monthlyCompletionMapProvider);
}

/// Yeni habit ekle
Future<void> addHabit(
  WidgetRef ref, {
  required String title,
  String? description,
  required String emoji,
  required String colorHex,
  required HabitFrequency frequency,
}) async {
  final repo = ref.read(habitRepositoryProvider);
  await repo.createHabit(Habit(
    id: _uuid.v4(),
    title: title,
    description: description,
    frequency: frequency,
    status: HabitStatus.active,
    createdAt: DateTime.now(),
    iconAsset: emoji,
  ));
}

Future<void> updateHabit(WidgetRef ref, Habit habit) async {
  await ref.read(habitRepositoryProvider).updateHabit(habit);
}

/// Habit sil
Future<void> removeHabit(WidgetRef ref, String habitId) async {
  await ref.read(habitRepositoryProvider).deleteHabit(habitId);
}
