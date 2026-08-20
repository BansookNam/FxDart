---
slug: pull-and-push
chapter: 12
part: 3
title: Pull y push
description: Iterables y Streams son duales formales — quién llama a quién. Esa única diferencia decide el backpressure, la cancelación y qué librería es la herramienta correcta, y es la razón de que FxDart no esté construido sobre Stream.
---
# Pull y push

> **En este capítulo**
> - la dualidad: `Iterator` y `Stream` difieren en quién hace la llamada
> - lo que se desprende de ahí — backpressure, cancelación y tiempo
> - por qué el modelo asíncrono de FxDart es un protocolo pull y no un
>   `Stream`
> - los puentes, y cómo elegir un lado para un problema dado

## Quién llama a quién

```
pull:  consumer asks  → producer answers   iterator.moveNext()
push:  producer calls → consumer receives  stream.listen(onData)
```

Esa es toda la diferencia, y todo lo demás en este capítulo es una
consecuencia de ella. Una fuente pull es una *función que llamas*; una fuente
push es un *callback que registras*.

| | Pull (`Iterable`, `FxAsyncIterable`) | Push (`Stream`) |
|---|---|---|
| Marca el ritmo | el consumidor | el productor |
| Backpressure | gratis — basta con no preguntar | hay que organizarlo |
| Parar antes | dejar de tirar | cancelar una suscripción |
| Tiempo | no se modela | inherente |
| Encaje natural | colecciones, archivos, APIs paginadas | eventos de UI, sockets, timers |

![Quién inicia](diagrams/t12-1-pull-push.svg)

*Figura 12-1. Los mismos valores, flechas opuestas. En una cadena pull la
petición viaja hacia arriba y el valor vuelve; en una cadena push el valor
viaja hacia abajo y nadie más arriba está esperando permiso.*

Formalmente son duales — uno es el espejo del otro con las flechas invertidas
— por lo que los vocabularios de operadores se parecen tanto (`map`, `filter`,
`take`, `scan` en ambos lados) y los *modos de fallo* son opuestos.

## Backpressure es la diferencia práctica

Si el consumidor es más lento que el productor, algo tiene que ceder.

En una cadena pull nada cede, porque la llamada `next` del consumidor *es* el
reloj. Un consumidor lento simplemente pregunta con menos frecuencia, y el
productor está inactivo entre medias:

```dart run
import 'package:fxdart/fxdart.dart';

void main() async {
  var produced = 0;

  final source = fx(range(1, 1000)).map((n) {
    produced++;
    return n;
  }).toAsync();

  // The consumer takes three and stops asking.
  final taken = await source.take(3).toList();

  print(taken);
  print('produced: $produced'); // not 999
}
```

En una cadena push el productor sigue adelante de todas formas. El `Stream` de
Dart maneja esto con pausa/reanudación para las fuentes que lo soportan, y con
búferes para las que no — lo que convierte un desajuste de ritmo en
crecimiento de memoria en vez de un error de compilación. El bug clásico es un
stream de difusión con un listener lento: la cola crece, la latencia crece, y
nada en los tipos lo decía.

## Por qué FxDart no está construido sobre `Stream`

Las secuencias asíncronas de FxDart son `FxAsyncIterable` — un protocolo pull
— porque su característica distintiva necesita que el consumidor esté al
mando.

`concurrent(n)` le pide a la *fuente anterior* que evalúe n elementos a la
vez. Esa petición tiene que viajar hacia atrás, del consumidor hacia la
fuente, que es exactamente la dirección para la que un protocolo pull ya
tiene una flecha. FxDart pasa un marcador a través de `iterator.next(concurrent)`:
el consumidor dice «dame el siguiente, y de paso, ejecuta n de estos en
paralelo», y cada etapa anterior puede honrarlo o reenviarlo.

No hay forma de expresar eso sobre un `Stream`. Una fuente push ya está en
marcha; el consumidor solo puede pedirle que se pause, no que *se ensanche*.
Tendrías que inventar un canal lateral — que es lo que son los distintos
operadores `parallel` en las librerías al estilo Rx — y luego conciliarlo a
mano con el búfer y el orden.

```dart run
import 'package:fxdart/fxdart.dart';

Future<String> fetch(String id) async {
  await Future.delayed(const Duration(milliseconds: 40));
  return 'data-$id';
}

void main() async {
  final ids = ['a', 'b', 'c', 'd', 'e', 'f'];
  final sw = Stopwatch()..start();

  // One at a time: six 40ms waits, serially.
  await fx(ids).toAsync().map(fetch).toList();
  final serial = sw.elapsedMilliseconds;

  sw.reset();
  // Three at a time, results still in source order.
  final out =
      await fx(ids).toAsync().map(fetch).concurrent(3).toList();
  final concurrent = sw.elapsedMilliseconds;

  print(out.first);
  print('serial ~${serial}ms, concurrent(3) ~${concurrent}ms');
}
```

El protocolo pull es lo que hace que el segundo número sea aproximadamente un
tercio del primero *sin* búfer, sin perder el orden, y sin una segunda API. El
capítulo 13 trata sobre las garantías que vienen con él.

## Los puentes

Ser una librería pull no significa ignorar push. Los programas reales tienen
ambos — un evento de UI es genuinamente un push, una página de base de datos
es genuinamente un pull — así que FxDart cruza en ambas direcciones:

