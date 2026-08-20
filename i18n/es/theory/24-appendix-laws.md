---
slug: laws
chapter: 0
part: 6
title: Apéndice B · Referencia de leyes
description: Cada ley del libro en páginas enfrentadas — qué dice, qué te permite hacer, y cómo comprobarla.
---
# Apéndice B · Referencia de leyes

Cada ley, en una línea de código, con el refactor que permite. Todo lo que hay
aquí es comprobable tal como lo comprobó el capítulo 19: genera entradas,
comprueba la ecuación.

## Functor — capítulo 5

| Ley | Ecuación |
|---|---|
| Identidad | `m.map((x) => x)` == `m` |
| Composición | `m.map(f).map(g)` == `m.map((x) => g(f(x)))` |

**Permite:** eliminar un `map` que no hace nada; fusionar dos `map` en una
sola pasada; dividir un `map` en dos por legibilidad.

**Se rompe cuando:** `map` hace algo además de aplicar la función — contar,
registrar, cachear, reordenar (`Counted` en el capítulo 5).

## Mónada — capítulo 1

| Ley | Ecuación |
|---|---|
| Identidad por la izquierda | `of(a).flatMap(f)` == `f(a)` |
| Identidad por la derecha | `m.flatMap(of)` == `m` |
| Asociatividad | `m.flatMap(f).flatMap(g)` == `m.flatMap((x) => f(x).flatMap(g))` |

**Permite:** insertar en línea un valor envuelto; eliminar un paso que no hace
nada; reagrupar una cadena — que es lo que hace «extrae esto en una función
auxiliar».

**Se rompe cuando:** el propio encadenamiento tiene un coste que el tipo
registra (`Logged` en el capítulo 1).

**Corolario:** `m.map(f)` == `m.flatMap((x) => of(f(x)))` — toda mónada legal
es un functor legal.

## Applicative — capítulo 6

| Ley | Ecuación |
|---|---|
| Identidad | `of(id).ap(m)` == `m` |
| Homomorfismo | `of(f).ap(of(a))` == `of(f(a))` |
| Intercambio | `u.ap(of(a))` == `of((f) => f(a)).ap(u)` |
| Composición | `of(compose).ap(u).ap(v).ap(w)` == `u.ap(v.ap(w))` |

En términos de `map2`, la consecuencia útil es: `map2` debe ejecutar *ambas*
estructuras y combinarlas, nunca inspeccionar una para decidir sobre la otra.

**Permite:** ejecutar ramas independientes de forma concurrente; acumular sus
fallos; reordenar ramas independientes (los resultados se combinan igual).

**Se rompe cuando:** las ramas «independientes» dependen en secreto una de
otra — el estado mutable compartido en una rama de validación es el culpable
habitual.

## Monoide / semigrupo — capítulo 8

| Ley | Ecuación |
|---|---|
| Asociatividad | `(a + b) + c` == `a + (b + c)` |
| Identidad por la izquierda | `empty + a` == `a` |
| Identidad por la derecha | `a + empty` == `a` |

**Permite:** trocear un fold; la reducción paralela o incremental; usar la
identidad como semilla de `fold` para que el caso vacío sea total.

**Se rompe cuando:** la operación tiene forma de resta, o la «identidad» se
adivina a partir del tipo en lugar de la operación (`0` para la
multiplicación).

**No implica:** conmutatividad — `a + b` == `b + a` es una ley *distinta* y
más fuerte que la mayoría de los monoides útiles no tienen.

## Traverse — capítulo 9

| Ley | Enunciado |
|---|---|
| Identidad | recorrer con el applicative identidad es `map` |
| Composición | recorrer con dos applicatives en secuencia == recorrer una vez con su composición |
| Naturalidad | una transformación natural conmuta con `traverse` |

**Permite:** elegir dónde recorrer dentro de una cadena; cambiar de fallo
rápido a acumulación sin tocar la función por elemento.

## Transformación natural — capítulo 20

| Ley | Ecuación |
|---|---|
| Naturalidad | `α(m.map(f))` == `α(m).map(f)` |

**Permite:** mover una conversión (`toList`, `toAsync`, `toNullable`, `first`)
a través de un `map`, en cualquier dirección.

**Se rompe cuando:** la conversión inspecciona los valores — `sortBy` es el
contraejemplo estándar.

## Categoría — capítulo 20

| Ley | Ecuación |
|---|---|
| Asociatividad | `(h ∘ g) ∘ f` == `h ∘ (g ∘ f)` |
| Identidad | `id ∘ f` == `f` == `f ∘ id` |

**Permite:** extraer o insertar en línea cualquier composición de funciones
puras, incluidas las etapas de una tubería.

## Las condiciones previas detrás de todas ellas

1. **Pureza.** Toda ley anterior se enuncia sobre valores; un efecto convierte
   dos valores iguales en dos programas distintos (capítulo 2).
2. **La igualdad correcta.** Estructural para `Either` y `Money`;
   observacional para `Future`; igualdad de conjuntos para `Set`. Una ley
   puede cumplirse bajo una y fallar bajo otra (capítulo 19).
3. **Alguien lo comprobó.** Las leyes de un tipo son una afirmación. Hasta que
   existe un test de propiedades, son un comentario (capítulo 19).

## Plantilla de prueba

```dart run
import 'package:fxdart/fxdart.dart';

// Generate → assert the equation → report. The seed is fixed so
// a failure can be reproduced exactly.
void main() {
  final rnd = createSeededRandom(7);
  final inputs = List.generate(100, (_) => (rnd() * 100).floor());

  Either<String, int> f(int n) =>
      n.isEven ? Either.right(n ~/ 2) : Either.left('odd');
  Either<String, int> g(int n) => Either.right(n + 1);

  var violations = 0;
  for (final x in inputs) {
    final m = Either<String, int>.right(x);
    if (m.map((v) => v) != m) violations++;
    final lifted = Either<String, int>.right(x);
    if (lifted.flatMap(f) != f(x)) violations++;
    if (m.flatMap(f).flatMap(g) !=
        m.flatMap((v) => f(v).flatMap(g))) {
      violations++;
    }
  }
  print('violations: $violations');
}
```
