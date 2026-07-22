import 'package:flutter/material.dart';

/// Design tokens (Round 5, ui-ux-pro-max design system):
/// trust-blue primary, profit-green income, both light and dark modes,
/// tabular figures for every money value so digit columns don't wiggle.
///
/// All income/spending/warning color decisions go through [LedgerColors] —
/// no widget hard-codes a Material palette color anymore.

const _seed = Color(0xFF1E40AF); // trust blue

/// Semantic colors that Material's [ColorScheme] has no slot for.
@immutable
class LedgerColors extends ThemeExtension<LedgerColors> {
  final Color income; // money coming in / positive net
  final Color spending; // money going out (not an error!)
  final Color warning; // budget nearly exhausted

  const LedgerColors({
    required this.income,
    required this.spending,
    required this.warning,
  });

  static const light = LedgerColors(
    income: Color(0xFF047857), // emerald 700 — 4.5:1 on white
    spending: Color(0xFFC2410C), // orange 700
    warning: Color(0xFFB45309), // amber 700
  );

  static const dark = LedgerColors(
    income: Color(0xFF34D399), // emerald 400 — readable on dark surfaces
    spending: Color(0xFFFB923C), // orange 400
    warning: Color(0xFFFBBF24), // amber 400
  );

  @override
  LedgerColors copyWith({Color? income, Color? spending, Color? warning}) =>
      LedgerColors(
        income: income ?? this.income,
        spending: spending ?? this.spending,
        warning: warning ?? this.warning,
      );

  @override
  LedgerColors lerp(LedgerColors? other, double t) => other == null
      ? this
      : LedgerColors(
          income: Color.lerp(income, other.income, t)!,
          spending: Color.lerp(spending, other.spending, t)!,
          warning: Color.lerp(warning, other.warning, t)!,
        );

  static LedgerColors of(BuildContext context) =>
      Theme.of(context).extension<LedgerColors>()!;
}

ThemeData _theme(Brightness brightness, LedgerColors colors) => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: brightness),
  extensions: [colors],
);

final ThemeData lightTheme = _theme(Brightness.light, LedgerColors.light);
final ThemeData darkTheme = _theme(Brightness.dark, LedgerColors.dark);

/// Tabular figures: every digit takes the same width, so amounts in
/// lists/tables stay column-aligned and don't jump when values change.
const tabularFigures = [FontFeature.tabularFigures()];

/// Ready-made style for money text that needs nothing else.
const tabularStyle = TextStyle(fontFeatures: tabularFigures);

extension MoneyTextStyle on TextStyle {
  TextStyle get tabular => copyWith(fontFeatures: tabularFigures);
}
