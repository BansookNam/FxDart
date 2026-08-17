import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:fxdart/fxdart.dart' show Nel;

import '../logic/errors.dart';

/// The one error surface in the app — every failure that reaches the user
/// comes through here (typed-errors series, round 11, chapter `NonEmptyList`).
///
/// It takes a `Nel`, not a `List`, and that is load-bearing:
///
/// - `errors.head` is **total**. There is no "what if it's empty" branch,
///   because an error panel with no errors is not a thing. Absence is
///   modelled by not building the widget at all (`Nel.orNull` returns null).
/// - `errors.tail` is possibly empty, which is exactly the "and N more"
///   disclosure — it collapses on its own.
class ErrorPanel extends StatefulWidget {
  final Nel<LedgerError> errors;

  /// Headline prefix, e.g. "Could not save". The first error follows it.
  final String? title;

  /// Shows a "Copy report" action. Off inside tight dialogs.
  final bool copyable;

  const ErrorPanel({
    super.key,
    required this.errors,
    this.title,
    this.copyable = true,
  });

  @override
  State<ErrorPanel> createState() => _ErrorPanelState();
}

class _ErrorPanelState extends State<ErrorPanel> {
  bool _expanded = false;

  /// Bumped only when the error set actually changes — see [didUpdateWidget].
  int _generation = 0;

  @override
  void didUpdateWidget(ErrorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `Nel` is an extension type, so it cannot override `==` — equality stays
    // `List` identity, and `widget.errors != oldWidget.errors` is therefore
    // ALWAYS true for a freshly validated list. Using it here would replay
    // the entrance animation on every keystroke. `deepEquals` is the
    // structural comparison the type forces you to reach for.
    if (!widget.errors.deepEquals(oldWidget.errors)) {
      setState(() {
        _generation++;
        _expanded = false;
      });
    }
  }

  Future<void> _copy() async {
    // `toList()` hands out a defensive copy, so the clipboard text can never
    // observe a later mutation of the panel's list.
    final lines = widget.errors.toList().map((e) => e.message).join('\n');
    await Clipboard.setData(ClipboardData(text: lines));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Problem report copied')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errors = widget.errors;
    final rest = errors.tail;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Container(
        key: ValueKey(_generation),
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 18,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  // `head` — no emptiness check, by construction.
                  child: Text(
                    widget.title == null
                        ? errors.head.message
                        : '${widget.title}: ${errors.head.message}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.copyable)
                  IconButton(
                    tooltip: 'Copy report',
                    visualDensity: VisualDensity.compact,
                    iconSize: 16,
                    color: theme.colorScheme.onErrorContainer,
                    icon: const Icon(Icons.copy_all),
                    onPressed: _copy,
                  ),
              ],
            ),
            // `tail` is possibly empty — the disclosure disappears by itself.
            if (rest.isNotEmpty) ...[
              const SizedBox(height: 4),
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    _expanded
                        ? 'Hide the other ${rest.length}'
                        : 'and ${rest.length} more',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              if (_expanded)
                for (final error in rest)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, left: 26),
                    child: Text(
                      '· ${error.message}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
