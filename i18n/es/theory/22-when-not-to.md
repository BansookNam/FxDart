---
slug: when-not-to
chapter: 22
part: 5
title: Cuándo no usar nada de esto
description: El capítulo contrapunto — los casos en los que un bucle for, un bloque try, un Stream normal o un buffer mutable son la respuesta correcta, y cómo saberlo antes de haber escrito la versión ingeniosa.
---
# Cuándo no usar nada de esto

> **En este capítulo**
> - cinco formas en las que la versión imperativa es sencillamente mejor
> - el coste que nadie pone en el README: lectura, depuración, contratación
> - una lista de comprobación que puedes aplicar antes de escribir la tubería
> - qué conservar incluso cuando descartas el resto

## La postura honesta

Todo lo que hay en este libro es una herramienta con un precio. Veintiún
capítulos han defendido las herramientas; este les pone precio, porque una
técnica contra la que no puedes argumentar es una creencia, no una decisión de
ingeniería.

## Cinco formas en las que gana el bucle

**1. Caliente, uniforme, consumido por completo.** La forma perdedora del
capítulo 14: muchas etapas baratas, cada elemento usado, en una ruta que se
ejecuta constantemente. La indirección por elemento es puro coste añadido y no
hay trabajo rechazado que lo recompense.

```dart run
void main() {
  final xs = List.generate(8, (i) => i);

  // Sometimes this is just the right code.
  var sum = 0;
  for (final x in xs) {
    if (x.isOdd) sum += x * x;
  }
  print(sum);
}
```

**2. Aritmética de índices.** Comparaciones deslizantes con zancadas
irregulares, transformaciones in situ, algoritmos definidos sobre posiciones
(búsqueda binaria, dos punteros, tablas de programación dinámica). El
vocabulario de tuberías describe *secuencias de valores*; cuando tu algoritmo
trata sobre *posiciones en un buffer*, traducirlo cuesta claridad y no compra
nada.

**3. Un solo paso.** Un único `map` sobre una lista de cinco elementos es
`list.map(f).toList()`. Envolverlo en `fx(...)` añade un nombre que aprender y
un tipo que explicar, por cero beneficio. Lo mismo vale para una única llamada
falible: que `int.tryParse` devuelva `null` es completo; convertirlo en un
`Either<String, int>` significa inventar un mensaje de error que nadie lee.

**4. Trabajo genuinamente imperativo.** Construir un buffer, dirigir una
máquina de estados, escribir bytes en un socket, orquestar un script de
migración. Son secuencias de *efectos*, y el consejo del capítulo 2 — empuja
los efectos hacia los bordes — significa que los bordes existen y deben
parecer lo que son.

**5. Problemas con forma de empuje.** La regla del capítulo 12. Eventos de
interfaz, sockets, temporizadores, y cualquier caso en el que varios
consumidores deban ver el mismo evento: usa `Stream` (o la capa `fxEvents`) y
deja de intentar tirar.

## Los costes que nadie enumera

**El coste de lectura es real y está distribuido de forma desigual.** Una
cadena de diez etapas es más densa que el bucle que sustituyó. La densidad es
buena cuando quien lee conoce el vocabulario y mala cuando no lo conoce, y *tu
equipo* es la variable que decide cuál de las dos.

**Depurar es peor.** Una traza de pila dentro de una tubería perezosa muestra
marcos del iterador, no los nombres de tus etapas. Un punto de interrupción en
un callback salta entremezclado con otras etapas (la fusión del capítulo 5,
funcionando como está diseñada). La depuración por impresión necesita `peek`.
Nada de esto es fatal; todo ello es más lento que recorrer un bucle paso a
paso.

**La abstracción puede desbordar el problema.** El modo de fallo no es una
cadena ingeniosa aislada — es una base de código donde quien la lee debe
mantener cuatro nombres de typeclass en la cabeza para seguir una función de
tres líneas. Si nombrar la abstracción tarda más que el código que ahorra, ha
perdido.

**El coste de equipo se acumula.** Cada construcción de este libro es algo que
enseñar. Eso es aceptable para `map`/`filter`/`fold`, que cualquier
desarrollador de Dart conoce; es una inversión real para `accumulate`,
`traverse` y el ámbito `Raise`. Gástalo donde compense y no en todas partes.

![Una lista de comprobación, no una filosofía](diagrams/t22-1-checklist.svg)

*Figura 22-1. Cuatro preguntas, formuladas antes de escribir la tubería. Tres
noes y un bucle es la respuesta correcta — lo cual es un resultado normal, no
una falta de coraje.*

## La lista de comprobación

Antes de recurrir al vocabulario de tuberías:

1. **¿Se descarta algo?** `take`, `first`, un `filter` selectivo, una salida
   anticipada. Si es así, la pereza se está ganando su sueldo (capítulo 11).
