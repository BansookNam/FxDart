import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:fxdart/fxdart.dart' show Debounced, debounce, fx;

import '../logic/export.dart';

import '../logic/calendar.dart' show dayKey;
import '../logic/summaries.dart';
import '../models/models.dart';
import 'app_shell.dart';
import 'entry_form.dart';
import 'format.dart';
import 'import_dialog.dart';
import 'theme.dart';
import 'widgets.dart';

class EntriesScreen extends StatefulWidget {
  const EntriesScreen({super.key});

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  EntryType? _typeFilter;
  String _query = '';

  /// fxdart's `debounce`: keystrokes only reach setState after 250ms of quiet.
  late final Debounced<String> _debouncedSearch = debounce(
    (q) => setState(() => _query = q),
    const Duration(milliseconds: 250),
  );

  @override
  void dispose() {
    _debouncedSearch.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = LedgerScope.of(context);
    final searched = searchEntries(state.entries, _query);
    // Counts reflect the search too, so chip badges match the visible list.
    final counts = typeCounts(searched, state.month);
    final filtered = fx(
      searched,
    ).filter((e) => _typeFilter == null || e.type == _typeFilter).toList();
    final grouped = entriesByDayDesc(filtered, state.month);
    // Exactly what the list below shows (month-scoped), for WYSIWYG export.
    final visible = fx(grouped).flatMap((g) => g.$2).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search title or tag (debounced 250ms)…',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: _debouncedSearch.call,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final csv = entriesToCsv(
                    visible,
                    categories: state.categoryIndex,
                  );
                  await Clipboard.setData(ClipboardData(text: csv));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Copied the ${visible.length} visible entries as CSV '
                          '(sortBy \u2192 map \u2192 pick \u2192 join)',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy_all, size: 18),
                label: const Text('Export CSV'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => showImportDialog(context),
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Import CSV'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => showEntryForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Add entry'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (final type in [null, ...EntryType.values])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      type == null
                          ? 'All'
                          : '${type.label} (${counts[type] ?? 0})',
                    ),
                    selected: _typeFilter == type,
                    onSelected: (_) => setState(() => _typeFilter = type),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  'debounce(250ms) → filter(query) → filter(type) → '
                  'groupBy(day) → sortBy(day desc)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              PipelineHelpButton(
                explain: () => PipelineExplanation(
                  title: 'Entries list',
                  formula:
                      'debounce(250ms, query)\n'
                      '→ filter(title|tag contains query)\n'
                      '→ filter(type == chip)\n'
                      '→ groupBy(day) → sortBy(day desc)',
                  steps: [
                    PipelineStep(
                      'debounce(250ms)',
                      'keystrokes only reach the pipeline after 250ms of quiet',
                      _query.isEmpty ? 'no query' : 'query: "$_query"',
                    ),
                    PipelineStep(
                      'filter(query)',
                      'case-insensitive match on title and tags',
                      '${searched.length} of ${state.entries.length} entries',
                    ),
                    PipelineStep(
                      'filter(type)',
                      _typeFilter == null
                          ? 'chip "All" — nothing filtered here'
                          : 'chip "${_typeFilter!.label}" only',
                      '${filtered.length} entries',
                    ),
                    PipelineStep(
                      'filter(month) → groupBy(day) → sortBy',
                      'this month\'s survivors, one card per day, newest day first',
                      '${visible.length} entries in ${grouped.length} days',
                    ),
                    PipelineStep(
                      'countBy(type)',
                      'chip badges — counted over the searched list, so '
                          'badges always match what you see',
                      counts.entries
                              .map((kv) => '${kv.key.label} ${kv.value}')
                              .join(' · ')
                              .isEmpty
                          ? 'no entries'
                          : counts.entries
                                .map((kv) => '${kv.key.label} ${kv.value}')
                                .join(' · '),
                    ),
                  ],
                  result:
                      'Export CSV copies exactly these ${visible.length} rows '
                      '(sortBy → map → pick → join)',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: grouped.isEmpty
              ? const EmptyHint('No entries match — try clearing the search')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: grouped.length,
                  itemBuilder: (context, i) {
                    final (day, entries) = grouped[i];
                    return _DayGroup(day: day, entries: entries);
                  },
                ),
        ),
      ],
    );
  }
}

class _DayGroup extends StatelessWidget {
  final DateTime day;
  final List<Entry> entries;
  const _DayGroup({required this.day, required this.entries});

  @override
  Widget build(BuildContext context) {
    final state = LedgerScope.of(context);
    final theme = Theme.of(context);
    final isToday = dayKey(day) == dayKey(state.today);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            isToday ? 'Today · ${dayLabel(day)}' : dayLabel(day),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (final e in entries)
                ListTile(
                  dense: true,
                  leading: Icon(
                    categoryIcon(state.categoryById(e.categoryId)),
                    color: categoryColor(state.categoryById(e.categoryId)),
                  ),
                  title: Text(
                    e.title,
                    style: e.done
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough,
                          )
                        : null,
                  ),
                  subtitle: Text(
                    [
                      e.type.label,
                      if (e.tags.isNotEmpty) e.tags.map((t) => '#$t').join(' '),
                      if (e.dueDate != null) 'due ${shortDate(e.dueDate!)}',
                    ].join(' · '),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (e.amount != null)
                        Text(
                          signedMoney(e.signedAmount),
                          style: tabularStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            color: e.signedAmount >= 0
                                ? LedgerColors.of(context).income
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      if (e.type == EntryType.task || e.type == EntryType.bill)
                        IconButton(
                          tooltip: e.done ? 'Reopen' : 'Mark done',
                          icon: Icon(
                            e.done
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                          ),
                          onPressed: () => state.toggleDone(e),
                        ),
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => showEntryForm(context, existing: e),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () async {
                          await state.deleteEntry(e.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Deleted "${e.title}"'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () => state.upsertEntry(e),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
