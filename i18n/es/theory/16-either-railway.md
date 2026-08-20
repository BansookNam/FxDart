---
slug: either-railway
chapter: 16
part: 4
title: Either como una vía de tren
description: Dos vías, un cambio de agujas por paso — la imagen que hace obvio el cortocircuito, más el mapeo de errores, la recuperación, y cómo componen en una tubería los pasos tipados por fallo.
---
# Either como una vía de tren

> **En este capítulo**
> - la imagen de las dos vías, y qué operaciones se mueven entre ellas
> - mapear el lado del fallo, y por qué los tipos de error necesitan eso para
>   componer
> - recuperación: `fold`, `getOrElse`, y dónde un programa deja de ser total
> - `Either` dentro de una tubería — `sequence`, `separate`, y la forma de una
>   importación real

## Dos vías

Dibuja una vía de éxito y una vía de fallo corriendo lado a lado. Cada paso
falible es un cambio de agujas: o bien continúa por la vía de éxito o se
desvía, una vez, hacia la vía de fallo — donde se queda.

![La vía de tren de dos carriles](diagrams/t16-1-railway.svg)

*Figura 16-1. `map` solo corre por la vía verde. `flatMap` es el cambio de agujas. `mapLeft` es lo único que toca la vía roja, y nada se reúne sin un `fold` explícito.*

Esa imagen es toda la semántica:

| Operación | Vía verde (`Right`) | Vía roja (`Left`) |
|---|---|---|
| `map(f)` | aplica `f` | pasa de largo |
| `flatMap(f)` | aplica `f`, que puede desviar | pasa de largo |
| `mapLeft(g)` | pasa de largo | aplica `g` |
| `fold(l, r)` | aplica `r` | aplica `l` |

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parseQty(String s) {
  final n = int.tryParse(s);
  return n == null
      ? Either.left('not a number')
      : Either.right(n);
}

void main() {
  final ok = parseQty('12');
  final bad = parseQty('twelve');

  print([ok.map((n) => n * 2), bad.map((n) => n * 2)]);
  print(ok.mapLeft((e) => 'qty: $e'));
  print(bad.mapLeft((e) => 'qty: $e'));
  print(bad.fold((e) => 'failed — $e', (n) => 'got $n'));
}
```

Una vez en la vía roja un valor está inerte: cada `map` y `flatMap`
subsiguiente es un no-op. Eso es cortocircuitar, y no necesita ningún soporte
especial en ningún lugar aguas abajo — por lo que puedes añadir un paso en
medio de una cadena sin tocar el resto.

## Los tipos de error también tienen que componer

Dos pasos con distintos tipos de error no encadenan, y aquí es donde el código
real suele atascarse:

```dart run
import 'package:fxdart/fxdart.dart';

class ParseError {
  const ParseError(this.input);
  final String input;
  @override
  String toString() => 'ParseError($input)';
}

class RangeError2 {
  const RangeError2(this.value);
  final int value;
  @override
  String toString() => 'RangeError2($value)';
}

// A common error type for the pipeline to speak.
sealed class OrderError {
  const OrderError();
}

class BadInput extends OrderError {
  const BadInput(this.detail);
  final String detail;
  @override
  String toString() => 'BadInput($detail)';
}

Either<ParseError, int> parse(String s) {
  final n = int.tryParse(s);
  return n == null ? Either.left(ParseError(s)) : Either.right(n);
}

Either<RangeError2, int> inStock(int n) =>
    n <= 5 ? Either.right(n) : Either.left(RangeError2(n));

void main() {
  // mapLeft lifts both into the pipeline's own error type.
  Either<OrderError, int> order(String raw) => either((r) {
        final n = r.bind(
            parse(raw).mapLeft((e) => BadInput('$e')));
        final ok = r.bind(
            inStock(n).mapLeft((e) => BadInput('$e')));
        return ok;
      });

  print(order('3'));
  print(order('nine'));
  print(order('9'));
}
```

`mapLeft` es lo que hace que un tipo de fallo sea *local*: cada módulo puede
lanzar el error que conoce, y quien llama traduce en la frontera. Sin él acabas
con un enum-dios de cada error del programa, que es el equivalente en errores
tipados de capturar `Exception`.

Un tipo de error `sealed` (capítulo 3) da sus frutos aquí: un `switch` sobre
`OrderError` en lo alto del programa es exhaustivo, así que añadir un caso es
un error de compilación en cada manejador.

## Recuperación, y dónde termina la totalidad

Una vía de tren solo es útil si las vías finalmente se reúnen en algo que quien
llama pueda usar. Esa reunión es `fold`, y es el punto donde debes decidir qué
*significa* el fallo:

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> configPort(String? raw) => raw == null
    ? Either.left('missing')
    : (int.tryParse(raw) == null
        ? Either.left('not a number: $raw')
        : Either.right(int.parse(raw)));

void main() {
  // Substitute a default — the failure was recoverable.
  print(configPort(null).fold((_) => 8080, (n) => n));

  // Keep the reason and report it — the failure was not.
  print(configPort('x')
      .fold((e) => 'config error: $e', (n) => '$n'));

  // Switch on it, exhaustively, when the type is sealed.
  final result = configPort('9000');
  final message = switch (result) {
    Left(:final value) => 'no port ($value)',
    Right(:final value) => 'port $value',
  };
  print(message);
}
```

