---
slug: what-it-costs
chapter: 14
part: 3
title: Lo que cuestan las abstracciones
description: El capítulo honesto — números medidos de la propia suite de benchmarks de FxDart, dónde una tubería gana a un bucle de mano, dónde pierde, y los mecanismos detrás de ambos.
---
# Lo que cuestan las abstracciones

> **En este capítulo**
> - la forma medida del trato, a través de 53 tareas reales
> - los dos mecanismos que hacen más lenta una tubería, y el que la hace más rápida
> - por qué «asignaciones» es la respuesta a casi toda pregunta de rendimiento aquí
> - cómo decidir, para tu código, sin fiarte de la proporción de nadie

## Los números

FxDart incluye una suite de benchmarks que compara cada uno de sus 53 ejemplos
lado a lado contra una versión de Dart escrita a mano de la misma tarea,
compilada AOT, mediana de ejecuciones repetidas. A la escala mayor de cada caso:

| Resultado a la escala titular | Casos |
|---|---|
| Empate (dentro del 5% o 0,6ms) | 38 |
| Dart escrito a mano más rápido | 12 |
| FxDart más rápido | 3 |

Proporción mediana entre los 53: **1,06×** — la tubería es típicamente un seis
por ciento más lenta, y dentro de la banda de ruido más a menudo que no.

Los extremos son más interesantes que la mediana:

| Caso | Proporción | Qué significa |
|---|---|---|
| `top-expenses` | **0,27×** | tubería casi 4× más *rápida* |
| `price-drop-detection` | 0,52× | tubería 2× más rápida |
| `smoothed-zone-changes` | 2,23× | tubería 2,2× más lenta |
| `anomaly-context` | 1,76× | tubería 1,8× más lenta |

Misma librería, misma máquina, una diferencia de ocho veces entre el mejor y el
peor. Cualquier frase de la forma «la PF es *n* veces más lenta en Dart» es por
tanto falsa; el número depende por completo de cuál de tres mecanismos domina.

## Mecanismo 1 — indirección por elemento (te cuesta)

Un bucle escrito a mano lee un elemento y aplica tu código en línea. Una
tubería envía cada elemento a través de un iterador por etapa: un `moveNext`
virtual, un getter `current`, una llamada a closure. El compilador AOT de Dart
en línea mucho de eso, pero no a través de una frontera de iterador
polimórfico, y el coste se paga *por elemento y por etapa*.

