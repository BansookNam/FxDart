import 'package:flutter/material.dart';

import 'data/ledger_repository.dart';
import 'state/ledger_state.dart';
import 'ui/app_shell.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LedgerRepository.init();
  final state = LedgerState(LedgerRepository());
  runApp(DailyLedgerApp(state: state));
  state.load();
}

class DailyLedgerApp extends StatelessWidget {
  final LedgerState state;
  const DailyLedgerApp({super.key, required this.state});

  /// Session-scoped theme choice (deliberately not persisted — the demo
  /// resets to the visitor's OS preference, which is the honest default).
  static final themeMode = ValueNotifier(ThemeMode.system);

  @override
  Widget build(BuildContext context) {
    return LedgerScope(
      state: state,
      child: ValueListenableBuilder(
        valueListenable: themeMode,
        builder: (context, mode, _) => MaterialApp(
          title: 'Daily Ledger — fxdart showcase',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          home: const AppShell(),
        ),
      ),
    );
  }
}
