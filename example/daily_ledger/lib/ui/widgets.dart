import 'package:flutter/material.dart';

import '../logic/summaries.dart';

/// One step of a pipeline explanation: the operator, what it does here, and
/// the **live** value it produced for the data currently on screen.
class PipelineStep {
  final String op; // e.g. 'filter(month & money)'
  final String what; // plain-language description
  final String value; // live result, e.g. '34 entries'
  const PipelineStep(this.op, this.what, this.value);
}

/// Everything the "?" dialog needs to teach one pipeline.
class PipelineExplanation {
  final String title;
  final String formula;
  final List<PipelineStep> steps;
  final String? result; // final takeaway line, e.g. 'net = +$1,234.56'
  const PipelineExplanation({
    required this.title,
    required this.formula,
    required this.steps,
    this.result,
  });
}

/// The circled "?" CTA shown at the right of every pipeline formula.
///
/// [explain] is a *builder*, invoked at click time — so the dialog always
/// walks the pipeline with the numbers currently on screen.
class PipelineHelpButton extends StatelessWidget {
  final PipelineExplanation Function() explain;
  const PipelineHelpButton({super.key, required this.explain});

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'How is this computed?',
    visualDensity: VisualDensity.compact,
    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    padding: EdgeInsets.zero,
    iconSize: 16,
    icon: Icon(
      Icons.help_outline,
      color: Theme.of(context).colorScheme.primary,
    ),
    onPressed: () => showPipelineDialog(context, explain()),
  );
}

Future<void> showPipelineDialog(BuildContext context, PipelineExplanation e) {
  final theme = Theme.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(e.title),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  e.formula,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              for (final (i, step) in e.steps.indexed) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  step.op,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                step.value,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            step.what,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (i < e.steps.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 9),
                    child: SizedBox(
                      height: 12,
                      child: VerticalDivider(
                        width: 2,
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ),
              ],
              if (e.result != null) ...[
                const Divider(height: 24),
                Text(
                  e.result!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

/// A titled card section — the visual unit of every screen. When [explain]
/// is provided, the formula line gets the circled "?" that opens the live
/// pipeline dialog.
class SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final PipelineExplanation Function()? explain;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.explain,
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
            if (subtitle == null && explain != null)
              Row(
                children: [
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleMedium),
                  ),
                  PipelineHelpButton(explain: explain!),
                ],
              )
            else
              Text(title, style: theme.textTheme.titleMedium),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                    if (explain != null) ...[
                      const SizedBox(width: 4),
                      PipelineHelpButton(explain: explain!),
                    ],
                  ],
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
/// When [projectedFrom] is set, points from that index on render as the
/// faded "future" segment (the cashflow forecast).
class BalanceSparkline extends StatelessWidget {
  final List<BalancePoint> points;
  final int? projectedFrom;
  const BalanceSparkline({super.key, required this.points, this.projectedFrom});

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
          projectedFrom: projectedFrom,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<BalancePoint> points;
  final int? projectedFrom;
  final Color color;
  _SparklinePainter({
    required this.points,
    required this.color,
    this.projectedFrom,
  });

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

    // The history/future boundary (clamped so both segments stay drawable).
    final split = (projectedFrom ?? values.length).clamp(1, values.length);

    final line = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < split; i++) {
      line.lineTo(at(i).dx, at(i).dy);
    }
    final fullLine = Path.from(line);
    for (var i = split; i < values.length; i++) {
      fullLine.lineTo(at(i).dx, at(i).dy);
    }
    final fill = Path.from(fullLine)
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
    if (split < values.length) {
      final projected = Path()..moveTo(at(split - 1).dx, at(split - 1).dy);
      for (var i = split; i < values.length; i++) {
        projected.lineTo(at(i).dx, at(i).dy);
      }
      canvas.drawPath(
        projected,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = color.withValues(alpha: 0.4),
      );
      // Boundary marker: where history hands over to projection.
      canvas.drawCircle(at(split - 1), 3, Paint()..color = color);
    }

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
      !identical(old.points, points) ||
      old.projectedFrom != projectedFrom ||
      old.color != color;
}
