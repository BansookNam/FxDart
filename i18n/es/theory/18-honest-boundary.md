---
slug: honest-boundary
chapter: 18
part: 4
title: La frontera honesta
description: Lo que un sistema de errores tipados no puede prometer en un lenguaje con throws sin verificar — los tres canales de fallo que Dart tiene en realidad, cómo elegir entre ellos, y dónde convertir.
---
# La frontera honesta

> **En este capítulo**
> - los tres canales de fallo de Dart, y qué puede y no puede decir cada uno
> - la regla para elegir: ¿puede quien llama hacer algo al respecto?
> - por qué `Either` nunca deja un programa libre de excepciones, y por qué eso está bien
> - convertir en los bordes, en ambas direcciones

## Tres canales

Dart deja que una función falle de tres maneras, y no son intercambiables.

| Canal | El tipo dice | Quien llama debe | Lleva |
|---|---|---|---|
| `throw` | nada | nada (sin comprobar) | cualquier objeto + traza de pila |
| `A?` | podría estar ausente | manejar null | ningún motivo |
| `Either<E, A>` | podría fallar, con `E` | manejar ambos lados | un motivo tipado |

Cada uno es adecuado para algo:

```dart run
import 'package:fxdart/fxdart.dart';

// 1. Nullable: absence is the whole story.
int? findIndexOf(List<String> xs, String needle) {
  final i = xs.indexOf(needle);
  return i == -1 ? null : i;
}

// 2. Either: the caller needs to know *why*.
Either<String, int> parsePort(String s) {
  final n = int.tryParse(s);
  if (n == null) return Either.left('not a number: $s');
  if (n < 1024) return Either.left('privileged: $n');
  return Either.right(n);
}

// 3. Throw: the caller cannot act, and the program is broken.
int divide(int a, int b) {
  if (b == 0) throw ArgumentError('b must not be zero');
  return a ~/ b;
}

void main() {
  print(findIndexOf(['a', 'b'], 'z'));
  print(parsePort('80'));
  try {
    divide(1, 0);
  } catch (e) {
    print('threw: $e');
  }
}
```

La regla de elección es una sola pregunta: **¿puede quien llama hacer algo
específico respecto a este fallo?** Si sí, pertenece al tipo — `Either` si el
motivo importa, `A?` si no. Si no, lanza una excepción: un bug, un invariante
roto, o un fallo del entorno que nadie puede recuperar en ese punto de
llamada.

![Tres canales, una decisión](diagrams/t18-1-three-channels.svg)

*Figura 18-1. La pregunta no es qué tan grave es el fallo, sino si quien
llama tiene una reacción. Todo lo que quien llama puede accionar pertenece al
tipo de retorno; todo lo demás pertenece al canal de excepciones, donde no
saturará cada firma entre aquí y la cima.*

## Lo que los errores tipados no pueden prometer

Aquí está la parte incómoda, y la razón de ser de este capítulo.

`Either<E, A>` en la firma *no* significa "esta función solo falla con `E`".
Dart tiene excepciones sin comprobar, así que cualquier código — el tuyo, el
del SDK, el de una dependencia — puede lanzar en cualquier momento. Una
función que devuelve `Either` puede igual explotar con `StateError`,
`RangeError`, `OutOfMemoryError`, o un bug en un paquete transitivo.

Así que la afirmación honesta es más estrecha, y aun así vale mucho:

> `Either<E, A>` dice: *los fallos que esta función modela son `E`, y están en
> el tipo.* No dice nada sobre los fallos que nadie modeló.

Compáralo con un lenguaje de excepciones comprobadas, que promete el conjunto
completo y lo paga con cláusulas `throws` en todo. Dart eligió no
comprobarlas; una librería no puede deshacer esa elección. Lo que FxDart
añade es un canal para los fallos en los que *sí* pensaste, que es de donde
realmente vienen los bugs.

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> risky(String s) => either((r) {
      if (s.isEmpty) r.raise('empty');
      // Not modelled, and not caught by the signature:
      return int.parse(s); // throws on 'abc'
    });

