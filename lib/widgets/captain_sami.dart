import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';

enum SamiMood { calm, talking, happy, dancing }

/// Captain Sami: an original, clearly fictional cartoon helper drawn in code.
/// Teal-and-sky "helper" outfit with a heart emblem. No badge, no police
/// insignia, no sirens.
///
/// Placeholder artwork: replace with final illustrations/Rive later while
/// keeping this widget's API.
class CaptainSami extends StatefulWidget {
  const CaptainSami({super.key, this.size = 200, this.mood = SamiMood.calm, this.reduceMotion = false});

  final double size;
  final SamiMood mood;
  final bool reduceMotion;

  @override
  State<CaptainSami> createState() => _CaptainSamiState();
}

class _CaptainSamiState extends State<CaptainSami> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 4));

  bool get _still => widget.reduceMotion || (MediaQuery.maybeOf(context)?.disableAnimations ?? false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(CaptainSami oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (_still) {
      _c.stop();
      _c.value = 0.3;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'كابتن سامي',
      image: true,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) => CustomPaint(
            painter: _SamiPainter(t: _c.value, mood: widget.mood, still: _still),
          ),
        ),
      ),
    );
  }
}

class _SamiPainter extends CustomPainter {
  _SamiPainter({required this.t, required this.mood, required this.still});

  final double t;
  final SamiMood mood;
  final bool still;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 200;
    canvas.save();
    canvas.scale(s);

    final wave = math.sin(t * 2 * math.pi);
    final fast = math.sin(t * 2 * math.pi * 4);
    final bob = still ? 0.0 : wave * (mood == SamiMood.dancing ? 6 : 3);
    final sway = (!still && mood == SamiMood.dancing) ? fast * 0.08 : 0.0;

    // Soft shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 192), width: 110, height: 12),
      Paint()..color = Colors.black.withValues(alpha: 0.08),
    );

    canvas.translate(100, 110 + bob);
    canvas.rotate(sway);
    canvas.translate(-100, -110);

    final ink = Paint()..color = AppColors.ink;

    // Body (helper shirt)
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(52, 112, 96, 74), const Radius.circular(36));
    canvas.drawRRect(body, Paint()..color = AppColors.teal);
    // Collar
    final collar = Path()
      ..moveTo(78, 114)
      ..lineTo(100, 132)
      ..lineTo(122, 114)
      ..close();
    canvas.drawPath(collar, Paint()..color = AppColors.sky);
    // Heart emblem
    _heart(canvas, const Offset(100, 158), 13, AppColors.yellow);

    // Arms
    final armPaint = Paint()
      ..color = AppColors.teal
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    final handPaint = Paint()..color = AppColors.skin;
    final happy = mood == SamiMood.happy || mood == SamiMood.dancing;
    final waveAngle = still ? 0.0 : fast * 0.25;
    // Left (viewer's) arm
    final leftHand = happy ? Offset(40 - waveAngle * 20, 92) : const Offset(46, 168);
    canvas.drawLine(const Offset(62, 130), leftHand, armPaint);
    canvas.drawCircle(leftHand, 9, handPaint);
    // Right arm waves when talking/happy
    final rightHand = (mood == SamiMood.calm)
        ? const Offset(154, 168)
        : Offset(162 + waveAngle * 22, 88 - waveAngle.abs() * 10);
    canvas.drawLine(const Offset(138, 130), rightHand, armPaint);
    canvas.drawCircle(rightHand, 9, handPaint);

    // Head
    canvas.drawCircle(const Offset(100, 78), 44, Paint()..color = AppColors.skin);
    // Ears
    canvas.drawCircle(const Offset(57, 82), 8, handPaint);
    canvas.drawCircle(const Offset(143, 82), 8, handPaint);

    // Cap (rounded helper cap, sky blue with heart, no badge)
    final cap = Path()
      ..moveTo(56, 66)
      ..quadraticBezierTo(60, 22, 100, 22)
      ..quadraticBezierTo(140, 22, 144, 66)
      ..close();
    canvas.drawPath(cap, Paint()..color = AppColors.skyDeep);
    final brim = RRect.fromRectAndRadius(const Rect.fromLTWH(50, 60, 100, 12), const Radius.circular(6));
    canvas.drawRRect(brim, Paint()..color = AppColors.tealDeep);
    _heart(canvas, const Offset(100, 44), 9, AppColors.coral);

    // Eyes with blink
    final blinkPhase = (t * 4) % 1.0;
    final blink = (!still && blinkPhase > 0.94) ? 0.15 : 1.0;
    for (final x in [84.0, 116.0]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(x, 84), width: 10, height: 13 * blink), ink);
      if (blink > 0.5) {
        canvas.drawCircle(Offset(x + 2, 81), 2.2, Paint()..color = Colors.white);
      }
    }
    // Soft eyebrows
    final brow = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.7)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCenter(center: const Offset(84, 74), width: 14, height: 6), math.pi, math.pi, false, brow);
    canvas.drawArc(Rect.fromCenter(center: const Offset(116, 74), width: 14, height: 6), math.pi, math.pi, false, brow);

    // Cheeks
    final cheek = Paint()..color = AppColors.coral.withValues(alpha: 0.45);
    canvas.drawCircle(const Offset(72, 98), 7, cheek);
    canvas.drawCircle(const Offset(128, 98), 7, cheek);

    // Mouth
    if (mood == SamiMood.talking && !still) {
      final open = 4 + (math.sin(t * 2 * math.pi * 10).abs()) * 7;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: const Offset(100, 104), width: 20, height: open),
          const Radius.circular(8),
        ),
        Paint()..color = const Color(0xFF8A3B3B),
      );
    } else {
      final smile = Paint()
        ..color = AppColors.ink
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final w = happy ? 30.0 : 22.0;
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(100, 98), width: w, height: happy ? 20 : 14),
        0.15 * math.pi,
        0.7 * math.pi,
        false,
        smile,
      );
    }
    canvas.restore();
  }

  void _heart(Canvas canvas, Offset c, double r, Color color) {
    final p = Path()
      ..moveTo(c.dx, c.dy + r * 0.9)
      ..cubicTo(c.dx - r * 1.6, c.dy - r * 0.2, c.dx - r * 0.6, c.dy - r * 1.3, c.dx, c.dy - r * 0.4)
      ..cubicTo(c.dx + r * 0.6, c.dy - r * 1.3, c.dx + r * 1.6, c.dy - r * 0.2, c.dx, c.dy + r * 0.9)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SamiPainter old) => old.t != t || old.mood != mood || old.still != still;
}
