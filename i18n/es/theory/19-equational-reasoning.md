---
slug: equational-reasoning
chapter: 19
part: 5
title: Razonamiento ecuacional
description: Refactorizar como sustitución — usar las leyes de la Parte II para transformar código que puedes probar equivalente, y convertir esas mismas leyes en property tests que corren en CI.
---
# Razonamiento ecuacional

> **En este capítulo**
> - refactorizar como una cadena de sustituciones, cada una justificada por una ley con nombre
> - una transformación resuelta: cinco etapas reducidas a dos, sobre el papel
> - leyes como property tests, con un generador y sin framework de testing
> - las precondiciones que hacen válido todo el método, y cómo fallan

## Refactorizar es sustitución

El capítulo 2 definió la transparencia referencial: una llamada puede
reemplazarse por su resultado. Su hermano mayor es el **razonamiento
ecuacional** — reemplazar cualquier expresión por una igual, en cualquier
lugar, y saber que el programa no cambió.

Cada ley de la Parte II es una ecuación de este tipo:

| Ley | Ecuación |
|---|---|
| Composición de functor | `m.map(f).map(g)` = `m.map(g ∘ f)` |
| Identidad de functor | `m.map(id)` = `m` |
| Identidad izquierda de mónada | `of(a).flatMap(f)` = `f(a)` |
| Asociatividad de mónada | `m.flatMap(f).flatMap(g)` = `m.flatMap((x) => f(x).flatMap(g))` |
| Asociatividad de monoide | `(a + b) + c` = `a + (b + c)` |

Leídas de izquierda a derecha son optimizaciones; de derecha a izquierda son
clarificaciones. Ambas direcciones son legales, que es lo que las convierte
en una *herramienta* y no en un simple hecho.

## Una transformación resuelta

Empieza con código que nadie defendería:

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  final source = [3, 8, 2, 9, 4];

  // Before: five stages, two of them pointless.
  final before = fx(source)
      .map((n) => n)
      .map((n) => n * 2)
      .map((n) => n + 1)
      .filter((n) => n > 5)
      .fold(0, (a, b) => a + b);

  // After: two stages. Same value, by four substitutions.
  final after = fx(source)
      .map((n) => n * 2 + 1)
      .filter((n) => n > 5)
      .fold(0, (a, b) => a + b);

  print([before, after, before == after]);
}
```

Los cuatro pasos, cada uno con su licencia:

1. `map((n) => n)` es `map(id)` → elimínalo. **Identidad de functor.**
2. `map(f).map(g)` → `map(g ∘ f)`, dando `map((n) => n * 2 + 1)`.
   **Composición de functor.**
3. Nada se movió a través del `filter`, porque el predicado lee el valor *ya
   mapeado* — ese reordenamiento necesitaría una precondición que no
   tenemos.
4. El `fold` queda intacto; `+` sobre `int` es asociativo con identidad `0`,
   así que la semilla es genuinamente el `empty` del monoide. **Leyes de
   monoide.**

Dos cosas vale la pena notar. Primero, la transformación es mecánica — no
hace falta ingenio ni testear para creérsela. Segundo, el paso 3 es donde una
"simplificación" descuidada introduciría un bug, y la ley es lo que te dice
que pares.

![Refactorizar como una cadena de reescrituras con licencia](diagrams/t19-1-rewrite-chain.svg)

*Figura 19-1. Cada flecha es una reescritura con nombre. Si no puedes nombrar
la ley, no estás refactorizando — estás reescribiendo y esperando.*

## Leyes como tests

Una ley es una propiedad, y una propiedad es un test que puedes correr sobre
muchas entradas. No hace falta ningún framework para demostrarlo:

```dart run
import 'package:fxdart/fxdart.dart';

// A tiny generator: deterministic, so a failure is reproducible.
List<int> sample(int n, int seed) {
  final rnd = createSeededRandom(seed);
  return List.generate(n, (_) => (rnd() * 200).floor() - 100);
}

Either<String, int> half(int n) =>
    n.isEven ? Either.right(n ~/ 2) : Either.left('odd: $n');

Either<String, int> dec(int n) => Either.right(n - 1);

void main() {
  var checked = 0;
  var failures = 0;

  for (final x in sample(200, 42)) {
    final m = Either<String, int>.right(x);

    // functor identity
    if (m.map((v) => v) != m) failures++;
    // monad left identity
    if (Either<String, int>.right(x).flatMap(half) != half(x)) {
      failures++;
    }
    // monad right identity
    if (m.flatMap((v) => Either<String, int>.right(v)) != m) {
      failures++;
    }
    // associativity
    final lhs = m.flatMap(half).flatMap(dec);
    final rhs = m.flatMap((v) => half(v).flatMap(dec));
    if (lhs != rhs) failures++;

    checked += 4;
  }

  print('$checked properties checked, $failures failures');
}
```

Doscientas entradas, cuatro leyes, una línea de salida. En una suite real
esto se convierte en un archivo de `package:test` (o `package:glados` para
shrinking), pero la forma no cambia: **generar entradas, afirmar una
ecuación, correr en cada commit.**

La razón para molestarse no es que el `Either` de FxDart pueda estar mal. Es
que *tus* tipos también tienen leyes — el `Money` que nunca debe volverse
negativo, el `Cache` cuyo `get` después de `put` debe devolver lo que
pusiste — y son exactamente así de testeables, con muchos más bugs por
encontrar.

```dart run
// A property test for a type of your own.
class Money {
  const Money(this.cents);
  final int cents;