void main() {
  print(risky(''));
  try {
    print(risky('abc'));
  } catch (e) {
    print('escaped the Either: ${e.runtimeType}');
  }

  // If you want throws folded into the failure channel, say so.
  print(eitherCatching<String, int>(
      (r) => int.parse('abc'), (e, _) => 'not a number'));
}
```

`eitherCatching` es la conversión explícita, y que sea explícita es el
diseño: tragarse en silencio cada excepción convertiría bugs genuinos en
fallos de dominio, y te enterarías en producción, un `Left('Bad state: no
element')` a la vez.

## Convertir en los bordes

Un programa tiene una frontera donde el estilo de fallo del mundo exterior se
encuentra con el tuyo. Ambas direcciones son una línea, y ambas pertenecen a
esa frontera, no dispersas por el código:

```dart run
import 'package:fxdart/fxdart.dart';

class Config {
  const Config(this.port);
  final int port;
  @override
  String toString() => 'Config($port)';
}

// Inbound: a throwing API becomes a typed failure.
Either<String, Config> loadConfig(Map<String, String> env) =>
    eitherCatching(
      (r) {
        final raw = env['PORT'];
        r.ensureNotNull(raw, () => 'PORT is not set');
        return Config(int.parse(raw!));
      },
      (e, _) => 'PORT is not a number',
    );

// Outbound: a typed failure becomes the framework's exception.
Config loadOrThrow(Map<String, String> env) =>
    loadConfig(env).fold(
      (e) => throw StateError('bad config: $e'),
      (c) => c,
    );

void main() {
  print(loadConfig({'PORT': '8080'}));
  print(loadConfig({}));
  print(loadConfig({'PORT': 'abc'}));

  try {
    loadOrThrow({});
  } catch (e) {
    print('at the edge: $e');
  }
}
```

La conversión de entrada ocurre donde llamas a código que no controlas. La
conversión de salida ocurre donde un framework exige un `throw` — un método
`build` de Flutter, un helper de test, `main`. En medio, los fallos son
valores.

> 🎓 **Errores versus excepciones, y qué significa eso en el propio SDK de
> Dart.** La convención de Dart es que `Error` (`ArgumentError`, `StateError`,
> `RangeError`) señala un *error de programación* — quien llama violó un
> contrato y debería corregirse, no manejarse — mientras que `Exception`
> señala una condición que un programa correcto puede igual encontrar
> (`FormatException`, `IOException`). Eso encaja perfectamente con este
> capítulo: `Error` nunca debería capturarse y convertirse en un `Left`,
> porque hacerlo esconde un bug; `Exception` es un buen candidato para
> `eitherCatching`. Cuando escribes una librería, seguir la convención es lo
> que permite que quienes la usan hagan esta distinción siquiera.

## El término medio nulable

`A?` es el canal de fallo más barato que tiene Dart, y es genuinamente la
respuesta correcta más a menudo de lo que admiten los entusiastas de los
errores tipados — con una prueba: *¿"ausente" es todo el mensaje?* Una
búsqueda en un mapa, una primera coincidencia, un campo opcional: sí. Un
parseo, una validación, una autorización: no, porque quien llama querrá saber
qué salió mal.

El scope `nullable` de FxDart existe para que la cadena con forma de null
reciba el mismo trato en línea recta:

```dart run
import 'package:fxdart/fxdart.dart';

class User {
  const User(this.name, this.managerId);
  final String name;
  final String? managerId;
}

final users = <String, User>{
  'u1': User('Ada', 'u2'),
  'u2': User('Grace', null),
};

String? managerName(String id) => nullable((r) {
      final user = r.bind(users[id]);
      final managerId = r.bind(user.managerId);
      final manager = r.bind(users[managerId]);
      return manager.name;
    });

void main() {
  print(managerName('u1'));
  print(managerName('u2')); // no manager
  print(managerName('u9')); // no such user
}
```

Tres formas de estar ausente, un `null` de salida, y ninguna pirámide de `?.`
y `??`. Nota lo que falta en la salida: cuál de las tres fue. Esa es
exactamente la información que a `Either` le cuesta un parámetro de tipo
conservar.

## Cuándo se gana el sueldo

Las reglas de este capítulo pagan cada vez que se escribe una función nueva,
lo que las convierte en la decisión de mayor frecuencia del libro. Acertar
con ellas mantiene las firmas honestas y los bloques `try` escasos y
significativos.

Dejan de pagar si se aplican dogmáticamente: un `Either<String, T>` en cada
helper privado añade ruido sin añadir información, y una base de código
donde `main` es el único `try` es una base de código que va a perder una
traza de pila que alguien necesitaba. Convierte en las fronteras, modela lo
que quien llama puede accionar, y deja que los bugs genuinos exploten con
ruido.

## Ejercicios

1. Clasifica esto como throw / `A?` / `Either`: un JSON que falla al
   parsearse; un parámetro de consulta opcional ausente; una longitud de
   array negativa pasada a tu propia función; un pago rechazado por el
   proveedor.
2. `int.parse` lanza y `int.tryParse` devuelve null. ¿Qué canal habría dado
   `Either`, y qué habría tenido que inventar?
3. ¿Por qué `eitherCatching` es una función separada en lugar del
   comportamiento por defecto de `either`? Describe el bug que seguiría de
   la otra elección.
4. Una función devuelve `Either<E, A>` pero también lanza en algunas
   entradas. ¿Cómo lo descubrirías, y qué cambiarías — el código o la
   firma?

## Soluciones

1. Fallo de parseo de JSON: `Either` si un usuario puede corregir la
   entrada, `A?` si quien llama solo ramifica sobre la validez. Parámetro
   opcional ausente: `A?` — la ausencia *es* el mensaje. Longitud negativa:
   `throw ArgumentError` — quien llama violó un contrato, y la corrección
   está en su código. Pago rechazado: `Either` con un motivo tipado, ya que
   quien llama debe mostrarlo a una persona y posiblemente reintentar.
2. Habría dado `Either<FormatException, int>` — y habría tenido que
   inventar un tipo de error. Ese es el costo completo del tercer canal:
   alguien debe decidir qué *es* el fallo, nombrarlo, y mantenerlo.
   `tryParse` lo evita diciendo solo "no", que es por qué es la llamada más
   común.
3. Porque plegar cada excepción en un `Left` blanquearía bugs
   convirtiéndolos en fallos de dominio. Un `StateError` de un bug de
   librería llegaría como un error de validación, quien llama lo
   renderizaría junto al campo de código postal, y nadie vería jamás la
   traza de pila. La explicitud significa que la conversión es una decisión
   con un nombre asociado.
4. Descúbrelo con tests sobre las entradas que fallan, o leyendo en busca
   de llamadas que puedan lanzar (`parse`, `!`, `first`, `[]` sobre una
   lista). Cambia el *código*: envuelve la llamada que lanza en
   `eitherCatching` y modela el fallo, o deja que se propague
   deliberadamente si es un bug. Lo único que no hay que hacer es
   documentarlo en un comentario y dejar la firma mintiendo.
