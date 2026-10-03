import 'package:fxdart/fxdart.dart';

const users = {1: 'kim'};
const scores = {'kim': 42};

Either<String, String> findUser(int id) =>
    fxEither((r) => r.ensureNotNull(users[id], () => 'no user $id'));

Either<String, int> findScore(String name) =>
    fxEither((r) => r.ensureNotNull(scores[name], () => 'no score for $name'));

// Each r.bind unwraps a success or short-circuits the whole block with
// the failure — no flatMap pyramid, just straight-line code:
Either<String, String> report(int id) => fxEither((r) {
  final name = r.bind(findUser(id));
  final score = r.bind(findScore(name));
  return '$name scored $score';
});

void main() {
  print(report(1)); // Right(kim scored 42)
  print(report(2)); // Left(no user 2)
}
