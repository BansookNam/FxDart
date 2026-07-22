import 'package:flutter/material.dart';

import '../logic/cached.dart';
import '../logic/heatmap.dart';
import '../logic/recurrence.dart';
import '../logic/summaries.dart';
import '../logic/tags.dart';
import 'app_shell.dart';
import 'format.dart';
import 'widgets.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String? _selectedTag;

  @override
  Widget build(BuildContext context) {
    final state = LedgerScope.of(context);
    final trend = monthlyTrend(state.entries, state.month);
    final heatmap = cachedHeatmap(state.entries)(state.month);
    final tags = tagStats(state.entries);
    final dupes = possibleDuplicates(state.entries);
    final projected = projectAll(
      state.rules,
      state.entries,
      state.today,
      DateTime(state.today.year, state.today.month + 2, state.today.day),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionCard(
            title: 'Month over month',
            subtitle:
                'range → map(monthSummary) → zip(shifted) — 6 months up to ${monthLabel(state.month)}',
            child: _TrendTable(trend: trend, thisMonth: state.month),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Spending heatmap — ${monthLabel(state.month)}',
            subtitle:
                'one filter, two fork()s: groupBy→fold per day + sum total '
                '(${money(heatmap.totalSpend)} this month) — walked once',
            child: _Heatmap(data: heatmap),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SectionCard(
                  title: 'Tags (all time)',
                  subtitle: 'flatMap(tags) → countBy — tap one to explore',
                  child: tags.isEmpty
                      ? const EmptyHint('No tags yet')
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final (tag, count) in tags)
                              FilterChip(
                                label: Text('#$tag · $count'),
                                selected: _selectedTag == tag,
                                onSelected: (on) => setState(
                                    () => _selectedTag = on ? tag : null),
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SectionCard(
                  title: 'Possible duplicates',
                  subtitle: 'what uniqBy(title+amount+day) would drop',
                  child: dupes.isEmpty
                      ? const EmptyHint('No suspicious duplicates')
                      : Column(
                          children: [
                            for (final e in dupes.take(8))
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(e.title),
                                subtitle: Text(shortDate(e.date)),
                                trailing: Text(money(e.amount ?? 0)),
                              ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          if (_selectedTag != null) ...[
            const SizedBox(height: 16),
            SectionCard(
              title: 'Tag explorer — #$_selectedTag',
              subtitle:
                  'intersection / difference over month tag sets; total via '
                  'compact(pluck(amount))',
              child: _TagExplorer(tag: _selectedTag!),
            ),
          ],
          const SizedBox(height: 16),
          SectionCard(
            title: 'Projected recurring entries (next 2 months)',
            subtitle:
                'infinite range → map(occurrence) → dropWhile → takeWhile, per rule',
            child: projected.isEmpty
                ? const EmptyHint('No recurring rules with a template entry')
                : Column(
                    children: [
                      for (final e in projected)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            categoryIcon(state.categoryById(e.categoryId)),
                            color: categoryColor(state.categoryById(e.categoryId)),
                            size: 20,
                          ),
                          title: Text(e.title),
                          subtitle: Text('due ${shortDate(e.dueDate ?? e.date)}'),
                          trailing: e.amount == null
                              ? null
                              : Text(money(e.amount!),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline)),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TrendTable extends StatelessWidget {
  final List<MonthTrendPoint> trend;
  final DateTime thisMonth;
  const _TrendTable({required this.trend, required this.thisMonth});

  Widget _delta(BuildContext context, double value, {required bool downIsGood}) {
    if (value.abs() < 0.005) return const Text('—');
    final good = downIsGood ? value < 0 : value > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          value > 0 ? Icons.arrow_upward : Icons.arrow_downward,
          size: 14,
          color: good ? Colors.green : Colors.red,
        ),
        Text(money(value.abs()),
            style: TextStyle(color: good ? Colors.green : Colors.red)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) return const EmptyHint('Not enough history');
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Month')),
          DataColumn(label: Text('Income'), numeric: true),
          DataColumn(label: Text('Δ income'), numeric: true),
          DataColumn(label: Text('Spending'), numeric: true),
          DataColumn(label: Text('Δ spending'), numeric: true),
          DataColumn(label: Text('Net'), numeric: true),
        ],
        rows: [
          for (final p in trend)
            DataRow(cells: [
              DataCell(Text(sameMonth(p.month, thisMonth)
                  ? '${shortMonthLabel(p.month)} · in progress'
                  : shortMonthLabel(p.month))),
              DataCell(Text(money(p.current.income))),
              DataCell(_delta(context, p.incomeDelta, downIsGood: false)),
              DataCell(Text(money(p.current.expense))),
              DataCell(_delta(context, p.expenseDelta, downIsGood: true)),
              DataCell(Text(signedMoney(p.current.net))),
            ]),
        ],
      ),
    );
  }
}


class _Heatmap extends StatelessWidget {
  final HeatmapData data;
  const _Heatmap({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (data.totalSpend == 0) return const EmptyHint('No spending this month');
    return Column(
      children: [
        Row(
          children: [
            for (final d in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
              Expanded(
                child: Center(
                  child: Text(d,
                      style: TextStyle(
                          fontSize: 11, color: theme.colorScheme.outline)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (final week in data.weeks)
          Row(
            children: [
              for (final (day, spent) in week)
                Expanded(
                  child: Tooltip(
                    message: spent > 0
                        ? '${shortDate(day)}: ${money(spent)}'
                        : shortDate(day),
                    child: Container(
                      height: 28,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Color.lerp(
                          theme.colorScheme.surfaceContainerHighest,
                          theme.colorScheme.primary,
                          data.intensity(spent),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}


class _TagExplorer extends StatelessWidget {
  final String tag;
  const _TagExplorer({required this.tag});

  @override
  Widget build(BuildContext context) {
    final state = LedgerScope.of(context);
    final theme = Theme.of(context);
    final comparison = compareTagMonths(state.entries, state.month);
    final entries = tagEntries(state.entries, tag, state.month);
    final spent = tagSpend(state.entries, tag, state.month);

    Widget tagRow(String label, List<String> tags) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: 150,
                  child: Text(label, style: theme.textTheme.bodySmall)),
              Expanded(
                child: Text(
                  tags.isEmpty ? '—' : tags.map((t) => '#$t').join('  '),
                  style: TextStyle(
                      color: tags.contains(tag)
                          ? theme.colorScheme.primary
                          : null),
                ),
              ),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${entries.length} entries in ${monthLabel(state.month)}'
          '${spent > 0 ? ' · ${money(spent)} spent' : ''}',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        tagRow('In both months', comparison.shared),
        tagRow('New this month', comparison.fresh),
        tagRow('Gone this month', comparison.dropped),
        const Divider(),
        if (entries.isEmpty)
          const EmptyHint('No entries with this tag in the viewed month')
        else
          for (final e in entries.take(8))
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                categoryIcon(state.categoryById(e.categoryId)),
                color: categoryColor(state.categoryById(e.categoryId)),
                size: 20,
              ),
              title: Text(e.title),
              subtitle: Text('${shortDate(e.date)} · ${e.type.label}'),
              trailing:
                  e.amount == null ? null : Text(signedMoney(e.signedAmount)),
            ),
      ],
    );
  }
}
