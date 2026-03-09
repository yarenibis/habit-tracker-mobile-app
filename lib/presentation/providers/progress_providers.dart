// lib/presentation/providers/progress_providers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/badge_definitions.dart';
import 'habit_providers.dart';

// ── Seçili ay (takvim navigasyonu) ───────────────────────────────────────────
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

// ── Seçili ayın her günü için tamamlanma oranı ────────────────────────────────
// Map<DateTime, double>  key=gün (saat=0), value=0.0..1.0
final monthlyCompletionMapProvider =
    FutureProvider<Map<DateTime, double>>((ref) async {
  final repo = ref.watch(habitRepositoryProvider);
  final month = ref.watch(selectedMonthProvider);
  // Bu satır: completions her değişince provider invalidate edilir
  ref.watch(todayCompletionsProvider).valueOrNull;

  final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
  final result = <DateTime, double>{};
  final today = DateTime.now();

  final allHabits = await repo.getAllHabits();
  final activeHabits =
      allHabits.where((h) => h.status.name == 'active').toList();
  if (activeHabits.isEmpty) return result;

  for (int day = 1; day <= daysInMonth; day++) {
    final date = DateTime(month.year, month.month, day);
    if (date.isAfter(today)) break;
    final completions = await repo.getCompletionsForDate(date);
    final completedHabitIds = completions.map((c) => c.habitId).toSet();
    final completedCount =
        activeHabits.where((h) => completedHabitIds.contains(h.id)).length;
    result[date] = completedCount / activeHabits.length;
  }
  return result;
});

// ── Kazanılmış badge'ler ──────────────────────────────────────────────────────
final unlockedBadgesProvider = Provider<List<BadgeDefinition>>((ref) {
  final streak = ref.watch(streakProvider).valueOrNull ?? 0;
  return BadgeDefinitions.unlockedBadges(streak);
});

// ── Kilitli badge'ler ─────────────────────────────────────────────────────────
final lockedBadgesProvider = Provider<List<BadgeDefinition>>((ref) {
  final streak = ref.watch(streakProvider).valueOrNull ?? 0;
  return BadgeDefinitions.lockedBadges(streak);
});

// ── Bir sonraki badge ─────────────────────────────────────────────────────────
final nextBadgeProvider = Provider<BadgeDefinition?>((ref) {
  final streak = ref.watch(streakProvider).valueOrNull ?? 0;
  return BadgeDefinitions.nextBadge(streak);
});

// ── Aylık istatistik özeti ────────────────────────────────────────────────────
class MonthStats {
  final int perfectDays; // %100 tamamlanan günler
  final int partialDays; // Kısmen tamamlanan
  final int missedDays; // Hiç tamamlanmayan (geçmiş)
  final double avgCompletion; // Ortalama tamamlanma oranı

  const MonthStats({
    required this.perfectDays,
    required this.partialDays,
    required this.missedDays,
    required this.avgCompletion,
  });
}

final monthStatsProvider = Provider<MonthStats>((ref) {
  final mapAsync = ref.watch(monthlyCompletionMapProvider);
  final map = mapAsync.valueOrNull ?? {};

  if (map.isEmpty) {
    return const MonthStats(
        perfectDays: 0, partialDays: 0, missedDays: 0, avgCompletion: 0.0);
  }

  int perfect = 0, partial = 0, missed = 0;
  double total = 0;

  for (final rate in map.values) {
    total += rate;
    if (rate >= 1.0) {
      perfect++;
    } else if (rate > 0.0) {
      partial++;
    } else {
      missed++;
    }
  }

  return MonthStats(
    perfectDays: perfect,
    partialDays: partial,
    missedDays: missed,
    avgCompletion: total / map.length,
  );
});
