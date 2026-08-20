---
slug: illegal-states
chapter: 3
part: 1
title: Hacer irrepresentables los estados ilegales
description: Tipos suma, tipos producto, y las clases sealed y los records de Dart — cómo mover toda una clase de bugs del tiempo de ejecución al de compilación eligiendo un tipo que no pueda expresar el caso malo.
---
# Hacer irrepresentables los estados ilegales

> **En este capítulo**
> - productos y sumas: las dos formas de combinar tipos, y cómo contar sus valores
> - por qué `sealed` + `switch` es la característica que hace que los tipos suma valgan la pena
> - el refactor: sustituir un saco de campos nulables por un tipo que no puede mentir
> - dónde encajan los records, y dónde un tipo es la herramienta equivocada

## Contar los estados

Un tipo es un conjunto de valores, y se puede contar. `bool` tiene 2. `Null`
tiene 1. Un enum con tres constantes tiene 3. Una vez sabes contar, las dos
formas de combinar tipos reciben su nombre:

- Un **producto** contiene uno de cada: un record `(bool, bool)` tiene
  2 × 2 = 4 valores. Los campos de una clase son un producto.
- Una **suma** contiene uno de entre varios: `bool | Null` tiene 2 + 1 = 3
  valores. En Dart, una jerarquía `sealed` es una suma, y — de manera
  informal — también lo es `T?`.

Los errores de diseño son casi siempre el mismo error: **el tipo tiene más
valores que el dominio.** Aquí está la forma clásica.

```dart run
// Four fields; 2 × 2 × 2 × 2 = 16 representable combinations…
class Request {
  Request(
      {this.loading = false,
      this.data,
      this.error,
      this.cancelled = false});
  final bool loading;
  final String? data;
  final String? error;
  final bool cancelled;
}

void main() {
  // …but this one is nonsense, and it compiles.
  final broken =
      Request(loading: true, data: 'ok', error: 'boom');
  print([broken.loading, broken.data, broken.error]);
}
```

Cuatro estados tienen sentido — cargando, cargado, fallido, cancelado — y el
tipo admite dieciséis. En los doce sobrantes es donde viven los bugs, y cada
`if (r.error != null && !r.loading)` del código es un parche escrito a mano
sobre uno de ellos.

![Dieciséis estados representables, cuatro reales](diagrams/t3-1-state-space.svg)

*Figura 3-1. El tipo de la izquierda es un producto de cuatro banderas; el dominio es una suma de cuatro casos. Cada celda fuera de la diagonal es un estado que tu código debe manejar o confiar en que nunca ocurra.*

## El tipo suma, y la característica que lo hace rentable

```dart run
sealed class Request {
  const Request();
}

class Loading extends Request {
  const Loading();
}

class Loaded extends Request {
  const Loaded(this.data);
  final String data;
}

class Failed extends Request {
  const Failed(this.message);
  final String message;
}

class Cancelled extends Request {
  const Cancelled();
}

String render(Request r) => switch (r) {
  Loading() => 'spinner',
  Loaded(:final data) => 'showing $data',
  Failed(:final message) => 'error: $message',
  Cancelled() => 'cancelled',
};

void main() {
  const all = [
    Loading(),
    Loaded('42 rows'),
    Failed('timeout'),
    Cancelled()
  ];
  all.map(render).forEach(print);
}
```

Cuatro casos, exactamente cuatro estados, ningún campo nulable y ninguna rama
`default`. Ese último detalle es el punto entero: `sealed` hace que el
`switch` sea **exhaustivo**, así que añadir un quinto caso convierte cada
lugar que maneja el tipo en un error de compilación que enumera con precisión
lo que aún no has pensado. Un tipo suma sin comprobación de exhaustividad no
es más que una jerarquía de clases con pasos de más; Dart 3 aportó la mitad
que faltaba.

Esta es la misma maquinaria que usa `Either` — es una suma sellada de `Left`
y `Right` (capítulo 16), y por eso un `switch` sobre un `Either` tampoco
necesita rama de reserva.

## Productos: los records, y dónde se detienen

