import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../logic/summaries.dart';

/// Base URL of the FxDart 101 tutorials — each function has its own lecture at
/// `<base><fn>.html`. Absolute (not relative to `Uri.base`) so the links reach
/// the live docs even when the demo runs on localhost.
const _tutorialBase = 'https://bansooknam.github.io/FxDart/tutorials/';

/// FxDart function names that have a 101 lecture page. An identifier appearing
/// in a pipeline formula/op that matches one of these is rendered as a link to
/// its tutorial; everything else (args, `monthGrid`, `→`, …) stays plain text.
/// Kept in sync with `docs/tutorials/*.html`.
const _linkableFns = <String>{
  'add', 'always', 'append', 'apply', 'average', 'averageBy', 'chunk',
  'compact', 'compactObject', 'compress', 'concat', 'concurrent',
  'concurrentPool', 'consume', 'countBy', 'createSeededRandom', 'cycle',
  'debounce', 'delay', 'difference', 'differenceBy', 'drop', 'dropRight',
  'dropUntil', 'dropWhile', 'each', 'entries', 'every', 'evolve', 'filter',
  'find', 'findIndex', 'flat', 'flatMap', 'fold', 'fork', 'fromEntries', 'fx',
  'groupBy', 'head', 'identity', 'includes', 'indexBy', 'intersection',
  'intersectionBy', 'isEmpty', 'isMatch', 'join', 'juxt', 'keys', 'last',
  'map', 'mapEffect', 'matches', 'max', 'maxBy', 'memoize', 'min', 'minBy',
  'negate', 'not', 'nth', 'omit', 'omitBy', 'partition', 'peek', 'pick',
  'pickBy', 'pipe', 'pipe1', 'pluck', 'prepend', 'prop', 'props', 'range',
  'reduce', 'reduceLazy', 'reject', 'repeat', 'resolveProps', 'reverse',
  'scan', 'shuffle', 'size', 'slice', 'some', 'sort', 'sortBy', 'split', 'sum',
  'sumBy', 'take', 'takeRight', 'takeUntilInclusive', 'takeWhile', 'tap',
  'throttle', 'throwError', 'throwIf', 'toAsync', 'toList', 'transpose',
  'unicodeToArray', 'unicodeToList', 'uniq', 'uniqBy', 'unless', 'values',
  'when', 'zip', 'zipWith', 'zipWithIndex',
};

/// Matches an FxDart-style identifier (letters, digits, underscores).
final _identifier = RegExp(r'[A-Za-z_][A-Za-z0-9_]*');

Future<void> _openTutorial(String fn) => launchUrl(
  Uri.parse('$_tutorialBase$fn.html'),
  webOnlyWindowName: '_blank',
);

/// Renders a pipeline op/formula string as monospace text where every FxDart
/// function name is a link to its 101 lecture (opens in a new tab). Owns the
/// tap recognisers so they are disposed with the widget.
class LinkedPipelineText extends StatefulWidget {
  final String text;
  final double fontSize;

  /// Colour for the non-link parts. Links always use the primary colour.
  final Color? baseColor;
  const LinkedPipelineText(
    this.text, {
    super.key,
    this.fontSize = 13,
    this.baseColor,
  });

  @override
  State<LinkedPipelineText> createState() => _LinkedPipelineTextState();
}

class _LinkedPipelineTextState extends State<LinkedPipelineText> {
  final List<TapGestureRecognizer> _recognizers = [];

  void _clearRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _clearRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _clearRecognizers();
    final theme = Theme.of(context);
    final base = TextStyle(
      fontFamily: 'monospace',
      fontSize: widget.fontSize,
      color: widget.baseColor,
    );
    final link = base.copyWith(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary.withValues(alpha: 0.5),
    );

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final m in _identifier.allMatches(widget.text)) {
      if (m.start > cursor) {
        spans.add(TextSpan(text: widget.text.substring(cursor, m.start)));
      }
      final word = m[0]!;
      if (_linkableFns.contains(word)) {
        final recognizer = TapGestureRecognizer()
          ..onTap = () => _openTutorial(word);
        _recognizers.add(recognizer);
        spans.add(
          TextSpan(text: word, style: link, recognizer: recognizer),
        );
      } else {
        spans.add(TextSpan(text: word));
      }
      cursor = m.end;
    }
    if (cursor < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(cursor)));
    }

    return Text.rich(TextSpan(style: base, children: spans));
  }
}

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
                child: LinkedPipelineText(e.formula),
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
                                child: LinkedPipelineText(
                                  step.op,
                                  baseColor: theme.colorScheme.onSurfaceVariant,
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
