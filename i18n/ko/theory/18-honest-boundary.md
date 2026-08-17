---
slug: honest-boundary
chapter: 18
part: 4
title: 정직한 경계
description: 검사되지 않는 예외가 있는 언어에서 타입 있는 오류 시스템이 약속할 수 없는 것 — Dart가 실제로 가진 세 가지 실패 통로, 그중에서 고르는 법, 그리고 어디서 변환할 것인가.
---
# 정직한 경계

> **이 장에서 다루는 것**
> - Dart의 세 가지 실패 통로와, 각각이 말할 수 있는 것과 없는 것
> - 고르는 규칙: 호출자가 이것에 대해 무언가 할 수 있는가?
> - 왜 `Either`는 프로그램을 예외 없는 것으로 만들지 못하며, 왜 그래도 괜찮은가
> - 가장자리에서의 변환, 양방향으로

## 세 가지 통로

Dart에서 함수는 세 가지 방식으로 실패할 수 있고, 그것들은 서로 바꿔 쓸 수
없습니다.

| 통로 | 타입이 말하는 것 | 호출자가 해야 하는 것 | 싣는 것 |
|---|---|---|---|
| `throw` | 아무것도 | 아무것도 (검사되지 않음) | 임의의 객체 + 스택 트레이스 |
| `A?` | 없을 수도 있음 | null 처리 | 이유 없음 |
| `Either<E, A>` | `E`로 실패할 수 있음 | 양쪽 처리 | 타입 있는 이유 |

각각이 맞는 자리가 있습니다.

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

고르는 규칙은 질문 하나입니다. **호출자가 이 실패에 대해 구체적으로 무언가 할 수
있는가?** 그렇다면 타입에 넣으세요 — 이유가 중요하면 `Either`, 아니면 `A?`.
아니라면 던지세요. 버그이거나, 깨진 불변식이거나, 그 호출 지점에서 아무도 복구할
수 없는 환경 실패입니다.

![세 통로, 하나의 결정](diagrams/t18-1-three-channels.svg)

*그림 18-1. 질문은 실패가 얼마나 나쁜가가 아니라 호출자에게 반응이 있는가이다. 호출자가 손쓸 수 있는 모든 것은 반환 타입에 속하고, 나머지는 예외 통로에 속한다. 거기라면 여기서 꼭대기까지의 모든 시그니처를 어지럽히지 않는다.*

## 타입 있는 오류가 약속할 수 없는 것

여기가 불편한 부분이고, 이 장이 존재하는 이유입니다.

시그니처의 `Either<E, A>`는 "이 함수는 `E`로만 실패한다"는 뜻이 *아닙니다*.
Dart의 예외는 검사되지 않으므로 어떤 코드든 — 여러분의 코드, SDK, 의존성 —
언제든 던질 수 있습니다. `Either`를 돌려주는 함수도 여전히 `StateError`,
`RangeError`, `OutOfMemoryError`, 또는 이행 의존성의 버그로 터질 수 있습니다.

그러니 정직한 진술은 더 좁고, 그래도 값어치가 큽니다.

> `Either<E, A>`가 말하는 것: *이 함수가 모델링한 실패는 `E`이고, 그것은 타입에
> 있다.* 아무도 모델링하지 않은 실패에 대해서는 아무 말도 하지 않습니다.

전체 집합을 약속하는 대신 모든 것에 `throws` 절을 붙이는 값을 치르는 검사 예외
언어와 비교해 보세요. Dart는 검사되지 않는 쪽을 골랐고, 라이브러리가 그 선택을
되돌릴 수는 없습니다. FxDart가 더하는 것은 여러분이 *생각해 둔* 실패를 위한
통로이고, 버그는 실제로 거기서 나옵니다.

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

`eitherCatching`이 명시적인 변환이고, 명시적이라는 것이 설계입니다. 모든 던지기를
말없이 삼키면 진짜 버그가 도메인 실패로 바뀌고, 여러분은 프로덕션에서
`Left('Bad state: no element')`를 하나씩 받으며 알게 될 것입니다.

## 가장자리에서 변환하기

프로그램에는 바깥세상의 실패 방식이 여러분의 방식과 만나는 경계가 있습니다.
양방향 모두 한 줄이고, 양쪽 모두 흩어지지 않고 그 경계에 있어야 합니다.

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

들어오는 변환은 여러분이 통제하지 않는 코드를 부르는 자리에서 일어납니다. 나가는
변환은 프레임워크가 던지기를 요구하는 자리 — Flutter의 build 메서드, 테스트 헬퍼,
`main` — 에서 일어납니다. 그 사이에서 실패는 값입니다.

