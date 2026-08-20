---
slug: functor
chapter: 5
part: 2
title: Functor
description: El primer piso de la torre — map, sus dos leyes, y por qué «estructura preservada, contenido cambiado» es lo que convierte la fusión de etapas en un refactor y no en una reescritura.
---
# Functor

> **En este capítulo**
> - el functor: una operación, `map`, con dos leyes
> - qué prohíben las leyes, mostrado con un tipo que las rompe
> - por qué la ley de composición es la que autoriza la fusión de etapas en una tubería
> - functores que no son contenedores, incluido el que se esconde en `Function`

## Una operación

Un **functor** es un tipo `F` con una sola operación:

`map : F<A> × (A → B) → F<B>`

Toma una estructura que contiene `A` y una función plana `A → B`, obtén la
misma estructura conteniendo `B`. «La misma estructura» es lo que hace el
trabajo de verdad en esa frase, y las dos leyes son lo que lo precisa.

Dart está lleno de functores y los llama de distintas maneras:

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  print([1, 2, 3].map((n) => n * 2).toList()); // List
  print(Either<String, int>.right(20).map((n) => n * 2));
  print(Either<String, int>.left('nope').map((n) => n * 2));
  print(fx([1, 2, 3]).map((n) => n * 2).toList()); // Fx
}
```

Fíjate en la tercera línea. Mapear un `Left` no hace nada, y eso no es un caso
especial atornillado — es forzoso. `map` no puede cambiar la estructura, y en
`Either` la elección de lado *es* la estructura. Un `map` que convirtiera un
`Left` en un `Right` sería otra función llevando ese nombre.

## Las dos leyes

1. **Identidad.** `m.map((x) => x) == m`. Mapear la función identidad no
   cambia absolutamente nada — ni los valores, ni la forma, ni nada
   observable.
2. **Composición.** `m.map(f).map(g) == m.map((x) => g(f(x)))`. Dos pasadas
   con dos funciones equivalen a una pasada con su composición.

```dart run
import 'package:fxdart/fxdart.dart';

int addOne(int n) => n + 1;
int triple(int n) => n * 3;

void main() {
  final m = Either<String, int>.right(7);

  // identity
  print(m.map((x) => x) == m);

  // composition
  print(m.map(addOne).map(triple) ==
      m.map((x) => triple(addOne(x))));

  // both hold on the other side too
  final bad = Either<String, int>.left('boom');
  print(bad.map((x) => x) == bad);
}
```

![Las dos leyes del functor](diagrams/t5-1-functor-laws.svg)

*Figura 5-1. La identidad dice que el bucle no hace nada. La composición dice que las dos rutas por el cuadrado aterrizan en el mismo valor — que es por lo que una tubería puede recortarse en cualquier punto entre etapas.*

## Qué prohíben las leyes

Descartan un `map` que haga cualquier cosa *además* de aplicar la función.
Aquí hay un tipo plausible que falla:

```dart run
// A box that remembers how many times it was mapped.
class Counted<A> {
  const Counted(this.value, this.maps);
  final A value;
  final int maps;

  Counted<B> map<B>(B Function(A) f) =>
      Counted(f(value), maps + 1);

  @override
  bool operator ==(Object other) =>
      other is Counted &&
      other.value == value &&
      other.maps == maps;

  @override
  int get hashCode => Object.hash(value, maps);

  @override
  String toString() => 'Counted($value, maps: $maps)';
}

void main() {
  final m = Counted(7, 0);

  // Identity fails: mapping "nothing" is observable.
  print(m.map((x) => x) == m);

  // Composition fails: two passes cost two, one pass costs one.
  print(m.map((x) => x + 1).map((x) => x * 3));
  print(m.map((x) => (x + 1) * 3));
}
```

El tipo no está *mal* — contar los mapeos podría ser exactamente lo que
quieres. Lo que no es, es un functor, y la consecuencia práctica es precisa:
quien lo lea ya no puede fusionar ni dividir sus llamadas a `map`, porque
hacerlo cambia el resultado. Las leyes son permisos, y este tipo retiene uno.

## La ley de composición es una característica de rendimiento

Lee la ley de composición de derecha a izquierda y deja de ser filosofía:

`m.map(f).map(g)` — dos recorridos — es *igual a* `m.map(g ∘ f)`, un
recorrido. Una librería puede por tanto reescribir el primero como el segundo
cuando le apetezca, y tú nunca te enteras.

Eso no es hipotético en FxDart. Las tuberías perezosas fusionan etapas para
que un valor recorra la cadena entera una vez en lugar de materializarse entre
pasos, y la licencia para esa reescritura es la ley del functor:

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  final seen = <String>[];

  final result = fx([1, 2, 3])
      .map((n) => n + 1)
      .peek((n) => seen.add('after +1: $n'))
      .map((n) => n * 3)
      .peek((n) => seen.add('after *3: $n'))
      .toList();

  print(result);
  // Interleaved, not staged: element by element through the
  // whole chain — the one-pass reading of the composition law.
  seen.forEach(print);
}
```

