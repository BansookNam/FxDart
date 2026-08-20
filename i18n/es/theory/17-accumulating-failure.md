---
slug: accumulating-failure
chapter: 17
part: 4
title: Acumulando el fallo
description: Recoger cada motivo en vez del primero — el vocabulario (Nel, zipOrAccumulate, mapOrAccumulate, dependent), las reglas que lo mantienen honesto, y una validación de formulario completa trabajada de principio a fin.
---
# Acumulando el fallo

> **En este capítulo**
> - la pregunta de producto que decide entre fallo rápido y fallo lento
> - las cuatro herramientas, y cuál encaja con qué forma de validación
> - reglas independientes y dependientes, y por qué mezclarlas mal es el bug
>   clásico
> - una validación de formulario completa, desde cadenas en bruto hasta un tipo
>   de dominio

## La pregunta de producto

El capítulo 6 estableció que solo la forma aplicativa *puede* acumular. Este
capítulo trata de cuándo *debería*, y la prueba no tiene nada que ver con
tipos:

> ¿Va a leer un humano estos errores y arreglarlos en una sola pasada?

Si sí — un formulario, un archivo de configuración, una importación, el cuerpo
de una petición de API — recógelos todos. Decirle a alguien que su código
postal está mal, esperar un viaje de ida y vuelta, y luego decirle que su
número de teléfono está mal es un mal producto, no un mal programa.

Si no — una cadena de pasos internos, una comprobación de autorización,
cualquier cosa donde el segundo fallo es una *consecuencia* del primero —
falla rápido. Diez errores en cascada de una sola causa raíz son ruido, y
esconden el que importaba.

## Las cuatro herramientas

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parseAge(String s) {
  final n = int.tryParse(s);
  return n == null
      ? Either.left('age: not a number')
      : Either.right(n);
}

void main() {
  final raw = ['31', 'x', '44', 'y'];

  // 1. zipOrAccumulate2..5 — a fixed set of independent branches.
  print(either<Nel<String>, String>((r) => r.zipOrAccumulate2(
        (br) {
          if (raw[1] != '0') br.raise('second must be 0');
          return raw[1];
        },
        (br) {
          if (raw[3] != '0') br.raise('fourth must be 0');
          return raw[3];
        },
        (a, b) => '$a/$b',
      )));

  // 2. mapOrAccumulate — the same rule over many items.
  print(mapOrAccumulate(
      (r, String s) => r.bind(parseAge(s)), raw));

  // 3. flattenOrAccumulate — you already have the Eithers.
  print(fx(raw).map(parseAge).flattenOrAccumulate());

  // 4. accumulate — the general scope, any number of branches,
  //    and the only one that supports dependent rules.
  print(either<Nel<String>, int>((r) => r.accumulate((acc) {
        final first = acc.accumulating(
            (br) => br.bind(parseAge(raw[0])));
        final third = acc.accumulating(
            (br) => br.bind(parseAge(raw[2])));
        return first.value + third.value;
      })));
}
```

Elegir entre ellas es mecánico:

| Forma | Herramienta |
|---|---|
| 2–5 campos nombrados e independientes | `zipOrAccumulate2..5` |
| Una regla, muchos elementos | `mapOrAccumulate` |
| Ya tienes `Either`s | `flattenOrAccumulate` / `.flattenOrAccumulate()` |
| Más de cinco ramas, o reglas dependientes | `accumulate` |

## Independiente, luego dependiente

La regla que hace correcta la acumulación es la distinción del capítulo 6, y
tiene una forma de API precisa:

- `acc.accumulating(...)` — una rama **independiente**. Siempre se ejecuta; sus
  fallos se registran en vez de propagarse.
- `acc.dependent(...)` — una regla **dependiente**. Solo se ejecuta cuando
  nada ha fallado todavía, porque lee el valor de otra rama.

Leer un `Accumulated.value` de una rama que falló detona a propósito: lanza
toda la lista acumulada de una vez. Eso es lo que hace seguro el `return`
final — para cuando combinas valores, o bien todas las ramas tuvieron éxito o
nunca llegas ahí.

![Ramas independientes, luego reglas dependientes](diagrams/t17-1-accumulate.svg)

*Figura 17-1. Las ramas independientes se ejecutan todas y dejan caer sus fallos en un mismo cubo. Las reglas dependientes están aguas abajo de ese cubo: se ejecutan solo si está vacío, porque leen valores que podrían no existir.*

## Un formulario, de principio a fin

```dart run
import 'package:fxdart/fxdart.dart';

class Signup {
  const Signup(this.email, this.age, this.plan);
  final String email;
  final int age;
  final String plan;

  @override
  String toString() => 'Signup($email, $age, $plan)';
}

Either<Nel<String>, Signup> validate(Map<String, String> form) =>
    either((r) => r.accumulate((acc) {
          final email = acc.accumulating((br) {
            final v = form['email'] ?? '';
            if (!v.contains('@')) {
              br.raise('email: must contain @');
            }
            return v;
          });

          final age = acc.accumulating((br) {
            final n = int.tryParse(form['age'] ?? '');
            if (n == null) br.raise('age: not a number');
            if (n != null && n < 18) br.raise('age: must be 18+');
            return n ?? 0;
          });

          final plan = acc.accumulating((br) {
            final v = form['plan'] ?? '';
            if (v != 'free' && v != 'pro') {
              br.raise('plan: unknown "$v"');
            }
            return v;
          });

          // Dependent: only meaningful once age and plan parsed.
          acc.dependent((br) {
            if (plan.value == 'pro' && age.value < 21) {
              br.raise('plan: pro requires 21+');
            }
            return null;
          });

          return Signup(email.value, age.value, plan.value);
        }));

