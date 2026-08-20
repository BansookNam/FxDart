---
slug: laziness
chapter: 11
part: 3
title: La pereza
description: Una tubería como descripción del trabajo en vez del trabajo mismo — qué cambia la pereza sobre el coste, qué cambia sobre el significado (nada), y las dos formas en que puede perjudicarte.
---
# La pereza

> **En este capítulo**
> - descripciones frente a ejecuciones, y qué operadores son cuáles
> - el modelo de coste: el trabajo es proporcional a lo que *consumes*, no a lo
>   que escribes
> - por qué la pereza no puede cambiar ninguna ley de la Parte II
> - los dos peligros reales: efectos dentro de una tubería, y una fuente que
>   solo se puede leer una vez

## Dos tipos de operador

Escribe una cadena y no pasa nada:

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  var calls = 0;
  final chain = fx([1, 2, 3, 4, 5]).map((n) {
    calls++;
    return n * 2;
  });

  print('after building the chain: $calls calls');
  print(chain.toList());
  print('after consuming it: $calls calls');
}
```

`map`, `filter`, `take`, `chunk`, `zip` son **perezosos** — cada uno devuelve
una nueva descripción con una etapa más. `toList`, `each`, `fold`, `first`,
`sum` son **terminales** — tiran de los valores, y solo entonces se ejecuta
algo.

La regla para distinguirlos es el tipo de retorno, y nunca miente: si te
devuelve otro `Fx`, todavía no ha pasado nada.

![Una descripción, luego un pull](diagrams/t11-1-description-pull.svg)

*Figura 11-1. La cadena discontinua es un plan: etapas conectadas entre sí,
sin valores en movimiento. El operador terminal es el que tira, y un valor
recorre toda la cadena antes de que empiece el siguiente.*

## El modelo de coste

Como el terminal decide cuánto tirar, el trabajo es proporcional a lo que
*consumes*:

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  var evaluated = 0;

  final result = fx(range(1, 1000000))
      .map((n) {
        evaluated++;
        return n * n;
      })
      .filter((n) => n.isOdd)
      .take(3)
      .toList();

  print(result);
  print('elements evaluated: $evaluated of 999,999');
}
```

Cinco evaluaciones para tres resultados de entre un millón de candidatos. La
versión ansiosa de ese programa construye una lista de un millón de elementos,
luego la filtra en otra lista, y después descarta todo menos tres.

Esta es la diferencia que aparece en la propia suite de benchmarks de FxDart
como los casos en los que la tubería *gana* a un bucle escrito a mano — el
bucle suele ser más rápido por elemento, pero la cadena perezosa se niega a
hacer el trabajo directamente. El capítulo 14 pone números a ambas
direcciones.

De ese mismo modelo se desprenden dos consecuencias más:

- **Las fuentes infinitas son normales.** La descripción de infinitos valores
  es finita; solo el pull tiene que detenerse.
- **El cortocircuito es automático.** `first`, `any`, `find` detienen el pull
  en cuanto tienen una respuesta, sin ningún soporte especial de las etapas
  anteriores.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  // An endless cycle, consumed finitely.
  print(fx([1, 2, 3]).cycle().take(7).toList());

  // `some` stops pulling at the first match.
  var checked = 0;
  final found = fx(range(1, 1000)).some((n) {
    checked++;
    return n > 4;
  });
  print([found, checked]);
}
```

## La pereza no puede cambiar el significado

Esta es la parte que vale la pena decir con todas las letras, porque es lo que
hace que fiarse de la pereza sea seguro. Cada ley de la Parte II es una
ecuación entre *valores*: la ley de functor dice que `m.map(f).map(g)` es
igual a `m.map(g ∘ f)`, y que dos tuberías sean iguales significa que producen
los mismos elementos en el mismo orden.

Cuándo ocurre la evaluación no forma parte de esa ecuación. Así que:

- fusionar dos etapas `map` es legal (ley de composición de functores);
- reordenar un `filter` antes de un `map` es legal *si* el predicado no
  depende del mapeo — una precondición genuina, no un asunto de pereza;
- mover trabajo del momento de construir al momento de tirar no cambia nada
  observable — **mientras los callbacks sean puros.**

Esa última cláusula es toda la trampa, y es la cláusula del capítulo 2. En una
tubería pura, la pereza es invisible salvo en la factura. En una impura, es
visible en todas partes, porque *cuándo* ocurre un efecto es exactamente lo
que un efecto te deja observar.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  final log = <String>[];

  // Built, never consumed: the effect never happens.
  final unused = fx([1, 2, 3]).map((n) {
    log.add('mapped $n');
    return n;
  });
  print('log after building: $log');

  // Same chain, consumed twice: the effect happens twice.
  final used = fx([1, 2]).map((n) {
    log.add('mapped $n');
    return n;
  });
  used.toList();
  used.toList();
  print('log after two pulls: $log');
  print(unused.take(0).toList());
}
```