2. **¿Hay espera?** IO independiente que podría solaparse. Si es así,
   `concurrent(n)` justifica la cadena por sí solo (capítulo 13).
3. **¿Los fallos son datos?** Varios pasos falibles cuyos motivos necesita
   quien llama. Si es así, los errores tipados compensan (capítulos 15–18).
4. **¿Necesitaría el bucle un comentario?** Agrupación anidada, tres
   acumuladores, un conjunto de «ya visto» — si la versión imperativa necesita
   un párrafo, la tubería suele ser más corta *y* más clara.

Tres o cuatro síes: usa las herramientas. Un sí: usa las herramientas solo
para esa parte. Cero: escribe el bucle, y no pidas disculpas.

## Qué conservar en cualquier caso

Aunque no vuelvas a usar FxDart nunca más, cuatro cosas de este libro
sobreviven:

- **La pureza como herramienta de diseño** (capítulo 2). Núcleo puro, capa
  efectual, y saber cuál es cuál.
- **Los estados ilegales irrepresentables** (capítulo 3). Esto es gratis — es
  el propio `sealed` de Dart y sus records, y evita más errores que todo lo
  demás junto.
- **La regla del canal de fallo** (capítulo 18). Lanza para los errores de
  programación, `A?` para la ausencia, un valor tipado para todo aquello sobre
  lo que quien llama puede actuar.
- **Las leyes como herramienta de predicción y revisión** (capítulos 5 y 19).
  «¿Qué ley te permite mover eso?» es una buena pregunta en cualquier base de
  código, en cualquier estilo.

Esas cuatro son independientes del estilo. El resto es una caja de
herramientas, y las cajas de herramientas se eligen según el trabajo.

> 🎓 **La versión más fuerte del contraargumento.** No es «la FP es lenta»
> (el capítulo 14 lo midió: normalmente un empate) ni «es difícil» (el
> vocabulario son una docena de palabras). Es *localidad*: un bucle imperativo
> pone todo lo que quien lee necesita en ocho líneas consecutivas, mientras
> que una tubería distribuye el comportamiento entre callbacks, leyes y
> semántica de biblioteca que quien lee ya debe conocer. La abstracción
> cambia claridad local por estructura global. Cuando una base de código tiene
> poca estructura global que ganar — un script, algo puntual, una herramienta
> pequeña — el cambio es sencillamente malo, y ninguna cantidad de elegancia
> cambia la aritmética.

## Cuándo este capítulo se gana el sueldo

Cada vez que estás a punto de escribir una tubería porque se siente
sofisticada en lugar de porque es más corta o más segura. La lista de
comprobación tarda diez segundos y es la revisión de código más barata que
harás jamás.

## Ejercicios

1. Toma una tubería de tu propio código y aplícale la lista de comprobación.
   ¿Cuántos síes obtiene? Si son menos de dos, reescríbela como un bucle y
   compara el diff.
2. Escribe la peor tubería razonable para «suma los números pares de una
   lista», y luego el bucle. ¿Cuál es más corta? ¿Cuál preferirías depurar a
   las 2 de la madrugada?
3. El capítulo 14 encontró la tubería más rápida en tres de 53 casos. ¿Qué
   tenían en común esos tres, y lo tiene tu ruta caliente?
4. Nombra un fragmento de código de tu proyecto donde los errores tipados
   serían *peores* que una excepción, y explica con precisión por qué.

## Soluciones

1. La mayoría de las tuberías existentes puntúan dos o tres, que es por lo
   que se escribieron así. Las que puntúan cero suelen ser un `map` sobre una
   lista fija pequeña que podría ser un `for` — y reescribirlas es una mejora
   pequeña y real, no una derrota.
2. El bucle es más corto y más fácil de depurar: `for (final x in xs) if
   (x.isEven) sum += x;` frente a una cadena más un fold con semilla. Depurar
   a las 2 de la madrugada favorece la versión donde cada valor es visible en
   una variable local — lo cual es un argumento genuino, no una concesión.
3. Los tres rechazaban trabajo: usaban `take`/`first` después de una etapa
   cuyo equivalente nativo hacía el trabajo completo (una ordenación
   completa, un recorrido completo). Si tu ruta caliente consume todo lo que
   produce, ese mecanismo no está disponible para ti y la proporción no
   favorecerá a la tubería.
4. Cualquier cosa sobre la que quien llama no pueda actuar: una aserción
   fallida sobre un invariante interno, un archivo de caché corrupto al
   arrancar, un error de programación en un argumento. Modelar esos casos
   como `Either` obliga a cada llamador a gestionar un caso cuyo único manejo
   sensato es rendirse — y esconde la traza de pila que habría localizado el
   error.
