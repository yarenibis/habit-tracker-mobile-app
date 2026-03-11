import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_theme.dart';

// ─── HABIT BAR — köşeli pixel border ─────────────────────────────────────────
class PixelHabitBar extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const PixelHabitBar({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isCompleted
        ? PixelColors.mint.withOpacity(0.55)
        : Colors.white.withOpacity(0.45);
    final border =
        isCompleted ? PixelColors.mintDark : Colors.white.withOpacity(0.8);
    final shadow = isCompleted ? PixelColors.mintDark : const Color(0xFF7BA7C2);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: bg,
            // Köşeli pixel border — border-radius 0 değil, 6 — hafif keskin
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: border, width: 3),
            boxShadow: [
              // Pixel art drop shadow — sağa ve aşağıya ofset
              BoxShadow(
                  color: shadow.withOpacity(0.5),
                  offset: const Offset(3, 3),
                  blurRadius: 0),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onToggle,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      isCompleted
                          ? AppAssets.checkboxDone
                          : AppAssets.checkboxEmpty,
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (_, __, ___) => Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isCompleted ? PixelColors.mint : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: isCompleted
                                  ? PixelColors.mintDark
                                  : PixelColors.textMedium,
                              width: 2),
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check,
                                size: 18, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'SoftPixel',
                      fontSize: 16,
                      color: isCompleted
                          ? PixelColors.textDark.withOpacity(0.5)
                          : PixelColors.textDark,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: PixelColors.textDark.withOpacity(0.4),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideX(begin: 0.04, end: 0);
  }
}

// ─── PROGRESS BAR ─────────────────────────────────────────────────────────────
class PixelProgressBar extends StatelessWidget {
  final double progress;
  const PixelProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      width: double.infinity,
      child: CustomPaint(
        painter: _ProgressPainter(progress: progress.clamp(0.0, 1.0)),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  _ProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const r = 4.0; // köşeli
    final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(r));

    // Arka plan
    canvas.drawRRect(bgRect, Paint()..color = Colors.white.withOpacity(0.3));

    // Dolum
    if (progress > 0) {
      final fillRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width * progress, size.height),
          const Radius.circular(r));
      canvas.drawRRect(
          fillRect, Paint()..color = PixelColors.pink.withOpacity(0.8));
      // Pixel parlama — üst şerit
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(2, 2, (size.width * progress) - 4, size.height * 0.3),
            const Radius.circular(2)),
        Paint()..color = Colors.white.withOpacity(0.3),
      );
    }

    // Dış border
    canvas.drawRRect(
      bgRect,
      Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Pixel drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(3, 3, size.width, size.height),
          const Radius.circular(r)),
      Paint()..color = Colors.black.withOpacity(0.08),
    );
  }

  @override
  bool shouldRepaint(_ProgressPainter old) => old.progress != progress;
}

// ─── ADD (+) BUTONU ───────────────────────────────────────────────────────────
class PixelAddButton extends StatelessWidget {
  final VoidCallback onTap;
  const PixelAddButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        AppAssets.btnAdd,
        width: 64,
        height: 64,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        errorBuilder: (_, __, ___) => Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: PixelColors.pink,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFB03060), width: 3),
            boxShadow: const [
              BoxShadow(
                  color: Color(0xFFB03060), offset: Offset(3, 3), blurRadius: 0)
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    ).animate().scale(
        begin: const Offset(0.85, 0.85),
        duration: 400.ms,
        curve: Curves.elasticOut);
  }
}

// ─── SAHNE KARTI ──────────────────────────────────────────────────────────────
class PixelSceneCard extends StatelessWidget {
  final String assetPath;
  final String description;

  const PixelSceneCard(
      {super.key, required this.assetPath, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.2,
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, __, ___) => const Center(
                child: Text('🎮', style: TextStyle(fontSize: 64)),
              ),
            ),
          ),
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SoftPixel',
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
