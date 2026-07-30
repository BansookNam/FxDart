import '../../harness.dart';
import 'data.dart';

int inFlight = 0;
int maxInFlight = 0;
final finished = <String>[];

Future<String> download(FileSpec f) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future<void>.delayed(Duration(milliseconds: f.ms));
  inFlight--;
  finished.add(f.name);
  return '${f.name} (${f.kb} KB)';
}

/// Worker pool: [limit] workers share a cursor; pre-sized slots keep the
/// results in request order even though completions interleave.
Future<List<String>> downloadAll(List<FileSpec> all, int limit) async {
  final results = List<String?>.filled(all.length, null);
  var next = 0;
  Future<void> worker() async {
    while (next < all.length) {
      final i = next++;
      results[i] = await download(all[i]);
    }
  }

  await Future.wait([for (var i = 0; i < limit; i++) worker()]);
  return results.cast<String>();
}

Future<void> main() async {
  final files = makeFiles();
  await bench(
    slug: 'parallel-downloads',
    impl: 'native',
    n: n,
    run: () async {
      maxInFlight = 0;
      finished.clear();
      final results = await downloadAll(files, 3);
      // The example prints a numbered listing; build it as the workload's
      // final materialization on both sides.
      final listing = [
        for (var i = 0; i < results.length; i++) '  ${i + 1}. ${results[i]}'
      ].join('\n');
      final totalKb = files.fold(0, (sum, f) => sum + f.kb);
      return '${results.length}|listing=${listing.length}'
          '|first=${finished.first}|total=$totalKb|max=$maxInFlight';
    },
  );
}
