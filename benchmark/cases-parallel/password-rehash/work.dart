// The per-element job, shared verbatim by all five variants.
//
// Top-level and sendable, which is what `parallel` asks of a worker and
// what `Isolate.run` needs anyway — so the four files differ only in where
// this runs, never in what it computes.

/// One credential to re-hash.
class Credential {
  const Credential(this.user, this.salt, this.secret);
  final int user;
  final int salt;
  final int secret;
}

/// The result: the derived key, and the user it belongs to.
class Derived {
  const Derived(this.user, this.key);
  final int user;
  final int key;
}

/// Iterated key derivation, PBKDF2's shape: mix the secret with the salt
/// over and over so that verifying a password is deliberately expensive.
///
/// The round count is what a KDF is *tuned* by, and it is set here so one
/// credential costs ~250 µs — the range a real deployment picks, and fifty
/// times the ~5 µs it costs to hand the credential to another isolate. That
/// ratio is the case: work this heavy does not need the batching the cheap
/// cases do.
///
/// Why not heavier still: the headline N has to stay above the 10,000 the
/// runner also measures at, or the "full" block would be *smaller* than the
/// block above it and the page would read backwards. Cost per credential and
/// the headline size trade off against each other at a fixed ~5 s baseline.
const kdfRounds = 55000;

Derived rehash(Credential c) {
  var h = c.secret ^ (c.salt * 0x9E3779B1);
  for (var i = 0; i < kdfRounds; i++) {
    h = (h * 31 + c.salt + i) & 0x1FFFFFFFFFFFFF;
    h ^= (h >> 13);
    h = (h * 0x27D4EB2D) & 0x1FFFFFFFFFFFFF;
    h ^= (h >> 7);
  }
  return Derived(c.user, h);
}

/// The same job over a slice, for the hand-rolled isolate variant.
List<Derived> rehashAll(List<Credential> batch) => [
  for (final c in batch) rehash(c),
];
