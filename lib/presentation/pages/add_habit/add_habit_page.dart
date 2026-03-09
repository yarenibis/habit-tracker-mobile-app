// lib/presentation/pages/add_habit/add_habit_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/habit.dart';
import '../../providers/habit_providers.dart';

const _kRadius = 20.0;
const _kBarH   = 52.0;

const _habitColors = [
  Color(0xFF98E4C8), Color(0xFFF4A7B9), Color(0xFFFFD580),
  Color(0xFFAEC6FF), Color(0xFFCFB1FF), Color(0xFFFFB085),
];
const _habitEmojis = [
  '💧','🏃','📚','🧘','🌿','🍎','✏️','🎵',
  '💤','🧹','💊','🌞','🏋️','🚶','🧠','❤️','🌙','⭐',
];

class AddHabitPage extends ConsumerStatefulWidget {
  const AddHabitPage({super.key});

  @override
  ConsumerState<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends ConsumerState<AddHabitPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _titleFocus = FocusNode();

  String _emoji          = '⭐';
  Color  _color          = _habitColors[0];
  HabitFrequency _freq   = HabitFrequency.daily;
  bool   _emojiOpen      = false;
  bool   _saving         = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  bool get _valid => _titleCtrl.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_valid) { HapticFeedback.lightImpact(); _titleFocus.requestFocus(); return; }
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    await addHabit(
      ref,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      emoji: _emoji,
      colorHex: _color.value.toRadixString(16).substring(2).toUpperCase(),
      frequency: _freq,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // ── Bulutlu arka plan ──────────────────────────────────────────────
        body: Stack(
          children: [
            // Arka plan: bg_add_habit.png tam ekran
            Positioned.fill(
              child: Image.asset(
                AppAssets.bgAddHabit, // assets/images/ui/ klasörüne bulutlu arka plan PNG'ni koy, adı: bg_add_habit.png
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFB8D8F0), Color(0xFFD6EEFF)],
                    ),
                  ),
                ),
              ),
            ),

            // İçerik
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildEmojiAndTitle(),
                          const SizedBox(height: 16),
                          if (_emojiOpen) ...[_buildEmojiPicker(), const SizedBox(height: 16)],
                          _buildColorPicker(),
                          const SizedBox(height: 16),
                          _buildDescField(),
                          const SizedBox(height: 16),
                          _buildFrequency(),
                          const SizedBox(height: 32),
                          _buildCreateButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF4A7FA5)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ── Emoji + başlık ─────────────────────────────────────────────────────────
  Widget _buildEmojiAndTitle() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => _emojiOpen = !_emojiOpen),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _color, width: 2.5),
              boxShadow: [BoxShadow(color: _color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Center(child: Text(_emoji, style: const TextStyle(fontSize: 26))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(_kRadius),
              border: Border.all(color: _color.withOpacity(0.6), width: 2),
            ),
            child: TextField(
              controller: _titleCtrl,
              focusNode: _titleFocus,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 13, color: Color(0xFF4A4A6A)),
              decoration: const InputDecoration(
                hintText: 'Habit adı...',
                hintStyle: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Emoji picker ───────────────────────────────────────────────────────────
  Widget _buildEmojiPicker() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(_kRadius),
        border: Border.all(color: _color.withOpacity(0.3), width: 1.5),
      ),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: _habitEmojis.map((e) {
          final sel = e == _emoji;
          return GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); setState(() { _emoji = e; _emojiOpen = false; }); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: sel ? _color.withOpacity(0.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sel ? _color : Colors.transparent, width: 2),
              ),
              child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  // ── Renk seçici ────────────────────────────────────────────────────────────
  Widget _buildColorPicker() {
    return _card(
      child: Row(
        children: _habitColors.map((c) {
          final sel = c == _color;
          return GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); setState(() => _color = c); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: sel ? 36 : 30, height: sel ? 36 : 30,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: c, shape: BoxShape.circle,
                border: Border.all(color: sel ? const Color(0xFF4A4A6A) : Colors.transparent, width: 2.5),
                boxShadow: sel ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 6, offset: const Offset(0, 2))] : null,
              ),
              child: sel ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Açıklama ───────────────────────────────────────────────────────────────
  Widget _buildDescField() {
    return _card(
      child: TextField(
        controller: _descCtrl,
        maxLines: 3,
        style: const TextStyle(fontSize: 12, color: Color(0xFF4A4A6A), height: 1.7),
        decoration: const InputDecoration(
          hintText: 'Neden bu habit önemli? (opsiyonel)',
          hintStyle: TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
      ),
    );
  }

  // ── Sıklık seçici ──────────────────────────────────────────────────────────
  Widget _buildFrequency() {
    return Row(
      children: HabitFrequency.values.map((f) {
        final sel = f == _freq;
        final label = f == HabitFrequency.daily ? '☀️  Her Gün' : '📅  Haftalık';
        return Expanded(
          child: GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); setState(() => _freq = f); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _kBarH,
              margin: EdgeInsets.only(right: f == HabitFrequency.daily ? 8 : 0),
              decoration: BoxDecoration(
                color: sel ? _color.withOpacity(0.25) : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(_kRadius),
                border: Border.all(color: sel ? _color : Colors.white.withOpacity(0.8), width: sel ? 2 : 1.5),
              ),
              child: Center(
                child: Text(label, style: TextStyle(
                  fontSize: 11,
                  color: sel ? const Color(0xFF4A4A6A) : const Color(0xFF9A9AAA),
                )),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Create butonu (asset PNG) ──────────────────────────────────────────────
  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: _save,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // btn_create.png arka plan
            Positioned.fill(
              child: Image.asset(
                AppAssets.btnCreate,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, __, ___) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _valid
                          ? [_color, _color.withOpacity(0.7)]
                          : [Colors.grey.shade300, Colors.grey.shade200],
                    ),
                    borderRadius: BorderRadius.circular(_kRadius),
                    border: Border.all(color: _valid ? _color : Colors.grey.shade300, width: 2),
                  ),
                ),
              ),
            ),
            // Loading veya metin
            if (_saving)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            else
              Text(
                '$_emoji  CREATE',
                style: const TextStyle(fontSize: 13, color: Colors.white, letterSpacing: 1.5),
              ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut).fadeIn();
  }

  // ── Kart sarmalayıcı ───────────────────────────────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(_kRadius),
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
      ),
      child: child,
    );
  }
}
