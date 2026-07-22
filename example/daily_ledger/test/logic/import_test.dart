import 'package:daily_ledger/logic/export.dart';
import 'package:daily_ledger/logic/import.dart';
import 'package:daily_ledger/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _categories = [
  Category(
    id: 'dining',
    name: 'Dining',
    iconCodePoint: 0xe000,
    colorSeed: 0xFF000001,
    kind: CategoryKind.money,
  ),
  Category(
    id: 'chores',
    name: 'Chores',
    iconCodePoint: 0xe001,
    colorSeed: 0xFF000002,
    kind: CategoryKind.task,
  ),
];

Entry entry(
  String id, {
  EntryType type = EntryType.expense,
  double? amount = 10,
  String categoryId = 'dining',
  List<String> tags = const [],
  bool done = false,
}) => Entry(
  id: id,
  title: id,
  type: type,
  amount: amount,
  categoryId: categoryId,
  tags: tags,
  date: DateTime(2026, 7, 10),
  done: done,
);

ImportPreview parse(String text, {List<Entry> existing = const []}) =>
    parseCsvEntries(
      text,
      categories: _categories,
      existing: existing,
      idPrefix: 'test',
    );

void main() {
  group('splitCsvLine', () {
    test('plain cells', () {
      expect(splitCsvLine('a,b,c'), ['a', 'b', 'c']);
    });

    test('quoted commas and escaped quotes', () {
      expect(splitCsvLine('"a,b",c,"say ""hi"""'), ['a,b', 'c', 'say "hi"']);
    });

    test('unbalanced quotes return null', () {
      expect(splitCsvLine('"open,ended'), isNull);
    });
  });

  group('parseCsvEntries', () {
    test('happy path builds entries with line-based ids', () {
      final p = parse(
        'date,type,title,category,amount,tags,done\n'
        '2026-07-03,expense,Coffee,Dining,4.50,treat|café,no\n'
        '2026-07-04,task,Sweep floor,Chores,,,yes\n',
      );
      expect(p.issues, isEmpty);
      expect(p.entries, hasLength(2));
      final coffee = p.entries.first;
      expect(coffee.id, 'test-L2');
      expect(coffee.title, 'Coffee');
      expect(coffee.amount, 4.50);
      expect(coffee.categoryId, 'dining');
      expect(coffee.tags, ['treat', 'café']);
      expect(p.entries.last.done, isTrue);
      expect(p.entries.last.amount, isNull);
    });

    test('bad rows produce line-precise issues, good rows still import', () {
      final p = parse(
        'date,type,title,category,amount,tags,done\n'
        '2026-07-03,expense,Coffee,Dining,4.50,,no\n'
        'not-a-date,expense,Broken,Dining,1.00,,no\n'
        '2026-07-05,expense,NoSuchCat,Books,2.00,,no\n'
        '2026-07-06,magic,BadType,Dining,2.00,,no\n',
      );
      expect(p.entries, hasLength(1));
      expect(p.issues.map((i) => i.line), [3, 4, 5]);
    });

    test('wrong header is rejected up front', () {
      final p = parse('id,name\n1,x\n');
      expect(p.entries, isEmpty);
      expect(p.issues.single.message, contains('header must be exactly'));
    });

    test('duplicates against existing entries are counted, not dropped', () {
      final existing = [
        Entry(
          id: 'orig',
          title: 'Coffee',
          type: EntryType.expense,
          amount: 4.5,
          categoryId: 'dining',
          date: DateTime(2026, 7, 3),
        ),
      ];
      final p = parse(
        'date,type,title,category,amount,tags,done\n'
        '2026-07-03,expense,Coffee,Dining,4.50,,no\n',
        existing: existing,
      );
      expect(p.entries, hasLength(1));
      expect(p.duplicateCount, 1);
    });

    test('round-trip: export → import preserves the exported fields', () {
      final original = [
        entry('Fancy, dinner "out"', amount: 120.5, tags: ['date-night']),
        entry(
          'Laundry',
          type: EntryType.task,
          amount: null,
          categoryId: 'chores',
          done: true,
        ),
      ];
      final csv = entriesToCsv(
        original,
        categories: {for (final c in _categories) c.id: c},
      );
      final p = parse(csv);
      expect(p.issues, isEmpty);
      expect(p.entries, hasLength(2));
      for (final (i, e) in p.entries.indexed) {
        // export sorts by date; both share a date so order is stable
        final o = original[i];
        expect(e.title, o.title);
        expect(e.type, o.type);
        expect(e.amount, o.amount);
        expect(e.categoryId, o.categoryId);
        expect(e.tags, o.tags);
        expect(e.done, o.done);
        expect(e.date, DateTime(2026, 7, 10));
      }
    });
  });
}