  Money operator +(Money other) => Money(cents + other.cents);
  static const zero = Money(0);

  @override
  bool operator ==(Object o) => o is Money && o.cents == cents;
  @override
  int get hashCode => cents;
}

void main() {
  final values =
      [0, 1, 99, 100, -50, 123456].map(Money.new).toList();
  var bad = 0;

  for (final a in values) {
    // identity
    if (a + Money.zero != a) bad++;
    if (Money.zero + a != a) bad++;
    for (final b in values) {
      for (final c in values) {
        // associativity
        if ((a + b) + c != a + (b + c)) bad++;
      }
    }
  }

  print('monoid violations: $bad');
}
```

## Las precondiciones

El razonamiento ecuacional funciona cuando lo igual es realmente igual, y hay
exactamente tres formas de que eso falle:

1. **Impureza.** Si un callback registra, muta, o lee el reloj, dos
   expresiones con el mismo valor no son el mismo programa. Capítulo 2.
2. **La igualdad equivocada.** Las leyes se enuncian *sobre una igualdad*:
   estructural para `Either`, observacional para `Future`, igualdad de
   conjunto para `Set`. Una ley puede valer bajo una y fallar bajo otra — el
   ejercicio del capítulo 1 lo hizo concreto.
3. **Un tipo que no obedece.** `Counted` en el capítulo 5 y `Logged` en el
   capítulo 1 tenían ambos un `map`/`flatMap` con pinta de legal y rompían
   una ley. Leer el nombre no basta; las leyes son una afirmación que alguien
   tiene que haber comprobado.

Ese tercer punto es por qué el test de este capítulo no es académico. Una ley
que no has testeado es un comentario.

> 🎓 **Hasta dónde llega esto.** En un lenguaje total y puro el método
> escala hasta la demostración: la fusión `foldr/build` de Haskell, la
> extracción de Coq, y las reglas de reescritura de GHC son todas
> razonamiento ecuacional ejecutado por una máquina en tu nombre. Dart no es
> ni total ni puro, así que el método sigue siendo una herramienta *humana*
> más tests. Esa es una diferencia real de fuerza, no de tipo: las mismas
> ecuaciones, comprobadas por muestreo en vez de por demostración, que es la
> misma relación que los property tests tienen con las demostraciones en
> todas partes.

## Cuándo se gana el sueldo

Cada vez que simplificas una tubería, extraes un helper, o fusionas dos
etapas por rendimiento — ese es el método de este capítulo, lo nombres o no.
Nombrarlo es lo que convierte "creo que esto es lo mismo" en "esto es lo
mismo, y aquí está el porqué".

Paga más fuerte en revisión: "¿qué ley te permite mover ese `filter` antes
del `map`?" es una pregunta que o tiene respuesta o encontró un bug.

No paga como ceremonia en código que no tiene leyes a las que apelar —
configuración imperativa, secuenciación de IO, callbacks de UI. Ahí, el
razonamiento es sobre estado y orden, y las ecuaciones no tienen nada que
decir.

## Ejercicios

1. ¿Es `fx(xs).filter(p).map(f)` igual a `fx(xs).map(f).filter(p)`? Enuncia
   la precondición con precisión, y luego da un `p` y una `f` que la rompan.
2. Justifica `xs.map(f).toList().map(g).toList()` → `xs.map((x) => g(f(x)))
   .toList()` paso a paso. ¿Qué paso también cambia el costo?
3. Extiende el property test para comprobar que `map` y `flatMap` coinciden:
   `m.map(f)` == `m.flatMap((x) => Either.right(f(x)))`. ¿Qué ley hace esto
   cierto para toda mónada legal?
4. Tu `Cache` tiene `put` seguido de `get` devolviendo el valor puesto.
   Escribe eso como una ecuación, y di qué implica la ecuación sobre el tipo
   de retorno de `put`.

## Soluciones

1. No en general. Solo vale cuando `p` es un predicado sobre el valor *sin
   mapear* — es decir, cuando la versión tras el intercambio testea lo
   mismo. Rómpelo con `f = (n) => n * 2` y `p = (n) => n > 5`: filtrar
   primero conserva 6, 7, 8…, mapear primero conserva 3, 4… duplicados. Las
   dos respuestas difieren porque `p` se escribió para un tipo de valor
   distinto.
2. Elimina el `toList()` intermedio (una materialización, no un paso
   semántico); aplica composición de functor para fusionar los dos `map`;
   conserva el `toList()` final. El costo cambia en el primer paso: una
   lista intermedia desaparece, que es el mecanismo de asignación del
   capítulo 14 apareciendo en un refactor.
3. Es la definición de `map` en términos de `flatMap` más la **identidad
   izquierda**: `flatMap((x) => of(f(x)))` aplicado a un `Right(a)` da
   `of(f(a))`, que es `Right(f(a))`, que es `map(f)`. Toda mónada legal la
   satisface, que es por qué "toda mónada es un functor" es un teorema y no
   una convención.
4. `cache.put(k, v).get(k) == v` — y nota que la ecuación solo *tipa* si
   `put` devuelve el caché. Un `put` de tipo `void` deja la propiedad
   inenunciable sin hablar de mutación y orden, que es la misma razón por la
   que las APIs inmutables son más fáciles de testear: las ecuaciones
   necesitan valores en ambos lados.
