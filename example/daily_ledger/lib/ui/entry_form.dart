import 'package:flutter/material.dart';

import '../models/models.dart';
import 'app_shell.dart';
import 'format.dart';

/// Add/edit dialog for an [Entry].
Future<void> showEntryForm(BuildContext context, {Entry? existing}) =>
    showDialog(context: context, builder: (_) => _EntryDialog(existing: existing));

class _EntryDialog extends StatefulWidget {
  final Entry? existing;
  const _EntryDialog({this.existing});

  @override
  State<_EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<_EntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _amount =
      TextEditingController(text: widget.existing?.amount?.toStringAsFixed(2));
  late final _tags =
      TextEditingController(text: widget.existing?.tags.join(', '));
  late EntryType _type = widget.existing?.type ?? EntryType.expense;
  late String? _categoryId = widget.existing?.categoryId;
  late DateTime _date = widget.existing?.date ?? DateTime.now();
  late DateTime? _dueDate = widget.existing?.dueDate;

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _tags.dispose();
    super.dispose();
  }

  bool get _needsAmount => _type != EntryType.task;
  bool get _hasDue => _type == EntryType.task || _type == EntryType.bill;

  @override
  Widget build(BuildContext context) {
    final state = LedgerScope.of(context);
    final categories = state.categories
        .where((c) => _type == EntryType.task
            ? c.kind == CategoryKind.task
            : c.kind == CategoryKind.money)
        .toList();
    if (_categoryId == null || !categories.any((c) => c.id == _categoryId)) {
      _categoryId = categories.isEmpty ? null : categories.first.id;
    }

    return AlertDialog(
      title: Text(widget.existing == null ? 'Add entry' : 'Edit entry'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<EntryType>(
                  segments: [
                    for (final t in EntryType.values)
                      ButtonSegment(value: t, label: Text(t.label)),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() => _type = s.first),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _title,
                  autofocus: true,
                  decoration: const InputDecoration(
                      labelText: 'Title', border: OutlineInputBorder()),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                if (_needsAmount) ...[
                  TextFormField(
                    controller: _amount,
                    decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: '\$ ',
                        border: OutlineInputBorder()),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final parsed = double.tryParse(v ?? '');
                      if (parsed == null) return 'Enter a number';
                      // A negative amount would silently flip an expense
                      // into income via signedAmount.
                      if (parsed <= 0) return 'Must be greater than zero';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                DropdownButtonFormField<String>(
                  // New key per type: initialValue is only read on first
                  // build, so force a rebuild when the category list changes.
                  key: ValueKey(_type),
                  initialValue: _categoryId,
                  decoration: const InputDecoration(
                      labelText: 'Category', border: OutlineInputBorder()),
                  items: [
                    for (final c in categories)
                      DropdownMenuItem(
                        value: c.id,
                        child: Row(children: [
                          Icon(categoryIcon(c), size: 18, color: categoryColor(c)),
                          const SizedBox(width: 8),
                          Text(c.name),
                        ]),
                      ),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tags,
                  decoration: const InputDecoration(
                      labelText: 'Tags (comma-separated)',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.event, size: 18),
                        label: Text('Date: ${shortDate(_date)}'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) setState(() => _date = picked);
                        },
                      ),
                    ),
                    if (_hasDue) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.flag, size: 18),
                          label: Text(_dueDate == null
                              ? 'Due date'
                              : 'Due: ${shortDate(_dueDate!)}'),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _dueDate ?? _date,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) setState(() => _dueDate = picked);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate() || _categoryId == null) return;
            final entry = Entry(
              id: widget.existing?.id ??
                  'user-${DateTime.now().microsecondsSinceEpoch}',
              title: _title.text.trim(),
              type: _type,
              amount: _needsAmount ? double.parse(_amount.text) : null,
              categoryId: _categoryId!,
              tags: _tags.text
                  .split(',')
                  .map((t) => t.trim())
                  .where((t) => t.isNotEmpty)
                  .toList(),
              date: _date,
              dueDate: _hasDue ? _dueDate : null,
              done: widget.existing?.done ?? false,
              recurringRuleId: widget.existing?.recurringRuleId,
            );
            LedgerScope.of(context).upsertEntry(entry);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
