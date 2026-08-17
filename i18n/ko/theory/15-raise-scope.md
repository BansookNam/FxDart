---
slug: raise-scope
chapter: 15
part: 4
title: Raise 스코프
description: do 표기법 없이 실패하는 단계에서 직선형 코드를 얻는 방법 — bind가 비국소 탈출을 수행하는 스코프, 왜 그것이 문법 설탕 해제가 아니라 제한된 연속인지, 그리고 그 차이의 대가.
---
# Raise 스코프

> **이 장에서 다루는 것**
> - 장치: 실패했을 때 `r.bind`가 실제로 하는 일
> - 제한된 연속(delimited continuation)과 모나드 desugaring, 그리고 Dart가 왜 그 선택을 강제했는가
> - 누출 규칙 — 스코프를 잘못 쓰는 유일한 방법과, 라이브러리가 그것을 잡는 법
> - `flatMap` 사슬 대비 얻는 것과 잃는 것

## `either`란 무엇인가

7장은 스코프를 쓰기만 하고 열어 보지는 않았습니다. 모양은 이렇습니다.

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

`either`는 여러분의 블록을 `Raise<E>` 객체와 함께 실행합니다. `r.bind`는
`Either`를 들여다봅니다. `Right`면 값을 돌려주고, `Left`면 **블록 전체를
포기**하고 `either`가 그 `Left`를 돌려주게 만듭니다. 피라미드도 `flatMap`도 없고,
블록은 위에서 아래로 읽힙니다.

장치는 제어 흐름 탈출입니다. `raise`가 비공개 표식을 던지고, `either`가 그것을
경계에서 잡아 `Left`로 바꿉니다. 던지기와 잡기가 모두 라이브러리 안에 있으므로
그 탈출은 *제한(delimited)* 되어 있습니다 — 감싸고 있는 `either`까지만 갈 수 있고
그 너머로는 못 갑니다.

![탈출이 착지하는 곳](diagrams/t15-1-scope-exit.svg)

*그림 15-1. 모든 `bind`가 탈출구가 될 수 있고, 모든 탈출은 같은 자리에 착지한다. `r`을 만든 스코프의 경계다. 제어 흐름의 점프를 다시 평범한 값으로 바꿔 주는 것이 그 경계다.*

## 문법 설탕 해제가 아니라 제한된 연속

스칼라의 `for`와 하스켈의 `do`는 **다시 쓰기**입니다. 컴파일러가 타입 검사 전에
블록을 `flatMap` 호출로 바꿉니다. 그것은 어떤 모나드에도 통하고, "어떤
모나드든"이라고 말하려면 고차 타입이 필요한데 — 10장이 설명했듯 Dart에는
없습니다.

FxDart의 스코프는 다시 쓰기가 아닙니다. 변환되는 것은 없고, 진짜 객체가 넘어가며,
제어는 언어가 이미 가진 장치로 블록을 떠납니다. 거래는 이렇습니다.

| | Desugaring (`do`, `for`) | 스코프 (`either`, Arrow의 `Raise`) |
|---|---|---|
| 통하는 대상 | 타입이 이름 붙일 수 있는 모든 모나드 | 라이브러리가 써 둔 효과들 |
| 필요한 것 | 고차 타입 | 특별한 것 없음 |
| 실패 탈출 | 단락 평가된 값을 반환 | 비국소 점프, 경계에서 잡힘 |
| `async`와의 합성 | 트랜스포머 필요 | 자연스러움 — `eitherAsync` |
| 사용자가 확장 가능 | 예, 모나드를 정의하면 | 아니오 |

마지막 두 줄이, 이 선택이 그저 강제된 것이 아니라 변호 가능한 이유입니다.
트랜스포머 탑(`EitherT[Future, E, A]`)이 일반적인 답이고 진짜로 읽기 어렵습니다.
스코프는 사람들이 실제로 쓰는 그 한 조합 — async 안의 실패 — 을 새 타입 없이
처리합니다.

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

`await`가 시간을 이어 붙이고 `r.bind`가 실패를 이어 붙이며, 둘은 서로를 모릅니다.
그것이 보상의 전부입니다.

## 세 가지 스코프

FxDart는 실패 표현마다 스코프를 하나씩 싣습니다 — 또다시 10장 때문에, 그 전부를
덮는 하나를 쓸 방법이 없기 때문입니다.

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

스코프 셋, 아이디어 하나. 직선형 코드를 실행하고, 첫 실패에서 빠져나오고, 그
탈출을 호출자의 타입이 말하는 것으로 바꾼다.

## 누출 규칙

스코프를 잘못 쓰는 방법은 정확히 하나뿐이고, 그것은 장치에서 따라 나옵니다.
**`r`은 자기 스코프가 실행 중일 때만 쓸 수 있습니다.** 블록보다 오래 사는
클로저가 그것을 붙잡으면, 그 탈출은 착지할 곳이 없습니다.

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

