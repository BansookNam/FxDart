// Faithful scaled copy of the RxDart panel. The panel's pipeline only uses
// core Stream.asyncMap, so no rxdart import is needed here.
import '../../harness.dart';
import 'data.dart';

// The example's 15 ms per call becomes Duration.zero at benchmark scale.
Future<String> call(String request) async {
  await Future<void>.delayed(Duration.zero);
  return apiResponse(request);
}

Future<void> main() async {
  await bench(
    slug: 'dependent-calls-in-sequence',
    impl: 'rxdart',
    n: n,
    run: () async {
      // asyncMap pauses the source per future, so the calls are sequential
      // by construction; a closure variable threads each response onward.
      var token = 'guest';
      final log = await Stream.fromIterable(steps).asyncMap((step) async {
        token = await call('$step($token)');
        return '$step -> $token';
      }).toList();
      return '${log.length}|${log.last}';
    },
  );
}
