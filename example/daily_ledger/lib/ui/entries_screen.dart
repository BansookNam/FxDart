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
    final filtered = fx(searched)
        .filter((e) => _typeFilter == null || e.type == _typeFilter)
        .toList();
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
                  final csv = entriesToCsv(visible,
                      categories: state.categoryIndex);
                  await Clipboard.setData(ClipboardData(text: csv));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Copied the ${visible.length} visible entries as CSV '
                          '(sortBy \u2192 map \u2192 pick \u2192 join)'),
                    ));
                  }
                },
                icon: const Icon(Icons.copy_all, size: 18),
                label: const Text('Export CSV'),
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
                    label: Text(type == null
                        ? 'All'
                        : '${type.label} (${counts[type] ?? 0})'),
                    selected: _typeFilter == type,
                    onSelected: (_) => setState(() => _typeFilter = type),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
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
            style: theme.textTheme.titleSmall
                ?.copyWith(color: theme.colorScheme.primary),
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
                        ? const TextStyle(decoration: TextDecoration.lineThrough)
                        : null,
                  ),
                  subtitle: Text([
                    e.type.label,
                    if (e.tags.isNotEmpty) e.tags.map((t) => '#$t').join(' '),
                    if (e.dueDate != null) 'due ${shortDate(e.dueDate!)}',
                  ].join(' · ')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (e.amount != null)
                        Text(
                          signedMoney(e.signedAmount),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: e.signedAmount >= 0
                                ? Colors.green.shade700
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      if (e.type == EntryType.task || e.type == EntryType.bill)
                        IconButton(
                          tooltip: e.done ? 'Reopen' : 'Mark done',
                          icon: Icon(e.done
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked),
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
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Deleted "${e.title}"'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () => state.upsertEntry(e),
                              ),
                            ));
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
