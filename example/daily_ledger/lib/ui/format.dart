import 'package:flutter/material.dart';

import '../models/models.dart';

/// `1234.5` → `$1,234.50` (own tiny formatter; no intl dependency).
String money(double value) {
  final sign = value < 0 ? '-' : '';
  final cents = (value.abs() * 100).round();
  final whole = cents ~/ 100;
  final frac = (cents % 100).toString().padLeft(2, '0');
  final digits = whole.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return '$sign\$$buf.$frac';
}

/// Signed variant with an explicit plus for income.
String signedMoney(double value) => value > 0 ? '+${money(value)}' : money(value);

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String monthLabel(DateTime m) => '${_monthNames[m.month - 1]} ${m.year}';

String shortMonthLabel(DateTime m) =>
    '${_monthNames[m.month - 1].substring(0, 3)} ${m.year}';

String dayLabel(DateTime d) =>
    '${_weekdayNames[d.weekday - 1]}, ${_monthNames[d.month - 1].substring(0, 3)} ${d.day}';

String shortDate(DateTime d) =>
    '${_monthNames[d.month - 1].substring(0, 3)} ${d.day}';

/// Icons are looked up from a const map (not `IconData(codePoint)`) so
/// Flutter web's icon tree-shaking keeps working.
const Map<String, IconData> categoryIcons = {
  'salary': Icons.payments,
  'groceries': Icons.shopping_basket,
  'dining': Icons.restaurant,
  'transport': Icons.directions_bus,
  'housing': Icons.home,
  'utilities': Icons.bolt,
  'fun': Icons.movie,
  'health': Icons.favorite,
  'chores': Icons.cleaning_services,
  'work': Icons.work,
  'personal': Icons.self_improvement,
};

IconData categoryIcon(Category? c) =>
    (c == null ? null : categoryIcons[c.id]) ?? Icons.category;

Color categoryColor(Category? c) =>
    c == null ? Colors.blueGrey : Color(c.colorSeed);

IconData typeIcon(EntryType type) => switch (type) {
      EntryType.expense => Icons.remove_circle_outline,
      EntryType.income => Icons.add_circle_outline,
      EntryType.task => Icons.check_circle_outline,
      EntryType.bill => Icons.receipt_long,
    };
