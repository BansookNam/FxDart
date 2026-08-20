---
slug: functions-as-values
chapter: 4
part: 1
title: Las funciones como valores
description: Composición, aplicación parcial y currificación — qué son, qué cuestan en un lenguaje sin genéricos variádicos, y por qué FxDart trae cadenas de métodos en lugar de un pipe currificado.
---
# Las funciones como valores

> **En este capítulo**
> - la composición como la operación que convierte dos funciones en una
> - la aplicación parcial y la currificación, y la diferencia entre ambas
> - por qué un `pipe` currificado fiel no se puede tipar en Dart
> - qué trae FxDart en su lugar, y el precio de esa elección

## Composición

Dos funciones encajan cuando la salida de una es la entrada de la otra, y
componerlas produce una tercera función que no menciona ningún valor
intermedio:

```dart run
import 'package:fxdart/fxdart.dart';

String trim(String s) => s.trim();
String upper(String s) => s.toUpperCase();

// Dart has no composition operator, so composition is a
// three-line helper. Its shortness is the point: the concept
// is small, only the notation is missing.
C Function(A) compose2<A, B, C>(
        B Function(A) f, C Function(B) g) =>
    (a) => g(f(a));

void main() {
  // By hand.
  String shout(String s) => upper(trim(s));
  print(shout('  hello  '));

  // As a value: the composition is itself passable.
  final shout2 = compose2(trim, upper);
  print(shout2('  hello  '));
  print(['  a ', ' b'].map(shout2).toList());

  // pipe1 is the same idea with the value supplied first.
  print(pipe1('  hi ', shout2));
}
```

La composición es asociativa — `(f ∘ g) ∘ h` es igual a `f ∘ (g ∘ h)` — y la
función identidad es su unidad. Eso es un monoide (capítulo 8), y es la razón
de que puedas agrupar las etapas de una tubería como quieras sin cambiar el
resultado. Es también la razón de que «extraer un ayudante» sea siempre
seguro: sacar tres pasos encadenados a una función con nombre es exactamente
la reagrupación que permite la ley.

## Aplicación parcial frente a currificación

Se usan como sinónimos y no son lo mismo.

- La **aplicación parcial** fija *algunos* argumentos ahora y toma el resto
  después: `add(2, _)` se convierte en una función de un argumento.
- La **currificación** reescribe una función de *n* argumentos como *n*
  funciones anidadas de un argumento: `int Function(int, int)` se convierte en
  `int Function(int) Function(int)`. La aplicación parcial es entonces solo
  llamar a la primera capa.

```dart run
import 'package:fxdart/fxdart.dart';

int addTwo(int a, int b) => a + b;

void main() {
  // Currying: one call per argument.
  final curriedAdd = addTwo.curried;
  final add10 = curriedAdd(10);
  print([add10(5), add10(32)]);

  // Partial application without currying: a closure does it too.
  int Function(int) addAlso(int a) => (b) => a + b;
  print(addAlso(10)(32));

  // Uncurrying goes back.
  print(curriedAdd.uncurried(40, 2));
}
```

![Composición y currificación](diagrams/t4-1-compose-curry.svg)

*Figura 4-1. La composición une dos máquinas de extremo a extremo y esconde la unión. La currificación recoloca una máquina de dos entradas como dos máquinas de una entrada cada una.*

## Por qué el `pipe` de FxTS no se pudo portar

FxTS está construido sobre un `pipe` currificado: cada operador es una función
que toma su callback y devuelve una función a la espera de los datos, y `pipe`
hace pasar un valor por una lista de ellas. TypeScript lo tipa con unas 20
sobrecargas escritas a mano, una por aridad, y tipos de tupla variádicos para
relacionarlas.

Dart no tiene sobrecargas ni genéricos variádicos. Un `pipe` que acepte
cualquier número de etapas tiene que recurrir a `dynamic`:

```dart
// FxDart ships this for FxTS parity — and every stage boundary
// is an unchecked cast.
final result = pipe(
  [1, 2, 3, 4],
  (dynamic xs) =>
      map((dynamic n) => (n as int) * 2, xs as Iterable),
  (dynamic xs) => toList(xs as Iterable<int>),
);
```

Cada frontera de etapa es un cast sin comprobar. El error de tipos que querías
que atrapara el compilador — una etapa `String` en una tubería de `int` —
llega ahora en tiempo de ejecución, en mitad de un iterador perezoso, con una
traza que apunta a las tripas de la librería.

