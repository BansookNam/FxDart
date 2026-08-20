---
slug: missing-floor
chapter: 10
part: 2
title: El piso que falta
description: Tipos de orden superior — qué son, la línea exacta en la que Dart se detiene, qué hacen en su lugar Arrow de Kotlin y Scala, y el precio concreto que paga FxDart por escribir cada abstracción a mano.
---
# El piso que falta

> **En este capítulo**
> - los kinds: los tipos de los tipos, y dónde queda `List` sin su argumento
> - la declaración exacta de Dart que no compila, y por qué ningún truco la recupera
> - qué hacen en su lugar Scala, Haskell y Arrow de Kotlin
> - la factura que paga FxDart, contada en funciones

## Kinds

Los valores tienen tipos. Los tipos tienen **kinds**.

`int` es un tipo completo: puedes declarar una variable de ese tipo. Su kind se
escribe `*`. `List` por sí solo *no* es un tipo completo — `List<int>` sí lo
es. `List` es una función de tipos a tipos, y su kind se escribe `* → *`.

| Cosa | Kind | ¿Completo? |
|---|---|---|
| `int`, `String`, `List<int>` | `*` | sí |
| `List`, `Future`, `Fx` | `* → *` | necesita un argumento |
| `Either`, `Map` | `* → * → *` | necesita dos |

Los capítulos 5 a 9 trataban por completo de tipos de kind `* → *`: functor,
applicative, mónada y traversable son propiedades de un *constructor de tipos*,
no de un tipo. `List<int>` no es una mónada; `List` sí lo es.

Esa frase es el capítulo entero. Para escribir la interfaz, necesitas un
parámetro de tipo que sea a su vez de kind `* → *` — un **tipo de orden
superior** (higher-kinded type).

## La línea en la que Dart se detiene

```dart
// Does not compile. Dart type parameters are always kind `*`,
// so `M` is a complete type and cannot take an argument.
abstract class Monad<M> {
  M<A> of<A>(A value);
  M<B> flatMap<A, B>(M<A> box, M<B> Function(A) f);
}
```

El error no es de sintaxis. Las variables de tipo de Dart solo recorren tipos
*completos*, así que `M<A>` carece de sentido de la misma forma que `3(4)`
carece de sentido. Es un punto de diseño deliberado — los genéricos de primer
orden mantienen la inferencia decidible y los mensajes de error legibles — y
es un techo, no un bug que rodear.

![Dónde se detiene la torre](diagrams/t10-1-hkt-wall.svg)

*Figura 10-1. Cada piso de la torre es una afirmación sobre un constructor de
tipos. Dart puede hablar de los pisos de uno en uno; la viga que los cargaría
todos a la vez necesita un kind que el lenguaje no tiene.*

Los rodeos fallan todos de la misma manera — compilan, y luego mienten:

```dart run
// The "defunctionalisation" trick: erase the constructor to a
// marker, then cast it back. It type-checks. It is not typed.
abstract class Kind<F, A> {}

class ListK<A> implements Kind<ListK<Never>, A> {
  ListK(this.value);
  final List<A> value;
}

abstract class Monad<F> {
  Kind<F, A> of<A>(A value);
  Kind<F, B> flatMap<A, B>(
      Kind<F, A> fa, Kind<F, B> Function(A) f);
}

class ListMonad implements Monad<ListK<Never>> {
  @override
  Kind<ListK<Never>, A> of<A>(A value) => ListK([value]);

  @override
  Kind<ListK<Never>, B> flatMap<A, B>(
    Kind<ListK<Never>, A> fa,
    Kind<ListK<Never>, B> Function(A) f,
  ) {
    // The cast is the whole problem: nothing checks it.
    final list = (fa as ListK<A>).value;
    return ListK(list
        .expand((a) => (f(a) as ListK<B>).value)
        .toList());
  }
}

void main() {
  final m = ListMonad();
  final r = m.flatMap<int, int>(
      m.of(3), (a) => ListK([a, a * 10]));
  print((r as ListK<int>).value);
}
```

Funciona, y mira el precio: tres casts, un fantasma `Never`, y un tipo de
retorno — `Kind<ListK<Never>, int>` — que ningún llamador quiere. Cada sitio de
uso vuelve a hacer cast al tipo real, así que la abstracción te entrega código
genérico cuyos errores de tipo aparecen en tiempo de ejecución. Las primeras
versiones de Arrow hicieron exactamente esto, en Kotlin, y luego lo
abandonaron. El `ARROW_MIGRATION_BLOCKER.md` de FxDart registra la misma
conclusión para Dart.

## Qué hacen otros lenguajes

- **Haskell** tiene los kinds en el lenguaje. `class Monad m where (>>=) :: m a
  → (a → m b) → m b` es código ordinario, y cada instancia se comprueba contra
  él.
- **Scala** tiene parámetros de tipo de orden superior (`F[_]`), por lo que
  Cats puede definir `Traverse[F[_]]` una sola vez y obtener gratis todos los
  combinadores.
- **Kotlin** no tiene ninguno de los dos, y **Arrow 1.x** usaba la codificación
  `Kind` de arriba. Arrow 2.x la eliminó: la ergonomía era lo bastante mala
  como para que el equipo eligiera en su lugar tipos concretos más *context
  receivers* y un ámbito `Raise` — el diseño que FxDart porta.
