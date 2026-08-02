// Deterministic n-file upload queue shared verbatim by both sides.
// The API accepts at most four files per request, as in the example.
import '../../harness.dart';

final n = caseN(1000000);

List<String> makePending() =>
    List.generate(n, (i) => 'img-${(i + 1).toString().padLeft(7, '0')}');