```dart run
import 'package:fxdart/fxdart.dart';

void main() async {
  // push → pull: a Stream becomes a pull chain.
  final ticks = Stream.fromIterable([1, 2, 3, 4, 5]);
  final doubled =
      await fxStream(ticks).map((n) => n * 2).take(3).toList();
  print(doubled);

  // pull → push: a chain becomes a Stream for the framework.
  final asStream =
      fx([1, 2, 3]).toAsync().map((n) => n + 10).toStream();
  print(await asStream.toList());
}
```

FxDart también incluye una capa explícitamente con forma push — `fxEvents`,
con operadores al estilo Rx sobre `Stream`s planos — para los problemas que
genuinamente tratan sobre tiempo y difusión:

```dart run
import 'package:fxdart/fxdart.dart';

void main() async {
  final clicks =
      Stream.fromIterable(['a', 'a', 'b', 'b', 'b', 'c']);

  // Push-side operators: same names, producer-driven semantics.
  final out = await fxEvents(clicks)
      .map((s) => s.toUpperCase())
      .where((s) => s != 'B')
      .toList();
  print(out);
}
```

La regla general para elegir: **¿quién decide cuándo existe el siguiente
valor?** Si la respuesta es «el mundo exterior», estás en el lado push y
deberías quedarte ahí. Si la respuesta es «quien lo consuma», pull es más
simple y te da backpressure gratis.

> 🎓 **Dual, con precisión.** Un iterador es `() → Option<(A, Iterator<A>)>` —
> el consumidor lo aplica. Un observador es `((A) → Unit) → Unit` — el
> productor aplica tu callback. Invierte cada flecha de uno y obtienes el
> otro; en ese sentido sus diseñadores describieron Rx como «el dual de
> `IEnumerable`». La dualidad también predice qué operadores son difíciles en
> cada lado: `zip` es fácil en pull (pregunta a ambos, espera a ambos) y
> necesita búfer en push, mientras que `debounce` es natural en push (trata
> sobre tiempo transcurrido) y no tiene sentido en pull, donde no pasa nada
> entre peticiones.

## Cuándo se gana el sueldo cada uno

Pull, cuando los datos *ya están ahí* y decides tú el ritmo: colecciones,
archivos, HTTP paginado, cursores de base de datos, cualquier cosa que
podrías dejar de leer antes de tiempo, cualquier cosa donde «N a la vez» sea
una política que quieres declarar.

Push, cuando los datos *llegan* estés listo o no: entrada de usuario,
websockets, sensores, timers, y en cualquier sitio donde varios consumidores
deban ver el mismo evento. Intentar modelar un flujo de clics como una
secuencia pull significa escribir un búfer a mano, y mal.

El error que evitar es convertir hacia el otro lado solo para reutilizar un
nombre de operador familiar. Cruza el puente cuando el *problema* cambia de
forma, no cuando el vocabulario suena mejor.

## Ejercicios

1. `take(3)` sobre una cadena pull detiene al productor. ¿Cuál es el
   equivalente en un `Stream`, y qué pasa con los valores que ya estaban en
   vuelo?
2. ¿Por qué `debounce` no está disponible en una cadena pull? Describe qué
   significaría siquiera, y qué parte es incoherente.
3. Una API HTTP paginada devuelve 100 filas por petición. Modélala de las dos
   formas, y di cuál hace más barato «parar tras la primera coincidencia» —
   y por cuántas peticiones.
4. `Stream` tiene `asBroadcastStream`; las cadenas pull tienen `fork`/`tee`.
   Ambos dejan que dos consumidores vean una fuente. ¿Cuál es la diferencia
   esencial en lo que pasa cuando un consumidor es lento?

## Soluciones

1. `subscription.cancel()`. Los valores ya emitidos se pierden, y un valor
   que el productor estaba a mitad de calcular se termina y se descarta — el
   productor nunca estuvo esperando permiso, así que la cancelación es una
   petición, no una barrera. En una cadena pull, «parar» es simplemente la
   ausencia de la siguiente llamada, así que no hay nada en vuelo que
   descartar.
2. `debounce` significa «emite solo si no llegó nada más en X». En una cadena
   pull nada llega por sí solo: el siguiente valor existe exactamente cuando
   lo pides, así que la ventana siempre estaría vacía y el operador degenera
   en `map`. Es el ejemplo más claro de un operador que trata *sobre* el
   ritmo del productor, algo que solo tiene push.
3. Pull: un `FxAsyncIterable` que pide una página cuando el consumidor agota
   la actual. Push: un `Stream` que pide páginas tan rápido como puede.
   «Parar tras la primera coincidencia» cuesta exactamente una petición en el
   modelo pull si la coincidencia está en la primera página; la versión push
   normalmente ya ha pedido varias páginas para entonces — la diferencia no
   tiene límite y crece con la latencia.
4. `asBroadcastStream` da a cada listener los mismos eventos al ritmo del
   productor: un listener lento o hace búfer o descarta, y no puede frenar al
   productor. `fork`/`tee` dividen un *pull*, así que la fuente compartida
   avanza solo cuando ambos consumidores han preguntado — el consumidor lento
   retiene al rápido, que es el backpressure funcionando como está diseñado,
   y es la opción por defecto correcta cuando la corrección importa más que
   la vivacidad.