Dos `map` y ninguna lista intermedia. En un lenguaje ansioso pagarías una
lista por etapa; aquí la ley dice que no hace falta, y la implementación toma
la ley por su palabra. El capítulo 11 hace explícita esta historia de
evaluación.

> 🎓 **Functor, formalmente.** Un functor es una aplicación entre categorías
> que lleva objetos a objetos y flechas a flechas preservando la identidad y
> la composición — que es exactamente las dos leyes, enunciadas una vez para
> el caso general. En programación solo usamos *endo*functores sobre la
> categoría de los tipos: `F` lleva el tipo `A` al tipo `F<A>`, y `map` eleva
> una flecha `A → B` a una flecha `F<A> → F<B>`. El capítulo 20 dibuja el
> diagrama; nada de lo anterior depende de él.

## Functores que no son contenedores

«Un functor contiene valores» es una mentira útil. Lo que un functor tiene en
realidad es una *posición* sobre la que la función puede actuar, y algunas de
esas posiciones no contienen nada en absoluto.

- `Future<A>` — el valor todavía no está aquí; `then` es su `map`.
- Un parser o un decodificador — `map` cambia lo que producirá un parseo
  *futuro*.
- `Function(X) → A` — el functor lector. Mapear sobre una función compone
  sobre su resultado:

```dart run
void main() {
  int Function(String) length = (s) => s.length;

  // map for functions IS composition: apply, then transform.
  int Function(String) doubledLength = (s) => length(s) * 2;

  print([length('functor'), doubledLength('functor')]);
}
```

Ese último merece un momento: la composición y `map` son la misma operación
vista desde dos ángulos, y por eso la asociatividad del capítulo 4 y la ley de
composición de este capítulo suenan a la misma frase dicha dos veces. Lo son.

## Cuándo se gana el sueldo

La palabra rinde como *herramienta de predicción*. Encuentra un tipo
desconocido con un `map` y ya sabes tres cosas: no cambiará la forma, mapear
la identidad no hace nada, y puedes dividir o fusionar las llamadas con
libertad. Eso es mucho conocimiento para una sola palabra.

También te dice cuándo un tipo miente. Un `map` cuya documentación menciona
reintentos, cambios de orden o caché no es el `map` de un functor, y deberías
leer el código antes de refactorizar a su alrededor.

## Ejercicios

1. Demuestra — informalmente, por casos — que `Either.map` cumple la ley de
   identidad. ¿Cuántos casos hay, y por qué ese número es la demostración
   entera?
2. `Set` tiene un `map`. ¿Cumple la ley de composición cuando `f` lleva dos
   elementos distintos al mismo valor? Prueba `{1, 2}` con `f = (x) => 0` y
   `g = (x) => x + 1`.
3. Si un tipo tiene `map` cumpliendo ambas leyes, ¿es `map` único? Es decir,
   ¿podría haber dos `map` legales distintos para el mismo tipo — y difiere la
   respuesta entre `List` y `Either`?
4. El `peek` de FxDart devuelve el mismo tipo de elemento. ¿Es `peek` un `map`?
   ¿Qué ley rompe, y el vocabulario de qué capítulo explica por qué a nadie le
   importa?

## Soluciones

1. Dos casos. `Left(e).map(id)` devuelve `Left(e)` por definición, y
   `Right(a).map(id)` devuelve `Right(id(a))` = `Right(a)`. `Either` es una
   suma con exactamente dos constructores, así que cubrir ambos *es* cubrir
   todos los valores — la misma exhaustividad que el capítulo 3 obtuvo de
   `sealed`.
2. La cumple. `{1, 2}.map(f)` es `{0}` y mapear `g` da `{1}`; la fusión
   `g ∘ f` da `{1}` también. La deduplicación ocurre a la salida en ambas
   rutas. Lo que `Set` rompe no es la composición sino la intuición de que un
   functor preserva el *tamaño* — nada en las leyes promete eso.
3. Para `List`, no: un `map` que además invirtiera la lista cumple la
   identidad (¿invirtiendo dos veces? no — invertir una vez rompe la
   identidad, porque `xs.map(id)` sería `xs.reversed`). La respuesta
   interesante es que las leyes fijan `map` para cualquier tipo cuya forma
   quede determinada por las posiciones de su contenido, lo cual cubre tanto
   a `List` como a `Either`. En la práctica, para estos tipos el `map` legal es
   único, y esa unicidad es por lo que el nombre merece confianza.
4. `peek` no es un `map` — es `map` con un efecto atado, así que rompe la ley
   de identidad en cuanto el callback hace algo observable (`peek((_) {})` no
   hace nada, `peek(print)` sí). El vocabulario del capítulo 2 es la
   explicación: `peek` existe precisamente para hacer un efecto *declarado*, y
   un efecto declarado no es una violación sino una excepción documentada.