void main() {
  print(validate(
      {'email': 'a@b.co', 'age': '30', 'plan': 'pro'}));
  print(validate(
      {'email': 'nope', 'age': 'x', 'plan': 'gold'}));
  print(validate(
      {'email': 'a@b.co', 'age': '19', 'plan': 'pro'}));
}
```

Tres formas de respuesta de una sola función: un valor, cada problema
independiente a la vez, y una regla dependiente que solo habla cuando existen
los valores que necesita.

Fíjate en que el segundo caso reporta *tres* errores de tres campos, y el
tercero reporta uno — la regla dependiente — porque todas las ramas
independientes pasaron. Ese es el comportamiento que un usuario espera y la
razón por la que existe esta maquinaria.

## Las reglas que mantienen esto honesto

1. **Una rama por preocupación independiente.** Una rama que valida dos campos
   no puede reportar sobre el segundo si el primero falló.
2. **Haz raise más de una vez en una rama cuando tenga sentido.** Una rama
   puede contribuir varios errores; `age` arriba hace raise hasta dos veces.
3. **Nunca leas `.value` dentro de una rama independiente.** Para eso está
   `dependent`, y leerlo pronto detona todo el ámbito.
4. **Ordena los errores como el usuario lee el formulario.** El orden de las
   ramas es el orden del reporte, y es gratis acertar con él.
5. **No acumules consecuencias.** Si el paso B no tiene sentido cuando A
   falló, B pertenece a `dependent` o a un ámbito de fallo rápido, no a una
   rama.

> 🎓 **Por qué no hay un tipo `Validated`.** Arrow 1.x tenía uno — un
> `Validated<E, A>` separado cuyo aplicativo acumulaba y que convertías hacia y
> desde `Either` en cada frontera. Arrow 2.x lo eliminó, y FxDart nunca lo
> tuvo: el mismo efecto está disponible como un *ámbito* sobre
> `Either<Nel<E>, A>`, lo que significa un solo tipo de resultado en las
> firmas de tu dominio en vez de dos, y ninguna llamada a `toEither()`
> esparcida por el código. La teoría no perdió nada — `Validated` siempre fue
> solo `Either` con una instancia de aplicativo distinta, y dado que Dart no
> puede seleccionar instancias por tipo de todas formas (capítulo 10), nombrar
> el comportamiento en el sitio de la llamada es estrictamente más honesto.

## Cuándo se gana el sueldo

Entrada de cara al usuario de cualquier tipo; importaciones por lotes donde un
reporte parcial ahorra otra ejecución; configuración, donde cada clave que
falta debería reportarse antes de que el proceso salga; cargas útiles de API,
donde un 400 que lista todas las violaciones vale por cinco que listan una
cada uno.

Cuesta donde los fallos son baratos de redescubrir (un reintento local rápido),
donde los errores son para máquinas en vez de humanos (un código basta), y
donde ejecutar cada rama es caro — la acumulación significa *sin*
cortocircuito, así que cinco comprobaciones independientes lentas se ejecutan
todas incluso cuando la primera ya falló.

## Ejercicios

1. En el formulario de registro, mueve la regla «pro requiere 21+» de
   `dependent` a `accumulating` y predice la salida para
   `{'age': 'x', 'plan': 'pro'}`.
2. `mapOrAccumulate` sobre 10.000 filas recoge cada fallo. ¿Cuál es la forma de
   memoria de eso, y qué harías de forma distinta para una importación de 10M
   de filas?
3. ¿Por qué el tipo de error es `Nel<String>` y no `List<String>`? Da el
   estado que `List` admite y `Nel` prohíbe.
4. Una rama llama a una API. ¿Debería ser `accumulating` o `dependent`, y qué
   cambia si dos ramas llaman a la misma API?

## Soluciones

1. Se ejecutaría, leería `age.value` de una rama fallida, y detonaría —
   lanzando los errores acumulados desde dentro de la rama en vez de al final
   del ámbito. La salida sigue siendo un `Left` con el error de parseo, pero el
   mecanismo es una salida temprana en vez de una acumulación limpia, y una
   regla que necesitara ejecutarse después se saltaría. `dependent` existe para
   hacer esto imposible por construcción.
2. Cada fallo se retiene hasta el final, así que en el peor caso mantienes
   10.000 cadenas de error — está bien. A 10M de filas no lo está: transmitirías
   en flujo y reportarías, poniendo un tope a los errores recogidos (los
   primeros N, más un contador) o escribiéndolos en un archivo de rechazados
   según ocurren. La acumulación está acotada por el recuento de fallos, y ese
   es el número que hay que sanity-check antes de elegirla.
3. `List<String>` admite `Left([])` — «esto falló, y no hay motivos» — que es
   el tipo exacto de estado sin sentido representable del que trata el
   capítulo 3. `Nel` hace la garantía estructural: un fallo siempre lleva al
   menos un motivo, así que ningún consumidor necesita una rama «¿sin
   errores?».
4. `accumulating`, si la llamada es independiente — quieres que su fallo se
   reporte junto a los demás. Si dos ramas llaman a la misma API, se ejecutan
   secuencialmente dentro del ámbito y pagas dos veces; eleva la llamada por
   encima del ámbito, pasa el resultado, y mantén las ramas puras. Eso también
   hace la validación testeable sin red, que es el argumento del capítulo 2
   llegando de nuevo desde otra dirección.
