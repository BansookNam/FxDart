import 'package:fxdart/fxdart.dart';

pipe(Function f, List fs) => (List as) => fxDart([f(as), ...fs]);
