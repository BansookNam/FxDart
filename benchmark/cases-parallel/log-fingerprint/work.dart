// The per-element job, shared verbatim by all four variants.
//
// Deliberately cheap — a few microseconds — because that is the case where
// the isolate round trip costs more than the work, and where `chunk` stops
// being a tuning knob and becomes the whole difference.

/// One raw log line.
class LogLine {
  const LogLine(this.id, this.text);
  final int id;
  final String text;
}

/// A line reduced to the shape it shares with every other line like it.
class Fingerprint {
  const Fingerprint(this.id, this.hash, this.digits);
  final int id;
  final int hash;
  final int digits;
}

/// How many hash permutations the sketch keeps. This is the knob the case
/// is calibrated on: it sets the per-line cost, and the point of this case
/// is that the cost lands *below* the ~5 µs it takes to hand one line to
/// another isolate. Real MinHash sketches run 16-128 permutations.
const sketchSize = 96;

/// Shingle width — overlapping character n-grams, so a line that differs by
/// one token still shares most of its shingles with the lines like it.
const shingle = 5;

/// Normalise a log line and reduce it to a MinHash sketch.
///
/// Digit runs collapse to `#` first, so ids and durations do not make every
/// line unique; then the normalised text is shingled and each shingle is fed
/// through [sketchSize] cheap permutations, keeping the minimum of each. Two
/// lines of the same shape land on the same sketch, which is how a log
/// pipeline groups a million lines into a handful of templates.
///
/// ~3 µs per line — *less* than the ~5 µs round trip to an isolate. That is
/// this case: at `chunk: 1`, `parallel` loses to the plain loop no matter
/// how many workers it is given, because the trip costs more than the trip
/// is for. It is the one case where `chunk` is not a tuning knob but the
/// difference between winning and losing.
Fingerprint fingerprint(LogLine line) {
  final text = line.text;
  var digits = 0;

  // Normalise in place into a small code-unit buffer: digit runs to one `#`.
  final norm = List<int>.filled(text.length, 0);
  var len = 0;
  var lastWasDigit = false;
  for (var i = 0; i < text.length; i++) {
    final c = text.codeUnitAt(i);
    final isDigit = c >= 0x30 && c <= 0x39;
    if (isDigit) {
      digits++;
      if (lastWasDigit) continue;
      norm[len++] = 0x23;
    } else {
      norm[len++] = c;
    }
    lastWasDigit = isDigit;
  }

  var sketch = 0x7FFFFFFF;
  var mixed = 0;
  for (var start = 0; start + shingle <= len; start++) {
    // One rolling hash per shingle...
    var h = 0x811C9DC5;
    for (var k = 0; k < shingle; k++) {
      h = ((h ^ norm[start + k]) * 0x01000193) & 0x3FFFFFFF;
    }
    // ...then the permutations, keeping each one's running minimum. The
    // minima are folded together rather than kept as a vector: the case
    // needs the *cost* of a sketch, not the sketch itself.
    for (var p = 0; p < sketchSize; p++) {
      final v = ((h + p * 0x9E3779B1) * 0x85EBCA6B) & 0x3FFFFFFF;
      if (v < sketch) sketch = v;
      mixed = (mixed + (v & 0x3F)) & 0x3FFFFFFF;
    }
  }
  return Fingerprint(line.id, (sketch * 31 + mixed) & 0x3FFFFFFF, digits);
}

/// The same job over a slice, for the hand-rolled isolate variant.
List<Fingerprint> fingerprintAll(List<LogLine> batch) => [
  for (final l in batch) fingerprint(l),
];
