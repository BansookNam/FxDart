---
slug: applicative
chapter: 6
part: 2
title: El applicative
description: El piso entre el functor y la mónada — combinar efectos independientes. Por qué una validación que acumula errores no puede ser una mónada, y cómo el ámbito accumulate de FxDart la entrega igualmente.
---
# Applicative

> **En este capítulo**
> - la diferencia entre pasos *dependientes* e *independientes*, en los tipos
> - el applicative: combinar varias estructuras sin que ninguna vea a la otra
> - por qué acumular todos los errores es imposible para una mónada y natural aquí
> - `map2`, `zipOrAccumulate` y el ámbito `accumulate` de FxDart

## Dos formas de «y luego»

El `flatMap` del capítulo 1 compone pasos donde el segundo depende del
primero: no puedes buscar el pedido del usuario hasta tener al usuario. Esa
dependencia está escrita en el tipo — `A → M<B>` saca el valor de la primera
caja.

Pero muchísimo código real no tiene esa dependencia. Validar un formulario: la
comprobación del nombre no necesita la edad, y la de la edad no necesita el
nombre. Son *independientes*, y el tipo de la operación que los combina lo
dice:

`map2 : F<A> × F<B> × ((A, B) → C) → F<C>`

Ninguna flecha desde `A` hacia la segunda estructura. Ambas están ya ahí; la
función solo combina los resultados. Un tipo con `map2` (más una forma de
elevar un valor plano, exactamente el `of` del capítulo 1) es un **functor
applicative**.

![Dependiente frente a independiente](diagrams/t6-1-dependent-independent.svg)

*Figura 6-1. `flatMap` no puede empezar el segundo paso hasta que el primero produce un valor. `map2` tiene los dos desde el principio — que es lo que hace siquiera posible ejecutarlos a la vez, o informar de ambos fallos.*

## Fallo rápido con `map2`

```dart run
import 'package:fxdart/fxdart.dart';

class User {
  const User(this.name, this.age);
  final String name;
  final int age;

  @override
  String toString() => 'User($name, $age)';
}

Either<String, String> vName(String s) =>
    s.isEmpty ? Either.left('name is empty') : Either.right(s);

Either<String, int> vAge(String s) {
  final n = int.tryParse(s);
  if (n == null) return Either.left('age is not a number');
  if (n < 0) return Either.left('age is negative');
  return Either.right(n);
}

void main() {
  print(vName('Ada').map2(vAge('36'), User.new));
  print(vName('').map2(vAge('36'), User.new));
  // Both wrong — but only the leftmost failure is reported.
  print(vName('').map2(vAge('nope'), User.new));
}
```

La última línea es el problema por el que existe este capítulo. La persona
rellenó mal dos campos; el formulario le habló de uno. Nada en la *estructura*
forzó eso — ambos `Either` estaban calculados. Es el informe el que falla
rápido, y `map2` informa solo del que está más a la izquierda.

## Por qué una mónada no puede acumular

Intenta escribir la versión acumuladora solo con `flatMap` y das contra un
muro que no es falta de empeño:

```dart
name.flatMap((n) => age.flatMap((a) => Either.right(User(n, a))));
```

Si `name` es un `Left`, el `flatMap` exterior cortocircuita — y la función que
habría mirado `age` *nunca se ejecuta*, porque está dentro del callback. El
tipo de `flatMap` dice que el segundo paso es una función del primer valor,
así que cuando no hay primer valor no hay segundo paso. Cortocircuitar no es
aquí una decisión de política; es lo que significa el tipo.

El applicative es estrictamente más débil, y la debilidad es la característica.
`map2` sostiene ambas estructuras como *datos* antes de combinarlas, así que
una implementación es libre de mirar las dos y concatenar sus fallos.

## Acumular, en FxDart

Dart no tiene un tipo `Validated`; FxDart sigue a Arrow 2.x y ofrece en su
lugar un *ámbito* acumulador. Dentro de `either`, pide uno:

```dart run
import 'package:fxdart/fxdart.dart';

class User {
  const User(this.name, this.age);
  final String name;
  final int age;

  @override
  String toString() => 'User($name, $age)';
}

Either<Nel<String>, User> parse(String name, String age) =>
    either((r) => r.zipOrAccumulate2(
          (br) {
            if (name.isEmpty) br.raise('name is empty');
            return name;
          },
          (br) {
            final n = int.tryParse(age);
            if (n == null) br.raise('age is not a number');
            if (n! < 0) br.raise('age is negative');
            return n;
          },
          User.new,
        ));

void main() {
  print(parse('Ada', '36'));
  print(parse('', '36'));
  print(parse('', 'nope')); // both failures, in branch order
}
```

Todas las ramas se ejecutan; los fallos se concatenan en una `NonEmptyList`
(el capítulo 8 explica por qué ese tipo y no una `List` corriente). Para más de
cinco ramas, o para reglas que dependen de otras anteriores, baja al ámbito
completo:

```dart run
import 'package:fxdart/fxdart.dart';

Either<Nel<String>, String> checkout(
  String item,
  String qty,
  String coupon,
) =>
    either((r) => r.accumulate((acc) {
          final i = acc.accumulating((br) {
            if (item.isEmpty) br.raise('item required');
            return item;
          });
          final q = acc.accumulating((br) {
            final n = int.tryParse(qty);
            if (n == null) br.raise('qty is not a number');
            return n ?? 0;
          });
          // Dependent rule: only meaningful once qty parsed.
          final c = acc.dependent((br) {
            if (coupon.isNotEmpty && q.value > 10) {
              br.raise('coupon not valid in bulk');
            }
            return coupon;
          });
          return '${q.value} x ${i.value} ${c.value}'.trim();
        }));

void main() {
  print(checkout('mug', '2', ''));
  print(checkout('', 'x', 'SAVE5'));
  print(checkout('mug', '99', 'SAVE5'));
}
```

