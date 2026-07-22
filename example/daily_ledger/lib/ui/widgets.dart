import 'package:flutter/material.dart';

import '../logic/summaries.dart';

/// A titled card section — the visual unit of every screen.
class SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class EmptyHint extends StatelessWidget {
  final String message;
  const EmptyHint(this.message, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Center(
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.outline),
      ),
    ),
  );
}

/// Sparkline of the running balance (`scan` output) as a CustomPaint.
class BalanceSparkline extends StatelessWidget {
  final List<BalancePoint> points;
  const BalanceSparkline({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) return const EmptyHint('Not enough data yet');
    return SizedBox(
      height: 96,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(
          // The memoized pipeline returns the SAME list instance across
          // rebuilds, so shouldRepaint can compare identity instead of
          // allocating (and repainting) every frame.
          points: points,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<BalancePoint> points;
  final Color color;
  _SparklinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final values = [for (final p in points) p.balance];
    var lo = values.first, hi = values.first;
    for (final v in values) {
      if (v < lo) lo = v;
      if (v > hi) hi = v;
    }
    if (hi == lo) hi = lo + 1;
    Offset at(int i) => Offset(
      i * size.width / (values.length - 1),
      size.height - (values[i] - lo) / (hi - lo) * size.height,
    );

    final line = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      line.lineTo(at(i).dx, at(i).dy);
    }
    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..style = PaintingStyle.fill
        ..color = color.withValues(alpha: 0.12),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color,
    );

    // Zero line, when the balance crosses it.
    if (lo < 0 && hi > 0) {
      final y = size.height - (0 - lo) / (hi - lo) * size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..strokeWidth = 1
          ..color = color.withValues(alpha: 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      !identical(old.points, points) || old.color != color;
}
