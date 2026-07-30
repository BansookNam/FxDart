import 'package:flutter/material.dart';
import 'package:fxdart/fxdart.dart' show Debounced, debounce;

import '../logic/errors.dart';
import '../logic/export.dart' show csvColumns;
import '../logic/import.dart';
import 'app_shell.dart';
import 'widgets.dart';

/// Paste-and-preview CSV import (Round 7) — the round-trip partner of
/// Export CSV. Parsing reruns on every edit, so the preview line and the
/// "?" dialog always describe exactly what the Import button would commit.
///
/// Round 10 (typed-errors series) added the **strictness selector**: the same
/// row parser feeds three `Either` terminals, and switching between them
/// changes nothing but the terminal — see [ImportMode].
Future<void> showImportDialog(BuildContext context) =>
    showDialog(context: context, builder: (_) => const _ImportDialog());

/// Copy for the three modes: label, the terminal it maps to, and what it does.
const _modeInfo = {
  ImportMode.lenient: (
    label: 'Lenient',
    terminal: 'separated()',
    blurb: 'import the good rows, list the bad ones',
  ),
  ImportMode.strict: (
    label: 'Strict',
    terminal: 'sequence()',
    blurb: 'the first bad row aborts the whole import',
  ),
  ImportMode.report: (
    label: 'Report',
    terminal: 'mapOrAccumulate()',
    blurb: 'import nothing; list every bad row',
  ),
};

class _ImportDialog extends StatefulWidget {
  const _ImportDialog();

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  final _controller = TextEditingController();
  ImportMode _mode = ImportMode.lenient;

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
    final info = _modeInfo[_mode]!;
    final preview = text.trim().isEmpty
        ? null
        : parseCsvEntries(
            text,
            categories: state.categories,
            existing: state.entries,
            idPrefix: 'import-${DateTime.now().millisecondsSinceEpoch}',
            mode: _mode,
          );

    return AlertDialog(
      title: const Text('Import CSV'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'map(parseRow) → ${info.terminal}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  PipelineHelpButton(explain: () => _explain(preview, text)),
                ],
              ),
              const SizedBox(height: 8),
              SegmentedButton<ImportMode>(
                showSelectedIcon: false,
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                segments: [
                  for (final mode in ImportMode.values)
                    ButtonSegment(
                      value: mode,
                      label: Text(_modeInfo[mode]!.label),
                      tooltip: _modeInfo[mode]!.blurb,
                    ),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  info.blurb,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                maxLines: 8,
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
              if (preview != null) _Preview(preview: preview),
            ],
          ),
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
                        '(${info.terminal})',
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

  PipelineExplanation _explain(ImportPreview? p, String text) {
    final info = _modeInfo[_mode]!;
    final lineCount = text.split('\n').where((l) => l.trim().isNotEmpty).length;
    return PipelineExplanation(
      title: 'CSV import — ${info.label}',
      formula:
          'split(\'\\n\') → zipWithIndex → filter(nonEmpty)\n'
          '→ map(parseRow)            // Either<RowError, Entry>\n'
          '→ ${info.terminal}',
      steps: [
        PipelineStep(
          'split → zipWithIndex',
          'every line keeps its 1-based number, so an error can name the '
              'line it came from',
          p == null ? 'nothing pasted' : '$lineCount lines',
        ),
        PipelineStep(
          'zip(header, cells) → fromEntries',
          'each row married to the ${csvColumns.length}-column header as a map',
          'columns: ${csvColumns.join(', ')}',
        ),
        PipelineStep(
          'either((r) => r.withError(…))',
          'one raise scope per row: ensure / ensureNotNull raise a FieldError, '
              'withError re-types it into a RowError carrying the line number. '
              'The first bad column wins — this row is fail-fast.',
          p == null ? '—' : '${p.rows.length} rows parsed',
        ),
        PipelineStep(
          info.terminal,
          switch (_mode) {
            ImportMode.lenient =>
              'partition for Either: (lefts, rights) in one walk — bad rows '
                  'are reported, good rows still import',
            ImportMode.strict =>
              'stops at the first Left and yields nothing else, so one bad '
                  'row means an all-or-nothing import',
            ImportMode.report =>
              'keeps walking after a failure, so the report is every bad row '
                  'rather than just the first — but commits nothing',
          },
          p == null
              ? '—'
              : '${p.entries.length} to import · ${p.issueCount} problems',
        ),
        PipelineStep(
          'filter(existing dup key)',
          'same title + amount + day as an existing entry '
              '(the possibleDuplicates key)',
          p == null ? '—' : '${p.duplicateCount} duplicates',
        ),
      ],
      result: p == null
          ? 'Paste a CSV to see the pipeline run'
          : p.isClean
          ? 'Right — ${p.entries.length} entries, committed with ONE bulk '
                'upsert'
          : 'Left — ${p.issues!.head.message}'
                '${p.issueCount > 1 ? ' (+${p.issueCount - 1} more)' : ''}',
    );
  }
}

/// The preview summary + problem list. Reads `issues` as a `Nel`, so the
/// headline (`head`) needs no emptiness check and the rest (`tail`) collapses
/// away on its own.
class _Preview extends StatelessWidget {
  final ImportPreview preview;
  const _Preview({required this.preview});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final issues = preview.issues;
    final aborted = preview.entries.isEmpty && preview.healthyCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${preview.entries.length} rows ready · ${preview.issueCount} '
          'problems'
          '${preview.duplicateCount > 0 ? ' · ${preview.duplicateCount} look like existing entries' : ''}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: preview.isClean ? null : theme.colorScheme.error,
          ),
        ),
        if (aborted)
          Text(
            '${preview.healthyCount} rows parsed fine — '
            '${_modeInfo[preview.mode]!.label} mode commits none of them.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        if (issues != null) ...[
          // head is total: a Nel cannot be empty, so there is always a
          // headline to show.
          _IssueLine(issues.head, theme: theme),
          for (final issue in issues.tail.take(4))
            _IssueLine(issue, theme: theme),
          if (issues.tail.length > 4)
            Text(
              '· +${issues.tail.length - 4} more problems',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
        ],
        if (preview.duplicateCount > 0)
          Text(
            'Duplicates import anyway — review them afterwards in '
            'Insights › Possible duplicates.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
      ],
    );
  }
}

class _IssueLine extends StatelessWidget {
  final RowError issue;
  final ThemeData theme;
  const _IssueLine(this.issue, {required this.theme});

  @override
  Widget build(BuildContext context) => Text(
    '· ${issue.message}',
    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
  );
}