Por eso los perdedores de arriba son los capítulos con muchas etapas baratas
sobre datos uniformes: suavizado con ventana deslizante, comparaciones
adyacentes, trabajo numérico pequeño. La sobrecarga por elemento es fija, el
trabajo útil por elemento es diminuto, así que la proporción es mala.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  final data = List.generate(200000, (i) => i);
  final sw = Stopwatch()..start();

  var loop = 0;
  for (final n in data) {
    if (n.isEven) loop += n * 2;
  }
  final loopMs = sw.elapsedMicroseconds;

  sw.reset();
  final piped =
      fx(data).filter((n) => n.isEven).map((n) => n * 2).sum();
  final pipeMs = sw.elapsedMicroseconds;

  print([loop, piped, loop == piped]);
  print('loop ${loopMs}us, pipeline ${pipeMs}us');
  // In the browser this is JIT-compiled JS, so treat the ratio
  // as indicative; the book's table is AOT.
}
```

## Mecanismo 2 — asignación de memoria (cuesta a ambos, de forma distinta)

La mayoría de las diferencias grandes de la suite no son de CPU, son basura. La
versión escrita a mano de una tarea de agrupación construye `List` y `Map`
intermedios; la versión con tubería puede no construir ninguno, o puede
construir un record por elemento. Qué lado asigna más depende de la tarea, y la
asignación domina el tiempo cada vez que difiere.

Este es el diagnóstico más útil de todos: *cuenta las asignaciones en ambos
lados.* Si son iguales, las dos versiones estarán dentro del ruido la una de la
otra. Si un lado materializa una colección intermedia que el otro nunca
construye, ese lado pierde sin importar cuán ajustado sea su bucle.

## Mecanismo 3 — trabajo rechazado (te paga)

El modelo de coste del capítulo 11, apareciendo en el marcador. `top-expenses`
es 3,7× más rápido en la versión con tubería no porque la tubería sea veloz,
sino porque nunca ordena la lista entera: toma lo que necesita y para, mientras
que la versión nativa ordena 10.000 elementos para leer los cinco primeros.

Cada una de las tres victorias de FxDart es este mecanismo. Cuando una tarea
tiene la forma «la mayoría de estos datos no importa», la pereza gana a un
bucle más rápido que hace todo el trabajo de todas formas.

![De dónde viene la proporción](diagrams/t14-1-cost-shape.svg)

*Figura 14-1. Tres fuerzas independientes. La indirección es un impuesto fijo por elemento y por etapa; la asignación es cualquiera que sea el lado que construya más intermedios; el trabajo rechazado es el reembolso de la tubería cuando un terminal se detiene pronto.*

## Las reglas de medición que mantienen esto honesto

Las propias reglas de la suite, dignas de copiar:

- **AOT, no JIT.** Los números JIT favorecen a cualquiera de los dos lados que
  caliente mejor.
- **Mediana de ejecuciones repetidas en un proceso nuevo**, no una sola
  medición.
- **Una banda de empate** — 5% o 0,6ms — porque una diferencia que un usuario
  no puede percibir no es una diferencia. Dos tercios de los casos caen en ella.
- **Reporta también la memoria.** El RSS pico es donde aparece una lista
  intermedia, y es el número que decide si un trabajo cabe en un contenedor
  pequeño.
- **Nunca hagas un benchmark de una afirmación que no has ejecutado dos veces.**
  El ruido entre ejecuciones en una máquina tranquila ronda el 5%, así que
  cualquier diferencia de un solo dígito porcentual de una sola ejecución es una
  moneda al aire.

> 🎓 **La notación O grande no cambia; las constantes sí.** Nada de esto afecta
> la complejidad asintótica: un `filter` + `map` + `fold` perezoso es O(n)
> exactamente igual que el bucle, y `top-expenses` es más rápido porque la
> pereza cambia el *algoritmo* (selección parcial en lugar de una ordenación
> completa), no porque mejorara la constante. Cuando encuentres una gran
> ganancia, pregunta cuál de las dos fue — una ganancia de factor constante de
> 30% es un resultado de ajuste fino, una ganancia asintótica es un resultado de
> diseño, y solo la segunda sobrevive a un cambio de tamaño de entrada.

## Cómo decidir para tu propio código

1. **Asume un empate.** Dos tercios de las tareas reales lo son, y la
   legibilidad es entonces el único criterio que queda.
2. **Busca trabajo rechazado.** Cualquier `take`, `first`, `find`, o `any` con
   salida temprana sobre una fuente grande es una razón para esperar que la
   tubería gane.
3. **Busca intermedios.** Cuéntalos en ambos lados; el lado con más pierde.
4. **Mide el caso real, dos veces.** Con una banda de empate, en AOT, al tamaño
   que tu programa realmente ve.
5. **Luego elige.** Un coste mediano del 6% es un precio justo por código que tu
   equipo puede leer — y no es un precio que debas pagar en el bucle interno de
   un renderizador de frames.

## Cuándo recurrir al bucle

Escribe el bucle `for` cuando el código está en una ruta caliente, las etapas
son baratas, y la fuente se consume por completo — esa es precisamente la forma
perdedora. Escríbelo también cuando la operación es genuinamente imperativa:
mutar un búfer, rellenar una lista pre-dimensionada, conducir un algoritmo
basado en índices. El capítulo 22 recoge el resto de estos casos; la
contribución de este capítulo es que ahora puedes *predecir* la respuesta en
lugar de adivinar, y comprobarla en diez minutos.

## Ejercicios

1. Una tubería tiene cinco etapas sobre 1M de elementos y termina con
   `.first`. ¿Cuál de los tres mecanismos domina, y cuál es la proporción
   esperada frente a un bucle que hace el mismo trabajo?
2. ¿Por qué el RSS pico es a menudo un mejor discriminador que el tiempo
   transcurrido al comparar dos versiones de una tarea de agrupación?
3. La suite llama empate a una diferencia por debajo del 5%. Construye un caso
   donde una diferencia del 4% importe genuinamente, y di qué tendrías que
   cambiar de la medición para detectarlo de forma fiable.
4. `smoothed-zone-changes` es 2,2× más lenta como tubería. Antes de mirarla,
   predice qué dos características de la tarea causan eso, basándote en este
   capítulo.

## Soluciones

1. Domina el trabajo rechazado. `.first` tira de un elemento a través de cinco
   etapas, así que la tubería hace aproximadamente cinco llamadas a closure de
   trabajo mientras que la versión con bucle — si está escrita de forma
   ingenua — procesa la lista entera. La proporción esperada es enorme y a
   favor de la tubería; si el bucle también sale pronto, los dos convergen a un
   empate más la sobrecarga fija por etapa de la tubería.
2. Porque la agrupación es donde se esconden los intermedios. Ambas versiones
   pueden tardar el mismo tiempo en una máquina caliente con RAM de sobra,
   mientras una mantiene cada grupo en memoria a la vez y la otra transmite en
   flujo; el RSS muestra esa diferencia de inmediato y predice cuál de las dos
   se cae en una entrada más grande.
3. Un bucle de renderizado ajustado a 120fps tiene un presupuesto de 8,3ms, así
   que el 4% de un frame de 5ms es un tercio de milisegundo de margen — real.
   Para detectarlo necesitas muchas más iteraciones por medición (para elevar
   la señal por encima de la resolución del temporizador), una máquina
   tranquila, y ejecuciones A/B entrelazadas y emparejadas en lugar de
   ejecuciones una tras otra, para que la deriva afecte a ambos lados por
   igual.
4. Muchas etapas baratas (una ventana deslizante más una comparación más un
   map) sobre datos numéricos uniformes, con todo consumido — ninguna etapa
   rechaza trabajo, y la indirección por elemento se paga varias veces por
   elemento con muy poco cómputo real para amortizarla.