> 🎓 **Error와 Exception, 그리고 Dart SDK 자신의 뜻.** Dart의 관례는 `Error`
> (`ArgumentError`, `StateError`, `RangeError`)가 *프로그래밍 실수*를 알린다는
> 것입니다 — 호출자가 계약을 어겼으니 처리할 게 아니라 고쳐야 하죠. 반면
> `Exception`은 올바른 프로그램도 마주칠 수 있는 상황을 알립니다
> (`FormatException`, `IOException`). 그것이 이 장에 그대로 대응됩니다. `Error`는
> 잡아서 `Left`로 바꾸면 안 됩니다. 버그를 감추니까요. `Exception`은
> `eitherCatching`의 훌륭한 후보입니다. 라이브러리를 쓸 때 이 관례를 지키는 것이,
> 여러분의 호출자가 애초에 이 구분을 할 수 있게 해 주는 일입니다.

## 널 허용이라는 중간 지대

`A?`는 Dart가 가진 가장 값싼 실패 통로이고, 타입 있는 오류 애호가들이 인정하는
것보다 훨씬 자주 진짜로 옳은 답입니다 — 검사는 하나입니다. *"없음"이 메시지의
전부인가?* 맵 조회, 첫 일치 검색, 선택적 필드: 그렇습니다. 파싱, 검증, 권한 확인:
아닙니다. 호출자가 무엇이 잘못됐는지 말하고 싶어 할 테니까요.

FxDart의 `nullable` 스코프는 null 모양의 사슬도 같은 직선형 대접을 받도록
존재합니다.

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

없을 수 있는 방식이 셋, 나오는 `null`은 하나, `?.`와 `??`의 피라미드는 없음.
출력에서 빠진 것을 보세요. 셋 중 무엇이었는지 알 수 없습니다. 그것이 정확히
`Either`가 타입 매개변수 하나를 치르고 지키는 정보입니다.

## 이것이 값을 하는 순간

이 장의 규칙은 새 함수를 쓸 때마다 값을 하고, 그래서 이 책에서 가장 자주
내리는 결정입니다. 이것을 제대로 하면 시그니처가 정직해지고 `try` 블록이 드물면서
의미 있는 것이 됩니다.

교조적으로 적용하면 값을 못 합니다. 모든 비공개 헬퍼에 `Either<String, T>`를
붙이는 것은 정보 없이 잡음만 더하고, `main`이 유일한 `try`인 코드베이스는
누군가에게 필요했던 스택 트레이스를 떨어뜨릴 코드베이스입니다. 경계에서
변환하고, 호출자가 손쓸 수 있는 것을 모델링하고, 진짜 버그는 요란하게 죽게
두세요.

## 연습문제

1. 다음을 throw / `A?` / `Either`로 분류하세요. 파싱에 실패한 JSON, 없는 선택적
   쿼리 파라미터, 여러분의 함수에 넘어온 음수 배열 길이, 결제사가 거절한 결제.
2. `int.parse`는 던지고 `int.tryParse`는 null을 돌려줍니다. `Either`라면 무엇을
   줬을 것이며, 무엇을 발명해야 했을까요?
3. `eitherCatching`은 왜 `either`의 기본 동작이 아니라 별도 함수인가요? 다른
   선택을 했다면 따라올 버그를 서술하세요.
4. 어떤 함수가 `Either<E, A>`를 돌려주면서 일부 입력에서는 던지기도 합니다.
   그것을 어떻게 발견하고, 코드와 시그니처 중 무엇을 바꾸겠어요?

## 정답과 해설

1. JSON 파싱 실패: 사용자가 입력을 고칠 수 있다면 `Either`, 호출자가 유효성만
   보고 분기한다면 `A?`. 없는 선택적 파라미터: `A?` — 없음이 *곧* 메시지입니다.
   음수 길이: `throw ArgumentError` — 호출자가 계약을 어겼고, 고칠 곳은 그쪽
   코드입니다. 결제 거절: 타입 있는 이유를 실은 `Either`. 호출자가 사람에게
   보여 주고 어쩌면 재시도해야 하니까요.
2. `Either<FormatException, int>`를 줬을 것이고 — 오류 타입을 발명해야 했을
   겁니다. 그것이 세 번째 통로의 값 전부입니다. 누군가 실패가 *무엇인지* 정하고,
   이름 붙이고, 유지해야 합니다. `tryParse`는 "아니오"만 말함으로써 그것을
   비껴가고, 그래서 더 흔히 쓰이는 호출입니다.
3. 모든 던지기를 `Left`로 접으면 버그를 도메인 실패로 세탁하기 때문입니다.
   라이브러리 버그에서 온 `StateError`가 검증 오류로 도착하고, 호출자는 그것을
   우편번호 칸 옆에 그리고, 스택 트레이스는 아무도 못 보게 됩니다. 명시성이란
   그 변환이 이름을 가진 결정이라는 뜻입니다.
4. 실패하는 입력에 대한 테스트로 발견하거나, 던질 수 있는 호출(`parse`, `!`,
   `first`, 리스트의 `[]`)을 찾아 읽어서 발견합니다. 바꿀 것은 *코드*입니다.
   던지는 호출을 `eitherCatching`으로 감싸 실패를 모델링하거나, 버그라면
   의도적으로 전파시키세요. 하지 말아야 할 한 가지는 주석으로 적어 두고 시그니처는
   거짓말하게 두는 것입니다.
