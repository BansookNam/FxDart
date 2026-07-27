class FileSpec {
  final String name;
  final int kb;
  final int ms; // fixed simulated transfer time
  const FileSpec(this.name, this.kb, this.ms);
}

const files = [
  FileSpec('video.mp4', 900, 30), FileSpec('notes.txt', 2, 10),
  FileSpec('slides.pdf', 340, 20), FileSpec('photo.jpg', 180, 30),
  FileSpec('data.csv', 55, 30), FileSpec('theme.zip', 260, 30),
];

int inFlight = 0;
int maxInFlight = 0;
final finished = <String>[];

Future<String> download(FileSpec f) async {
  inFlight++;
  if (inFlight > maxInFlight) maxInFlight = inFlight;
  await Future.delayed(Duration(milliseconds: f.ms));
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
  final results = await downloadAll(files, 3);
  print('downloaded ${files.length} files, 3 at a time, in request order:');
  for (var i = 0; i < results.length; i++) {
    print('  ${i + 1}. ${results[i]}');
  }
  print('first to finish: ${finished.first}');
  print('total size: ${files.fold(0, (sum, f) => sum + f.kb)} KB');
  print('max downloads in flight: $maxInFlight');
}
