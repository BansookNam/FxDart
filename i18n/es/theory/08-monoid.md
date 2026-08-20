---
slug: monoid
chapter: 8
part: 2
title: Monoide y semigrupo
description: Una combinación asociativa más un elemento identidad — el álgebra útil más pequeña, y la que decide si fold necesita semilla, si la reducción puede ser paralela, y por qué los errores se acumulan en una NonEmptyList.
---
# Monoide y semigrupo

> **En este capítulo**
> - dos leyes — asociatividad e identidad — y qué compra cada una por separado
> - por qué `reduce` lanza sobre una colección vacía y `fold` no
> - la propiedad que hace que la reducción paralela y por trozos den la misma respuesta
> - `NonEmptyList` como semigrupo, y por qué los errores de FxDart se acumulan en una

## El álgebra útil más pequeña

Un **semigrupo** es un tipo con una operación binaria asociativa:

`combine(a, combine(b, c)) == combine(combine(a, b), c)`

Un **monoide** es un semigrupo con un elemento identidad:

`combine(empty, a) == a == combine(a, empty)`

Eso es todo. `int` con `+` y `0`; `int` con `*` y `1`; `String` con `+` y `''`;
`List` con `+` y `[]`; `bool` con `&&` y `true`. Has usado todos ellos hoy.

```dart run
void main() {
  // associativity: grouping does not matter
  print((1 + 2) + 3 == 1 + (2 + 3));
  print(('a' + 'b') + 'c' == 'a' + ('b' + 'c'));

  // identity: the neutral element changes nothing
  print(0 + 7 == 7 && 7 + 0 == 7);
  print(''.length + 'abc'.length == 3);

  // subtraction is neither associative nor unital
  print((10 - 3) - 2 == 10 - (3 - 2));
}
```

La última línea es la razón de ser de la definición: «combinar dos cosas» no
basta. La resta combina dos `int` y es inútil para los trabajos de abajo.

## Qué compra cada ley

**La identidad te da el caso vacío.** Por eso Dart tiene dos métodos de
plegado y se comportan de forma distinta sobre una colección vacía:

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  // fold carries the identity element as a seed — total, always.
  print(fx(<int>[]).fold<int>(0, (a, b) => a + b));
  print(fx([1, 2, 3]).fold<int>(0, (a, b) => a + b));

  // reduce has no seed, so the empty case has no answer to give.
  try {
    print(fx(<int>[]).reduce((a, b) => a + b));
  } catch (e) {
    print('reduce on empty: ${e.runtimeType}');
  }
}
```

`reduce` solo requiere un semigrupo y por tanto es parcial. `fold` requiere un
monoide — tú aportas `empty` como semilla — y es total. La excepción con la
que has chocado cien veces es un elemento identidad ausente, apareciendo en
tiempo de ejecución.

**La asociatividad te da libertad de agrupación**, y eso vale más de lo que
parece. Significa que la misma operación puede ejecutarse:

- de izquierda a derecha, un elemento cada vez (un fold normal);
- por trozos, combinando después los resultados de cada trozo;
- en paralelo, en varios isolates, combinando según llegan los resultados;
- de forma incremental, manteniendo un total parcial y sumándole más después.

Las cuatro dan la misma respuesta, y *solo* la asociatividad lo garantiza.

![Una ley, cuatro órdenes de evaluación](diagrams/t8-1-monoid-orders.svg)

*Figura 8-1. La asociatividad dice que toda forma de poner paréntesis en la misma secuencia aterriza en el mismo valor. Esa es la licencia para trocear, para reducir en paralelo y para retomar un total parcial.*

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  final data = List.generate(12, (i) => i + 1);

  // Sequential.
  final straight = fx(data).fold(0, (a, b) => a + b);

  // Chunked, then the chunk results combined — legal because +
  // is associative and 0 is its identity.
  final chunked = fx(data)
      .chunk(5)
      .map((c) => fx(c).fold(0, (a, b) => a + b))
      .fold(0, (a, b) => a + b);

  print([straight, chunked, straight == chunked]);

  // Order does NOT come free: subtraction disagrees with itself.
  final subStraight = fx(data).fold(0, (a, b) => a - b);
  final subChunked = fx(data)
      .chunk(5)
      .map((c) => fx(c).fold(0, (a, b) => a - b))
      .fold(0, (a, b) => a - b);
  print([subStraight, subChunked, subStraight == subChunked]);
}
```

## La conmutatividad es una ley *distinta*

La asociatividad dice que la agrupación no importa. La **conmutatividad** —
`a + b == b + a` — dice que el *orden* no importa, y la mayoría de los
monoides útiles no la tienen. La concatenación de cadenas, el append de listas
y la composición de funciones son todos asociativos y ninguno es conmutativo.

La distinción tiene dientes en el capítulo asíncrono de FxDart: `concurrent(n)`
evalúa los elementos fuera de orden pero los emite **en el orden de la
fuente**, precisamente para que un fold posterior solo necesite asociatividad y
no conmutatividad. Una librería que entregara los resultados en orden de
finalización estaría exigiendo en silencio la ley más fuerte a tu código.

## `NonEmptyList`, y por qué los errores son un semigrupo

