import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/badge_definitions.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/habit_providers.dart';
import '../../providers/progress_providers.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: PixelColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/ui/oyun1.jpg',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, __, ___) =>
                  Container(color: PixelColors.background),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _TopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatsRow(streak: streak),
                        const SizedBox(height: 20),
                        const _PixelCalendarSection(),
                        const SizedBox(height: 20),
                        const _BadgeGallerySection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Pixel geri butonu
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF5A9FD4), width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xFF0A0A1A),
                      offset: Offset(2, 2),
                      blurRadius: 0)
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 14, color: Colors.white),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF5A9FD4), width: 2),
              boxShadow: const [
                BoxShadow(
                    color: Color(0xFF0A0A1A),
                    offset: Offset(2, 2),
                    blurRadius: 0)
              ],
            ),
            child: const Text(
              '★ İLERLEME ★',
              style: TextStyle(
                  fontFamily: 'PixelFont',
                  fontSize: 8,
                  color: PixelColors.yellow,
                  letterSpacing: 1),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 36),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ── Stat kartları ──────────────────────────────────────────────────────────────
class _StatsRow extends ConsumerWidget {
  final int streak;
  const _StatsRow({required this.streak});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(unlockedBadgesProvider);
    final stats = ref.watch(monthStatsProvider);
    return Row(
      children: [
        _StatCard(
            emoji: '🔥',
            value: '$streak',
            label: 'STREAK',
            color: const Color(0xFFFF6B35)),
        const SizedBox(width: 10),
        _StatCard(
            emoji: '⚔️',
            value: '${stats.perfectDays}',
            label: 'MÜKEMMEL',
            color: PixelColors.mint),
        const SizedBox(width: 10),
        _StatCard(
            emoji: '🏅',
            value: '${unlocked.length}',
            label: 'BADGE',
            color: PixelColors.yellow),
      ],
    ).animate().slideY(begin: 0.1, duration: 400.ms).fadeIn();
  }
}

