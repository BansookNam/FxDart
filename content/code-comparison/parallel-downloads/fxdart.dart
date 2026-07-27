import 'package:fxdart/fxdart.dart';

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

Future<void> main() async {
  final listing = await fx(files)
      .toAsync()
      .map(download)
      .concurrent(3)
      .zipWithIndex()
      .map((e) => '  ${e.$1 + 1}. ${e.$2}')
      .join('\n');
  print('downloaded ${files.length} files, 3 at a time, in request order:');
  print(listing);
  print('first to finish: ${finished.first}');
  print('total size: ${fx(files).sumBy((f) => f.kb)} KB');
  print('max downloads in flight: $maxInFlight');
}
