---
slug: accumulating-failure
chapter: 17
part: 4
title: 실패 모아 보고하기
description: 첫 이유가 아니라 모든 이유를 수집하기 — 어휘(Nel, zipOrAccumulate, mapOrAccumulate, dependent), 그것을 정직하게 유지하는 규칙, 그리고 폼 검증 하나를 처음부터 끝까지.
---
# 실패 모아 보고하기

> **이 장에서 다루는 것**
> - 빨리 실패냐 천천히 실패냐를 결정하는 제품 질문
> - 네 가지 도구, 그리고 어떤 모양에 어느 것이 맞는가
> - 독립 규칙과 의존 규칙, 그리고 그 둘을 잘못 섞는 전형적 버그
> - 원시 문자열에서 도메인 타입까지, 완전한 폼 검증 하나

## 제품 질문

6장에서 어플리커티브 모양만이 누적을 *할 수 있다*는 것을 확인했습니다. 이 장은
언제 *해야 하는가*에 관한 것이고, 그 기준은 타입과는 아무 상관이 없습니다.

> 사람이 이 오류들을 읽고 한 번에 고칠까?

그렇다면 — 폼, 설정 파일, 임포트, API 요청 본문 — 전부 모으세요. 우편번호가
틀렸다고 알려 주고, 왕복 한 번을 기다린 뒤, 이번엔 전화번호가 틀렸다고 알려 주는
것은 나쁜 프로그램이 아니라 나쁜 제품입니다.

아니라면 — 내부 단계의 사슬, 권한 확인, 두 번째 실패가 첫 번째의 *귀결*인 모든
것 — 빨리 실패하세요. 뿌리 하나에서 파생된 오류 열 개는 잡음이고, 정작 중요했던
하나를 감춥니다.

## 네 가지 도구

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

고르는 일은 기계적입니다.

| 모양 | 도구 |
|---|---|
| 이름이 있는 독립 필드 2~5개 | `zipOrAccumulate2..5` |
| 규칙 하나, 항목 여럿 | `mapOrAccumulate` |
| 이미 `Either`를 갖고 있음 | `flattenOrAccumulate` / `.flattenOrAccumulate()` |
| 가지가 다섯을 넘거나 의존 규칙이 있음 | `accumulate` |

## 먼저 독립, 그다음 의존

누적을 옳게 만들어 주는 규칙은 6장의 구분이고, 그것에는 정확한 API 모양이
있습니다.

- `acc.accumulating(...)` — **독립적인** 가지. 언제나 실행되고, 그 실패는 전파되지
  않고 기록됩니다.
- `acc.dependent(...)` — **의존적인** 규칙. 아직 아무 실패도 없을 때만 실행됩니다.
  다른 가지의 값을 읽기 때문입니다.

실패한 가지의 `Accumulated.value`를 읽으면 일부러 폭발합니다. 누적된 목록 전체를
한 번에 raise 하죠. 그것이 마지막 `return`을 안전하게 만듭니다 — 값을 결합하는
시점이면 모든 가지가 성공했거나, 아니면 거기까지 오지도 못합니다.

![독립적인 가지들, 그다음 의존 규칙](diagrams/t17-1-accumulate.svg)

*그림 17-1. 독립적인 가지는 모두 실행되어 실패를 한 바구니에 떨어뜨린다. 의존 규칙은 그 바구니의 하류에 있다. 존재하지 않을 수도 있는 값을 읽으므로, 바구니가 비어 있을 때만 실행된다.*

## 폼 하나, 처음부터 끝까지

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

함수 하나에서 세 가지 모양의 답이 나옵니다. 값 하나, 독립적인 문제 전부, 그리고
필요한 값이 존재할 때만 입을 여는 의존 규칙.

둘째 경우가 세 필드에서 오류 *셋*을 보고하고, 셋째는 하나 — 의존 규칙 — 만
보고한다는 점을 보세요. 독립적인 가지들이 모두 통과했기 때문입니다. 사용자가
기대하는 동작이고, 이 장치가 존재하는 이유입니다.

## 이것을 정직하게 유지하는 규칙

1. **독립적인 관심사마다 가지 하나.** 두 필드를 검증하는 가지는 첫째가 실패하면
   둘째에 대해 보고할 수 없습니다.
2. **한 가지에서 여러 번 raise 해도 됩니다.** 한 가지가 여러 오류를 기여할 수
   있고, 위의 `age`는 최대 둘을 올립니다.
3. **독립적인 가지 안에서는 절대 `.value`를 읽지 마세요.** 그러라고 `dependent`가
   있으며, 일찍 읽으면 스코프 전체가 폭발합니다.
4. **사용자가 폼을 읽는 순서대로 오류를 배치하세요.** 가지 순서가 곧 보고
   순서이고, 제대로 하는 데 비용이 들지 않습니다.
