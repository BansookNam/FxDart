import 'package:flutter/material.dart';
import 'package:fxdart/fxdart.dart'
    show Throttled, throttle, pipe, filter, map, sum;

import '../logic/summaries.dart' show sameMonth;
import '../main.dart' show DailyLedgerApp;
import '../models/models.dart';
import '../state/ledger_state.dart';
import 'calendar_screen.dart';
import 'dashboard_screen.dart';
import 'entries_screen.dart';
import 'format.dart';
import 'insights_screen.dart';

/// Below this width the rail becomes a bottom bar and side-by-side cards
/// stack — one breakpoint shared by every screen.
const narrowBreakpoint = 700.0;

bool isNarrow(BuildContext context) =>
    MediaQuery.sizeOf(context).width < narrowBreakpoint;

/// Exposes [LedgerState] to the tree — a plain [InheritedNotifier], no
/// state-management package (per the plan: the star is the data layer).
class LedgerScope extends InheritedNotifier<LedgerState> {
  const LedgerScope({
    super.key,
    required LedgerState state,
    required super.child,
  }) : super(notifier: state);

  static LedgerState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LedgerScope>()!.notifier!;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  /// fxdart `throttle` (leading edge only): double-clicking "Reset demo
  /// data" cannot start two overlapping reseeds.
  late final Throttled<LedgerState> _throttledReseed = throttle(
    (state) => state.reseed(),
    const Duration(seconds: 3),
    trailing: false,
  );

  @override
  void dispose() {
    _throttledReseed.cancel();
    super.dispose();
  }

  /// Reseeding wipes every user edit — destructive, so it confirms first.
  Future<void> _confirmReseed(LedgerState state) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset demo data?'),
        content: const Text(
          'This replaces the whole ledger with fresh seeded fixtures. '
          'Entries and budgets you added or edited will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) _throttledReseed(state);
  }

  static const _tabs = [
    (
      icon: Icons.dashboard_outlined,
      selected: Icons.dashboard,
      label: 'Dashboard',
    ),
    (
      icon: Icons.calendar_month_outlined,
      selected: Icons.calendar_month,
      label: 'Calendar',
    ),
    (icon: Icons.list_alt_outlined, selected: Icons.list_alt, label: 'Entries'),
    (
      icon: Icons.insights_outlined,
      selected: Icons.insights,
      label: 'Insights',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = LedgerScope.of(context);
    if (state.isLoading) return _LoadingScreen(loaded: state.loadedBoxes);
    final narrow = isNarrow(context);

    final content = Column(
      children: [
        _MonthBar(state: state, onReseed: () => _confirmReseed(state)),
        const Divider(height: 1),
        Expanded(
          child: IndexedStack(
            index: _tab,
            children: const [
              DashboardScreen(),
              CalendarScreen(),
              EntriesScreen(),
              InsightsScreen(),
            ],
          ),
        ),
      ],
    );

    if (narrow) {
      return Scaffold(
        body: content,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: [
            for (final t in _tabs)
              NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.selected),
                label: t.label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Icon(Icons.account_balance_wallet, size: 32),
            ),
            destinations: [
              for (final t in _tabs)
                NavigationRailDestination(
                  icon: Icon(t.icon),
                  selectedIcon: Icon(t.selected),
                  label: Text(t.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  final LedgerState state;
  final VoidCallback onReseed;
  const _MonthBar({required this.state, required this.onReseed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final narrow = isNarrow(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (!narrow) ...[
            Text('Daily Ledger', style: theme.textTheme.titleLarge),
            const SizedBox(width: 12),
            Text(
              'an fxdart showcase',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous month',
            onPressed: () => state.goToMonth(-1),
          ),
          SizedBox(
            width: narrow ? 110 : 150,
            child: Text(
              narrow ? shortMonthLabel(state.month) : monthLabel(state.month),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next month',
            onPressed: () => state.goToMonth(1),
          ),
          TextButton(
            onPressed: () => state.setMonth(state.today),
            child: const Text('Today'),
          ),
          const Spacer(),
          ValueListenableBuilder(
            valueListenable: DailyLedgerApp.themeMode,
            builder: (context, mode, _) => IconButton(
              tooltip: switch (mode) {
                ThemeMode.system => 'Theme: follow system',
                ThemeMode.light => 'Theme: light',
                ThemeMode.dark => 'Theme: dark',
              },
              icon: Icon(switch (mode) {
                ThemeMode.system => Icons.brightness_auto,
                ThemeMode.light => Icons.light_mode,
                ThemeMode.dark => Icons.dark_mode,
              }),
              onPressed: () => DailyLedgerApp.themeMode.value = switch (mode) {
                ThemeMode.system => ThemeMode.light,
                ThemeMode.light => ThemeMode.dark,
                ThemeMode.dark => ThemeMode.system,
              },
            ),
          ),
          IconButton(
            tooltip: 'Reset demo data',
            icon: const Icon(Icons.restart_alt),
            onPressed: onReseed,
          ),
          IconButton(
            tooltip: 'About this demo (runs a live pipe)',
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAbout(context, state),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context, LedgerState state) {
    // The dynamic `pipe` exists for FxTS parity (Dart can't type variadic
    // composition) — everywhere else this app uses the typed fx() chain.
    // Here it runs for real on the live ledger:
    final net =
        pipe(state.entries, [
              (List<Entry> es) => filter(
                (Entry e) => e.type.isMoney && sameMonth(e.date, state.month),
                es,
              ),
              (Iterable<Entry> es) => map((Entry e) => e.signedAmount, es),
              (Iterable<double> ns) => sum(ns),
            ])
            as num;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Ledger — an fxdart showcase'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Every number in this app is an fxdart pipeline over one '
                'List<Entry>. Storage (hive_ce) only shelves data; all '
                'grouping, summing and windowing happens in logic/ — each '
                'card names the operators it uses in its subtitle, and the '
                '? beside any formula walks that pipeline step by step with '
                'the live numbers on screen.',
              ),
              const SizedBox(height: 12),
              const Text('Live demo of the dynamic pipe (FxTS parity API):'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'pipe(entries, [\n'
                  '  (es) => filter((e) => e.type.isMoney\n'
                  '            && sameMonth(e.date, month), es),\n'
                  '  (es) => map((e) => e.signedAmount, es),\n'
                  '  sum,\n'
                  '])',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '= net for ${monthLabel(state.month)}: '
                '${net.toStringAsFixed(2)}',
              ),
            ],
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
}

class _LoadingScreen extends StatelessWidget {
  final List<String> loaded;
  const _LoadingScreen({required this.loaded});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Loading 4 boxes with toAsync().map(read).concurrent(3) …',
            ),
            const SizedBox(height: 8),
            Text(
              loaded.isEmpty ? ' ' : loaded.join(' · '),
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
