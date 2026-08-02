// Deterministic n-event session log, shared verbatim by both sides.
import '../../harness.dart';

final n = caseN(1000000);

const _actions = ['open', 'edit', 'save', 'view', 'close'];

final List<String> events = List.generate(n, (i) {
  final h = (9 + i ~/ 3600) % 24;
  final m = (i ~/ 60) % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} '
      '${_actions[i % _actions.length]} doc-$i';
});
