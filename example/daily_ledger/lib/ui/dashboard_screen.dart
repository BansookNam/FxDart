import 'package:flutter/material.dart';

import '../logic/budgets.dart';
import '../logic/cached.dart';
import '../logic/calendar.dart' show dayKey;
import '../logic/stats.dart';
import '../logic/summaries.dart';
import '../models/models.dart';
import 'app_shell.dart';
import 'format.dart';
import 'theme.dart';
import 'widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = LedgerScope.of(context);
    // Every value below is a pure logic/ pipeline call — the widget only lays
    // things out. The cached* variants are nested-memoize'd, so rebuilds
    // that don't change the data are cache hits.
    final summary = cachedMonthSummary(state.entries)(state.month);
    final breakdown = cachedBreakdown(state.entries)(state.month);
    final balance = cachedBalance(state.entries)(state.month);
    final (overdue, upcoming) = duePartition(state.entries, state.today);
    final stats = cachedQuickStats(state.entries)(state.month);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(summary: summary),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Quick stats',
            subtitle: 'juxt: one list of stat functions, one application',
            child: _QuickStats(stats: stats),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 720;
              final cards = [
                SectionCard(
                  title: 'Running balance',
                  subtitle:
                      'sortBy(date) → scan(sum) — ${monthLabel(state.month)}',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BalanceSparkline(points: balance),
                      if (balance.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'starts ${signedMoney(balance.first.balance)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'ends ${signedMoney(balance.last.balance)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SectionCard(
                  title: 'Top spending categories',
                  subtitle: 'groupBy → sortBy → take(5)',
                  child: _CategoryBreakdown(breakdown: breakdown),
                ),
              ];
              return wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 16),
                        Expanded(child: cards[1]),
                      ],
                    )
                  : Column(
                      children: [
                        cards[0],
                        const SizedBox(height: 16),
                        cards[1],
                      ],
                    );
            },
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Budgets',
            subtitle: 'groupBy → fold per category; suggestions via evolve',
            child: _BudgetList(
              statuses: budgetStatuses(
                state.entries,
                state.budgets,
                state.month,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Due & overdue',
            subtitle: 'filter(open) → sortBy(dueDate) → partition(overdue)',
            child: _DueLists(overdue: overdue, upcoming: upcoming),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Recent activity',
            subtitle: 'sortBy(date) → takeRight(8) → reverse',
            child: _RecentActivity(entries: recentActivity(state.entries)),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final List<(String, String)> stats;
  const _QuickStats({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      children: [
        for (final (label, value) in stats)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              Text(value, style: theme.textTheme.titleMedium),
            ],
          ),
      ],
    );
  }
}

class _RecentActivity extends StatelessWidget {
  final List<Entry> entries;
  const _RecentActivity({required this.entries});

  @override
  Widget build(BuildContext context) {
    final state = LedgerScope.of(context);
    if (entries.isEmpty) return const EmptyHint('Nothing recorded yet');
    return Column(
      children: [
        for (final e in entries)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              categoryIcon(state.categoryById(e.categoryId)),
              color: categoryColor(state.categoryById(e.categoryId)),
              size: 20,
            ),
            title: Text(e.title),
            subtitle: Text(
              '${dayKey(e.date) == dayKey(state.today) ? 'Today' : shortDate(e.date)} · ${e.type.label}',
            ),
            trailing: e.amount == null
                ? null
                : Text(signedMoney(e.signedAmount), style: tabularStyle),
          ),
      ],
    );
  }
}

class _BudgetList extends StatelessWidget {
  final List<BudgetStatus> statuses;
  const _BudgetList({required this.statuses});