Así que FxDart eligió otra forma para la misma idea:

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  final result = fx([1, 2, 3, 4, 5, 6])
      .map((n) => n * 2)
      .filter((n) => n > 4)
      .take(3)
      .toList();
  print(result);
}
```

La cadena es una composición *tipada*: cada método devuelve `Fx<R>` con el
nuevo tipo de elemento, así que el compilador sigue el valor hasta el final y
tu editor puede autocompletarlo. Lo que renuncia es a poder sostener una etapa
como valor de primera clase y pasarla por ahí — en FxTS, `map(f)` por sí solo
es un valor; en FxDart es una llamada a método que necesita un receptor.
`WHY_CURRIED.md` en el repositorio recoge ese intercambio al completo.

> 🎓 **La currificación es un isomorfismo, no una convención.** `(A, B) → C` y
> `A → (B → C)` llevan exactamente la misma información — puedes convertir en
> cualquier dirección sin pérdida, que es lo que demuestran `.curried` /
> `.uncurried` en tiempo de ejecución. Los lenguajes que currifican por
> defecto (Haskell, OCaml) eligieron un lado del isomorfismo como primitivo;
> Dart eligió el otro. Nada expresable en uno deja de serlo en el otro — solo
> difiere la ergonomía, y la ergonomía es justo por lo que importa la
> elección.

## Funciones de orden superior que ya usas

Una función que toma o devuelve funciones es de **orden superior**, y el
vocabulario de las tuberías no es otra cosa que funciones de orden superior:
`map`, `filter`, `fold`, `sortBy` toman comportamiento como argumento. Dos más
de FxDart que conviene conocer por su nombre:

```dart run
import 'package:fxdart/fxdart.dart';

bool small(int n) => n < 10;
bool odd(int n) => n.isOdd;

void main() {
  // juxt: one input, several functions, all their results.
  final stats = juxt([
    (Iterable<int> xs) => xs.length,
    (Iterable<int> xs) => xs.reduce((a, b) => a + b),
  ]);
  print(stats([3, 1, 4, 1, 5]));

  // Predicates are values too, so they combine.
  final both = (int n) => small(n) && odd(n);
  print(fx([3, 12, 7, 20]).filter(both).toList());
  print(fx([3, 12, 7, 20]).filter(negate(small)).toList());
}
```

## Cuándo se gana el sueldo

Tratar las funciones como valores paga cuando el comportamiento varía pero la
estructura no — una tubería, cuatro políticas pasadas por argumento; un
validador compuesto de reglas pequeñas con nombre. Paga también a la hora de
probar: un parámetro de función es la costura más barata que existe, y no
necesita ningún framework de mocks.

Deja de pagar cuando la composición se hace más larga que aquello que
sustituyó. Una cadena de seis combinadores sin puntos que quien lee tiene que
aplicar mentalmente a un valor es peor que un bucle `for` con un buen nombre.
La falta de un operador de composición en Dart hace que ese umbral llegue
antes que en Haskell, y fingir lo contrario es cómo el código funcional se
gana su fama.

## Ejercicios

1. `compose2(f, g)` aplica `f` primero. El operador `.` de Haskell aplica
   primero la función de la *derecha*. ¿Qué orden usa `fx(...).map(f).map(g)`,
   y por qué es la única elección sensata para una cadena de métodos?
2. Escribe `compose3` para tres funciones de un argumento usando `compose2`
   dos veces. Argumenta después que las dos formas de agrupar las llamadas dan
   la misma función.
3. `addTwo.curried(10)` devuelve una función. ¿Cuál es su tipo, escrito por
   completo? ¿Por qué Dart no puede inferir un getter `curried` para una
   función de aridad arbitraria?
4. Reescribe `fx(xs).filter(small).filter(odd)` como un único `filter`. ¿Es
   siempre un refactor seguro? ¿De qué propiedad de `filter` depende?

## Soluciones

1. La cadena aplica de izquierda a derecha: `map(f)` y luego `map(g)`,
   siguiendo el orden de lectura. Una cadena de métodos no puede hacer otra
   cosa — el receptor está a la izquierda, así que lo primero escrito es lo
   primero aplicado. El `.` de Haskell se lee de derecha a izquierda porque
   refleja el `f ∘ g` matemático; ambos son coherentes, y mezclarlos en un
   mismo código es el peligro real.
2. `D Function(A) compose3<A, B, C, D>(...)` construido como
   `compose2(compose2(f, g), h)` o `compose2(f, compose2(g, h))`. La misma
   función porque la composición es asociativa — la misma ley que te deja
   reagrupar etapas de una tubería, y la misma forma que la asociatividad
   monádica del capítulo 1.
3. `int Function(int)`. Dart no puede expresar «una función de cualquier
   aridad» como parámetro de tipo, así que `curried` está escrito una vez por
   aridad — extensiones `Curry2` a `Curry5` sobre `R Function(A, B)`,
   `R Function(A, B, C)`, etcétera. Es el mismo muro que los genéricos
   variádicos ausentes en `pipe`, y el mismo muro que los tipos de orden
   superior del capítulo 10: el sistema de tipos de Dart es deliberadamente de
   primer orden.
4. `fx(xs).filter((n) => small(n) && odd(n))`. Es seguro cuando los predicados
   son puros — la versión fusionada llama a `small` y a `odd` sobre el mismo
   elemento en el mismo orden, y cortocircuita igual. Si un predicado tiene un
   efecto colateral (contar cuántos elementos vio, digamos), las dos versiones
   difieren: la forma encadenada ejecuta `odd` solo sobre los supervivientes, y
   la fusionada también, pero un efecto ordenado *entre* los dos filtros se
   movería. La pureza es lo que convierte la fusión en un refactor y no en una
   reescritura.