5. **귀결을 누적하지 마세요.** A가 실패했을 때 B가 무의미하다면 B는 `dependent`
   또는 빨리 실패 스코프에 속하지 가지에 속하지 않습니다.

> 🎓 **왜 `Validated` 타입이 없는가.** Arrow 1.x에는 있었습니다 — 어플리커티브가
> 누적하는 별도의 `Validated<E, A>`를, 모든 경계에서 `Either`와 오가며 변환해야
> 했죠. Arrow 2.x는 그것을 지웠고 FxDart는 애초에 갖지 않았습니다. 같은 효과를
> `Either<Nel<E>, A>` 위의 *스코프*로 얻을 수 있으니까요. 그 결과 도메인
> 시그니처에는 결과 타입이 둘이 아니라 하나만 있고, 코드 곳곳에 흩어진
> `toEither()` 호출도 없습니다. 이론적으로 잃은 것은 없습니다 — `Validated`는
> 애초에 어플리커티브 인스턴스만 다른 `Either`였고, 어차피 Dart는 타입으로
> 인스턴스를 고를 수 없으므로(10장) 호출 지점에서 동작에 이름을 붙이는 편이
> 엄밀히 더 정직합니다.

## 이것이 값을 하는 순간

모든 종류의 사용자 입력. 한 번 더 돌리는 수고를 아껴 주는 배치 임포트. 프로세스가
종료하기 전에 빠진 키를 모두 보고해야 하는 설정. 위반 사항을 전부 나열하는 400
응답 하나가 하나씩 알려 주는 다섯 번보다 나은 API 페이로드.

실패를 다시 알아내는 것이 값쌀 때(빠른 로컬 재시도), 오류가 사람이 아니라 기계를
위한 것일 때(코드 하나면 충분합니다), 그리고 모든 가지를 실행하는 것이 비쌀 때는
비용이 듭니다 — 누적은 단락 평가가 *없다*는 뜻이므로, 첫째가 이미 실패했어도 느린
독립 검사 다섯이 전부 실행됩니다.

## 연습문제

1. 가입 폼에서 "pro는 21세 이상" 규칙을 `dependent`에서 `accumulating`으로 옮기고
   `{'age': 'x', 'plan': 'pro'}`의 출력을 예측하세요.
2. `mapOrAccumulate`가 행 10,000개에 대해 모든 실패를 모읍니다. 그것의 메모리
   모양은 어떻고, 1,000만 행 임포트라면 무엇을 다르게 하시겠어요?
3. 오류 타입이 왜 `List<String>`이 아니라 `Nel<String>`인가요? `List`가 허용하고
   `Nel`이 금지하는 상태를 대세요.
4. 어떤 가지가 API를 호출합니다. `accumulating`이어야 할까요 `dependent`여야
   할까요? 두 가지가 같은 API를 부른다면 무엇이 달라지나요?

## 정답과 해설

1. 실행되어 실패한 가지의 `age.value`를 읽고 폭발합니다 — 스코프 끝이 아니라
   가지 안에서 누적된 오류가 raise 되죠. 출력은 여전히 파싱 오류를 담은
   `Left`이지만, 장치는 깔끔한 누적이 아니라 이른 탈출이고, 그 뒤에 실행되어야
   했을 규칙은 건너뛰어집니다. `dependent`는 그것을 구조적으로 불가능하게 만들려고
   존재합니다.
2. 모든 실패가 끝까지 보관되므로 최악의 경우 오류 문자열 10,000개를 들고
   있습니다 — 괜찮습니다. 1,000만 행이면 괜찮지 않습니다. 스트리밍하며 보고하고,
   수집하는 오류에 상한을 두거나(처음 N개 + 개수) 발생하는 대로 거부 파일에 쓰게
   됩니다. 누적의 메모리는 실패 개수에 비례하며, 그 수야말로 이 방식을 고르기 전에
   가늠해 봐야 할 숫자입니다.
3. `List<String>`은 `Left([])` — "실패했는데 이유가 없음" — 을 허용하는데, 이는
   정확히 3장이 다룬 종류의 표현 불가능해야 할 헛소리입니다. `Nel`은 그 보장을
   구조로 만듭니다. 실패는 언제나 이유를 적어도 하나 싣고 있으므로, 어떤 소비자도
   "오류가 없나?" 갈래를 둘 필요가 없습니다.
4. 호출이 독립적이라면 `accumulating` 입니다 — 그 실패가 다른 것들과 나란히
   보고되기를 원하니까요. 두 가지가 같은 API를 부르면 스코프 안에서 순차로
   실행되어 두 번 값을 치릅니다. 호출을 스코프 위로 끌어올려 결과를 넘기고,
   가지는 순수하게 유지하세요. 그러면 네트워크 없이 검증을 테스트할 수도 있는데,
   그것은 2장의 논지가 다른 방향에서 다시 도착한 것입니다.
