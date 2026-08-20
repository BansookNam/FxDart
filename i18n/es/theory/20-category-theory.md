---
slug: category-theory
chapter: 20
part: 5
title: Teoría de categorías, en la dosis correcta
description: El vocabulario detrás del vocabulario — objetos, morfismos, functores, transformaciones naturales y mónadas — presentado solo hasta donde explica cosas que ya has usado, y ni un paso más.
---
# Teoría de categorías, en la dosis correcta

> **En este capítulo**
> - qué es una categoría, en cuatro líneas, con Dart como ejemplo
> - functores y transformaciones naturales, y cuál código Dart es cuál
> - la definición de mónada en su forma original, y cómo se relaciona con `flatMap`
> - la frase famosa, decodificada — y por qué no la necesitabas

Este capítulo es saltable. Todo lo que nombra ya lo has usado; nada de él
cambiará cómo escribes Dart. Léelo si quieres el mapa que conecta las partes,
o para poder leer un paper sin tropezar con la notación.

## Una categoría, en cuatro líneas

Una **categoría** es:

1. una colección de **objetos**;
2. para cada par de objetos, una colección de **morfismos** (flechas) entre
   ellos;
3. una operación de **composición**: dados `f : A → B` y `g : B → C`, una
   flecha `g ∘ f : A → C`;
4. una flecha de **identidad** `id_A : A → A` para cada objeto.

Sujeto a dos leyes: la composición es asociativa, y la identidad es neutra.

Esa es toda la definición, y Dart es un ejemplo de ella. Los objetos son
tipos; los morfismos son funciones; la composición es lo que el capítulo 4
escribió como `compose2`; las identidades son `(x) => x`. Las dos leyes de
categoría son los dos hechos en los que el capítulo 4 se apoyó sin
ceremonia.

![Objetos, flechas, y las dos leyes](diagrams/t20-1-category.svg)

*Figura 20-1. Una categoría es flechas que componen. Nada sobre "elementos"
aparece en la definición — que es exactamente por qué la misma teoría cubre
tipos, y también conjuntos, espacios, y órdenes.*

El paso que hace tropezar a la gente es que una categoría *olvida de qué
están hechos los objetos*. `int` no es un conjunto de números aquí; es un
punto con flechas que salen de él. Cada teorema de la materia es por tanto
un enunciado sobre la *forma de la composición*, y por eso se transfiere a
la programación en absoluto.

## Functores, otra vez

Un **functor** `F` entre categorías mapea objetos a objetos y flechas a
flechas, preservando identidad y composición:

```
F(id_A)   = id_F(A)
F(g ∘ f)  = F(g) ∘ F(f)
```

Esas son precisamente las dos leyes del capítulo 5. En programación usamos
*endo*functores: `F` mapea la categoría de los tipos de Dart a sí misma.
`List` envía el objeto `int` al objeto `List<int>`, y envía la flecha
`int → String` a la flecha `List<int> → List<String>` — esta última es
`map`.

Así que `map` es la mitad-flecha de un functor, y la razón por la que no
debe cambiar la estructura es que un functor se *define* como aquello que
la preserva.

## Transformaciones naturales

Dados dos functores `F` y `G`, una **transformación natural** `α : F ⇒ G`
es una familia de flechas `α_A : F(A) → G(A)`, una por tipo, que satisface:

```
α_B ∘ F(f)  =  G(f) ∘ α_A
```

En Dart: una función genérica que cambia el *contenedor* sin tocar el
contenido, y que conmuta con `map`. Has escrito varias:

```dart run
import 'package:fxdart/fxdart.dart';

// A natural transformation: Either<E, _> ⇒ Option-ish (_?)
A? toNullable<E, A>(Either<E, A> e) =>
    e.fold((_) => null, (a) => a);

void main() {
  int f(int n) => n * 3;

  final r = Either<String, int>.right(7);
  final l = Either<String, int>.left('nope');

  // naturality: map then transform == transform then map
  print([toNullable(r.map(f)), toNullable(r)?.let(f)]);
  print([toNullable(l.map(f)), toNullable(l)?.let(f)]);
}

extension Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
```

Ambos lados coinciden, en ambos casos — eso es naturalidad, y es el
enunciado formal de "esta conversión no mira los valores". `toList()`,
`toAsync()`, `first`, `sequence` y `flatten` son todas transformaciones
naturales, que es por qué ninguna puede sorprender: no pueden depender del
contenido que están moviendo.

## La mónada, con su ropa original

Una mónada sobre una categoría **C** es una tripla `(T, η, μ)`:

- `T` — un endofunctor;
- `η : Id ⇒ T` — una transformación natural, "unidad";
- `μ : T² ⇒ T` — una transformación natural, "multiplicación" o "join";

que satisface tres condiciones de coherencia:

```
μ ∘ T(μ)  = μ ∘ μ_T          (associativity)
μ ∘ T(η)  = id  =  μ ∘ η_T   (unit, both sides)
```

Traducido:

| Teoría de categorías | Dart |
|---|---|
| `T` | el constructor de tipo — `Either<E, _>`, `List`, `Future` |
| `η` (unidad) | `of` / `Either.right` / `[x]` / `Future.value` |
| `μ` (join) | `flatten` — `List<List<A>> → List<A>` |
| `flatMap(f)` | `μ ∘ T(f)` — map, y luego flatten |
| las condiciones de coherencia | las tres leyes del capítulo 1 |

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  // μ: T² ⇒ T. Dart spells it `flat` / `expand(id)`.
  final nested = [
    [1, 2],
    [3],
    [4, 5]
  ];
  print(fx(nested).flat().toList());

  // flatMap = μ ∘ T(f): map to a nested structure, then join.
  int f(int n) => n;
  final viaMapThenJoin =
      fx([1, 2, 3]).map((n) => [n, n * 10]).flat().toList();
  final viaFlatMap =
      fx([1, 2, 3]).flatMap((n) => [n, n * 10]).toList();
  print([viaMapThenJoin, viaFlatMap, f(1)]);
}
```

Las dos definiciones — `flatMap` frente a `map` + `join` — son
intercambiables, que es por qué algunos lenguajes te dan una y otros la
otra, y por qué el capítulo 1 pudo definir la mónada sin mencionar `μ` en
absoluto.

## La frase famosa

> *Una mónada es un monoide en la categoría de los endofunctores.*

Ahora tienes todas las piezas:

- Los **endofunctores** sobre los tipos de Dart forman una categoría: los
  objetos son functores como `List` y `Future`, las flechas son
  transformaciones naturales entre ellos.
- Esa categoría tiene una forma de combinar dos objetos: la **composición**
  de functores (`F` y luego `G`), que juega el papel de la multiplicación.
- El functor identidad juega el papel de la unidad.
- Un **monoide** ahí es un objeto `T` con `μ : T ∘ T ⇒ T` (combinar) y
  `η : Id ⇒ T` (unidad), obedeciendo asociatividad e identidad — las dos
  leyes del capítulo 8, un nivel más arriba.

Que es exactamente la definición de arriba. La frase es *cierta*, *precisa*,
e inútil como primera explicación — define el caso especial señalando al
caso general, que es el orden correcto para las matemáticas y el
equivocado para aprender.

> 🎓 **Lo que compra la teoría, honestamente.** No código — has escrito
> cada construcción de este libro sin ella. Lo que compra es *transferencia*:
> los mismos teoremas se aplican a parsers, distribuciones de probabilidad,
> sistemas de build y máquinas de estados, así que un resultado probado una
> vez está disponible en todas partes. Y compra un vocabulario lo bastante
> preciso como para que dos personas puedan discrepar productivamente. Si
> quieres ir más allá, los siguientes objetos útiles son las adjunciones
> (que explican por qué `flatMap` y `map` vienen en pares) y las mónadas
> libres (que explican los intérpretes); ninguna es necesaria para nada de
> la Parte I a la IV.

## Cuándo se gana el sueldo

Leyendo. Papers, librerías de Haskell, Cats de Scala, y cualquier discusión
donde alguien diga "eso es solo una transformación natural" — este
capítulo es el anillo decodificador para eso.

También nombrando. Una vez que puedes decir "esta conversión es natural",
tienes una forma precisa de enunciar una regla de diseño ("no debe
inspeccionar el contenido") que ninguna cantidad de prosa en un comentario
de documentación logra.

No se gana el sueldo en la revisión de código, en los mensajes de commit,
ni en conversación con un colega que no lo ha leído. El vocabulario es una
herramienta para pensar, y usarlo como credencial es cómo la materia se
ganó su reputación.

## Ejercicios

1. Demuestra que los tipos y funciones de Dart sí satisfacen las dos leyes
   de categoría. ¿En qué te estás apoyando en realidad sobre `compose2`?
2. ¿Es `List.reversed` una transformación natural de `List` a `List`?
   Comprueba la naturalidad con `f = (n) => n * 2`, y luego di qué la hace
   natural pese a cambiar el orden.
3. `first` mapea `List<A>` a `A?`. ¿Es natural? ¿Y `sortBy`, que mapea
   `List<A>` a `List<A>`?
4. Escribe `flatMap` como `μ ∘ T(f)` para `Either<E, _>`. ¿Qué es `μ` para
   `Either`, concretamente?

## Soluciones

1. Asociatividad: `compose2(compose2(f, g), h)` y `compose2(f, compose2(g,
   h))` ambos llaman a `h(g(f(x)))`. Identidad: `compose2(id, f)` y
   `compose2(f, id)` ambos llaman a `f(x)`. Te estás apoyando en que
   `compose2` sea *solo* aplicación — sin logging, sin memoización, sin
   nada extra. Un `compose2` impuro rompería las leyes de categoría, que es
   la misma observación que hizo el capítulo 2 sobre la sustitución.
2. Sí. `xs.map(f).reversed` y `xs.reversed.map(f)` dan la misma lista,
   porque `reversed` reordena posiciones sin consultar los valores. Natural
   no significa "que preserva la estructura" en el sentido de orden —
   significa "independiente del contenido", y una permutación califica.
3. `first` es natural: `xs.map(f).first` equivale a `f(xs.first)` cuando no
   está vacía, y ambas están ausentes cuando lo está. `sortBy` *no* lo es —
   inspecciona los valores para decidir el orden, así que
   `xs.map(f).sortBy(k)` y `xs.sortBy(k).map(f)` difieren en general. Esa
   es la prueba más clara de una línea para la naturalidad: ¿mira el
   contenido?
4. `μ : Either<E, Either<E, A>> → Either<E, A>` colapsa las dos capas —
   `Left(e)` sigue siendo `Left(e)`, `Right(Left(e))` se vuelve `Left(e)`,
   `Right(Right(a))` se vuelve `Right(a)`. Entonces `flatMap(f)` es
   `map(f)` seguido de ese colapso, que es exactamente lo que hace la
   implementación cuando hace pattern-matching sobre ambos niveles.
