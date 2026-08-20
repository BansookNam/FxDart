---
slug: raise-scope
chapter: 15
part: 4
title: El ámbito de Raise
description: Cómo FxDart saca código lineal de pasos que fallan sin do-notation — un ámbito cuyo bind realiza una salida no local, por qué eso es una continuación delimitada en vez de azúcar sintáctico, y qué cuesta la diferencia.
---
# El ámbito de Raise

> **En este capítulo**
> - el mecanismo: qué hace realmente `r.bind` cuando falla
> - continuaciones delimitadas frente a azúcar sintáctico monádico, y por qué
>   Dart forzó la elección
> - la regla de la fuga — la única forma de usar mal un ámbito, y cómo la
>   librería la detecta
> - qué ganas y qué pierdes frente a cadenas de `flatMap`

## Qué es `either`

El capítulo 7 usó el ámbito y no lo abrió. Esta es la forma:

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> half(int n) => n.isEven
    ? Either.right(n ~/ 2)
    : Either.left('odd: $n');

void main() {
  final result = either<String, int>((r) {
    final a = r.bind(half(20)); // 10
    final b = r.bind(half(a)); // 5
    final c = r.bind(half(b)); // odd → exits here
    return c * 100; // never reached
  });

  print(result);
}
```

`either` ejecuta tu bloque con un objeto `Raise<E>`. `r.bind` mira un `Either`:
en un `Right` devuelve el valor, en un `Left` **abandona el bloque por
completo** y hace que `either` devuelva ese `Left`. Sin pirámide, sin
`flatMap`, y el bloque se lee de arriba abajo.

El mecanismo es un escape de flujo de control: `raise` lanza un marcador
privado que `either` captura en la frontera y convierte en un `Left`. Como el
throw y el catch están ambos dentro de la librería, el escape es *delimitado*
— solo puede viajar hasta el `either` que lo envuelve, y no más allá.

![Dónde aterriza la salida](diagrams/t15-1-scope-exit.svg)

*Figura 15-1. Cada `bind` es una posible salida, y cada salida aterriza en el mismo lugar: la frontera del ámbito que creó `r`. Esa frontera es lo que convierte un salto de flujo de control de vuelta en un valor ordinario.*

## Continuación delimitada, no azúcar sintáctico

El `for` de Scala y el `do` de Haskell son **reescrituras**: el compilador
convierte el bloque en llamadas a `flatMap` antes de comprobar tipos. Eso
funciona para cualquier mónada, y necesita tipos de orden superior para decir
«cualquier mónada» — que el capítulo 10 explicó que Dart no tiene.

El ámbito de FxDart no es una reescritura. Nada se transforma; se pasa un
objeto real, y el control sale del bloque mediante un mecanismo que el
lenguaje ya tiene. El trato es exacto:

| | Azúcar sintáctico (`do`, `for`) | Ámbito (`either`, `Raise` de Arrow) |
|---|---|---|
| Funciona para | cualquier mónada que los tipos puedan nombrar | los efectos que la librería escribió |
| Necesita | tipos de orden superior | nada especial |
| Salida de fallo | devolver un valor cortocircuitado | salto no local, capturado en la frontera |
| Compone con `async` | necesita un transformador | de forma natural — `eitherAsync` |
| Extensible por ti | sí, definiendo una mónada | no |

Las dos últimas filas son la razón de que la elección sea defendible en vez de
meramente forzada. Una torre de transformadores (`EitherT[Future, E, A]`) es
la respuesta general, y es genuinamente difícil de leer; el ámbito maneja la
única combinación que la gente realmente escribe — fallo dentro de async — sin
ningún tipo nuevo:

```dart run
import 'package:fxdart/fxdart.dart';

Future<Either<String, int>> lookup(String key) async {
  await Future.delayed(const Duration(milliseconds: 10));
  return key == 'port'
      ? Either.right(8080)
      : Either.left('missing: $key');
}

void main() async {
  final ok = await eitherAsync<String, String>((r) async {
    final port = r.bind(await lookup('port'));
    final host = r.bind(await lookup('port'));
    return 'http://$host:$port';
  });
  print(ok);

  final bad = await eitherAsync<String, String>((r) async {
    final port = r.bind(await lookup('nope'));
    return 'never: $port';
  });
  print(bad);
}
```

`await` secuencia el tiempo, `r.bind` secuencia el fallo, y los dos no son
conscientes el uno del otro. Ese es todo el beneficio.

## Los tres sabores de ámbito

FxDart incluye un ámbito por cada representación de fallo, porque —
capítulo 10 otra vez — no hay forma de escribir uno que las cubra todas:

```dart run
import 'package:fxdart/fxdart.dart';

int? parseTeen(String s) {
  final n = int.tryParse(s);
  return (n != null && n >= 13 && n <= 19) ? n : null;
}

