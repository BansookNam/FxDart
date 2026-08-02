// Async case: n dependent calls, each response feeding the next request.
// The example's four-entry const api map becomes a deterministic response
// formula so the chain scales with n while every response still depends on
// the whole request (step name + prior token).
import '../../harness.dart';

final n = caseN(10000);

/// n pipeline steps, replacing the example's four named steps.
final steps = List<String>.generate(n, (i) => 'step${i + 1}');

/// Deterministic stand-in for the example's const api map: a small
/// polynomial hash of the request string yields the response token.
String apiResponse(String request) {
  var h = 7;
  for (final c in request.codeUnits) {
    h = (h * 31 + c) & 0x3fffffff;
  }
  return 'tok$h';
}
