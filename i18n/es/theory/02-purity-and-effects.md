---
slug: purity
chapter: 2
part: 1
title: Pureza y efectos
description: La transparencia referencial es una propiedad de sustitución, no una moral. Este capítulo la define con precisión, muestra las cuatro cosas que te compra y encuentra dónde se esconden los efectos en el Dart de todos los días.
---
# Pureza y efectos

> **En este capítulo**
> - la transparencia referencial como prueba mecánica que puedes aplicar a cualquier expresión
> - las cuatro capacidades que compra la pureza — memoizar, reordenar, paralelizar, probar
> - dónde se esconden los efectos en el Dart corriente, incluidos los que no parecen efectos
> - la costura: un núcleo puro con los efectos empujados al borde, y qué te da FxDart en esa costura

## La prueba de la sustitución

Una función es **pura** cuando una llamada a ella puede sustituirse por su
resultado en todas partes sin cambiar lo que hace el programa. Esa propiedad
tiene nombre — **transparencia referencial** — y es una prueba mecánica, no
una preferencia de estilo.

```dart run
int double_(int n) => n * 2;

var log = <String>[];
int doubleAndLog(int n) {
  log.add('doubled $n');
  return n * 2;
}

void main() {
  // Substitution holds: double_(21) and 42 are the same thing.
  print([double_(21), double_(21)]);
  print([42, 42]);

  // Substitution fails: the two programs differ in `log`.
  print([doubleAndLog(21), doubleAndLog(21)]);
  print(log);
}
```

Las dos funciones devuelven el mismo número. Solo una de ellas te deja
reescribir el programa a su alrededor. Esa diferencia — no la presencia de la
palabra `void`, no que un linter se queje — es lo que significa «pura».

![Sustitución: reemplazar una llamada por su resultado](diagrams/t2-1-substitution.svg)

*Figura 2-1. La pureza es el permiso para redibujar la imagen de la izquierda como la de la derecha. Cada refactor que haces a mano invoca ese permiso.*

## Qué compra la pureza

Cuatro capacidades, y ya dependes de las cuatro:

| Capacidad | Por qué hace falta pureza |
|---|---|
| **Memoizar** | Cachear un resultado supone que la segunda llamada habría hecho lo mismo |
| **Reordenar** | Mover una línea supone que nadie más observa cuándo se ejecutó |
| **Paralelizar** | Ejecutar dos llamadas a la vez supone que ninguna puede ver a la otra |
| **Probar** | Aseverar sobre un valor de retorno supone que el valor es toda la historia |

El `memoize` de FxDart es el ejemplo más nítido: es *correcto* para una
función pura y un bug silencioso para una impura.

```dart run
import 'package:fxdart/fxdart.dart';

int calls = 0;
int slowSquare(int n) {
  calls++;
  return n * n;
}

void main() {
  final fast = memoize(slowSquare);
  print([fast(9), fast(9), fast(9)]);
  print('underlying calls: $calls');
}
```

Tres llamadas, una evaluación. Nada dentro de `memoize` comprueba que
`slowSquare` sea pura — lo *supone*. Esa es la forma de casi toda la
maquinaria funcional: la librería aporta el mecanismo, la ley aporta la
licencia, y quien tiene que cumplir el trato eres tú.

## Dónde se esconden los efectos en Dart

Un **efecto** es cualquier cosa que quien llama pueda observar además del
valor devuelto, o cualquier cosa de la que dependa el resultado además de los
argumentos. Dart esconde varios a plena vista:

- **Mutación de estado compartido** — el evidente, incluida una `List`
  capturada.
- **Leer el reloj o la plataforma** — `DateTime.now()`, `Platform.isIOS`.
  Mismos argumentos, respuestas distintas.
- **Aleatoriedad** — por eso FxDart trae `createSeededRandom`: una semilla
  convierte un efecto de vuelta en un argumento.
- **Lanzar excepciones** — una excepción es un segundo canal de retorno
  invisible. La Parte IV trata de darle uno visible.
