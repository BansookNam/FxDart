import 'package:flutter/material.dart';
import 'package:fxdart/fxdart.dart' show EitherNel, Left, Nel, Right, find;

import '../logic/errors.dart';
import '../logic/validate.dart';
import '../models/models.dart';
import 'app_shell.dart';
import 'error_panel.dart';
import 'format.dart';
import 'widgets.dart';

/// Add/edit dialog for an [Entry].
///
/// Round 11 (typed-errors series) replaced `Form` + per-field `validator:`
/// callbacks with a single pure function over an [EntryDraft]. The visible
/// difference is the **All at once / First only** toggle: the same five
/// validators, composed by `zipOrAccumulate5` or by a plain raise scope.
/// Five bad fields light five messages, or one — that contrast is the whole
/// point of the accumulation chapter.
Future<void> showEntryForm(BuildContext context, {Entry? existing}) =>
    showDialog(
      context: context,
      builder: (_) => _EntryDialog(existing: existing),
    );

class _EntryDialog extends StatefulWidget {
  final Entry? existing;
  const _EntryDialog({this.existing});

  @override
  State<_EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<_EntryDialog> {
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _amount = TextEditingController(
    text: widget.existing?.amount?.toStringAsFixed(2),
  );
  late final _tags = TextEditingController(
    text: widget.existing?.tags.join(', '),
  );
  late EntryType _type = widget.existing?.type ?? EntryType.expense;
  late String? _categoryId = widget.existing?.categoryId;
  late DateTime _date = widget.existing?.date ?? DateTime.now();
  late DateTime? _dueDate = widget.existing?.dueDate;

  /// Fail-slow (`zipOrAccumulate5`) or fail-fast (a plain `either` scope).
  bool _failSlow = true;

  /// Errors only appear after the first Save; from then on the form
  /// re-validates on every edit, so messages clear as they are fixed.
  bool _attempted = false;

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _tags.dispose();
    super.dispose();
  }

  bool get _needsAmount => _type != EntryType.task;
  bool get _hasDue => _type == EntryType.task || _type == EntryType.bill;

  EntryDraft _draft() => EntryDraft(
    id: widget.existing?.id ?? 'user-${DateTime.now().microsecondsSinceEpoch}',
    title: _title.text,
    type: _type,
    // The amount field is hidden for tasks, so its stale text must not leak
    // into the draft.
    amount: _needsAmount ? _amount.text : '',
    categoryId: _categoryId,
    tags: _tags.text,
    date: _date,
    dueDate: _hasDue ? _dueDate : null,
    done: widget.existing?.done ?? false,
    recurringRuleId: widget.existing?.recurringRuleId,
  );

  /// Both policies return the same type, so the caller never branches:
  /// `toEitherNel` lifts the fail-fast single error into a one-element list.
  EitherNel<FieldError, Entry> _validate(Map<String, Category> byId) {
    final draft = _draft();
    return _failSlow
        ? validateDraft(draft, byId)
        : validateDraftFailFast(draft, byId).toEitherNel();
  }

  void _onEdited() {
    if (_attempted) setState(() {});
  }

