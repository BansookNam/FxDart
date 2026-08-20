---
slug: traverse
chapter: 9
part: 2
title: Recorrido (traverse)
description: Convertir una lista de resultados en un resultado de lista — la operación que intercambia dos estructuras, por qué necesita un applicative, y las cuatro grafías que trae FxDart porque Dart no puede escribirla una sola vez.
---
# Traverse

> **En este capítulo**
> - el intercambio: `List<Either<E, A>>` → `Either<E, List<A>>`, y por qué lo necesitas una y otra vez
> - `traverse` = map + sequence, y qué aporta el applicative
> - versiones de fallo rápido y fallo lento, y el coste honesto de cada una
> - la gemela asíncrona, y dónde `traverse` se encuentra con `concurrent(n)`

## La forma que llevas escribiendo a mano

Valida diez filas y tienes `List<Either<E, Row>>`. Nada de lo que viene
después quiere eso: quien llama quiere o bien todas las filas, o bien los
motivos por los que no puede tenerlas. Escrito a mano son las mismas quince
líneas siempre — un acumulador, un bucle, un retorno temprano.

La operación tiene nombre, **sequence**, y su generalización — mapear primero,
después secuenciar — es **traverse**:

```
sequence : List<F<A>>              → F<List<A>>
traverse : List<A> × (A → F<B>)    → F<List<B>>
```

Léelo como *intercambiar las dos estructuras*. La lista sigue siendo lista, el
efecto sigue siendo efecto; lo que cambia es cuál queda por fuera.

![Intercambiar las estructuras](diagrams/t9-1-traverse-swap.svg)

*Figura 9-1. Cada elemento lleva su propio efectito; tras el intercambio, un solo efecto lleva la lista entera. Los valores no cambian — solo el anidamiento.*

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parsePort(String s) {
  final n = int.tryParse(s);
  if (n == null) return Either.left('not a number: $s');
  if (n < 1024) return Either.left('privileged: $n');
  return Either.right(n);
}

void main() {
  // traverse: map each element to an Either, then swap.
  print(fx(['8080', '9000']).map(parsePort).sequence());
  print(fx(['8080', 'x', '80']).map(parsePort).sequence());
}
```

Un solo valor de salida, y es el valor que quiere el resto del programa:
`Right` con todos los puertos, o `Left` con el primer motivo por el que no hay
lista en absoluto.

## Por qué necesita un applicative y no solo un functor

`map` por sí solo no puede hacer esto. Mapear sobre la lista te deja los
efectos *dentro*, y nada en `map` puede sacar uno fuera. Para construir
`F<List<A>>` tienes que combinar los efectos de los elementos entre sí — eso es
`map2` del capítulo 6, aplicado repetidamente:

`sequence([a, b, c])` = `map2(a, map2(b, map2(c, of([]), cons), cons), cons)`

Lo cual explica de inmediato los dos comportamientos que puedes obtener. La
operación que combina es la del applicative, así que **el applicative con el
que recorres decide la política de fallo**:

- Recorre con el applicative de fallo rápido de `Either` → párate en el primer
  `Left`.
- Recorre con el applicative acumulador → recoge todos los `Left`.

El mismo recorrido, distinta álgebra, distinto informe. FxDart expone ambos:

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parsePort(String s) {
  final n = int.tryParse(s);
  if (n == null) return Either.left('not a number: $s');
  if (n < 1024) return Either.left('privileged: $n');
  return Either.right(n);
}

void main() {
  final raw = ['8080', 'x', '80', '9000'];

  // Fail fast: the first reason, and nothing after it ran.
  print(fx(raw).map(parsePort).sequence());

  // Fail slow: every reason, in order.
  print(fx(raw).map(parsePort).flattenOrAccumulate());

  // And the map-and-swap in one step, with the accumulating
  // applicative doing the combining.
  print(mapOrAccumulate(
      (r, String s) => r.bind(parsePort(s)), raw));
}
```

Hay una tercera cosa que podrías querer — *quedarte con las filas buenas e
informar de las malas* — y eso no es un recorrido en absoluto, porque el
resultado son dos listas en vez de un efecto. Tiene su propio nombre:

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parsePort(String s) {
  final n = int.tryParse(s);
  return n == null ? Either.left('bad: $s') : Either.right(n);
}

void main() {
  final results = ['8080', 'x', '9000'].map(parsePort).toList();
  final (bad, good) = separateEither(results);
  print('kept: $good');
  print('dropped: $bad');

  // …or take just one side.
  print(rights(results));
  print(lefts(results));
}
```

Elegir entre ellos es una decisión de producto, no técnica: una herramienta de
importación quiere `separateEither`, un cargador de configuración quiere
`flattenOrAccumulate`, un manejador de API quiere `sequenceEither`.

## La gemela asíncrona

Cambia `Either` por `Future` y la misma operación aparece vestida con la ropa
del propio Dart: `Future.wait` **es** `sequence` para futures. Lo cual
significa que la versión interesante es la que recorre *y además* acota el
trabajo:

```dart run
import 'package:fxdart/fxdart.dart';

Future<int> fetchSize(String url) async {
  await Future.delayed(const Duration(milliseconds: 20));
  return url.length;
}

