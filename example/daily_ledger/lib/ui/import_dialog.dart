import 'package:flutter/material.dart';
import 'package:fxdart/fxdart.dart' show Debounced, debounce;

import '../logic/export.dart' show csvColumns;
import '../logic/import.dart';
import 'app_shell.dart';
import 'widgets.dart';

/// Paste-and-preview CSV import (Round 7) — the round-trip partner of
/// Export CSV. Parsing reruns on every edit, so the preview line and the
/// "?" dialog always describe exactly what the Import button would commit.
Future<void> showImportDialog(BuildContext context) =>
    showDialog(context: context, builder: (_) => const _ImportDialog());

class _ImportDialog extends StatefulWidget {
  const _ImportDialog();

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  final _controller = TextEditingController();

  /// Reparsing a large paste on every keystroke is wasteful — the same
  /// fxdart `debounce` that guards the entries search guards the preview.
  late final Debounced<String> _debouncedParse = debounce(
    (_) => setState(() {}),
    const Duration(milliseconds: 250),
  );

  @override
  void dispose() {
    _debouncedParse.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = LedgerScope.of(context);
    final theme = Theme.of(context);
    final text = _controller.text;
    final preview = text.trim().isEmpty
        ? null
        : parseCsvEntries(
            text,
            categories: state.categories,
            existing: state.entries,
            idPrefix: 'import-${DateTime.now().millisecondsSinceEpoch}',
          );

    return AlertDialog(
      title: const Text('Import CSV'),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    'split(\\n) → zipWithIndex → map(parse) → compact ×2',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                PipelineHelpButton(
                  explain: () {
                    final p = preview;
                    final lineCount = text
                        .split('\n')
                        .where((l) => l.trim().isNotEmpty)
                        .length;
                    return PipelineExplanation(
                      title: 'CSV import',
                      formula:
                          'split(\'\\n\') → zipWithIndex → filter(nonEmpty)\n'
                          '→ map(splitCsvLine → zip(header, cells) → fromEntries\n'
                          '        → Entry | ImportIssue)\n'
                          '→ compact(entries) · compact(issues)',
                      steps: [
                        PipelineStep(
                          'split → zipWithIndex',
                          'every line keeps its 1-based number for '
                              'line-precise error messages',
                          p == null ? 'nothing pasted' : '$lineCount lines',
                        ),
                        PipelineStep(
                          'zip(header, cells) → fromEntries',
                          'each row married to the ${csvColumns.length}-column '
                              'header as a map',
                          'columns: ${csvColumns.join(', ')}',
                        ),
                        PipelineStep(
                          'map(parse) → compact ×2',
                          'a row becomes either an Entry or an issue; compact '
                              'separates the two streams',
                          p == null
                              ? '—'
                              : '${p.entries.length} entries · ${p.issues.length} issues',
                        ),
                        PipelineStep(
                          'filter(existing dup key)',
                          'same title + amount + day as an existing entry '
                              '(the possibleDuplicates key)',
                          p == null ? '—' : '${p.duplicateCount} duplicates',
                        ),
                      ],
                      result:
                          'Import commits with ONE bulk upsert — one Hive '
                          'write, one notifyListeners',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 10,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: InputDecoration(
                hintText:
                    'Paste CSV here — header must be:\n'
                    '${csvColumns.join(',')}',
                border: const OutlineInputBorder(),
              ),
              onChanged: _debouncedParse.call,
            ),
            const SizedBox(height: 8),
            if (preview != null) ...[
              Text(
                '${preview.entries.length} rows ready · '
                '${preview.issues.length} issues'
                '${preview.duplicateCount > 0 ? ' · ${preview.duplicateCount} look like existing entries' : ''}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: preview.issues.isEmpty
                      ? null
                      : theme.colorScheme.error,
                ),
              ),
              for (final issue in preview.issues.take(5))
                Text(
                  '· $issue',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              if (preview.issues.length > 5)
                Text(
                  '· +${preview.issues.length - 5} more issues',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              if (preview.duplicateCount > 0)
                Text(
                  'Duplicates import anyway — review them afterwards in '
                  'Insights › Possible duplicates.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: preview == null || preview.entries.isEmpty
              ? null
              : () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  await state.upsertEntries(preview.entries);
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Imported ${preview.entries.length} entries '
                        '(zip → fromEntries → compact)',
                      ),
                    ),
                  );
                },
          child: Text(
            preview == null
                ? 'Import'
                : 'Import ${preview.entries.length} entries',
          ),
        ),
      ],
    );
  }
}