`accumulating` ejecuta ramas independientes y registra sus errores;
`dependent` se ejecuta solo cuando aún no ha fallado nada, porque una regla que
lee el valor de otra rama no puede ejecutarse cuando ese valor no existe. Esa
división — independiente frente a dependiente — es la distinción de este
capítulo, convertida en API.

> 🎓 **Las leyes, y la definición de verdad.** Un applicative se suele dar como
> `pure : A → F<A>` más `ap : F<A → B> × F<A> → F<B>` (una función *dentro* de
> la estructura, aplicada a un valor dentro de la estructura). `map2` y `ap`
> son interdefinibles, y `map2` se lee mejor en un lenguaje sin currificación
> por defecto, y por eso FxDart expone esa cara. Las cuatro leyes — identidad,
> composición, homomorfismo, intercambio — dicen lo que esperarías: `pure` no
> añade nada, y la aplicación es asociativa igual que lo es la composición.
> Toda mónada es un applicative (`map2` vía `flatMap`); el recíproco falla, y
> la validación de este capítulo es el contraejemplo estándar.

## Elegir entre ellos

| Necesitas | Usa | Porque |
|---|---|---|
| El paso 2 necesita el valor del paso 1 | `flatMap` / ámbito `either` | La dependencia es real |
| Los pasos son independientes, basta el primer fallo | `map2` | Lo más barato, y cortocircuita |
| Los pasos son independientes, informa de todos los fallos | `zipOrAccumulate` / `accumulate` | Solo la forma applicative puede |
| Los pasos son independientes y lentos | Applicative + concurrencia | La independencia es lo que hace legal el solape |

La última fila es la que se pasa por alto. `concurrent(n)` (capítulo 13) se
aplica exactamente cuando los pasos no dependen entre sí — la misma condición
que hace posible acumular errores. La independencia te compra ambas cosas, y
`flatMap` la gasta.

## Cuándo se gana el sueldo

Validación de formularios y de payloads, evidentemente. También: carga de
configuración (informar de todas las claves ausentes a la vez, no de la
primera), importación de CSV (todas las filas malas, no la fila 7), y
dondequiera que una persona vaya a leer los errores y arreglarlos de una
pasada. La prueba es simple — *¿preferiría quien lo usa ver todos los
problemas a la vez?* Si sí, quieres el applicative.

Sáltatelo cuando los fallos sean genuinamente secuenciales (no puedes
comprobar el pedido hasta que el usuario existe) o cuando haya exactamente una
cosa que pueda salir mal. `accumulate` alrededor de una sola regla es
ceremonia sin recompensa.

## Ejercicios

1. `Future` tiene en la librería estándar un combinador con forma de `map2`.
   Nómbralo, y explica por qué puede ejecutar ambos futures a la vez mientras
   que `f1.then((_) => f2)` no.
2. Escribe `map2` para `Either` usando solo `flatMap` y `map`. Explica después
   por qué la versión que escribiste no puede acumular errores, en una frase
   sobre tipos.
3. En el ejemplo `checkout`, cambia `dependent` por `accumulating` en la regla
   del cupón y predice qué imprime `checkout('', 'x', 'SAVE5')`. ¿Por qué es
   `dependent` el valor por defecto más seguro para reglas que leen a sus
   hermanas?
4. ¿Es `Set` un applicative? ¿Qué significaría `map2`, y encaja con tu
   intuición sobre «combinar dos conjuntos»?

## Soluciones

1. `Future.wait([a, b])` — recibe ambos futures ya construidos, así que los dos
   están corriendo antes de llamarlo. `a.then((_) => b)` construye `b` dentro
   de un callback, así que `b` ni siquiera puede existir hasta que `a` termine.
   La diferencia es exactamente `map2` frente a `flatMap`, y se ve en el reloj
   de pared.
2. `a.flatMap((x) => b.map((y) => f(x, y)))`. No puede acumular porque `b.map`
   está dentro de una función de `x`: cuando `a` es un `Left`, esa función
   nunca se aplica, así que el fallo de `b` nunca se examina. El tipo
   `A → Either<E, C>` es lo que vuelve inaccesible el segundo valor.
3. Con `accumulating`, la rama del cupón se ejecuta aunque `qty` haya fallado, y
   leer `q.value` dentro de ella detona — elevando los errores acumulados desde
   dentro de una rama en vez de al final. `dependent` existe para hacer eso
   imposible: se salta el bloque por completo cuando ya hay errores, que es el
   valor por defecto correcto para cualquier regla que lea el `.value` de una
   hermana.
4. Sí: `map2` sobre conjuntos es el producto cartesiano con los resultados
   deduplicados — `{1,2}` y `{10,20}` con `+` dan `{11, 21, 12, 22}`. Encaja
   con la lectura no determinista (cada conjunto es «uno de estos valores»),
   que es la misma lectura que hace de `List` una mónada en el capítulo 1. *No*
   encaja con la intuición de estilo zip — y elegir entre esas dos lecturas es
   exactamente por lo que Haskell tiene `[]` y `ZipList` como applicatives
   separados.
