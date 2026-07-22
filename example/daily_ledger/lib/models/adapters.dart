/// Hand-written Hive TypeAdapters. Each model is serialized as a Map of
/// primitives (DateTime → epoch ms), which keeps the format inspectable and
/// avoids a build_runner step in an example project.
library;

import 'package:hive_ce/hive.dart';

import 'models.dart';

DateTime _dt(Object? ms) => DateTime.fromMillisecondsSinceEpoch(ms as int);

class EntryAdapter extends TypeAdapter<Entry> {
  @override
  int get typeId => 1;

  @override
  Entry read(BinaryReader reader) {
    final m = reader.readMap().cast<String, dynamic>();
    return Entry(
      id: m['id'] as String,
      title: m['title'] as String,
      type: EntryType.values[m['type'] as int],
      amount: m['amount'] as double?,
      categoryId: m['categoryId'] as String,
      tags: (m['tags'] as List).cast<String>(),
      date: _dt(m['date']),
      dueDate: m['dueDate'] == null ? null : _dt(m['dueDate']),
      done: m['done'] as bool,
      recurringRuleId: m['recurringRuleId'] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Entry obj) {
    writer.writeMap({
      'id': obj.id,
      'title': obj.title,
      'type': obj.type.index,
      'amount': obj.amount,
      'categoryId': obj.categoryId,
      'tags': obj.tags,
      'date': obj.date.millisecondsSinceEpoch,
      'dueDate': obj.dueDate?.millisecondsSinceEpoch,
      'done': obj.done,
      'recurringRuleId': obj.recurringRuleId,
    });
  }
}

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  int get typeId => 2;

  @override
  Category read(BinaryReader reader) {
    final m = reader.readMap().cast<String, dynamic>();
    return Category(
      id: m['id'] as String,
      name: m['name'] as String,
      iconCodePoint: m['icon'] as int,
      colorSeed: m['color'] as int,
      kind: CategoryKind.values[m['kind'] as int],
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer.writeMap({
      'id': obj.id,
      'name': obj.name,
      'icon': obj.iconCodePoint,
      'color': obj.colorSeed,
      'kind': obj.kind.index,
    });
  }
}

class RecurringRuleAdapter extends TypeAdapter<RecurringRule> {
  @override
  int get typeId => 3;

  @override
  RecurringRule read(BinaryReader reader) {
    final m = reader.readMap().cast<String, dynamic>();
    return RecurringRule(
      id: m['id'] as String,
      period: RecurrencePeriod.values[m['period'] as int],
      anchorDate: _dt(m['anchor']),
    );
  }

  @override
  void write(BinaryWriter writer, RecurringRule obj) {
    writer.writeMap({
      'id': obj.id,
      'period': obj.period.index,
      'anchor': obj.anchorDate.millisecondsSinceEpoch,
    });
  }
}