class _StatCard extends StatelessWidget {
  final String emoji, value, label;
  final Color color;
  const _StatCard(
      {required this.emoji,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontFamily: 'PixelFont', fontSize: 14, color: color)),
            const SizedBox(height: 3),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 5,
                    color: Colors.white70,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

// ── Takvim ─────────────────────────────────────────────────────────────────────
class _PixelCalendarSection extends ConsumerWidget {
  const _PixelCalendarSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final completionMapAsync = ref.watch(monthlyCompletionMapProvider);
    final months = [
      'OCAK',
      'ŞUBAT',
      'MART',
      'NİSAN',
      'MAYIS',
      'HAZİRAN',
      'TEMMUZ',
      'AĞUSTOS',
      'EYLÜL',
      'EKİM',
      'KASIM',
      'ARALIK'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('📅 TAKVİM'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withOpacity(0.85),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF5A9FD4), width: 2),
            boxShadow: const [
              BoxShadow(
                  color: Color(0xFF0A0A1A), offset: Offset(4, 4), blurRadius: 0)
            ],
          ),
          child: Column(
            children: [
              // Ay navigasyon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CalNavBtn(
                      icon: Icons.chevron_left,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(selectedMonthProvider.notifier).state =
                            DateTime(
                                selectedMonth.year, selectedMonth.month - 1);
                      }),
                  Text(
                    '${months[selectedMonth.month - 1]} ${selectedMonth.year}',
                    style: const TextStyle(
                        fontFamily: 'PixelFont',
                        fontSize: 8,
                        color: PixelColors.yellow,
                        letterSpacing: 1),
                  ),
                  _CalNavBtn(
                      icon: Icons.chevron_right,
                      onTap: () {
                        final next = DateTime(
                            selectedMonth.year, selectedMonth.month + 1);
                        if (!next.isAfter(DateTime.now())) {
                          HapticFeedback.selectionClick();
                          ref.read(selectedMonthProvider.notifier).state = next;
                        }
                      }),
                ],
              ),
              const SizedBox(height: 12),
              // Gün başlıkları
              Row(
                children: ['PT', 'SA', 'ÇA', 'PE', 'CU', 'CT', 'PZ']
                    .map((d) => Expanded(
                        child: Center(
                            child: Text(d,
                                style: const TextStyle(
                                    fontFamily: 'PixelFont',
                                    fontSize: 6,
                                    color: Color(0xFF5A9FD4))))))
                    .toList(),
              ),
              const SizedBox(height: 8),
              completionMapAsync.when(
                data: (map) =>
                    _CalendarGrid(month: selectedMonth, completionMap: map),
                loading: () => const SizedBox(
                    height: 160,
                    child: Center(
                        child: Text('...',
                            style: TextStyle(
                                fontFamily: 'PixelFont',
                                fontSize: 10,
                                color: Colors.white54)))),
                error: (_, __) => const SizedBox(height: 160),
              ),
              const SizedBox(height: 12),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Legend(color: PixelColors.mint, label: 'TAM'),
                  const SizedBox(width: 14),
                  _Legend(color: PixelColors.yellow, label: 'KISMİ'),
                  const SizedBox(width: 14),
                  _Legend(color: const Color(0xFFE8547A), label: 'BOŞ'),
                ],
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final Map<DateTime, double> completionMap;
  const _CalendarGrid({required this.month, required this.completionMap});

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final startOffset = firstDay.weekday - 1;
    final rows = ((startOffset + daysInMonth) / 7).ceil();
    final today = DateTime.now();

    return Column(
      children: List.generate(rows, (rowIdx) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: List.generate(7, (colIdx) {
              final day = rowIdx * 7 + colIdx - startOffset + 1;
              if (day < 1 || day > daysInMonth)
                return const Expanded(child: SizedBox());
              final date = DateTime(month.year, month.month, day);
              final isFuture = date.isAfter(today);
              final isToday = DateUtils.isSameDay(date, today);
              final rate = completionMap[date];

              Color cellColor;
              String symbol = '';
              if (isFuture) {
                cellColor = Colors.white.withOpacity(0.05);
              } else if (rate == null || rate == 0.0) {
                cellColor = const Color(0xFFE8547A).withOpacity(0.3);
                symbol = '✗';
              } else if (rate >= 1.0) {
                cellColor = PixelColors.mint.withOpacity(0.4);
                symbol = '✓';
              } else {
                cellColor = PixelColors.yellow.withOpacity(0.35);
                symbol = '~';
              }

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(3),
                        border: isToday
                            ? Border.all(color: PixelColors.yellow, width: 2)
                            : Border.all(
                                color: Colors.white.withOpacity(0.1), width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$day',
                              style: TextStyle(
                                fontFamily: 'PixelFont',
                                fontSize: 6,
                                color: isFuture ? Colors.white24 : Colors.white,
                              )),
                          if (symbol.isNotEmpty)
                            Text(symbol,
                                style: TextStyle(
                                  fontSize: 7,
                                  color: rate != null && rate >= 1.0
                                      ? PixelColors.mint
                                      : rate != null && rate > 0
                                          ? PixelColors.yellow
                                          : const Color(0xFFE8547A),
                                )),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

// ── Badge galerisi ─────────────────────────────────────────────────────────────
class _BadgeGallerySection extends ConsumerWidget {
  const _BadgeGallerySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(unlockedBadgesProvider);
    final locked = ref.watch(lockedBadgesProvider);
    final nextBadge = ref.watch(nextBadgeProvider);
    final streak = ref.watch(streakProvider).valueOrNull ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SectionTitle('🏅 BADGE\'LER'),
            const Spacer(),
            Text('${unlocked.length}/${BadgeDefinitions.all.length}',
                style: const TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 7,
                    color: PixelColors.yellow)),
          ],
        ),
        const SizedBox(height: 10),
        if (nextBadge != null) ...[
          _NextBadgeCard(badge: nextBadge, streak: streak),
          const SizedBox(height: 14),
        ],
        if (unlocked.isNotEmpty) ...[
          const _SubLabel('✦ KAZANILDI'),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.85),
            itemCount: unlocked.length,
            itemBuilder: (_, i) =>
                _BadgeCard(badge: unlocked[i], isUnlocked: true)
                    .animate(delay: Duration(milliseconds: i * 60))
                    .scale(
                        begin: const Offset(0.7, 0.7),
                        duration: 400.ms,
                        curve: Curves.elasticOut),
          ),
          const SizedBox(height: 16),
        ],
        if (locked.isNotEmpty) ...[
          const _SubLabel('🔒 KİLİTLİ'),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.85),
            itemCount: locked.length,
            itemBuilder: (_, i) =>
                _BadgeCard(badge: locked[i], isUnlocked: false)
                    .animate(delay: Duration(milliseconds: i * 40))
                    .fadeIn(duration: 300.ms),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }
}