- **`print` y la E/S** — la salida es observable por definición.
- **La identidad** — la igualdad de `List` es por referencia, así que
  devolver una lista nueva es observablemente distinto de devolver una
  compartida bajo `identical`.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  // A seed makes randomness reproducible: same input, same
  // output, so a shuffle becomes testable.
  final a = shuffle([1, 2, 3, 4, 5], 7);
  final b = shuffle([1, 2, 3, 4, 5], 7);
  print(a);
  print('reproducible: ${a.toString() == b.toString()}');
}
```

> 🎓 **«Puro» habla de lo que observa el lenguaje, no el universo.** Una
> función pura sigue quemando CPU, reservando memoria y calentando la
> habitación. La pureza se define relativa a lo que el *programa* puede
> observar: dos expresiones son intercambiables si ningún código Dart puede
> distinguirlas. El tiempo y la memoria quedan fuera de esa lente — que es
> justo por lo que el capítulo 14 tiene que medirlos aparte, y por lo que
> «puro» nunca significa «gratis».

## La costura

Nadie publica un programa sin efectos; el objetivo es saber *dónde* están. La
disposición estándar es un **núcleo puro con una cáscara con efectos**:
parsear, decidir y calcular en funciones puras; leer y escribir en los bordes.

Las tuberías hacen visible la costura, porque una tubería perezosa es una
*descripción* del trabajo y no el trabajo. Compara dónde queda el efecto:

```dart run
import 'package:fxdart/fxdart.dart';

class Order {
  const Order(this.id, this.total, this.status);
  final String id;
  final int total;
  final String status;
}

const orders = [
  Order('a', 120, 'paid'),
  Order('b', 40, 'refunded'),
  Order('c', 260, 'paid'),
];

// Pure core: data in, data out. No printing, no clock, no IO.
List<String> receipts(Iterable<Order> all) => fx(all)
    .filter((o) => o.status == 'paid')
    .sortByDesc((o) => o.total)
    .map((o) => '${o.id}: ${o.total}')
    .toList();

void main() {
  // Effectful shell: the one place that touches the world.
  receipts(orders).forEach(print);
}
```

`receipts` es comprobable solo por igualdad, y `peek` te da una costura
declarada para las veces en que necesitas observar una tubería sin romper esa
propiedad — es un efecto *etiquetado* en lugar de uno oculto:

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  final seen = <int>[];
  final result = fx(range(1, 6))
      // the effect is named, and it is the only one
      .peek(seen.add)
      .filter((n) => n.isEven)
      .toList();
  print(result);
  print(seen);
}
```

## Cuándo se gana el sueldo

La pureza no es una virtud que se acumula; es una palanca que se gasta. Paga
cuando necesitas cachear, reintentar, reordenar, ejecutar en paralelo o
escribir una prueba que no necesite un fixture — es decir, exactamente en las
situaciones de las que tratan las Partes III y IV. `concurrent(n)`
(capítulo 13) solo es seguro porque los callbacks que ejecuta fuera de orden
no pueden verse entre sí.

Cuesta cuando el efecto *es* el objetivo. Un logger, un script de migración,
un manejador de eventos de interfaz: envolver eso en ceremonia no compra
nada. El capítulo 22 defiende ese caso con calma.

## Ejercicios

1. ¿Es `List.of(items)` pura? Considera tanto `==` como `identical` como la
   forma en que quien llama podría observar el resultado.
2. Escribe una función que sea pura a ojos de Dart pero que dependa de un
   campo mutable que nunca cambia tras la construcción. ¿Es referencialmente
   transparente? ¿Qué se rompería en el momento en que alguien quitara el
   `final`?
3. `memoize` sobre una función de tipo `int Function(int)` es seguro. ¿Qué
   sale mal si el tipo del argumento es una `List<int>` mutable?
4. Toma la tubería `receipts` de arriba y añade un requisito: registrar cada
   pedido que quedó filtrado. Hazlo sin volver impura a `receipts`.

## Soluciones

1. **Pura según `==`, impura según `identical`.** Dos llamadas con el mismo
   argumento devuelven listas iguales pero nunca el mismo objeto, así que un
   programa que compare con `identical` puede distinguir las llamadas. Por eso
   «pura» se enuncia siempre relativa a una observación — la misma sutileza
   aparece en el ejercicio del capítulo 1 sobre la igualdad de `Future`.
2. Algo como `class Rate { const Rate(this.pct); final int pct;
   int apply(int n) => n * pct ~/ 100; }`. Es referencialmente transparente
   porque `pct` no puede cambiar; la instancia es parte de la entrada, solo
   que escrita como receptor en vez de como argumento. Quita `final` y la
   misma llamada puede devolver dos respuestas, así que la sustitución falla.
3. `memoize` indexa por el argumento, y el contenido de una lista mutable
   puede cambiar después de haberse usado como clave — quien llama muta la
   lista, vuelve a llamar y recibe la respuesta del contenido *antiguo*. La
   caché no está mal; la suposición sí lo estaba.
4. Devuelve los pedidos rechazados en lugar de registrarlos — `fork` o una
   división al estilo `partition` hacen la función total en lo que informa, y
   quien llama (la cáscara) decide qué imprimir. Si solo necesitas observar,
   usa `.peek(rejected.add)` en la rama rechazada: sigue siendo un efecto
   declarado en una costura con nombre, y sigue sin haber E/S dentro del
   núcleo.
