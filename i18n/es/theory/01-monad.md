---
slug: monad
chapter: 1
part: 1
title: Qué es realmente una mónada
description: Una mónada es un tipo con dos operaciones y tres leyes. Dart tiene varias; este capítulo nombra la forma, muestra qué te compran las leyes y explica por qué ni Dart ni FxDart pueden escribir la interfaz.
---
# Qué es realmente una mónada

> **En este capítulo**
> - las tres mónadas que ya usas en Dart, y qué las convierte en una sola forma
> - las dos operaciones — `of` y `flatMap` — y por qué aplanar es el punto
> - las tres leyes, como código que puedes ejecutar, y qué se rompe cuando un tipo las ignora
> - por qué Dart no puede declarar una interfaz `Monad`, y qué hace FxDart en su lugar

## Empieza por el código, no por la definición

La famosa definición — *una mónada es un monoide en la categoría de los
endofunctores* — es cierta, y es la peor primera frase posible. Describe el
caso general a alguien que todavía no ha visto una sola instancia. Así que
aquí van tres instancias primero. Has escrito las tres.

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parsePort(String text) => either((r) {
  final n = r.ensureNotNull(
      int.tryParse(text), () => 'not a number: $text');
  r.ensure(n > 1023, () => 'privileged port: $n');
  return n;
});

Future<int> fetchTimeout(int port) async => port + 100;

void main() async {
  // List<A>: many values in one structure.
  print([1, 2, 3].expand((x) => [x, x * 10]).toList());

  // Either<String, int>: a value, or a failure instead of it.
  print(parsePort('8080'));
  print(parsePort('80'));

  // Future<A>: a value that is not here yet.
  print(await Future.value(8080).then(fetchTimeout));
}
```

Tres tipos sin relación entre sí. `List` guarda muchos valores, `Either`
guarda un valor o un fallo, `Future` guarda un valor que aún no ha llegado.
Lo que comparten no es lo que guardan: es lo que puedes *hacer* con ellos.

![Tres estructuras, dos puertos cada una](diagrams/t1-1-three-boxes.svg)

*Figura 1-1. Contenidos distintos, cableado idéntico: todas ellas pueden recibir un valor plano, y todas ellas pueden encadenar una función que devuelve otra caja del mismo tipo.*

Cada uno de estos tipos te da dos operaciones:

| | meter un valor | encadenar un paso que devuelve otra caja |
|---|---|---|
| `List<A>` | `[a]` | `expand` |
| `Future<A>` | `Future.value(a)` | `then` |
| `Either<E, A>` | `Either.right(a)` | `flatMap` |
| `Fx<A>` (FxDart) | `fx([a])` | `flatMap` |

Un tipo con esas dos operaciones, que cumple tres leyes a las que llegaremos,
es una **mónada**. Esa es toda la definición. La palabra intimida porque
llegó desde la teoría de categorías con su vocabulario a cuestas, no porque
la idea de debajo sea grande.

## Las dos operaciones, con precisión

Escribe `M<A>` para un valor de tipo `A` dentro de una estructura `M`. Una
mónada es un constructor de tipos `M` más:

- **of** (también llamado `pure`, `return` o `unit`): `A → M<A>`. Toma un
  valor corriente, obtén la caja más aburrida posible que lo contenga.
  Aburrida es un requisito técnico: `Either.right(3)` no añade ningún fallo,
  `Future.value(3)` no añade ninguna espera, `[3]` no añade elementos de más.
- **flatMap** (también llamado `bind` o `>>=`):
  `M<A> × (A → M<B>) → M<B>`. Toma una caja, y una función que convierte el
  valor de dentro en *otra caja*, y recupera una sola caja — no una caja de
  cajas.

La segunda mitad de esa última frase es el punto entero, y se ve mejor
quitándola. `map` por sí solo no basta:

```dart run
void main() {
  // The step returns a List, so map gives a List of Lists.
  final nested = [1, 2, 3].map((x) => [x, x * 10]).toList();
  print(nested);
  print(nested.runtimeType);

  // flatMap (Dart spells it `expand`) joins the inner lists
  // into the outer one.
  final flat = [1, 2, 3].expand((x) => [x, x * 10]).toList();
  print(flat);
  print(flat.runtimeType);
}
```

![map anida, flatMap aplana](diagrams/t1-2-map-vs-flatmap.svg)

*Figura 1-2. Ambas operaciones aplican la misma función. `map` conserva la caja que devolvió la función, envolviéndola en la caja de la que partió; `flatMap` une las dos capas en una.*

¿Por qué importa tanto? Porque *un paso que puede fallar, o esperar, o
producir muchas respuestas, es exactamente una función de tipo* `A → M<B>`.
Los programas reales son secuencias de esos pasos. Con solo `map`, cada paso
añade una capa: tres pasos seguidos te dan
`Either<E, Either<E, Either<E, A>>>`, y no se puede hacer nada con ese valor
sin desenvolverlo tres veces. `flatMap` mantiene la profundidad en uno, para
siempre, encadenes los pasos que encadenes. Las mónadas son cómo compones
funciones que devuelven contextos.

> **Terminología.** Un tipo con solo `map` (que cumple sus propias dos leyes)
> es un **functor** — capítulo 5. Toda mónada es un functor: puedes definir
> `map(f)` como `flatMap((a) => of(f(a)))`. Lo contrario no es cierto, y por
> eso la torre tiene más de un piso.

## Llevas escribiendo flatMap disfrazado

Dart esconde `flatMap` detrás de sintaxis que usas a diario. `await` *es*
`flatMap` para `Future`: saca el valor de un future, ejecuta el resto de la
función sobre él, y el resultado es un solo future — nunca un
`Future<Future<T>>`. Un bucle `for`-in que va añadiendo a una lista es
`flatMap` para `List`. El bloque `either { }` del capítulo 14 es `flatMap`
para `Either`.

Observa el mismo cálculo escrito de las dos maneras — primero como cadena
explícita, luego dentro del ámbito `either` de FxDart:

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parseAge(String text) => either((r) {
  final n = r.ensureNotNull(
      int.tryParse(text), () => 'not a number: $text');
  r.ensure(n >= 0, () => 'negative age: $n');
  return n;
});

Either<String, String> lookup(String id) => id == 'u1'
    ? Either.right('Ada')
    : Either.left('no such user: $id');

// Explicit chaining: every dependent step nests
// one level deeper.
Either<String, String> greetChained(String id, String ageText) =>
    lookup(id).flatMap((name) =>
        parseAge(ageText).flatMap((age) =>
            Either.right('$name is $age')));

// The same steps in a Raise scope: straight-line code,
// with the same short-circuiting.
Either<String, String> greetScoped(String id, String ageText) =>
    either((r) {
  final name = r.bind(lookup(id));
  final age = r.bind(parseAge(ageText));
  return '$name is $age';
});

void main() {
  print(greetChained('u1', '36'));
  print(greetScoped('u1', '36'));
  print(greetScoped('u9', '36'));
  print(greetScoped('u1', 'old'));
}
```