class _NextBadgeCard extends StatelessWidget {
  final BadgeDefinition badge;
  final int streak;
  const _NextBadgeCard({required this.badge, required this.streak});

  @override
  Widget build(BuildContext context) {
    final remaining = badge.requiredStreak - streak;
    final progress = (streak / badge.requiredStreak).clamp(0.0, 1.0);
    final rarityColor = Color(badge.rarity.colorValue);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.85),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: rarityColor, width: 2),
        boxShadow: [
          BoxShadow(
              color: rarityColor.withOpacity(0.4),
              offset: const Offset(3, 3),
              blurRadius: 0)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: rarityColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: rarityColor.withOpacity(0.5), width: 2),
            ),
            child: Center(
                child: Text(badge.emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(badge.title,
                    style: const TextStyle(
                        fontFamily: 'PixelFont',
                        fontSize: 8,
                        color: Colors.white,
                        letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(badge.description,
                    style: const TextStyle(
                        fontFamily: 'SoftPixel',
                        fontSize: 11,
                        color: Colors.white60)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: rarityColor.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(rarityColor),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text('$remaining gün kaldı',
                    style: TextStyle(
                        fontFamily: 'PixelFont',
                        fontSize: 6,
                        color: rarityColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final BadgeDefinition badge;
  final bool isUnlocked;
  const _BadgeCard({required this.badge, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    final rarityColor = Color(badge.rarity.colorValue);
    return GestureDetector(
      onTap: isUnlocked ? () => _showDetail(context) : null,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withOpacity(isUnlocked ? 0.9 : 0.5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isUnlocked ? rarityColor : Colors.white24,
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                      color: rarityColor.withOpacity(0.4),
                      offset: const Offset(2, 2),
                      blurRadius: 0)
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isUnlocked
                ? Text(badge.emoji, style: const TextStyle(fontSize: 24))
                : Stack(alignment: Alignment.center, children: [
                    Text(badge.emoji,
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.black.withOpacity(0.1))),
                    const Text('🔒', style: TextStyle(fontSize: 16)),
                  ]),
            const SizedBox(height: 4),
            Text(badge.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 5,
                    color: isUnlocked ? Colors.white : Colors.white30)),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          border: Border(top: BorderSide(color: Color(0xFF5A9FD4), width: 3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(badge.emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(badge.title,
                style: const TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 12,
                    color: PixelColors.yellow,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            Text(badge.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'SoftPixel',
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.8)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Yardımcılar ───────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontFamily: 'PixelFont',
          fontSize: 9,
          color: Colors.white,
          letterSpacing: 1.5));
}

class _SubLabel extends StatelessWidget {
  final String text;
  const _SubLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontFamily: 'PixelFont',
          fontSize: 7,
          color: Colors.white54,
          letterSpacing: 1));
}

class _CalNavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CalNavBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF5A9FD4).withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF5A9FD4), width: 2),
          ),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
      );
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'PixelFont', fontSize: 6, color: Colors.white70)),
        ],
      );
}