void main() {
  // Failure as a typed value.
  print(either<String, int>((r) {
    final n = r.ensureNotNull(
        parseTeen('15'), () => 'not a teen');
    return n * 2;
  }));

  // Failure as null — no error value to carry.
  print(nullable((r) {
    final n = r.bind(parseTeen('15'));
    return n * 2;
  }));
  print(nullable((r) {
    final n = r.bind(parseTeen('42'));
    return n * 2;
  }));

  // Failure as a thrown exception, handled at the boundary.
  print(catching<int>(() => int.parse('nope'), (e, _) => -1));

  // …or converted straight into a Left.
  print(eitherCatching<String, int>(
      (r) => int.parse('nope'), (e, _) => 'not a number'));
}
```

Tres ámbitos, una idea: ejecutar código lineal, salir en el primer fallo,
convertir la salida en lo que sea que el tipo de quien llama diga.

## La regla de la fuga

Hay exactamente una forma de usar mal un ámbito, y se sigue del mecanismo:
**`r` solo puede usarse mientras su ámbito está en ejecución.** Captúralo en un
closure que sobreviva al bloque, y su escape no tiene dónde aterrizar.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  late Raise<String> escaped;

  final result = either<String, int>((r) {
    escaped = r; // capturing the scope object…
    return 1;
  });
  print(result);

  try {
    escaped.raise('too late'); // …and using it after it closed
  } catch (e) {
    print('caught: ${e.runtimeType}');
  }
}
```

La librería lo detecta y lanza `RaiseLeakedError` en vez de dejar que un salto
de flujo de control perdido escape a código no relacionado. En la práctica la
regla muerde en un solo lugar: **no uses `r` dentro de un callback que se
ejecuta más tarde** — un future sin `await`, un timer, un listener de stream.
Dentro de `eitherAsync`, quédate en la cadena esperada; esa es la misma regla
enunciada para async.

> 🎓 **Esta es una idea antigua con un nombre nuevo.** Una continuación
> delimitada captura «el resto del cómputo hasta una frontera» y te deja
> abandonarlo o reanudarlo; `shift`/`reset` en Scheme, `Cont` en Haskell, los
> manejadores de efectos algebraicos en OCaml 5 y Koka son todos esta
> maquinaria. `Raise` usa solo la mitad de abandono, que es por qué puede
> implementarse con una excepción privada en vez de una captura real de la
> pila. Esa restricción es también lo que lo hace barato y predecible: sin
> reentrada, sin reanudación, sin re-ejecución sorprendente — una salida, una
> frontera, un valor.

## Cuándo se gana el sueldo

Tres o más pasos falibles que comparten un tipo de error, especialmente con
retornos anticipados y condiciones de guarda entre medias —
`r.ensure(cond, () => err)` reemplaza el `if (!cond) return Left(...)` que una
cadena de `flatMap` no puede expresar sin otro nivel de anidación.

Es la herramienta equivocada para validaciones independientes (capítulo 6 —
quieres acumulación), para una única llamada falible (devuelve el `Either`
directamente), y en cualquier lugar donde el bloque le pasa `r` a código que se
ejecutará más tarde, que es lo que la regla de la fuga prohíbe.

## Ejercicios

1. Reescribe el primer listado como una cadena de `flatMap`. ¿Qué versión hace
   más fácil añadir una guarda — «falla si el valor cae por debajo de 3» —
   entre pasos?
2. ¿Qué devuelve `either` cuando el bloque lanza una excepción genuina en vez
   de hacer raise? Pruébalo, y explica por qué ese es el comportamiento por
   defecto correcto.
3. ¿Por qué un ámbito no puede reanudarse — es decir, por qué no hay un
   `r.recover(...)` que continúe el bloque después de un fallo? Responde en
   términos del mecanismo.
4. `nullable` no tiene ningún valor de error. ¿Cuál es su tipo `E`, y qué te
   dice eso sobre la relación entre `Either<E, A>` y `A?`?

## Soluciones

1. La cadena es `half(20).flatMap(half).flatMap(half).map((c) => c * 100)`.
   Añadir una guarda significa insertar un `flatMap((v) => v < 3 ? Left(...) :
   Right(v))` — un nuevo nivel de anidación y una nueva lambda — donde la
   versión de ámbito añade una línea: `r.ensure(a >= 3, () => 'too small')`.
   Las guardas son donde el ámbito toma una ventaja decisiva.
2. La excepción se propaga fuera de `either` sin cambios. Eso es correcto
   porque una excepción lanzada significa «pasó algo que este tipo de error no
   describe» — convertirla silenciosamente en un `Left` lavaría un bug hasta
   convertirlo en un fallo de dominio. `eitherCatching` existe para cuando *sí*
   quieres la conversión, y es una función separada precisamente para que la
   elección sea explícita. El capítulo 18 desarrolla esta frontera.
3. Porque el escape está implementado como un throw: para cuando `either` ve el
   fallo, los marcos de pila del bloque ya se han desenrollado y sus variables
   locales han desaparecido. Reanudar requeriría capturar la continuación antes
   del desenrollado, que es la mitad de las continuaciones delimitadas que
   `Raise` deliberadamente no implementa. La recuperación por tanto ocurre
   *fuera*, sobre el `Either` devuelto — `result.fold(...)` o `getOrElse`.
4. Su `E` es efectivamente `void`/`Null` — no hay nada que llevar. `A?` es
   `Either<Unit, A>` con el lado de fallo sin llevar información, así que todo
   cómputo anulable es un `Either` que ha olvidado por qué falló. Ese es el
   trato que el capítulo 18 examina: la nulabilidad es gratis y muda, los
   errores tipados cuestan un parámetro de tipo y pueden decirte qué salió mal.