Los records te dan un producto anónimo donde una clase sería ceremonia:

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  // `attach` pairs each value with something derived from it:
  // a product, produced lazily, with no class to declare.
  final priced = fx(['apple', 'fig', 'banana'])
      .attach((name) => name.length)
      .toList();
  print(priced);

  final total = fx(priced).sumBy((row) => row.$2);
  print('total letters: $total');
}
```

Un record es la herramienta correcta cuando el emparejamiento es *local* — un
paso intermedio de una tubería, un retorno de dos valores. Es la herramienta
equivocada en cuanto el emparejamiento tiene un nombre en el dominio y reglas
asociadas, porque un record no puede llevar una invariante. `(String, int)` no
puede prometer que el `int` sea no negativo;
`class Money { Money(this.cents) : assert(cents >= 0); }` sí.

> 🎓 **Por qué tipos de datos «algebraicos».** Los productos multiplican sus
> tamaños y las sumas los suman, y el álgebra sigue: `Either<A, B>` tiene
> |A| + |B| valores, `A?` tiene |A| + 1, y las funciones `A → B` tienen
> |B|^|A| — por eso en la literatura la flecha se escribe como exponenciación.
> El isomorfismo `(A, B) → C ≅ A → (B → C)` — currificación, capítulo 4 — es
> el enunciado a nivel de tipos de que `(c^b)^a = c^(b×a)`. Los nombres no son
> adorno; la aritmética es real, y predice qué refactorizaciones preservan el
> significado.

## El refactor, en tres movimientos

1. **Cuenta.** Anota cuántos estados admite el tipo y cuántos tiene el
   dominio. Si difieren, la diferencia es tu presupuesto de bugs.
2. **Nombra los casos reales.** Una subclase `sealed` para cada uno, cargando
   exactamente los datos que ese caso necesita — `Loaded` tiene `data` y no
   `message`, y nada nulable.
3. **Borra las guardas.** Cada `if (x != null && !y)` que existía para
   descartar una combinación imposible desaparece, sustituido por una rama de
   `switch` que el compilador vigila.

La recompensa no es elegancia, es que el *siguiente* cambio queda comprobado.
Añadir `Retrying` a `Request` produce una lista de errores de compilación, que
es una lista de tareas escrita por el compilador e imposible de olvidar.

## Cuándo se gana el sueldo

Úsalo donde una combinación equivocada sería un defecto real y donde los casos
vayan a crecer: estados de petición/respuesta, resultados de parseo, mensajes
de protocolo, cualquier cosa con un «o» en su especificación.

Sáltatelo para datos genuinamente abiertos, para una estructura que solo son
tres números independientes y — importante — en la frontera con JSON, donde el
mundo te entrega un saco de nulables de todos modos. Ahí el tipo suma es
aquello *hacia lo que* parseas: un único sitio convierte el mapa informe en un
valor que no puede mentir, y todo lo que viene después recibe la garantía. Ese
parseo es el tema de la Parte IV.

## Ejercicios

1. ¿Cuántos valores tiene `(bool, String?)` si `String` tiene *n* valores? ¿Y
   `Either<bool, bool>`?
2. Modela un semáforo que sea rojo, ámbar, verde o «ámbar intermitente con un
   motivo». ¿Qué casos llevan datos, y cuántos estados admite tu tipo?
3. Toma la clase `Request` del principio del capítulo y anota los doce estados
   sin sentido. ¿En cuáles reventaría hoy tu código, y en cuáles renderizaría
   algo incorrecto en silencio?
4. Tanto `Either<String, int>` como `(String?, int?)` pueden representar «un
   fallo o un número». Da una razón concreta para preferir el primero.

## Soluciones

1. `(bool, String?)` es un producto de 2 por (*n* + 1), o sea 2*n* + 2
   valores. `Either<bool, bool>` es una suma: 2 + 2 = 4 — la misma cuenta que
   `(bool, bool)`, pero son tipos distintos, y confundirlos es precisamente el
   error de modelado del que trata este capítulo.
2. Tres casos constantes más uno que lleva un `String reason`:
   `sealed class Light` con `Red`, `Amber`, `Green`, `FlashingAmber(reason)`.
   El tipo admite 3 + *r* estados, donde *r* es el número de cadenas de
   motivo — lo cual es honesto, porque un ámbar intermitente lleva de verdad
   más información que un rojo.
3. Los dieciséis menos los cuatro reales: `loading` con `data`, `loading` con
   `error`, `data` con `error`, `cancelled` con cualquier otra cosa, y el
   estado vacío en que los cuatro son null/false. El vacío suele ser el
   reventón (no hay nada que renderizar); las combinaciones suelen ser el bug
   silencioso, porque gana el primer `if` de la función de render y el resto
   del estado se descarta sin leer.
4. `Either` es una suma, así que el compilador puede demostrar que hay
   exactamente un lado presente y el `switch` cubre ambos sin reserva.
   `(String?, int?)` es un producto de dos opcionales: cuatro estados, dos de
   los cuales — ambos null, ambos no null — son un sinsentido que tienes que
   manejar a mano en cada punto de uso.
