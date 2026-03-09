import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/app_database.dart';

const _uuid = Uuid();

class HabitRepositoryImpl implements HabitRepository {
  final AppDatabase _db;

  // Her değişiklikte tüm dinleyicileri tetikleyen tek bir notifier
  final _changeNotifier = StreamController<void>.broadcast();

  HabitRepositoryImpl(this._db);

  // Değişiklik olduğunda bildir
  void _notify() => _changeNotifier.add(null);

  // ── Mappers ────────────────────────────────────────────────────────────────

  Habit _mapToHabit(Map<String, dynamic> row) => Habit(
        id: row['id'] as String,
        title: row['title'] as String,
        description: row['description'] as String?,
        frequency: row['frequency'] == 'weekly'
            ? HabitFrequency.weekly
            : HabitFrequency.daily,
        status: row['status'] == 'archived'
            ? HabitStatus.archived
            : HabitStatus.active,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
        iconAsset: row['emoji'] as String?,
      );

  HabitCompletion _mapToCompletion(Map<String, dynamic> row) => HabitCompletion(
        id: row['id'] as String,
        habitId: row['habit_id'] as String,
        completedAt: DateTime.fromMillisecondsSinceEpoch(row['completed_at'] as int),
        date: DateTime.fromMillisecondsSinceEpoch(row['date'] as int),
      );

  // ── Habit CRUD ─────────────────────────────────────────────────────────────

  @override
  Future<List<Habit>> getAllHabits() async {
    final rows = await _db.getAllHabits();
    return rows.map(_mapToHabit).toList();
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    final row = await _db.getHabitById(id);
    return row == null ? null : _mapToHabit(row);
  }

  @override
  Future<void> createHabit(Habit habit) async {
    await _db.insertHabit({
      'id': habit.id,
      'title': habit.title,
      'description': habit.description,
      'emoji': habit.iconAsset ?? '⭐',
      'color_hex': '98E4C8',
      'frequency': habit.frequency == HabitFrequency.weekly ? 'weekly' : 'daily',
      'status': habit.status == HabitStatus.archived ? 'archived' : 'active',
      'created_at': habit.createdAt.millisecondsSinceEpoch,
    });
    _notify();
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    await _db.updateHabit({
      'id': habit.id,
      'title': habit.title,
      'description': habit.description,
      'emoji': habit.iconAsset ?? '⭐',
      'color_hex': '98E4C8',
      'frequency': habit.frequency == HabitFrequency.weekly ? 'weekly' : 'daily',
      'status': habit.status == HabitStatus.archived ? 'archived' : 'active',
      'created_at': habit.createdAt.millisecondsSinceEpoch,
    });
    _notify();
  }

  @override
  Future<void> deleteHabit(String id) async {
    await _db.deleteHabit(id);
    _notify();
  }

  // ── Completions ────────────────────────────────────────────────────────────

  @override
  Future<List<HabitCompletion>> getCompletionsForDate(DateTime date) async {
    final rows = await _db.getCompletionsForDate(date);
    return rows.map(_mapToCompletion).toList();
  }

  @override
  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId) async {
    final rows = await _db.getCompletionsForHabit(habitId);
    return rows.map(_mapToCompletion).toList();
  }

  @override
  Future<void> markComplete(HabitCompletion completion) async {
    final existing = await _db.getCompletionForHabitOnDate(
        completion.habitId, completion.date);
    if (existing != null) return;

    await _db.insertCompletion({
      'id': completion.id,
      'habit_id': completion.habitId,
      'completed_at': completion.completedAt.millisecondsSinceEpoch,
      'date': DateTime(
        completion.date.year,
        completion.date.month,
        completion.date.day,
      ).millisecondsSinceEpoch,
    });
    _notify();
  }

  @override
  Future<void> unmarkComplete(String completionId) async {
    await _db.deleteCompletion(completionId);
    _notify();
  }

  @override
  Future<bool> isCompletedToday(String habitId) async {
    final row = await _db.getCompletionForHabitOnDate(habitId, DateTime.now());
    return row != null;
  }

  // ── Stats ──────────────────────────────────────────────────────────────────

  @override
  Future<double> getCompletionRate(DateTime from, DateTime to) async {
    final habits = await getAllHabits();
    if (habits.isEmpty) return 0.0;
    final completions = await _db.getCompletionsInRange(from, to);
    final completedIds = completions.map((c) => c['habit_id'] as String).toSet();
    final count = habits.where((h) => completedIds.contains(h.id)).length;
    return count / habits.length;
  }

  @override
  Future<int> getConsecutiveFullDays({int lookbackDays = 60}) async {
    final habits = await getAllHabits();
    if (habits.isEmpty) return 0;
    int streak = 0;
    final today = DateTime.now();
    for (int i = 1; i < lookbackDays; i++) {
      final day = today.subtract(Duration(days: i));
      final rows = await _db.getCompletionsForDate(day);
      final completedIds = rows.map((c) => c['habit_id'] as String).toSet();
      if (habits.every((h) => completedIds.contains(h.id))) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  // ── Streams — değişiklik olunca DB'den yeniden okur ───────────────────────

  @override
  Stream<List<Habit>> watchAllHabits() async* {
    yield await getAllHabits();
    await for (final _ in _changeNotifier.stream) {
      yield await getAllHabits();
    }
  }

  @override
  Stream<List<HabitCompletion>> watchCompletionsForDate(DateTime date) async* {
    yield await getCompletionsForDate(date);
    await for (final _ in _changeNotifier.stream) {
      yield await getCompletionsForDate(date);
    }
  }
}
