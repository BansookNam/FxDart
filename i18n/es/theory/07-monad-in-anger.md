---
slug: monad-in-anger
chapter: 7
part: 2
title: La mónada, en serio
description: Secuenciar pasos dependientes de verdad — composición de Kleisli, el problema de la pirámide, la notación do en cuatro lenguajes, y qué es realmente el async/await de Dart.
---
# La mónada, en serio

> **En este capítulo**
> - la composición de Kleisli: por qué las funciones `A → M<B>` necesitan su propio `∘`
> - la pirámide, y la sintaxis que todo lenguaje inventa para aplanarla
> - `async`/`await` leído como notación do para exactamente una mónada
> - por qué «una mónada cada vez» es el límite real, y qué cuesta en Dart

## Las funciones que devuelven cajas no componen

El capítulo 4 compuso `A → B` con `B → C` y obtuvo `A → C`. Prueba lo mismo con
pasos que pueden fallar:

- `parseId : String → Either<E, int>`
- `loadUser : int → Either<E, User>`

No encajan. La salida de `parseId` es `Either<E, int>`, y `loadUser` quiere un
`int` pelado. La composición corriente queda descartada, y esto no es un caso
límite — *todo* paso con efectos tiene esta forma.

`flatMap` es el arreglo, y darle un operador de composición hace visible el
patrón:

```dart run
import 'package:fxdart/fxdart.dart';

// Kleisli composition: compose two "returns a box" functions.
Either<E, C> Function(A) kleisli<E, A, B, C>(
  Either<E, B> Function(A) f,
  Either<E, C> Function(B) g,
) =>
    (a) => f(a).flatMap(g);

Either<String, int> parseId(String s) {
  final n = int.tryParse(s);
  return n == null ? Either.left('bad id: $s') : Either.right(n);
}

Either<String, String> loadUser(int id) =>
    id == 1 ? Either.right('Ada') : Either.left('no user $id');

void main() {
  final lookup = kleisli(parseId, loadUser);
  print(lookup('1'));
  print(lookup('2'));
  print(lookup('x'));
}
```

`kleisli` compone `A → M<B>` con `B → M<C>` en `A → M<C>`. Esas flechas forman
su propia categoría — la **categoría de Kleisli** de la mónada — y las tres
leyes del capítulo 1 son exactamente lo que una categoría necesita: `of` es la
flecha identidad (identidad por izquierda y por derecha), y `flatMap` es
composición asociativa.

Ese es todo el contenido de «una mónada es una forma de componer funciones con
efectos»: `flatMap` restaura la composición después de que los efectos la
rompan.

![Composición corriente frente a composición de Kleisli](diagrams/t7-1-kleisli.svg)

*Figura 7-1. Las funciones planas encajan entre sí. Las que tienen efectos no — la salida lleva una envoltura que la siguiente entrada no acepta. `flatMap` es el adaptador, y las leyes dicen que el adaptador es invisible.*

## La pirámide, y cuatro salidas

Compón tres o cuatro pasos dependientes a mano y el código se va a la derecha:

```dart
parseId(raw).flatMap((id) =>
    loadUser(id).flatMap((user) =>
        loadOrders(user).flatMap((orders) =>
            Either.right(summarise(user, orders)))));
```

Todo lenguaje con mónadas acaba criando sintaxis para aplanar esto. El mismo
cálculo, cuatro superficies:

| Lenguaje | Sintaxis | Qué emite el compilador |
|---|---|---|
| Haskell | `do { id <- parseId raw; … }` | una cadena de `>>=` |
| Scala | `for { id <- parseId(raw) } yield …` | una cadena de `flatMap`/`map` |
| Kotlin (Arrow) | `either { val id = parseId(raw).bind() }` | un ámbito con una salida no local |
| Dart | `either((r) { final id = r.bind(parseId(raw)); … })` | un ámbito con una salida no local |

Los dos primeros son *azúcar sintáctico*: el compilador reescribe el bloque en
llamadas a métodos, y funciona para cualquier mónada que el verificador de
tipos pueda nombrar. Los dos últimos no lo son — no hay reescritura, solo un
objeto de ámbito cuyo `bind` puede abandonar el bloque. El capítulo 15 trata
de ese mecanismo y de por qué Dart lo obligó.

El resultado se lee igual en cualquier caso:

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parseId(String s) {
  final n = int.tryParse(s);
  return n == null ? Either.left('bad id: $s') : Either.right(n);
}

Either<String, String> loadUser(int id) =>
    id == 1 ? Either.right('Ada') : Either.left('no user $id');

Either<String, List<String>> loadOrders(String user) =>
    user == 'Ada'
        ? Either.right(['mug', 'book'])
        : Either.left('none');

Either<String, String> summary(String raw) => either((r) {
      final id = r.bind(parseId(raw));
      final user = r.bind(loadUser(id));
      final orders = r.bind(loadOrders(user));
      return '$user bought ${orders.length} things';
    });

void main() {
  print(summary('1'));
  print(summary('2'));
  print(summary('nope'));
}
```

Código en línea recta, tres pasos dependientes, un tipo de fallo y ninguna
pirámide.

## `async`/`await` es notación do para una sola mónada

Dart ya trae esta idea — para `Future`, y solo para `Future`:

```dart run
Future<int> parseId(String s) async => int.parse(s);
Future<String> loadUser(int id) async =>
    id == 1 ? 'Ada' : 'nobody';

Future<String> summary(String raw) async {
  final id = await parseId(raw); // r.bind, spelled `await`
  final user = await loadUser(id);
  return 'user: $user';
}