void main() async {
  final urls = ['a.com', 'bb.com', 'ccc.com', 'dddd.com'];

  // Sequence with unbounded concurrency: Future.wait.
  print(await Future.wait(urls.map(fetchSize)));

  // Traverse with *bounded* concurrency: three in flight,
  // results still in source order.
  final bounded =
      fx(urls).toAsync().mapConcurrent(3, fetchSize);
  print(await bounded.toList());
}
```

`Future.wait` es el recorrido applicative sin freno: lo arranca todo.
`mapConcurrent(n)` es el mismo recorrido con un límite, que es lo que
realmente quieres contra una API con límite de tasa. El capítulo 13 explica el
canal de retorno que hace que el límite sea real y no una recomendación.

> 🎓 **Traverse es más general que las listas.** La firma completa es
> `traverse : T<A> × (A → F<B>) → F<T<B>>` para cualquier contenedor
> *recorrible* `T` y cualquier applicative `F` — los árboles, los mapas y
> `Option` también son recorribles. Tiene dos leyes (identidad y composición,
> como las del functor) y un corolario famoso: `traverse` con el applicative
> identidad es simplemente `map`, y con el applicative constante es `fold`.
> `map`, `fold` y `traverse` son tres caras de una sola operación — lo cual es
> un resultado precioso, y requiere tipos de orden superior para enunciarlo
> siquiera una vez. Ese es el tema del capítulo 10, y la razón de que FxDart
> traiga cuatro recorridos concretos en lugar de uno genérico.

## El coste de no tenerlo genéricamente

Cuenta las versiones del código de arriba: `sequenceEither`,
`flattenOrAccumulate`, `mapOrAccumulate`, `separateEither` — más
`sequenceEitherAsync`, `flattenOrAccumulateAsync` y `mapOrAccumulateAsync`
para cadenas asíncronas. Siete funciones donde un lenguaje con tipos de orden
superior escribe una.

Eso no es incompetencia, es el techo del lenguaje, y tiene un coste real para
ti: cuando FxDart añada un nuevo tipo de efecto, ninguno de tus recorridos
existentes funcionará con él hasta que alguien escriba a mano las variantes
séptima, octava y novena.

## Cuándo se gana el sueldo

Cualquier frontera donde una colección de cosas independientes y falibles debe
convertirse en una decisión: parsear un fichero de configuración, validar una
importación, cargar N registros, abanicarse hacia N servicios. Si has escrito
`for (final x in xs) { final r = f(x); if (r.isLeft) return r; out.add(...); }`
más de dos veces, eso es un recorrido y deberías decirlo.

Sáltatelo cuando la colección tenga un elemento (usa el `Either` directamente),
cuando necesites semántica de éxito parcial (eso es `separateEither`), o cuando
el bucle haga de verdad algo por elemento que no sea un map puro — un recorrido
que esconde un efecto colateral es peor que el bucle al que sustituyó.

## Ejercicios

1. ¿Qué es `sequence` sobre una lista vacía — para `Either`, y para `Future`?
   ¿Qué ley del capítulo 8 decide la respuesta?
2. `traverse(xs, f)` y `xs.map(f)` seguido de `sequence` dan el mismo
   resultado. ¿Cuál es más barato en Dart, y por qué FxDart trae aun así las
   dos grafías?
3. Tienes `Either<E, List<A>>` y quieres `List<Either<E, A>>` — el intercambio
   en la otra dirección. ¿Es siempre posible? Pruébalo con un `Left`.
4. `Future.wait` arranca todos los futures de inmediato. Anota dos situaciones
   donde eso es exactamente lo correcto y dos donde `mapConcurrent(n)` es la
   única elección correcta.

## Soluciones

1. `Right([])` y `Future.value([])` — la lista vacía envuelta en el `pure` del
   applicative. El elemento identidad del monoide de listas del capítulo 8 es
   `[]`, y `sequence` de nada debe producir la identidad; cualquier otra cosa
   rompería la composición de dos recorridos sobre entradas concatenadas.
2. Es el mismo trabajo; `traverse` evita construir la `List<F<B>>` intermedia,
   lo cual importa a escala pero no con diez elementos. FxDart trae ambas
   porque la forma en dos pasos compone dentro de una cadena perezosa existente
   (`.map(f).sequenceEither()`), mientras que la forma fusionada es la que
   quieres cuando la fuente ya está materializada.
3. Sí, pero el caso interesante es `Left(e)`: ¿se convierte en `[Left(e)]`? ¿O
   en `[]`? Ambas son defendibles, y eso delata que esta dirección *no* es un
   recorrido — no hay ninguna ley que fuerce la respuesta. El intercambio
   general `F<T<A>> → T<F<A>>` se llama *ley distributiva* y existe solo para
   pares concretos de estructuras.
4. Correcto: un puñado de cálculos locales rápidos; un abanico donde el lado
   remoto está explícitamente construido para carga en paralelo. Incorrecto:
   cualquier API con límite de tasa o de pago (un abanico sin acotar te lleva
   al estrangulamiento o a la factura), y cualquier lista cuya longitud
   controle quien usa el programa — `Future.wait` sobre una lista de 100.000
   elementos abre 100.000 sockets, y el modo de fallo es tu proceso, no el
   suyo.
