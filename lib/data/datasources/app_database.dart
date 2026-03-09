// lib/data/datasources/app_database.dart
// Kod üretimi gerektirmeyen saf sqflite implementasyonu

import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static AppDatabase? _instance;
  static Database? _db;

  AppDatabase._();

  factory AppDatabase() {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'pixel_habits.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE habits (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            emoji TEXT NOT NULL DEFAULT '⭐',
            color_hex TEXT NOT NULL DEFAULT '98E4C8',
            frequency TEXT NOT NULL DEFAULT 'daily',
            status TEXT NOT NULL DEFAULT 'active',
            created_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE completions (
            id TEXT PRIMARY KEY,
            habit_id TEXT NOT NULL,
            completed_at INTEGER NOT NULL,
            date INTEGER NOT NULL,
            FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
          )
        ''');

        await db.execute(
            'CREATE INDEX idx_completions_date ON completions (date)');
        await db.execute(
            'CREATE INDEX idx_completions_habit ON completions (habit_id)');
      },
    );
  }

  // ── Habits ──────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllHabits() async {
    final db = await database;
    return db.query('habits',
        where: 'status = ?',
        whereArgs: ['active'],
        orderBy: 'created_at ASC');
  }

  Future<Map<String, dynamic>?> getHabitById(String id) async {
    final db = await database;
    final rows =
        await db.query('habits', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> insertHabit(Map<String, dynamic> habit) async {
    final db = await database;
    await db.insert('habits', habit,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateHabit(Map<String, dynamic> habit) async {
    final db = await database;
    await db.update('habits', habit,
        where: 'id = ?', whereArgs: [habit['id']]);
  }

  Future<void> deleteHabit(String id) async {
    final db = await database;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  // ── Completions ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCompletionsForDate(
      DateTime date) async {
    final db = await database;
    final dayStart =
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final dayEnd = dayStart + 86400000;
    return db.query('completions',
        where: 'date >= ? AND date < ?', whereArgs: [dayStart, dayEnd]);
  }

  Future<List<Map<String, dynamic>>> getCompletionsForHabit(
      String habitId) async {
    final db = await database;
    return db.query('completions',
        where: 'habit_id = ?',
        whereArgs: [habitId],
        orderBy: 'date DESC');
  }

  Future<Map<String, dynamic>?> getCompletionForHabitOnDate(
      String habitId, DateTime date) async {
    final db = await database;
    final dayStart =
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final dayEnd = dayStart + 86400000;
    final rows = await db.query('completions',
        where: 'habit_id = ? AND date >= ? AND date < ?',
        whereArgs: [habitId, dayStart, dayEnd],
        limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> insertCompletion(Map<String, dynamic> completion) async {
    final db = await database;
    await db.insert('completions', completion,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteCompletion(String id) async {
    final db = await database;
    await db.delete('completions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getCompletionsInRange(
      DateTime from, DateTime to) async {
    final db = await database;
    final start =
        DateTime(from.year, from.month, from.day).millisecondsSinceEpoch;
    final end = DateTime(to.year, to.month, to.day).millisecondsSinceEpoch +
        86400000;
    return db.query('completions',
        where: 'date >= ? AND date < ?', whereArgs: [start, end]);
  }
}
