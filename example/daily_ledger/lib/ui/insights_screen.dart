import 'package:flutter/material.dart';

import '../logic/cached.dart';
import '../logic/heatmap.dart';
import '../logic/recurrence.dart';
import '../logic/summaries.dart';
import '../logic/tags.dart';
import 'app_shell.dart';
import 'format.dart';
import 'theme.dart';
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
            explain: () => PipelineExplanation(
              title: 'Month over month',
              formula:
                  'range(6) → map(monthSummary)\n'
                  '→ drop(1) → zip(self) → map(Δ)',
              steps: [
                PipelineStep(
                  'range(6, -1, -1) → map(month)',
                  'the 6 months ending at the viewed month',
                  trend.isEmpty
                      ? '—'
                      : '${shortMonthLabel(trend.first.month)} … ${shortMonthLabel(trend.last.month)}',
                ),
                PipelineStep(
                  'map(monthSummary)',
                  'income/expense totals per month (filter → partition → sumBy each)',
                  '6 summaries',
                ),
                PipelineStep(
                  'drop(1) → zip(self)',
                  'pair every month with its predecessor — zipping a list '
                      'against itself shifted by one',
                  '${trend.length} pairs',
                ),
              ],
              result: trend.isEmpty
                  ? 'not enough history'
                  : '${shortMonthLabel(state.month)} net: ${signedMoney(trend.last.current.net)} '
                        '(Δ spending ${signedMoney(-trend.last.expenseDelta)})',
            ),
            child: _TrendTable(trend: trend, thisMonth: state.month),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Spending heatmap — ${monthLabel(state.month)}',
            subtitle:
                'one filter, two fork()s: groupBy→sumBy per day + sumBy total '
                '(${money(heatmap.totalSpend)} this month) — walked once',
            explain: () {
              final spendingDays = heatmap.weeks
                  .expand((w) => w)
                  .where((c) => c.$2 > 0)
                  .length;
              return PipelineExplanation(
                title: 'Spending heatmap',
                formula:
                    'source = filter(month & spending)   // lazy\n'
                    'fork #1 → groupBy(day) → sumBy(amount)\n'
                    'fork #2 → sumBy(amount)',
                steps: [
                  PipelineStep(
                    'filter(month & spending)',
                    'lazy source — not walked until a fork pulls it',
                    'shared by both forks',
                  ),
                  PipelineStep(
                    'fork → groupBy(day) → sumBy',
                    'per-day totals for the cell colors',
                    '$spendingDays days with spending',
                  ),
                  PipelineStep(
                    'fork → sumBy(amount)',
                    'the month total — same walk, second consumer',
                    money(heatmap.totalSpend),
                  ),
                  PipelineStep(
                    'monthGrid → map(perDay)',
                    'cells normalize against the busiest day',
                    'max ${money(heatmap.maxDaySpend)} / day',
                  ),
                ],
                result:
                    'fork shares one iterator+buffer: the source is walked once '
                    'even with two consumers',
              );
            },
            child: _Heatmap(data: heatmap),
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final tagsCard = SectionCard(
                title: 'Tags (all time)',
                subtitle: 'flatMap(tags) → countBy — tap one to explore',
                explain: () => PipelineExplanation(
                  title: 'Tags (all time)',
                  formula:
                      'flatMap(entry.tags) → countBy(tag) → sortBy(-count)',
                  steps: [
                    PipelineStep(
                      'flatMap(tags)',
                      'flatten every entry\'s tag list into one stream',
                      '${state.entries.expand((e) => e.tags).length} tag usages',
                    ),
                    PipelineStep(
                      'countBy(tag)',
                      'frequency per unique tag',
                      '${tags.length} unique tags',
                    ),
                    PipelineStep(
                      'sortBy(-count)',
                      'most used first',
                      tags.isEmpty
                          ? '—'
                          : 'top: #${tags.first.$1} × ${tags.first.$2}',
                    ),
                  ],
                  result: 'counts run over ALL months — hence the card title',
                ),
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
                                () => _selectedTag = on ? tag : null,
                              ),
                            ),
                        ],
                      ),
              );
              final dupesCard = SectionCard(
                title: 'Possible duplicates',
                subtitle: 'what uniqBy(title+amount+day) would drop',
                explain: () {
                  final moneyCount = state.entries
                      .where((e) => e.type.isMoney)
                      .length;
                  return PipelineExplanation(
                    title: 'Possible duplicates',
                    formula:
                        'money = filter(isMoney)\n'
                        'firstSeen = uniqBy(title|amount|day)\n'
                        'duplicates = difference(firstSeen, money)',
                    steps: [
                      PipelineStep(
                        'filter(isMoney)',
                        'only money entries',
                        '$moneyCount entries',
                      ),
                      PipelineStep(
                        'uniqBy(title|amount|day)',
                        'keeps the FIRST of each key',
                        '${moneyCount - dupes.length} kept',
                      ),
                      PipelineStep(
                        'difference(firstSeen, money)',
                        'everything uniqBy dropped — exactly the duplicates',
                        '${dupes.length} suspects',
                      ),
                    ],
                  );
                },
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
                              trailing: Text(
                                money(e.amount ?? 0),
                                style: tabularStyle,
                              ),
                            ),
                        ],
                      ),
              );
              if (isNarrow(context)) {
                return Column(
                  children: [tagsCard, const SizedBox(height: 16), dupesCard],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: tagsCard),
                  const SizedBox(width: 16),
                  Expanded(child: dupesCard),
                ],
              );
            },
          ),
          if (_selectedTag != null) ...[
            const SizedBox(height: 16),
            SectionCard(
              title: 'Tag explorer — #$_selectedTag',
              subtitle:
                  'intersection / difference over month tag sets; total via '
                  'compact(pluck(amount))',
              explain: () {
                final comparison = compareTagMonths(state.entries, state.month);
                final entriesForTag = tagEntries(
                  state.entries,
                  _selectedTag!,
                  state.month,
                );
                final spent = tagSpend(
                  state.entries,
                  _selectedTag!,
                  state.month,
                );
                return PipelineExplanation(
                  title: 'Tag explorer — #$_selectedTag',
                  formula:
                      'sets  = flatMap(tags) → uniq, per month\n'
                      'shared = intersection(last, this)\n'
                      'fresh/gone = difference, both directions\n'
                      'spend = compact(pluck(amount)) → sum',
                  steps: [
                    PipelineStep(
                      'flatMap → uniq × 2',
                      'the tag SETS of this month and last month',
                      '${comparison.shared.length + comparison.fresh.length} this month',
                    ),
                    PipelineStep(
                      'intersection(last, this)',
                      'tags used in both months',
                      '${comparison.shared.length} shared',
                    ),
                    PipelineStep(
                      'difference (both ways)',
                      'new this month / vanished this month',
                      '${comparison.fresh.length} new · ${comparison.dropped.length} gone',
                    ),
                    PipelineStep(
                      'compact(pluck(amount)) → sum',
                      'non-spending entries pluck to null, compact drops '
                          'them, sum totals the rest',
                      '${entriesForTag.length} entries · ${money(spent)}',
                    ),
                  ],
                );
              },
              child: _TagExplorer(tag: _selectedTag!),
            ),
          ],
          const SizedBox(height: 16),
          SectionCard(
            title: 'Projected recurring entries (next 2 months)',
            subtitle:
                'infinite range → map(occurrence) → dropWhile → takeWhile, per rule',
            explain: () => PipelineExplanation(
              title: 'Projected recurring entries',
              formula:
                  'per rule: range(∞) → map(i → date)\n'
                  '→ dropWhile(< today) → takeWhile(≤ horizon)\n'
                  'all: flatMap(rules) → filter(not materialized)',
              steps: [
                PipelineStep(
                  'range(100000) → map(occurrence)',
                  'a lazy, effectively infinite stream of fire dates per rule',
                  '${state.rules.length} rules',
                ),
                PipelineStep(
                  'dropWhile → takeWhile',
                  'laziness does the bounding: only dates inside the '
                      '2-month window are ever computed',
                  'window: today → +2 months',
                ),
                PipelineStep(
                  'flatMap(rules) → filter',
                  'ghosts whose date already has a real entry are dropped',
                  '${projected.length} projected entries',
                ),
              ],
              result:
                  'the pipeline never materializes occurrences beyond the horizon',
            ),
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
                            color: categoryColor(
                              state.categoryById(e.categoryId),
                            ),
                            size: 20,
                          ),
                          title: Text(e.title),
                          subtitle: Text(
                            'due ${shortDate(e.dueDate ?? e.date)}',
                          ),
                          trailing: e.amount == null
                              ? null
                              : Text(
                                  money(e.amount!),
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                                ),
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

  Widget _delta(
    BuildContext context,
    double value, {
    required bool downIsGood,
  }) {
    if (value.abs() < 0.005) return const Text('—');
    final good = downIsGood ? value < 0 : value > 0;
    final color = good
        ? LedgerColors.of(context).income
        : Theme.of(context).colorScheme.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          value > 0 ? Icons.arrow_upward : Icons.arrow_downward,
          size: 14,
          color: color,
        ),
        Text(money(value.abs()), style: tabularStyle.copyWith(color: color)),
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
            DataRow(
              cells: [
                DataCell(
                  Text(
                    sameMonth(p.month, thisMonth)
                        ? '${shortMonthLabel(p.month)} · in progress'
                        : shortMonthLabel(p.month),
                  ),
                ),
                DataCell(Text(money(p.current.income), style: tabularStyle)),
                DataCell(_delta(context, p.incomeDelta, downIsGood: false)),
                DataCell(Text(money(p.current.expense), style: tabularStyle)),
                DataCell(_delta(context, p.expenseDelta, downIsGood: true)),
                DataCell(Text(signedMoney(p.current.net), style: tabularStyle)),
              ],
            ),
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
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.outline,
                    ),
                  ),
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
        // Legend: what the color ramp means and where it tops out.
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '\$0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(width: 4),
              for (final t in const [0.0, 0.25, 0.5, 0.75, 1.0])
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Color.lerp(
                      theme.colorScheme.surfaceContainerHighest,
                      theme.colorScheme.primary,
                      t,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              Text(
                '${money(data.maxDaySpend)} / day',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
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
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              tags.isEmpty ? '—' : tags.map((t) => '#$t').join('  '),
              style: TextStyle(
                color: tags.contains(tag) ? theme.colorScheme.primary : null,
              ),
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
              trailing: e.amount == null
                  ? null
                  : Text(signedMoney(e.signedAmount)),
            ),
      ],
    );
  }
}
