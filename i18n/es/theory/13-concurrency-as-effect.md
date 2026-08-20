---
slug: concurrency
chapter: 13
part: 3
title: La concurrencia como efecto
description: concurrent(n) cambia cuándo se calculan los elementos sin cambiar cuáles ni en qué orden — la garantía que convierte el paralelismo acotado en un cambio de una sola palabra, y el canal trasero que lo implementa.
---
# La concurrencia como efecto

> **En este capítulo**
> - la garantía: *cuándo*, no *qué* — y por qué eso la hace componible
> - el canal trasero que lleva «ve n de ancho» hacia arriba
> - la preservación del orden, y el coste de renunciar a ella
> - las dos formas de equivocarse: compartir estado, y un fan-out sin límite

## Una palabra, una garantía

```dart run
import 'package:fxdart/fxdart.dart';

Future<int> slowSquare(int n) async {
  await Future.delayed(const Duration(milliseconds: 40));
  return n * n;
}

void main() async {
  final input = [1, 2, 3, 4, 5, 6];
  final sw = Stopwatch()..start();

  final serial =
      await fx(input).toAsync().map(slowSquare).toList();
  final serialMs = sw.elapsedMilliseconds;

  sw.reset();
  final wide = await fx(input)
      .toAsync()
      .map(slowSquare)
      .concurrent(3)
      .toList();
  final wideMs = sw.elapsedMilliseconds;

  print(serial);
  print(wide);
  print('same result: ${serial.toString() == wide.toString()}');
  print('serial ~${serialMs}ms, concurrent(3) ~${wideMs}ms');
}
```

Dos listas idénticas, una de ellas producida en un tercio del tiempo. Esa es
la afirmación que hace `concurrent(n)`, y merece la pena decirla con
precisión:

> `concurrent(n)` cambia **cuándo** se calculan los elementos. No cambia
> **cuáles** elementos se calculan, **a qué** valor se calculan, ni **en qué
> orden** llegan.

Todo lo que va después — folds, filtros, quien llama — no puede notar la
diferencia salvo mirando un reloj. La concurrencia se añade como un *efecto
sobre la evaluación*, no como un programa distinto.

Por eso compone. La asociatividad del capítulo 8 basta para un fold
posterior, porque el orden se preserva; la independencia del capítulo 6 es lo
que hace legal el solapamiento en primer lugar; y la pureza del capítulo 2 es
lo que lo hace seguro. Cada parte de la torre aparece aquí como una
precondición.

## El canal trasero

El capítulo 12 decía que un protocolo pull tiene una flecha que apunta hacia
arriba. Esto es lo que FxDart envía por ella.

Un pull ordinario es «dame el siguiente elemento». El iterador asíncrono de
FxDart toma un argumento: `iterator.next(concurrent)`, donde `concurrent` es
un marcador que lleva un ancho. Una etapa que lo recibe puede:

- honrarlo — iniciar n pulls anteriores a la vez, retener los resultados, y
  entregarlos en orden; o
- reenviarlo — un `map` no puede paralelizar nada por sí mismo, así que pasa
  la petición más arriba.

La petición viaja por tanto del consumidor hacia la etapa que de verdad puede
ensanchar, y los valores vuelven a bajar en orden.

![La petición sube, los valores bajan](diagrams/t13-1-back-channel.svg)

*Figura 13-1. `concurrent(3)` no es un búfer en medio de la cadena — es un
mensaje que viaja hacia arriba hasta que algo puede actuar sobre él. Tres
elementos están en vuelo; el consumidor sigue recibiendo 1, 2, 3.*

Esta es también la razón de que el operador se coloque *después* de la etapa
costosa en la cadena y aun así la afecte: el marcador sube.
`map(fetch).concurrent(3)` se lee como «tráeme estos ya obtenidos, de tres en
tres», que es exactamente lo que hace. `mapConcurrent(3, fetch)` es lo mismo
precombinado.

## El orden, y lo que cuesta mantenerlo

Preservar el orden no es gratis: si el elemento 2 termina antes que el 1, su
resultado espera. A cambio obtienes una secuencia que es *igual* a la serial,
que es lo que te permite meter `concurrent(n)` en una tubería existente sin
releer el resto.

Cuando de verdad no te importa, pide el orden de finalización y obtén los
resultados antes:

```dart run
import 'package:fxdart/fxdart.dart';

Future<String> job(String name, int ms) async {
  await Future.delayed(Duration(milliseconds: ms));
  return name;
}

void main() async {
  final jobs = [('slow', 90), ('quick', 10), ('mid', 45)];

  // Source order: 'slow' first, however long it takes.
  final ordered = await fx(jobs)
      .toAsync()
      .map((j) => job(j.$1, j.$2))
      .concurrent(3)
      .toList();
  print(ordered);

  // Completion order: whoever finishes first.
  final asDone = await fx(jobs)
      .toAsync()
      .map((j) => job(j.$1, j.$2))
      .concurrentPool(3)
      .toList();
  print(asDone);
}
```