- **Dart** no tiene ninguno de los dos, ni un sistema de plugins que pudiera
  añadir uno. Por eso FxDart escribe los casos concretos, y lo dice.

> 🎓 **Qué se pierde de verdad.** No expresividad — todo programa que puedes
> escribir con una abstracción HKT se puede escribir sin ella, a mano, por
> tipo. Lo que se pierde es *la abstracción sobre la abstracción*: un
> `traverse` en vez de siete, un `sequence`, un único conjunto de leyes que
> probar una vez. En un lenguaje con HKT, un nuevo tipo de efecto llega ya
> equipado con toda la librería; en Dart llega vacío, y alguien tiene que
> rellenarlo. La diferencia es coste de mantenimiento de librería, no
> capacidad del programa — que es precisamente por qué es una decisión de
> diseño de lenguaje razonable y aun así irritante.

## La factura, contada

Toda abstracción de la Parte II que un lenguaje de orden superior escribe una
vez, FxDart la escribe por tipo. En concreto, para una sola operación —el
recorrido (traverse)— la librería ofrece:

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  final xs = <Either<String, int>>[
    Either.right(1),
    Either.left('bad'),
    Either.right(3),
  ];

  // Four spellings of "swap the structures", because there is no
  // way to write one that works for every effect type.
  print(sequenceEither(xs));
  print(flattenOrAccumulate(xs));
  print(separateEither(xs));
  print(fx(xs).sequence());
  // …plus sequenceEitherAsync, flattenOrAccumulateAsync,
  //   mapOrAccumulateAsync for the async chain.
}
```

Y la otra cara, para que el trato sea honesto: por ser concretas, son
*rápidas* y sus tipos son exactos. `sequenceEither` devuelve `Either<L,
List<R>>` — no `Kind<F, List<R>>`, ni un envoltorio que tengas que desmontar.
La inferencia de Dart funciona, el editor completa, los errores señalan tu
código. Una versión genérica en la codificación `Kind` devolvería algo que
ningún lector podría usar sin un cast.

## Cuándo te importa esto

Casi nunca — hasta que sales a buscar el combinador genérico que
«obviamente» debería existir. Este capítulo es la respuesta a esa búsqueda: no
existe, no puede existir, y la versión concreta está ahí al lado.

Importa cuando diseñas una librería. Si te sorprendes intentando abstraer
sobre «cualquier contenedor con un `map`», detente: en Dart, escribe las dos o
tres versiones concretas y ponles buen nombre. La abstracción que persigues
costará más de lo que devuelve.

También importa cuando lees Haskell o Scala en busca de ideas — que vale la
pena hacer. Solo tradúcelo de forma estructural, no literal: sus definiciones
genéricas de una línea se convierten en tus métodos concretos, y las leyes
sobreviven la traducción aunque el polimorfismo no lo haga.

## Ejercicios

1. ¿Cuál es el kind de `Map`? ¿El de `Map<String, dynamic>`? ¿El de una
   hipotética interfaz `Traverse`?
2. Extiende la codificación `Kind` de arriba a `Either` y escribe `flatMap`
   para ella. ¿Cuántos casts necesitas, y dónde explotaría uno incorrecto?
3. `Fx<T>` tiene `map`, `flatMap` y terminales al estilo `sequence`. ¿Puedes
   escribir una función que acepte «cualquier tipo de FxDart con un `map`» sin
   usar `dynamic` ni un supertipo común? Explica la respuesta en términos de
   kinds.
4. Dart sí te deja escribir `T extends Comparable<T>`. ¿Por qué eso no es un
   contraejemplo de este capítulo?

## Soluciones

1. `Map` es `* → * → *` (dos argumentos); `Map<String, dynamic>` es `*`;
   `Traverse` sería `(* → *) → *` — toma un *constructor de tipos* y produce
   un tipo. Ese último kind es exactamente lo que Dart no puede escribir, y el
   paréntesis es donde el lenguaje se detiene.
2. Dos casts como mínimo — uno para desenvolver `Kind<F, A>` en `EitherK<E,
   A>`, otro sobre el resultado de `f`. Explotan en tiempo de ejecución,
   cuando alguien pasa un `ListK` a una instancia de mónada `Either`: el
   sistema de tipos nunca estuvo vigilando, porque ambos se borran a
   `Kind<F, _>`.
3. No. Tal función necesita un parámetro de kind `* → *` («algún `F` tal que
   `F<A>` tenga un `map`»), y los parámetros de Dart son todos de kind `*`.
   Los rodeos disponibles son exactamente los tres malos: `dynamic`, un
   supertipo compartido (que `Fx` y `Either` no tienen y no deberían tener), o
   la codificación con cast `Kind`.
4. `T extends Comparable<T>` restringe un tipo *completo* — `T` sigue siendo
   kind `*`, y `Comparable<T>` es una cota sobre él, no un parámetro de orden
   superior. El polimorfismo F-acotado es una característica distinta que
   resuelve un problema distinto, y es una buena ilustración de que «lo
   bastante genérico para la mayoría del código» y «de orden superior» son
   ejes separados.