  void _save(Map<String, Category> byId) {
    setState(() => _attempted = true);
    switch (_validate(byId)) {
      case Left():
        break; // the panel and the field messages render it
      case Right(:final value):
        LedgerScope.of(context).upsertEntry(value);
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = LedgerScope.of(context);
    final categories = state.categories
        .where(
          (c) => _type == EntryType.task
              ? c.kind == CategoryKind.task
              : c.kind == CategoryKind.money,
        )
        .toList();
    if (_categoryId == null || !categories.any((c) => c.id == _categoryId)) {
      _categoryId = categories.isEmpty ? null : categories.first.id;
    }

    final errors = _attempted
        ? _validate(state.categoryIndex).leftOrNull()
        : null;
    String? errorFor(String field) => errors == null
        ? null
        : find((FieldError e) => e.field == field, errors)?.detail;

    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(widget.existing == null ? 'Add entry' : 'Edit entry'),
          ),
          PipelineHelpButton(explain: () => _explain(errors)),
        ],
      ),
      content: SizedBox(
        width: 420,
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
              TextField(
                controller: _title,
                autofocus: true,
                onChanged: (_) => _onEdited(),
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: const OutlineInputBorder(),
                  errorText: errorFor('title'),
                ),
              ),
              const SizedBox(height: 12),
              if (_needsAmount) ...[
                TextField(
                  controller: _amount,
                  onChanged: (_) => _onEdited(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$ ',
                    border: const OutlineInputBorder(),
                    errorText: errorFor('amount'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              DropdownButtonFormField<String>(
                // New key per type: initialValue is only read on first
                // build, so force a rebuild when the category list changes.
                key: ValueKey(_type),
                initialValue: _categoryId,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: const OutlineInputBorder(),
                  errorText: errorFor('category'),
                ),
                items: [
                  for (final c in categories)
                    DropdownMenuItem(
                      value: c.id,
                      child: Row(
                        children: [
                          Icon(
                            categoryIcon(c),
                            size: 18,
                            color: categoryColor(c),
                          ),
                          const SizedBox(width: 8),
                          Text(c.name),
                        ],
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tags,
                onChanged: (_) => _onEdited(),
                decoration: InputDecoration(
                  labelText: 'Tags (comma-separated)',
                  border: const OutlineInputBorder(),
                  errorText: errorFor('tags'),
                ),
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
                          firstDate: DateTime(DateTime.now().year - 10),
                          lastDate: DateTime(DateTime.now().year + 10),
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
                        label: Text(
                          _dueDate == null
                              ? 'Due date'
                              : 'Due: ${shortDate(_dueDate!)}',
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate ?? _date,
                            firstDate: DateTime(DateTime.now().year - 10),
                            lastDate: DateTime(DateTime.now().year + 10),
                          );
                          if (picked != null) {
                            setState(() => _dueDate = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
              if (errorFor('dueDate') != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    errorFor('dueDate')!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (errors != null)
                ErrorPanel(
                  errors: errors,
                  title: 'Cannot save',
                  copyable: false,
                ),
              const SizedBox(height: 8),
              _PolicyToggle(
                failSlow: _failSlow,
                errorCount: errors?.length ?? 0,
                onChanged: (v) => setState(() => _failSlow = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => _save(state.categoryIndex),
          child: const Text('Save'),
        ),
      ],
    );
  }

  PipelineExplanation _explain(Nel<FieldError>? errors) {
    final failed = errors?.map((e) => e.field).toList() ?? const <String>[];
    return PipelineExplanation(
      title: 'Saving an entry',
      formula: _failSlow
          ? 'either((r) => r.zipOrAccumulate5(\n'
                '  vTitle, vAmount, vCategoryId, vDueDate, vTags,\n'
                '  Entry.new))'
          : 'either((r) {\n'
                '  final title = vTitle(r, …);   // first failure ends it\n'
                '  final amount = vAmount(r, …);\n'
                '  …\n'
                '})',
      steps: [
        PipelineStep(
          'EntryDraft',
          'the raw widget state as one value, so validation is a pure '
              'function instead of a GlobalKey<FormState>',
          '${_type.label} draft',
        ),
        PipelineStep(
          _failSlow ? 'zipOrAccumulate5' : 'either((r) { … })',
          _failSlow
              ? 'five independent branches all run; a raise inside one is '
                    'recorded rather than propagated, and the errors '
                    'concatenate in branch order'
              : 'one scope, five calls in order: the first raise ends the '
                    'block and the remaining validators never run',
          _failSlow ? '5 branches' : 'stops at 1',
        ),
        PipelineStep(
          'Nel<FieldError>',
          'the failure side is a non-empty list, so the panel can show '
              'head without an emptiness check and tail as "and N more"',
          failed.isEmpty ? 'no errors' : failed.join(' · '),
        ),
        PipelineStep(
          'toEitherNel',
          'the fail-fast path returns Either<FieldError, Entry>; lifting it '
              'to a one-element Nel means the UI has a single shape to render',
          _failSlow ? 'not needed here' : 'Left → Nel(1)',
        ),
      ],
      result: errors == null
          ? 'Right — the draft is valid and Save commits it'
          : 'Left — ${errors.length} problem${errors.length == 1 ? '' : 's'}: '
                '${failed.join(', ')}'
                '${_failSlow ? '' : ' (fail-fast: switch to "All at once" to see the rest)'}',
    );
  }
}

/// The fail-slow / fail-fast switch. Present because the difference is
/// invisible until you can flip it on the same bad form.
class _PolicyToggle extends StatelessWidget {
  final bool failSlow;
  final int errorCount;
  final ValueChanged<bool> onChanged;

  const _PolicyToggle({
    required this.failSlow,
    required this.errorCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<bool>(
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          segments: const [
            ButtonSegment(
              value: true,
              label: Text('All at once'),
              tooltip: 'zipOrAccumulate5 — report every bad field',
            ),
            ButtonSegment(
              value: false,
              label: Text('First only'),
              tooltip: 'a plain raise scope — stop at the first bad field',
            ),
          ],
          selected: {failSlow},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            failSlow
                ? 'zipOrAccumulate5 · showing $errorCount problem'
                      '${errorCount == 1 ? '' : 's'}'
                : 'fail-fast · showing at most 1 problem',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      ],
    );
  }
}