Las dos sorpresas son la misma sorpresa: una cadena perezosa es una *receta*,
y las recetas se pueden cocinar cero veces o dos.

> 🎓 **Perezoso, estricto, y lo que Haskell entiende por ello.** Haskell es
> perezoso por defecto al nivel de *cada expresión*: un valor es un thunk
> hasta que se fuerza, lo que te da estructuras de datos infinitas y
> cláusulas `where` que no cuestan nada si no se usan — y fugas de memoria
> cuando una cadena de thunks crece sin forzarse. Dart es estricto; una
> tubería perezosa es la pereza recreada al nivel de las *secuencias*, y el
> mecanismo es un protocolo pull en vez de thunks. La diferencia práctica:
> obtienes los beneficios del cortocircuito y del streaming, no obtienes (ni
> tienes que depurar) una acumulación de thunks sin límite, y `fx(xs).map(f)`
> compuesto dos veces es un plan, mientras que `let y = f x` ya es un thunk.

## El segundo peligro: fuentes de un solo uso

Una tubería sobre una `List` se puede tirar repetidamente — una lista se puede
releer. Una tubería sobre una fuente que se consume al leerla no puede:

```dart run
import 'package:fxdart/fxdart.dart';

Iterable<int> readOnce() sync* {
  // A generator: iterating it again starts over, but a *stream*
  // or a socket would not — that is the shape to watch for.
  yield 1;
  yield 2;
}

void main() {
  final chain = fx(readOnce()).map((n) => n * 10);
  print(chain.toList());
  print(chain.toList()); // fine here — the generator restarts

  // The rule that always holds: if you need the values twice,
  // materialise once and re-read the list.
  final materialised = chain.toList();
  print([materialised.length, materialised.first]);
}
```

La guía es corta: **consume una vez, o materializa.** Si una cadena la usan
dos consumidores, llama a `toList()` y comparte la lista, o usa `fork`/`tee`,
que existen precisamente para dividir un pull en varios sin volver a ejecutar
la fuente.

## Cuándo se gana el sueldo

La pereza paga siempre que la tubería pudiera producir más de lo que
necesitas: tomar los primeros N, buscar la primera coincidencia, transmitir un
archivo que dejarás de leer, componer filtros cuya selectividad combinada es
alta. También paga en memoria — un elemento en vuelo en vez de una lista por
etapa.

Cuesta cuando todo se consume de todas formas y la fuente es pequeña: entonces
el protocolo por elemento es sobrecarga frente a un bucle plano, y el
capítulo 14 mide exactamente cuánto. Y cuesta en depurabilidad — una traza de
pila dentro de una cadena perezosa muestra fotogramas de iterador, no tu
tubería, que es el precio de la indirección.

## Ejercicios

1. `fx(xs).map(f).toList()` y `xs.map(f).toList()` hacen el mismo trabajo.
   ¿En qué punto empieza a ganar la versión de FxDart, y qué operador de la
   cadena lo causa?
2. Predice la salida de una cadena que llama a `peek(print)` antes de
   `take(2)` sobre una fuente de diez elementos. ¿Cuántas líneas se imprimen,
   y por qué?
3. Escribe una cadena cuyos callbacks se ejecuten dos veces por accidente.
   Luego arréglala de dos formas distintas.
4. `fx(range(1, 1000000)).map(expensive).first` — ¿cuántas veces se ejecuta
   `expensive`? ¿Y si `.first` se sustituye por `.last`?

## Soluciones

1. Gana en cuanto una etapa *descarta* trabajo que la versión ansiosa ya ha
   hecho — `take`, `first`, `some`, `find`, o un `filter` que rechaza la
   mayoría de los elementos antes de un `map` costoso. Sin esa etapa, las dos
   hacen el mismo trabajo, y la versión ansiosa tiene menos maquinaria por
   elemento.
2. Dos líneas. `take(2)` deja de tirar después del segundo elemento, así que
   nunca se le pregunta a `peek` por los elementos tres en adelante — el pull
   es lo que impulsa la etapa anterior, y se detuvo.
3. Cualquier cadena asignada a una variable y consumida por dos terminales,
   como en el listado de arriba. Arreglo uno: `final xs = chain.toList();` y
   luego usa `xs` dos veces. Arreglo dos: usa `fork`/`tee` para dividir un
   pull en dos consumidores, de modo que la fuente se siga leyendo una sola
   vez.
4. Una vez con `.first` — un pull le basta. Con `.last`, las 999.999 veces:
   `last` tiene que llegar al final, así que no queda nada que saltarse. La
   misma cadena, la misma pereza, coste opuesto, decidido por completo por el
   terminal.
