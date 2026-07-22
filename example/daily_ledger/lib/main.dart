import 'package:flutter/material.dart';

import 'data/ledger_repository.dart';
import 'state/ledger_state.dart';
import 'ui/app_shell.dart';

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

  @override
  Widget build(BuildContext context) {
    return LedgerScope(
      state: state,
      child: MaterialApp(
        title: 'Daily Ledger — fxdart showcase',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
          useMaterial3: true,
        ),
        home: const AppShell(),
      ),
    );
  }
}
