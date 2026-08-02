// Deterministic n-day forecast/actual temperature series, shared verbatim.
// actual[i] tracks forecast[i] within ±2° so the +/- delta formatting in
// line() exercises both branches, like the example.
import '../../harness.dart';

final n = caseN(1000000);

final List<double> forecast = _makeForecast();
final List<double> actual = _makeActual();

List<double> _makeForecast() {
  final rng = Lcg(16);
  return List.generate(n, (i) => 10.0 + rng.nextDouble() * 20.0);
}

List<double> _makeActual() {
  final rng = Lcg(1616);
  return List.generate(n, (i) => forecast[i] + (rng.nextDouble() * 4.0 - 2.0));
}
