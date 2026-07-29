import 'package:fxdart/fxdart.dart';

EitherNel<String, (String, String)> signup(String user, String email) =>
    either((r) => r.zipOrAccumulate2(
          // TODO branch 1: r.ensure user is not empty → 'user is empty'
          (r) => user,
          // TODO branch 2: r.ensure email contains '@' → 'email is invalid'
          (r) => email,
          (u, e) => (u, e),
        ));

void main() {
  print(signup('kim', 'kim@fx.dev')); // expect: Right((kim, kim@fx.dev))
  print(signup('', 'nope')); // expect: Left([user is empty, email is invalid])
}