Las dos versiones hacen lo mismo, incluido detenerse en el primer fallo y no
ejecutar nunca el segundo paso cuando el primero falla. La diferencia es que
la versión encadenada se desplaza un nivel de indentación a la derecha por
cada paso — la forma que todo lenguaje con mónadas acaba inventando sintaxis
para ocultar. Haskell llama a la suya notación `do`, Scala la llama
`for`-comprehension, Dart llama al caso especial `async`/`await`. El bloque
`either` de FxDart es la misma idea alcanzada por otro mecanismo, que es
[el tema del capítulo 15](#ch15).

## Las tres leyes

Las dos operaciones no bastan. Un tipo podría definir `of` y `flatMap` y aun
así comportarse de forma sorprendente — de modo que una mónada debe cumplir
además tres leyes. Se leen como enunciados pedantes de lo obvio, que es
justo lo que las hace valiosas: son las garantías que ya das por supuestas
cuando refactorizas.

1. **Identidad por la izquierda.** `of(a).flatMap(f)` = `f(a)`. Encajar un
   valor y encadenar un paso inmediatamente es lo mismo que llamar al paso.
2. **Identidad por la derecha.** `m.flatMap(of)` = `m`. Sacar el valor de una
   caja y volver a meterlo tal cual no cambia nada.
3. **Asociatividad.** `m.flatMap(f).flatMap(g)` =
   `m.flatMap((a) => f(a).flatMap(g))`. Cómo agrupes una cadena de pasos no
   afecta al resultado.

![Las leyes como dos caminos con el mismo destino](diagrams/t1-3-monad-laws.svg)

*Figura 1-3. Todas las leyes dicen lo mismo: dos rutas distintas por el diagrama tienen que llegar al mismo valor. Las leyes son lo que te permite tomar cualquiera de las dos.*

Aquí están como aserciones que puedes ejecutar contra el `Either` de FxDart:

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> half(int n) =>
    n.isEven ? Either.right(n ~/ 2) : Either.left('odd: $n');

Either<String, int> minusOne(int n) => Either.right(n - 1);

void main() {
  final m = Either<String, int>.right(20);

  print(
      Either<String, int>.right(20).flatMap(half) == half(20));
  print(m.flatMap((a) => Either<String, int>.right(a)) == m);
  print(m.flatMap(half).flatMap(minusOne) ==
      m.flatMap((a) => half(a).flatMap(minusOne)));

  // The laws hold on the failure side too — that is what makes
  // short-circuiting composable rather than a special case.
  final bad = Either<String, int>.left('boom');
  print(bad.flatMap(half).flatMap(minusOne) ==
      bad.flatMap((a) => half(a).flatMap(minusOne)));
}
```

### Lo que cuesta una ley rota

Las leyes no son adorno. Rompe una y un refactor corriente cambia el
comportamiento en silencio. Aquí hay una caja que cuenta los pasos dados —
un diseño plausible, y sin ley:

```dart run
class Logged<A> {
  const Logged(this.value, this.steps);
  final A value;
  final int steps;

  static Logged<A> of<A>(A value) => Logged(value, 0);

  // The `+ 1` is the bug: chaining charges for
  // the chaining itself.
  Logged<B> flatMap<B>(Logged<B> Function(A) f) {
    final next = f(value);
    return Logged(next.value, steps + next.steps + 1);
  }

  @override
  String toString() => 'Logged($value, steps: $steps)';
}

Logged<int> double_(int n) => Logged(n * 2, 1);

void main() {
  // Left identity: of(a).flatMap(f) should equal f(a).
  // It does not.
  print(Logged.of(21).flatMap(double_));
  print(double_(21));

  // Right identity: chaining a step that does nothing
  // should be invisible.
  final m = double_(21);
  print(m);
  print(m.flatMap(Logged.of));
}
```

La asociatividad sobrevive aquí por casualidad — reagrupa la cadena y la
cuenta no cambia — pero ambas leyes de identidad fallan, y eso ya es fatal.
Extraer un paso trivial a su propio `flatMap`, o eliminarlo por inlining, es
un refactor que cualquier revisor dejaría pasar, y en este tipo cambia la
respuesta.

El arreglo no es añadir un caso especial; es hacer de `steps` un **monoide**
— un tipo con una combinación asociativa y un elemento identidad (capítulo 8)
— y dejar que `of` produzca la identidad. Quita el `+ 1` y `Logged` se
convierte en la mónada Writer, con ley y útil. Ese es el patrón detrás de la
mayoría de violaciones: una operación que parece inocua pero no tiene
elemento identidad.

> 🎓 **La definición formal, para que conste.** En teoría de categorías una
> mónada sobre una categoría **C** es un endofunctor `T : C → C` con dos
> transformaciones naturales, `η : Id ⇒ T` (eso es `of`) y `μ : T² ⇒ T` (eso
> es `flatten`, de donde `flatMap(f) = μ ∘ T(f)`), que satisfacen las
> condiciones de coherencia de unidad y asociatividad — las tres leyes de
> arriba, dibujadas como diagramas conmutativos. «Un monoide en la categoría
> de los endofunctores» dice lo mismo otra vez: `μ` es la multiplicación, `η`
> la unidad. Nada de este párrafo te ayudará a escribir Dart, y por eso está
> en una caja, y por eso el capítulo 20 es donde le corresponde.

## Qué implementa FxDart realmente

Ahora la parte honesta. Dart no puede expresar la interfaz que este capítulo
acaba de describir. Escribirla requiere un parámetro de tipo que a su vez sea
genérico — un tipo de orden superior — y Dart no tiene ninguno:

```dart
// Does not compile. `M` is a type, and a type cannot take
// arguments here.
abstract class Monad<M> {
  M<A> of<A>(A value);
  M<B> flatMap<A, B>(M<A> box, M<B> Function(A) f);
}
```

Arrow, la librería de Kotlin de la que están portados los errores tipados de
FxDart, lo sortea con plugins de compilador y context receivers. Scala tiene
el sistema de kinds de forma nativa. Dart no tiene ninguno de los dos, y
ninguna astucia lo recupera — los intentos acaban en casts a `dynamic` que
renuncian exactamente a la seguridad de tipos por la que existía la
abstracción.

Así que FxDart hace lo único honesto: implementa la *forma*, tipo a tipo, y
nunca finge abstraer sobre ella.

- **`Either<L, R>`** tiene `flatMap`, y `Either.right` es su `of`. Las leyes
  se cumplen; ejecutaste la comprobación dos páginas atrás.
- **`either((r) { … })`** es el sustituto ergonómico de la notación `do`. No
  es azúcar sintáctico — `r.bind` cortocircuita elevando hacia un ámbito
  (capítulo 15), un truco de continuaciones delimitadas y no una reescritura
  monádica. El mismo código en línea recta, distinto mecanismo, y una
  distinción que importa cuando preguntas por qué no hay una instancia de
  mónada para `Raise`.
- **`Fx<A>`** es una cadena perezosa de `Iterable`, e `Iterable` es la mónada
  lista: `flatMap` es su bind, `fx([a])` su `of`. La pereza no perturba las
  leyes — el capítulo 11 muestra por qué el orden de evaluación les es
  invisible.
- **`FxAsyncIterable<A>`** es la misma forma sobre fuentes asíncronas, con la
  propiedad extra de que `concurrent(n)` cambia *cuándo* se calculan los
  elementos sin cambiar *cuáles* — una afirmación de razonamiento ecuacional
  que las leyes respaldan.

Lo que pierdes por no tener una interfaz `Monad` es el código genérico que
funciona para todas las mónadas a la vez: un `traverse`, un `sequence`, un
juego de combinadores reutilizado entre `Either`, `Fx` y `Future`. FxDart
escribe en su lugar las versiones concretas. Eso es más código en la librería
y menos abstracción en tu programa — un intercambio que eligió el lenguaje,
no la librería.

## Cuándo el vocabulario se gana el sueldo

No necesitas la palabra «mónada» para usar `await`. La palabra empieza a
pagar cuando adviertes el *mismo* problema en tres sitios — callbacks
anidados, una pirámide de comprobaciones de null, una cadena de `Either` — y
te das cuenta de que es un problema con una sola forma de solución. Paga otra
vez cuando una librería te da un tipo con `flatMap` y puedes predecir, sin
leer el código, qué hará encadenarlo.

Y paga cuando eliges entre diseños: si tu tipo tiene `of` y `flatMap` y las
leyes se cumplen, quien lo use podrá refactorizar cadenas con libertad. Si
los tiene y las leyes no se cumplen, has construido una trampa. El capítulo 5
baja un piso hasta el functor y el capítulo 6 hasta el applicative, donde
vive buena parte del código práctico de validación.

## Ejercicios

1. `Set<A>` tiene `expand` y `{a}`. Comprueba las tres leyes con un paso cuyos
   resultados colisionen — por ejemplo `(x) => {x % 3}` sobre `{1, 2, 3, 4}`.
   ¿Es `Set` una mónada? ¿De qué depende tu respuesta?
2. Escribe `map` para `Either` usando solo `flatMap` y `Either.right`, y
   comprueba después que coincide con el `map` incorporado tanto sobre un
   `Right` como sobre un `Left`.
3. `Future` tiene `then`. ¿Es `Future.value(a).then(f)` realmente igual a
   `f(a)` — igual como *valores*, o solo en lo que acaban produciendo? ¿Qué
   te dice eso sobre qué igualdad enuncian las leyes?
4. Arregla `Logged` para que las tres leyes se cumplan, encadena después dos
   pasos en ambas agrupaciones y demuestra que las cuentas coinciden.

## Soluciones

1. **Sí, con una salvedad sobre la igualdad.** Las tres leyes se cumplen
   cuando la igualdad es la de conjuntos, porque `Set` descarta orden y
   duplicados a ambos lados de cada ley por igual.
   `{1,2,3,4}.expand((x) => {x % 3})` da `{1, 2, 0}` los agrupes como los
   agrupes. La salvedad es el punto: una ley se enuncia *sobre una igualdad*,
   y un tipo puede cumplirla bajo una noción de igualdad y no bajo otra —
   `List` bajo igualdad de conjuntos la cumple; `Set` bajo «mismo orden de
   inserción» no.
2. `Either<L, B> mapViaFlatMap<L, A, B>(Either<L, A> e, B Function(A) f) =>
   e.flatMap((a) => Either.right(f(a)));`. Sobre un `Left` ninguna de las dos
   versiones llama a `f`, que es la huella de la identidad por la izquierda
   en el lado del fallo.
3. No son el mismo objeto, y `==` sobre futures compara identidad, así que la
   ley se enuncia sobre igualdad *observacional*: los dos programas producen
   el mismo valor y los mismos efectos. Esa es la igualdad de la que hablan
   en realidad todas las leyes monádicas; las comprobaciones con `Either` de
   antes en el capítulo solo pudieron usar `==` porque `Either` define
   igualdad estructural.
4. Quita el `+ 1` de `flatMap` y deja que `double_` declare su propio coste:
   `Logged(next.value, steps + next.steps)`. Ahora `of` aporta el elemento
   identidad de `+`, encadenar no aporta nada por su cuenta, y las tres leyes
   se cumplen — `Logged.of(1).flatMap(f).flatMap(g)` y
   `Logged.of(1).flatMap((x) => f(x).flatMap(g))` informan ambos de 2.
