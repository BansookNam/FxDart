import 'package:fxdart/fxdart.dart';

void main() {
  // TODO: build a throwing function for "not implemented" and trigger it
  final notImplemented = fxThrowError<String>(
    (name) => UnimplementedError(name),
  );

  try {
    notImplemented('exportPdf');
  } catch (e) {
    print('caught: $e'); // caught: UnimplementedError: exportPdf
  }
}
