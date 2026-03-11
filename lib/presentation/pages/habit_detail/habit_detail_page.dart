import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/habit.dart';
import '../../providers/habit_providers.dart';

void showHabitDetail(BuildContext context, WidgetRef ref, Habit habit) {
  HapticFeedback.lightImpact();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _HabitDetailSheet(habit: habit, ref: ref),
  );
}

class _HabitDetailSheet extends ConsumerStatefulWidget {
  final Habit habit;
  final WidgetRef ref;
  const _HabitDetailSheet({required this.habit, required this.ref});

  @override
  ConsumerState<_HabitDetailSheet> createState() => _HabitDetailSheetState();
}

class _HabitDetailSheetState extends ConsumerState<_HabitDetailSheet> {
  bool _editing = false;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.habit.title);
    _descCtrl = TextEditingController(text: widget.habit.description ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final updated = Habit(
      id: widget.habit.id,
      title: title,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      frequency: widget.habit.frequency,
      status: widget.habit.status,
      createdAt: widget.habit.createdAt,
      iconAsset: widget.habit.iconAsset,
    );
    await updateHabit(widget.ref, updated);
    HapticFeedback.lightImpact();
    if (mounted) setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = ref.watch(isHabitCompletedProvider(widget.habit.id));

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF5A9FD4), width: 2),
          boxShadow: const [
            BoxShadow(
                color: Color(0xFF0A0A1A), offset: Offset(4, 4), blurRadius: 0)
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tutamaç
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),

            if (_editing) ...[
              // ── Düzenleme modu ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const Text('✎ DÜZENLEMEMODUᅠ',
                        style: TextStyle(
                            fontFamily: 'PixelFont',
                            fontSize: 7,
                            color: Color(0xFF5A9FD4),
                            letterSpacing: 1)),
                    const SizedBox(height: 16),
                    _PixelTextField(
                        controller: _titleCtrl,
                        hint: 'HABİT ADI',
                        autofocus: true),
                    const SizedBox(height: 10),
                    _PixelTextField(
                        controller: _descCtrl,
                        hint: 'AÇIKLAMA (OPSİYONEL)',
                        maxLines: 3),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                            child: _PixelButton(
                          label: 'İPTAL',
                          color: Colors.white10,
                          borderColor: Colors.white24,
                          shadowColor: Colors.transparent,
                          textColor: Colors.white38,
                          onTap: () => setState(() => _editing = false),
                        )),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _PixelButton(
                          label: 'KAYDET',
                          color: const Color(0xFF5A9FD4),
                          borderColor: const Color(0xFF3A7FB0),
                          shadowColor: const Color(0xFF3A7FB0),
                          textColor: Colors.white,
                          onTap: _save,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // ── Normal mod ──────────────────────────────────────────
              Text(widget.habit.iconAsset ?? '⭐',
                  style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 10),
              Text(
                widget.habit.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 11,
                    color: Colors.white,
                    letterSpacing: 1),
              ),
              if (widget.habit.description != null &&
                  widget.habit.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(widget.habit.description!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'SoftPixel',
                          fontSize: 14,
                          color: Colors.white54)),
                ),
              ],
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? PixelColors.mint.withOpacity(0.2)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: isCompleted ? PixelColors.mint : Colors.white24,
                      width: 1),
                ),
                child: Text(
                  isCompleted ? '✓ BUGÜN TAMAMLANDI' : '○ BUGÜN BEKLİYOR',
                  style: TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 6,
                    color: isCompleted ? PixelColors.mint : Colors.white38,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _PixelButton(
                      label: isCompleted
                          ? 'TAMAMLANMADI OLARAK İŞARETLE'
                          : 'TAMAMLANDI OLARAK İŞARETLE',
                      color: isCompleted ? Colors.white24 : PixelColors.mint,
                      borderColor:
                          isCompleted ? Colors.white38 : PixelColors.mintDark,
                      shadowColor: isCompleted
                          ? Colors.transparent
                          : const Color(0xFF1A4A30),
                      textColor: isCompleted ? Colors.white54 : Colors.white,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        toggleHabitCompletion(widget.ref, widget.habit.id);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 10),
                    _PixelButton(
                      label: 'DÜZENLEMEMODUᅠ',
                      color: const Color(0xFF5A9FD4).withOpacity(0.15),
                      borderColor: const Color(0xFF5A9FD4),
                      shadowColor: const Color(0xFF3A7FB0),
                      textColor: const Color(0xFF5A9FD4),
                      onTap: () => setState(() => _editing = true),
                    ),
                    const SizedBox(height: 10),
                    _PixelButton(
                      label: 'HABİTİ SİL',
                      color: const Color(0xFFE8547A),
                      borderColor: const Color(0xFFB03060),
                      shadowColor: const Color(0xFFB03060),
                      textColor: Colors.white,
                      onTap: () => _confirmDelete(context),
                    ),
                    const SizedBox(height: 10),
                    _PixelButton(
                      label: 'KAPAT',
                      color: Colors.transparent,
                      borderColor: Colors.white24,
                      shadowColor: Colors.transparent,
                      textColor: Colors.white38,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ).animate().slideY(begin: 0.2, duration: 300.ms, curve: Curves.easeOut),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: Color(0xFFE8547A), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 12),
              const Text('HABİTİ SİL?',
                  style: TextStyle(
                      fontFamily: 'PixelFont',
                      fontSize: 10,
                      color: Colors.white,
                      letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(widget.habit.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'SoftPixel',
                      fontSize: 14,
                      color: Colors.white54)),
              const SizedBox(height: 6),
              const Text('Bu işlem geri alınamaz.',
                  style: TextStyle(
                      fontFamily: 'SoftPixel',
                      fontSize: 12,
                      color: Colors.white38)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: _PixelButton(
                    label: 'İPTAL',
                    color: Colors.white10,
                    borderColor: Colors.white24,
                    shadowColor: Colors.transparent,
                    textColor: Colors.white54,
                    onTap: () => Navigator.pop(ctx),
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _PixelButton(
                    label: 'SİL',
                    color: const Color(0xFFE8547A),
                    borderColor: const Color(0xFFB03060),
                    shadowColor: const Color(0xFFB03060),
                    textColor: Colors.white,
                    onTap: () {
                      removeHabit(widget.ref, widget.habit.id);
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── TextField ─────────────────────────────────────────────────────────────────
class _PixelTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool autofocus;
  final int maxLines;

  const _PixelTextField({
    required this.controller,
    required this.hint,
    this.autofocus = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: const Color(0xFF5A9FD4).withOpacity(0.5), width: 2),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        maxLines: maxLines,
        style: const TextStyle(
            fontFamily: 'SoftPixel', fontSize: 15, color: Colors.white),
        cursorColor: PixelColors.yellow,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: 'PixelFont', fontSize: 6, color: Colors.white24),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}

// ── Buton ─────────────────────────────────────────────────────────────────────
class _PixelButton extends StatelessWidget {
  final String label;
  final Color color, borderColor, shadowColor, textColor;
  final VoidCallback onTap;

  const _PixelButton({
    required this.label,
    required this.color,
    required this.borderColor,
    required this.shadowColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: shadowColor == Colors.transparent
              ? null
              : [
                  BoxShadow(
                      color: shadowColor,
                      offset: const Offset(3, 3),
                      blurRadius: 0),
                ],
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'PixelFont',
                fontSize: 7,
                color: textColor,
                letterSpacing: 0.5)),
      ),
    );
  }
}