Tres finales, una regla: **el programa vuelve a ser total en el `fold`.** Antes
de él, un fallo es dato fluyendo por una vía; después, se ha tomado una
decisión. Empujar ese punto lo más tarde posible — al manejador HTTP, a la UI,
al código de salida de la CLI — es el hábito más útil que ofrece este
capítulo.

## Either en una tubería

El trabajo real tiene muchas filas, y los recorridos del capítulo 9 son cómo la
vía de tren escala más allá de un solo valor:

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parseRow(String s) {
  final n = int.tryParse(s);
  return n == null ? Either.left('bad row: $s') : Either.right(n);
}

void main() {
  final rows = ['10', 'x', '30', 'y'];

  // All or nothing.
  print(fx(rows).map(parseRow).sequence());

  // Everything that failed, and everything that did not.
  final (errors, values) = separateEither(rows.map(parseRow));
  print('imported ${values.length}, rejected: $errors');

  // Keep going, but report every reason at the end.
  print(fx(rows).map(parseRow).flattenOrAccumulate());
}
```

Tres políticas, un solo parser. Esa separación — la función por fila no sabe
nada de la política, la tubería la elige — es lo que compra la forma de dos
vías a escala.

> 🎓 **Programación orientada a vía de tren, y dónde la metáfora hace agua.**
> La charla de Scott Wlaschin sobre «railway-oriented programming» es donde la
> mayoría se encuentra con esta imagen, y es buena — pero describe `Either`
> usado *monádicamente*, que es solo la mitad de la historia. La imagen no
> tiene forma de dibujar dos trenes que chocaron ambos (la acumulación del
> capítulo 6), y sugiere que los fallos son descarrilamientos raros cuando en
> la mayoría de los sistemas son resultados ordinarios con su propia lógica.
> Conserva la imagen para secuenciar y déjala cuando necesites combinar
> resultados independientes.

## Cuándo se gana el sueldo

Fallos de dominio sobre los que quien llama puede actuar: validación, parseo,
autorización, reglas de negocio, cualquier cosa que de otro modo expresarías
como un retorno anulable más un comentario. Da sus frutos sobre todo donde los
fallos deben llevar *información* — qué regla, qué campo, qué id.

No da sus frutos para fallos sobre los que nadie puede actuar (falta de
memoria, un bug), para una única llamada cuyo único modo de fallo es «no
encontrado» (`A?` es más pequeño), o para tipos de error que todavía no sabes
nombrar — un `Either<String, T>` donde la cadena se construye por
interpolación es una excepción disfrazada de tipo con pasos extra.

## Ejercicios

1. `map` sobre un `Left` no hace nada. ¿Qué ley del functor obliga a eso, y qué
   se rompería si una librería «útilmente» ejecutara la función de todas
   formas?
2. Escribe `getOrElse` para `Either` en términos de `fold`. Luego escribe
   `orElse`, que toma un `Either` de respaldo en vez de un valor de respaldo.
3. Tienes `Either<A, T>` de un módulo y `Either<B, T>` de otro, y quien llama
   quiere `Either<C, T>`. Esboza las tres llamadas a `mapLeft` y di dónde
   pertenecen en una aplicación por capas.
4. `separateEither` devuelve `(errors, values)`. ¿Por qué ese orden, y qué
   consecuencia tiene la elección para leer código de un vistazo?

## Soluciones

1. La ley de identidad: `left.map(id)` debe ser igual a `left`. Si `map`
   ejecutara `f` sobre el valor de fallo tendría que poner el resultado en
   algún lugar — cambiando el tipo del `Left` o su contenido — así que mapear
   la identidad ya no sería un no-op. Lo que se rompe en concreto es la
   composición: `map(f).map(g)` aplicaría ambas funciones a un error para el
   que ninguna fue escrita, normalmente colapsando dentro de código que asumía
   un valor de éxito.
2. `T getOrElse<T>(Either<Object?, T> e, T fallback) =>
   e.fold((_) => fallback, (v) => v);` y
   `Either<E, T> orElse<E, T>(Either<E, T> e, Either<E, T> other) =>
   e.fold((_) => other, (_) => e);`. El segundo es el semigrupo sobre `Either`
   que conserva el primer éxito — un monoide si tienes un fallo identidad, que
   normalmente no tienes.
3. `moduleA().mapLeft(toC)` y `moduleB().mapLeft(toC)`, ambas en la costura
   donde los dos módulos se encuentran — típicamente la capa de caso de uso o
   de servicio, no dentro de ningún módulo y no en la frontera HTTP. Traducir
   demasiado pronto acopla el módulo al vocabulario de quien llama; demasiado
   tarde significa el enum-dios.
4. Coincide con `(Left, Right)` — el mismo orden que los parámetros de tipo y
   que los brazos del `switch`, así que nada en el código base pregunta jamás
   «¿cuál va primero?». La consistencia aquí vale más que cualquier argumento
   sobre cuál es más importante: un lector que tiene que comprobar el orden una
   vez tendrá que comprobarlo cada vez.
