// lib/domain/entities/habit.dart
import 'package:equatable/equatable.dart';

enum HabitFrequency { daily, weekly }
enum HabitStatus { active, archived }

class Habit extends Equatable {
  final String id;
  final String title;
  final String? description;
  final HabitFrequency frequency;
  final HabitStatus status;
  final DateTime createdAt;
  final String? iconAsset;   // Opsiyonel pixel art ikon

  const Habit({
    required this.id,
    required this.title,
    this.description,
    this.frequency = HabitFrequency.daily,
    this.status = HabitStatus.active,
    required this.createdAt,
    this.iconAsset,
  });

  @override
  List<Object?> get props => [id, title, frequency, status, createdAt];
}

class HabitCompletion extends Equatable {
  final String id;
  final String habitId;
  final DateTime completedAt;
  final DateTime date; // Günün tarihi (saat bilgisi olmadan)

  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.completedAt,
    required this.date,
  });

  @override
  List<Object?> get props => [id, habitId, date];
}