void main() async {
  print(await summary('1'));
  print(await summary('7'));
}
```

Línea por línea, esto es el bloque `either` de arriba con `await` donde estaba
`r.bind`. `async` marca el ámbito; `await` desenvuelve una capa; el compilador
reescribe el cuerpo en continuaciones, que es `flatMap` con otro nombre. La
prueba de que es monádico y no magia: `await` sobre un `Future<Future<T>>` te
da `Future<T>` — aplanando, exactamente como exigía el capítulo 1.

Lo que Dart *no* hizo fue generalizarlo. `await` funciona sobre `Future` (y
sobre cualquier cosa con un `then`, por suerte estructural), y no hay `await`
para `Either`, ni `await` para `Iterable`, ni forma de escribir el tuyo. Todos
los lenguajes de la tabla anterior tomaron la misma decisión al principio y
luego generalizaron; el `async` de Dart es donde esa generalización se detuvo.

> 🎓 **Las mónadas no se apilan.** Dado `Future<Either<E, A>>` tienes dos
> mónadas y ningún `flatMap` único para el par. Scala recurre a los
> *transformadores de mónadas* (`EitherT[Future, E, A]`), una envoltura por
> combinación, con una torre de elevaciones. Kotlin y Dart evitan la torre
> haciendo que el ámbito cumpla doble función: `eitherAsync` te da un ámbito
> `Raise` *dentro* de un cuerpo `async`, así que `await` se ocupa del tiempo y
> `r.bind` del fallo, sin un tercer tipo. No es más potente que los
> transformadores — es menos general y mucho más fácil de leer, y el
> capítulo 21 registra quién pagó qué por ese intercambio.

## Una mónada cada vez

```dart run
import 'package:fxdart/fxdart.dart';

Future<Either<String, int>> fetchPort(String key) async =>
    key == 'http'
        ? Either.right(8080)
        : Either.left('unknown: $key');

Future<Either<String, String>> describe(String key) =>
    eitherAsync((r) async {
      // `await` sequences time; `r.bind` sequences failure.
      final port = r.bind(await fetchPort(key));
      return 'listening on $port';
    });

void main() async {
  print(await describe('http'));
  print(await describe('gopher'));
}
```

Dos efectos, un bloque en línea recta, ningún `EitherT`. El coste es que esto
solo funciona para las combinaciones que FxDart escribió a mano —
`eitherAsync`, `nullable`, `catching`. No hay un mecanismo genérico que puedas
extender, porque expresar «cualquier mónada» requiere una característica de
tipos que Dart no tiene. Eso es el capítulo 10.

## Cuándo se gana el sueldo

Recurre al ámbito siempre que tres o más pasos dependientes puedan fallar con
el mismo tipo de error — parsear, cargar, autorizar, calcular. Esa es la forma
donde aparece la pirámide, y la forma donde una cadena artesanal de
`if (x == null) return null` pierde en silencio el motivo del fallo.

No recurras a él cuando los pasos sean independientes (capítulo 6: pierdes la
acumulación y la concurrencia), cuando haya exactamente un paso (un
`Either.map` simple dice más), o cuando el fallo sea genuinamente excepcional y
quien llama no pueda hacer nada al respecto (capítulo 18).

## Ejercicios

1. Escribe `kleisli` para `Future` — compón `A → Future<B>` con
   `B → Future<C>`. ¿De qué método existente de Dart es una envoltura fina?
2. La flecha identidad de Kleisli para `Either` es `Either.right`. Demuestra
   que `kleisli(Either.right, f)` y `kleisli(f, Either.right)` se comportan
   ambas como `f`, y nombra las dos leyes monádicas que acabas de usar.
3. Reescribe el bloque `summary` usando solo `flatMap`, y cuenta después las
   líneas y la indentación máxima de cada versión. ¿A partir de cuántos pasos
   empieza a ganar la versión con ámbito?
4. `await` aplana `Future<Future<T>>`. ¿Qué te dice eso sobre la firma de
   `Future.then`, comparada con el `map` del capítulo 5?

## Soluciones

1. `Future<C> Function(A) k<A, B, C>(Future<B> Function(A) f,
   Future<C> Function(B) g) => (a) => f(a).then(g);`. Envuelve a `then`, que es
   el `flatMap` de `Future` — el mismo método que hace además de `map`, que es
   el tema del ejercicio 4.
2. `kleisli(Either.right, f)` aplicado a `a` es `Either.right(a).flatMap(f)`,
   que es `f(a)` por **identidad por la izquierda**. `kleisli(f, Either.right)`
   aplicado a `a` es `f(a).flatMap(Either.right)`, que es `f(a)` por
   **identidad por la derecha**. Esas dos leyes son precisamente el enunciado
   de que `of` es una flecha identidad en la categoría de Kleisli.
3. La versión con `flatMap` tiene aproximadamente el mismo número de líneas
   pero anida tres niveles y termina en una ristra de paréntesis de cierre; la
   versión con ámbito se mantiene plana. El cruce está en dos pasos — en tres
   no hay color, y en cuatro la versión pirámide empieza a acumular bugs en los
   paréntesis.
4. `then` está sobrecargado de una forma en que `map` no lo está: acepta tanto
   `B Function(A)` como `Future<B> Function(A)`, y aplana en el segundo caso.
   Así que `then` es `map` y `flatMap` fundidos en un solo método, lo cual es
   cómodo y es también por lo que `Future` a solas nunca te enseña la
   diferencia entre los dos pisos de la torre.