`concurrentPool` es el nombre honesto para «estoy cambiando determinismo por
latencia». Úsalo cuando cada resultado se maneja de forma independiente —
escribir en un sink, actualizar una UI— y nunca cuando un paso posterior
asume alineación posicional con la entrada.

> 🎓 **Concurrencia no es paralelismo, y Dart lo hace literal.** Todo esto
> ocurre en un solo isolate: un único hilo intercalando continuaciones
> mientras espera E/S. Nada de lo anterior hace más rápido el código ligado a
> CPU: seis *cómputos* de 40ms tardan 240ms con o sin `concurrent`, porque no
> hay un segundo núcleo en juego. Lo que se solapa es la espera. Para
> paralelismo genuino necesitas isolates, que no pueden compartir estado
> mutable y por tanto convierten la pureza del capítulo 2 en un requisito
> mecánico en vez de una disciplina. Vale la pena mantener el vocabulario
> claro: `concurrent(n)` acota el *trabajo en vuelo*; los isolates compran
> *núcleos*.

## Dos formas de equivocarse

**Compartir estado mutable entre callbacks.** Con `concurrent(n)`, hay n
callbacks en vuelo a la vez y su intercalado no está especificado. Un
contador incrementado dentro de `map` está bien en un solo isolate (no hay
apropiación entre sentencias), pero una lectura-modificación-escritura *a
través de un await* no lo está:

```dart run
import 'package:fxdart/fxdart.dart';

void main() async {
  var balance = 100;

  // Each callback reads, awaits, then writes — the read is stale
  // by the time the write happens.
  await fx([1, 2, 3])
      .toAsync()
      .map((n) async {
        final read = balance;
        await Future.delayed(const Duration(milliseconds: 10));
        balance = read - 10;
        return n;
      })
      .concurrent(3)
      .toList();

  print('balance: $balance (serial answer would be 70)');
}
```

El arreglo no es un lock; es no escribir ese código. Devuelve valores y
pliégalos después — donde el orden *sí* está garantizado— en vez de mutar
estado compartido dentro de una etapa concurrente.

**Fan-out sin límite.** `Future.wait(items.map(fetch))` inicia todo: bien
para diez elementos, una caída de servicio para diez mil. Todo el sentido de
un parámetro de ancho es que el ancho lo eliges tú, y el número correcto
viene de los límites del lado remoto, no de la longitud de tu lista.

## Cuándo se gana el sueldo

Cualquier tubería cuyo trabajo por elemento sea E/S: peticiones HTTP,
lecturas de archivo, idas y vueltas a una base de datos. La ganancia es
aproximadamente el ancho, hasta el punto en que el lado remoto se convierte
en el cuello de botella — y la medición del primer listado es la que hay que
repetir contra tu propio servicio en vez de confiar en la proporción.

No hace nada por el trabajo ligado a CPU en un solo isolate, y activamente
perjudica cuando la fuente es barata y corta: tres futures extra para
calcular seis cuadrados es sobrecarga. Como con la pereza, el modelo te dice
dónde está la ganancia — esperar, no calcular.

## Ejercicios

1. Seis fetches de 40ms con `concurrent(3)` tardaron ~90ms. Predice el
   tiempo con `concurrent(6)` y con `concurrent(2)`, y luego ejecútalo.
2. ¿Por qué `concurrent(n)` colocado después de `map(fetch)` afecta a
   `fetch` en absoluto? Responde en términos de la dirección de la petición.
3. Reescribe el ejemplo del saldo para que la respuesta sea determinista sin
   reducir la concurrencia. ¿Qué cambió el arreglo sobre dónde vive el
   estado?
4. Un `.chunk(10)` posterior sigue a un `concurrentPool(4)`. ¿Qué se rompe, y
   tendría `concurrent(4)` el mismo problema?

## Soluciones

1. `concurrent(6)` debería ser más o menos una ronda — ~45ms — porque las
   seis esperas se solapan. `concurrent(2)` tarda tres rondas, ~130ms. El
   patrón es `ceil(items / n) × latencia`, que es la fórmula que vale la
   pena recordar al elegir un ancho.
2. Porque la petición viaja *hacia arriba*. `concurrent(3)` no procesa los
   valores que le llegan; le pide a su fuente tres a la vez, y esa fuente es
   la etapa `map(fetch)`, que inicia tres fetches. En un modelo push no
   habría nada que pedir — los fetches ya estarían corriendo.
3. Devuelve el delta desde cada callback y pliega después:
   `.map((n) async { …; return -10; }).concurrent(3)` y luego
   `fold(100, (a, d) => a + d)`. El estado se movió fuera de la región
   concurrente hacia la ordenada — que es el arreglo general, y la razón de
   que `fold` se ejecute después de la tubería y no dentro de ella.
4. Nada se rompe *mecánicamente* — `chunk` agrupará con gusto lo que sea que
   llegue— pero los trozos ya no corresponden a posiciones de entrada, así
   que cualquier código que asuma «el trozo 0 son las primeras diez
   entradas» ahora está equivocado. Con `concurrent(4)` la correspondencia
   se mantiene, porque el orden se preserva. Este es el coste concreto de
   cambiar determinismo por latencia.