라이브러리는 그것을 감지해 `RaiseLeakedError`를 던집니다. 길 잃은 제어 흐름
점프가 무관한 코드로 새어 나가게 두는 대신에요. 실무에서 이 규칙이 물리는 자리는
하나입니다. **나중에 실행되는 콜백 안에서 `r`을 쓰지 마세요** — await 하지 않은
future, 타이머, 스트림 리스너. `eitherAsync` 안에서는 await 사슬 위에 머무르세요.
같은 규칙을 비동기로 말한 것입니다.

> 🎓 **오래된 아이디어에 새 이름.** 제한된 연속은 "경계까지의 나머지 계산"을
> 붙잡아 두었다가 포기하거나 재개할 수 있게 해 줍니다. Scheme의 `shift`/`reset`,
> 하스켈의 `Cont`, OCaml 5와 Koka의 대수적 효과 핸들러가 모두 이 장치입니다.
> `Raise`는 그중 포기하는 절반만 쓰고, 그래서 진짜 스택 캡처가 아니라 비공개
> 예외로 구현할 수 있습니다. 그 제약이 이것을 싸고 예측 가능하게 만들기도
> 합니다 — 재진입 없음, 재개 없음, 놀라운 재실행 없음. 탈출 하나, 경계 하나, 값
> 하나.

## 이것이 값을 하는 순간

같은 오류 타입을 공유하는 실패 가능 단계가 셋 이상일 때, 특히 중간에 이른 반환과
가드 조건이 있을 때. `r.ensure(cond, () => err)`가 `if (!cond) return Left(...)`를
대신하는데, `flatMap` 사슬은 그것을 중첩 한 겹 없이는 표현하지 못합니다.

독립적인 검증에는(6장 — 누적을 원할 겁니다), 실패 가능 호출이 하나뿐일 때는
(`Either`를 그냥 돌려주세요), 그리고 블록이 나중에 실행될 코드에 `r`을 넘기는
곳에는 잘못된 도구입니다. 마지막 것은 누출 규칙이 금지합니다.

## 연습문제

1. 첫 예제를 `flatMap` 사슬로 다시 쓰세요. "값이 3 미만이면 실패"라는 가드를
   중간에 넣기가 어느 버전에서 더 쉬운가요?
2. 블록이 raise가 아니라 진짜 예외를 던지면 `either`는 무엇을 돌려주나요?
   해 보고, 왜 그것이 옳은 기본값인지 설명하세요.
3. 스코프는 왜 재개할 수 없나요 — 즉 실패 후 블록을 이어 가는 `r.recover(...)`가
   왜 없나요? 장치의 언어로 답하세요.
4. `nullable`에는 오류 값이 아예 없습니다. 그 `E` 타입은 무엇이고, 그것은
   `Either<E, A>`와 `A?`의 관계에 대해 무엇을 말해 주나요?

## 정답과 해설

1. 사슬은 `half(20).flatMap(half).flatMap(half).map((c) => c * 100)` 입니다.
   가드를 넣으려면 `flatMap((v) => v < 3 ? Left(...) : Right(v))`를 끼워야 하고 —
   중첩 한 겹과 람다 하나가 늘어납니다 — 스코프 버전은 한 줄이면 됩니다.
   `r.ensure(a >= 3, () => 'too small')`. 가드야말로 스코프가 결정적으로 앞서는
   자리입니다.
2. 예외는 `either` 밖으로 그대로 전파됩니다. 던져진 예외는 "이 오류 타입이
   서술하지 않는 무언가가 일어났다"는 뜻이므로 옳습니다. 그것을 조용히 `Left`로
   바꾸면 버그를 도메인 실패로 세탁하게 됩니다. 그 변환을 원할 때를 위해
   `eitherCatching`이 있고, 선택이 명시적이도록 별도 함수인 것입니다. 18장이 이
   경계를 발전시킵니다.
3. 탈출이 던지기로 구현되기 때문입니다. `either`가 실패를 보는 시점에는 블록의
   스택 프레임이 이미 풀려 있고 지역 변수도 사라졌습니다. 재개하려면 풀리기 전에
   연속을 붙잡아야 하는데, 그것이 `Raise`가 의도적으로 구현하지 않는 제한된
   연속의 나머지 절반입니다. 그래서 복구는 *바깥에서*, 돌려받은 `Either`에 대해
   일어납니다 — `result.fold(...)` 또는 `getOrElse`.
4. 그 `E`는 사실상 `void`/`Null` 입니다 — 실을 것이 없습니다. `A?`는 실패 쪽이
   아무 정보도 싣지 않는 `Either<Unit, A>`이므로, 모든 nullable 계산은 왜
   실패했는지를 잊어버린 `Either`입니다. 그것이 18장이 살펴보는 거래입니다.
   널 허용은 공짜지만 말이 없고, 타입 있는 오류는 타입 매개변수 하나를 치르고 무엇이
   잘못됐는지 말해 줍니다.
