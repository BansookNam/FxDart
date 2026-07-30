import 'package:fxdart/fxdart.dart';

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

Future<void> main() async {
  final files = makeFiles();
  await bench(
    slug: 'parallel-downloads',
    impl: 'fxdart',
    n: n,
    run: () async {
      maxInFlight = 0;
      finished.clear();
      final listing = await fx(files)
          .toAsync()
          .map(download)
          .concurrent(3)
          .zipWithIndex()
          .map((e) => '  ${e.$1 + 1}. ${e.$2}')
          .join('\n');
      final totalKb = fx(files).sumBy((f) => f.kb);
      return '${finished.length}|listing=${listing.length}'
          '|first=${finished.first}|total=$totalKb|max=$maxInFlight';
    },
  );
}
