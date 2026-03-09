// lib/domain/repositories/habit_repository.dart
import '../entities/habit.dart';

abstract class HabitRepository {
  // Habit CRUD
  Future<List<Habit>> getAllHabits();
  Future<Habit?> getHabitById(String id);
  Future<void> createHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(String id);

  // Completion tracking
  Future<List<HabitCompletion>> getCompletionsForDate(DateTime date);
  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId);
  Future<void> markComplete(HabitCompletion completion);
  Future<void> unmarkComplete(String completionId);
  Future<bool> isCompletedToday(String habitId);

  // Streak & stats
  /// Son N günde kaç gün tüm habitler tamamlandı
  Future<int> getConsecutiveFullDays({int lookbackDays = 30});

  /// Belirli tarih aralığındaki tamamlanma oranı (0.0 - 1.0)
  Future<double> getCompletionRate(DateTime from, DateTime to);

  // Stream: habit listesi değiştiğinde UI güncellenir
  Stream<List<Habit>> watchAllHabits();
  Stream<List<HabitCompletion>> watchCompletionsForDate(DateTime date);
}
