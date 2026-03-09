import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pixel_habit_tracker/core/theme/app_theme.dart';
import 'package:pixel_habit_tracker/domain/entities/habit.dart';
import 'package:pixel_habit_tracker/presentation/providers/habit_providers.dart';

// ── Providers ──────────────────────────────────────────────────────────────────
final usernameProvider = StateNotifierProvider<UsernameNotifier, String>(
    (ref) => UsernameNotifier());

class UsernameNotifier extends StateNotifier<String> {
  UsernameNotifier() : super('') {
    _load();
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('username') ?? '';
  }

  Future<void> set(String name) async {
    state = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
  }
}

final profilePhotoProvider =
    StateNotifierProvider<ProfilePhotoNotifier, String?>(
        (ref) => ProfilePhotoNotifier());

class ProfilePhotoNotifier extends StateNotifier<String?> {
  ProfilePhotoNotifier() : super(null) {
    _load();
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('profile_photo');
  }

  Future<void> set(String path) async {
    state = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_photo', path);
  }
}

// ── Sayfa ──────────────────────────────────────────────────────────────────────
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});
  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nameCtrl = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = ref.read(usernameProvider);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    HapticFeedback.mediumImpact();
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85);
    if (picked != null)
      await ref.read(profilePhotoProvider.notifier).set(picked.path);
  }

  Future<void> _saveName() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    await ref.read(usernameProvider.notifier).set(name);
    setState(() => _editing = false);
    HapticFeedback.lightImpact();
    if (mounted) FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final username = ref.watch(usernameProvider);
    final photoPath = ref.watch(profilePhotoProvider);
    final streak = ref.watch(streakProvider).valueOrNull ?? 0;
    final habits = ref.watch(habitsProvider).valueOrNull ?? [];
    final completions = ref.watch(todayCompletionsProvider).valueOrNull ?? [];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (_editing) setState(() => _editing = false);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/ui/oyun_bg.jpg',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (_, __, ___) =>
                      Container(color: PixelColors.background)),
            ),
            Positioned.fill(
                child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                    16, 16, 16, MediaQuery.of(context).padding.bottom + 90),
                child: Column(
                  children: [
                    // Başlık
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: const Color(0xFF5A9FD4), width: 2),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0xFF0A0A1A),
                              offset: Offset(2, 2),
                              blurRadius: 0)
                        ],
                      ),
                      child: const Text('★ PROFİL ★',
                          style: TextStyle(
                              fontFamily: 'PixelFont',
                              fontSize: 8,
                              color: PixelColors.yellow,
                              letterSpacing: 1)),
                    ).animate().fadeIn(duration: 300.ms),

                    const SizedBox(height: 24),

                    // Avatar
                    _PixelAvatar(photoPath: photoPath, onTap: _pickPhoto)
                        .animate()
                        .scale(
                            begin: const Offset(0.8, 0.8),
                            duration: 500.ms,
                            curve: Curves.elasticOut),

                    const SizedBox(height: 16),

                    // İsim
                    _PixelUsername(
                      controller: _nameCtrl,
                      username: username,
                      editing: _editing,
                      onEditTap: () => setState(() => _editing = true),
                      onSave: _saveName,
                    ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                    const SizedBox(height: 28),

                    // Stats grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.5,
                      children: [
                        _PixelStatCard(
                            emoji: '🔥',
                            value: '$streak',
                            label: 'STREAK',
                            color: const Color(0xFFFF6B35)),
                        _PixelStatCard(
                            emoji: '📋',
                            value:
                                '${habits.where((h) => h.status == HabitStatus.active).length}',
                            label: 'AKTİF HABİT',
                            color: PixelColors.mint),
                        _PixelStatCard(
                            emoji: '✅',
                            value: '${completions.length}',
                            label: 'BUGÜN',
                            color: const Color(0xFF5A9FD4)),
                        _PixelStatCard(
                            emoji: '⭐',
                            value: streak >= 30
                                ? 'PRO'
                                : streak >= 7
                                    ? 'İYİ'
                                    : 'YENİ',
                            label: 'SEVİYE',
                            color: PixelColors.yellow),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 250.ms, duration: 400.ms)
                        .slideY(begin: 0.1),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────
class _PixelAvatar extends StatelessWidget {
  final String? photoPath;
  final VoidCallback onTap;
  const _PixelAvatar({required this.photoPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF5A9FD4), width: 3),
              boxShadow: const [
                BoxShadow(
                    color: Color(0xFF0A0A1A),
                    offset: Offset(4, 4),
                    blurRadius: 0)
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: photoPath != null
                  ? Image.file(File(photoPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultAvatar())
                  : _defaultAvatar(),
            ),
          ),
          // Kamera butonu — pixel style
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: PixelColors.yellow, width: 2),
              boxShadow: const [
                BoxShadow(
                    color: Color(0xFF0A0A1A),
                    offset: Offset(2, 2),
                    blurRadius: 0)
              ],
            ),
            child: const Icon(Icons.camera_alt_rounded,
                size: 14, color: PixelColors.yellow),
          ),
        ],
      ),
    );
  }

  Widget _defaultAvatar() => Container(
        color: const Color(0xFF1A1A2E),
        child: const Center(child: Text('👤', style: TextStyle(fontSize: 48))),
      );
}

// ── İsim ─────────────────────────────────────────────────────────────────────
class _PixelUsername extends StatelessWidget {
  final TextEditingController controller;
  final String username;
  final bool editing;
  final VoidCallback onEditTap;
  final VoidCallback onSave;

  const _PixelUsername({
    required this.controller,
    required this.username,
    required this.editing,
    required this.onEditTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    if (editing) {
      return Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF5A9FD4), width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xFF0A0A1A),
                      offset: Offset(3, 3),
                      blurRadius: 0)
                ],
              ),
              child: TextField(
                controller: controller,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'PixelFont', fontSize: 10, color: Colors.white),
                cursorColor: PixelColors.yellow,
                decoration: const InputDecoration(
                  hintText: 'İSMİNİ GİR...',
                  hintStyle: TextStyle(
                      fontFamily: 'PixelFont',
                      fontSize: 8,
                      color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                onSubmitted: (_) => onSave(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSave,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: PixelColors.mint,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: PixelColors.mintDark, width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xFF1A4A30),
                      offset: Offset(3, 3),
                      blurRadius: 0)
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onEditTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withOpacity(0.7),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              username.isEmpty ? 'İSİM EKLE...' : username.toUpperCase(),
              style: TextStyle(
                fontFamily: 'PixelFont',
                fontSize: 10,
                letterSpacing: 1,
                color: username.isEmpty ? Colors.white38 : Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit_rounded, size: 14, color: PixelColors.yellow),
          ],
        ),
      ),
    );
  }
}

// ── Stat kart ─────────────────────────────────────────────────────────────────
class _PixelStatCard extends StatelessWidget {
  final String emoji, value, label;
  final Color color;
  const _PixelStatCard(
      {required this.emoji,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.85),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.5),
              offset: const Offset(3, 3),
              blurRadius: 0)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontFamily: 'PixelFont', fontSize: 13, color: color)),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'PixelFont',
                  fontSize: 5,
                  color: Colors.white54,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