El capítulo 6 acumulaba errores de validación. Pregunta en qué tipo se acumulan
*hacia* y el álgebra responde antes que tú: necesitas algo que puedas combinar
asociativamente (dos ramas fallidas se concatenan), y el resultado de combinar
fallos nunca está vacío — así que la identidad no es meramente innecesaria,
sería una mentira.

Eso es un semigrupo sin monoide, y FxDart lo llama `NonEmptyList`:

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  final a = NonEmptyList.of('name is empty');
  final b = NonEmptyList.of(
      'age is negative', ['age is not a number']);

  // Combining failures is list concatenation: associative,
  // and the result cannot be empty.
  final all = NonEmptyList.of(a.first, [...a.skip(1), ...b]);
  print(all.toList());
  print('length: ${all.length}');

  // Nel is an extension type over List, so it costs nothing at
  // runtime — and `orNull` is the only way in from a plain list.
  print(NonEmptyList.orNull(<String>[]));
}
```

`Either<Nel<E>, A>` se lee por tanto como una afirmación precisa: *si esto
falló, hay al menos un motivo, y los motivos se combinan.* Una `List<E>`
habría admitido el estado sin sentido «falló con cero errores» — el argumento
del capítulo 3, aplicado al canal de errores.

> 🎓 **Los monoides componen, y por eso están en todas partes.** Si `A` y `B`
> son monoides, también lo es `(A, B)`, combinando componente a componente con
> `(emptyA, emptyB)` como identidad — así que «suma, cuenta y máximo en una
> pasada» es un único fold sobre un monoide producto, y una media es ese fold
> más una división. Las funciones hacia un monoide forman un monoide
> (`(f + g)(x) = f(x) + g(x)`), y las endofunciones forman un monoide bajo
> composición con `identity` como unidad — que es la frase escondida dentro de
> «una mónada es un monoide en la categoría de los endofunctores»: `flatten` es
> la combinación, `of` es la identidad, y las tres leyes monádicas del
> capítulo 1 son estas dos leyes disfrazadas.

## Cuándo se gana el sueldo

Cada vez que escribes un `fold` estás eligiendo un monoide, y nombrarlo en voz
alta te dice si el código está bien: ¿tiene identidad (qué debería devolver el
caso vacío?), y es asociativo (se puede repartir el trabajo?).

Paga más fuerte a escala — procesamiento por trozos, agregación paralela,
totales incrementales en una base de datos — y en el diseño de API, donde
«dame una semilla y una combinación» es la interfaz que deja a una librería
agrupar tu trabajo sin preguntar.

No paga como vocabulario en un código que hace un `reduce` sobre diez
elementos. Ahí di «suma».

## Ejercicios

1. ¿Es `max` un semigrupo sobre `int`? ¿Un monoide? ¿Cuál tendría que ser el
   elemento identidad, y lo tiene Dart?
2. Da un monoide cuyo `empty` no sea el valor «obviamente vacío» — es decir,
   uno donde quien lea lo adivinaría mal.
3. `fx(xs).fold(0, (a, b) => a + b.length)` suma longitudes de cadenas. ¿Es
   asociativa la función que le pasaste a `fold`? ¿Por qué eso no es un
   problema?
4. Tanto la acumulación de `Either` como `Future.wait` combinan resultados
   independientes. ¿Qué monoide usa `Future.wait`, y qué hace con los fallos?

## Soluciones

1. Sí y sí. `max` es asociativo y conmutativo; su identidad es menos infinito,
   que para `int` no existe en Dart — así que `max` es un *semigrupo* sobre
   `int` y un monoide solo sobre `double` (`double.negativeInfinity`) o sobre
   `int?` con `null` como identidad. Esa es la razón honesta de que `reduce`
   encaje de forma natural con `max` y `fold` necesite una semilla incómoda.
2. Varios: `bool` bajo `&&` tiene identidad `true`, no `false`; `int` bajo `*`
   tiene identidad `1`, no `0`; y el monoide «el primero no nulo» tiene
   identidad `null`. La lección es que `empty` lo determina la operación, nunca
   el tipo — adivinarlo por el tipo es cómo un fold acaba multiplicándolo todo
   por cero.
3. No es asociativa — ni siquiera tiene la forma adecuada, porque el tipo de la
   semilla `int` difiere del tipo del elemento `String`. `fold` en Dart es el
   *catamorfismo* más general `(B, A) → B`, y solo cuando `B == A` surge la
   pregunta del monoide. No es un problema porque el fold secuencial nunca
   reagrupa; se convierte en un problema en el momento en que quieres trocearlo,
   punto en el cual debes factorizar la operación en un monoide genuino
   (`String → int`, y luego sumar).
4. `Future.wait` usa el monoide de listas sobre los resultados — concatenándolos
   en el orden de los argumentos, con `[]` como identidad (esperar a nada da
   una lista vacía). Los fallos *no* se acumulan: por defecto gana el primer
   error y los demás se descartan, que es el comportamiento de fallo rápido que
   el capítulo 6 contrastaba con `zipOrAccumulate`. `eagerError: false` cambia
   cuándo informa, no de cuántos informa.
