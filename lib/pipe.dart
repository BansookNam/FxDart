import 'go.dart';

pipe(Function f, List fs) => (List as) => go([f(as), ...fs]);
