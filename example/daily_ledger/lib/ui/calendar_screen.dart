import 'package:flutter/material.dart';

import '../logic/calendar.dart';
import '../models/models.dart';
import 'app_shell.dart';
import 'format.dart';
import 'widgets.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final state = LedgerScope.of(context);
    // range(42) → map(day) → chunk(7): the grid *is* the pipeline output.
    final grid = monthGrid(state.month);
    final byDay = entriesByDay(state.entries);
    final dueByDay = dueCountByDay(state.entries);
    // A selection from a previously viewed month is stale — ignore it.
    final selected = _selected != null &&
            _selected!.year == state.month.year &&
            _selected!.month == state.month.month
        ? _selected
        : null;
    final selectedEntries =
        selected == null ? const <Entry>[] : (byDay[dayKey(selected)] ?? const []);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: SectionCard(
              title: monthLabel(state.month),
              subtitle: 'range(42) → map → chunk(7); cells read a groupBy index',
              child: Column(
                children: [
                  Row(
                    children: [
                      for (final d in const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'])
                        Expanded(
                          child: Center(
                            child: Text(d,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  for (final week in grid)
                    Row(
                      children: [
                        for (final day in week)
                          Expanded(
                            child: _DayCell(
                              day: day,
                              inMonth: day.month == state.month.month,
                              isToday: dayKey(day) == dayKey(state.today),
                              isSelected:
                                  selected != null && dayKey(day) == dayKey(selected),
                              entries: byDay[dayKey(day)] ?? const [],
                              dueCount: dueByDay[dayKey(day)] ?? 0,
                              onTap: () {
                                // Tapping a leading/trailing cell hops to
                                // that month, so the selection stays visible.
                                if (day.month != state.month.month) {
                                  state.setMonth(day);
                                }
                                setState(() => _selected = day);
                              },
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SectionCard(
              title: selected == null ? 'Pick a day' : dayLabel(selected),
              subtitle: selected == null
                  ? 'Tap a cell to see its entries'
                  : '${selectedEntries.length} entries · net ${signedMoney(dayNet(selectedEntries))}',
              child: selectedEntries.isEmpty
                  ? const EmptyHint('No entries on this day')
                  : Column(
                      children: [
                        for (final e in selectedEntries)
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              categoryIcon(state.categoryById(e.categoryId)),
                              color: categoryColor(state.categoryById(e.categoryId)),
                              size: 20,
                            ),
                            title: Text(e.title),
                            subtitle: Text(e.type.label),
                            trailing: e.amount == null
                                ? Icon(
                                    e.done
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    size: 18,
                                  )
                                : Text(signedMoney(e.signedAmount)),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final List<Entry> entries;
  final int dueCount;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.entries,
    required this.dueCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final net = dayNet(entries);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 72,
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isToday ? Border.all(color: theme.colorScheme.primary) : null,
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : inMonth
                  ? theme.colorScheme.surfaceContainerLow
                  : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${day.day}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: inMonth
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.outlineVariant,
                    )),
                const Spacer(),
                if (dueCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$dueCount',
                        style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onErrorContainer)),
                  ),
              ],
            ),
            const Spacer(),
            if (entries.isNotEmpty && net != 0)
              Text(
                signedMoney(net),
                style: TextStyle(
                  fontSize: 10,
                  color: net >= 0 ? Colors.green.shade700 : theme.colorScheme.error,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