  Future<void> _editBudget(BuildContext context, BudgetStatus status) async {
    final state = LedgerScope.of(context);
    final name =
        state.categoryById(status.categoryId)?.name ?? status.categoryId;
    final controller = TextEditingController(
      text: status.budget.toStringAsFixed(0),
    );
    final value = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Budget for $name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: '\$ ',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.of(context).pop(double.tryParse(v)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(double.tryParse(controller.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (value != null && value > 0) {
      await state.setBudget(status.categoryId, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = LedgerScope.of(context);
    final theme = Theme.of(context);
    if (statuses.isEmpty) {
      return const EmptyHint('No budgets set — reset demo data to seed some');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final b in statuses)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  categoryIcon(state.categoryById(b.categoryId)),
                  size: 18,
                  color: categoryColor(state.categoryById(b.categoryId)),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 110,
                  child: Text(
                    state.categoryById(b.categoryId)?.name ?? b.categoryId,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: b.ratio.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: b.over
                          ? theme.colorScheme.error
                          : b.ratio > 0.85
                          ? LedgerColors.of(context).warning
                          : categoryColor(state.categoryById(b.categoryId)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 170,
                  child: Text(
                    b.over
                        ? '${money(b.spent)} / ${money(b.budget)} · over!'
                        : '${money(b.spent)} / ${money(b.budget)}',
                    textAlign: TextAlign.right,
                    style: b.over
                        ? tabularStyle.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          )
                        : tabularStyle,
                  ),
                ),
                IconButton(
                  tooltip: 'Edit budget',
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  onPressed: () => _editBudget(context, b),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.auto_fix_high, size: 18),
            label: const Text('Suggest from last 3 months (evolve)'),
            onPressed: () {
              final suggested = suggestedBudgets(state.entries, state.month);
              state.setBudgets(suggested);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Applied ${suggested.length} suggested budgets '
                    '(3-month average + 10%, rounded up)',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final MonthSummary summary;
  const _SummaryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final colors = LedgerColors.of(context);
    final items = [
      ('Income', summary.income, colors.income),
      ('Spending', summary.expense, colors.spending),
      (
        'Net',
        summary.net,
        summary.net >= 0 ? colors.income : Theme.of(context).colorScheme.error,
      ),
    ];
    return Row(
      children: [
        for (final (label, value, color) in items)
          Expanded(
            child: Card(
              margin: EdgeInsets.only(right: label == 'Net' ? 0 : 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      label == 'Net' ? signedMoney(value) : money(value),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: color, fontWeight: FontWeight.w600)
                          .tabular,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<CategoryTotal> breakdown;
  const _CategoryBreakdown({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) return const EmptyHint('No spending this month');
    final state = LedgerScope.of(context);
    final maxTotal = breakdown.first.total;
    return Column(
      children: [
        for (final item in breakdown)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  categoryIcon(state.categoryById(item.categoryId)),
                  size: 18,
                  color: categoryColor(state.categoryById(item.categoryId)),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 110,
                  child: Text(
                    state.categoryById(item.categoryId)?.name ??
                        item.categoryId,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item.total / maxTotal,
                      minHeight: 8,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      color: categoryColor(state.categoryById(item.categoryId)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 90,
                  child: Text(
                    money(item.total),
                    textAlign: TextAlign.right,
                    style: tabularStyle,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DueLists extends StatelessWidget {
  final List<Entry> overdue;
  final List<Entry> upcoming;
  const _DueLists({required this.overdue, required this.upcoming});

  @override
  Widget build(BuildContext context) {
    final state = LedgerScope.of(context);
    if (overdue.isEmpty && upcoming.isEmpty) {
      return const EmptyHint('Nothing due — enjoy the calm');
    }
    Widget tile(Entry e, {required bool late}) => ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        typeIcon(e.type),
        color: late
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.outline,
      ),
      title: Text(e.title),
      subtitle: Text(
        '${e.type.label} · due ${shortDate(e.dueDate!)}'
        '${e.amount != null ? ' · ${money(e.amount!)}' : ''}',
      ),
      trailing: TextButton(
        onPressed: () => state.toggleDone(e),
        child: Text(e.type == EntryType.bill ? 'Mark paid' : 'Done'),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overdue.isNotEmpty) ...[
          Text(
            'Overdue (${overdue.length})',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          for (final e in overdue) tile(e, late: true),
          const SizedBox(height: 8),
        ],
        if (upcoming.isNotEmpty) ...[
          Text(
            'Upcoming (${upcoming.length})',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          for (final e in upcoming.take(6)) tile(e, late: false),
          if (upcoming.length > 6)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+ ${upcoming.length - 6} more in the Entries tab',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ],
    );
  }
}
