---
slug: illegal-states
chapter: 3
part: 1
title: 불가능한 상태를 표현조차 못 하게 만들기
description: 합 타입, 곱 타입, 그리고 Dart의 sealed 클래스와 레코드 — 나쁜 경우를 표현할 수 없는 타입을 골라, 버그 한 부류를 런타임에서 컴파일 타임으로 옮기는 법.
---
# 불가능한 상태를 표현조차 못 하게 만들기

> **이 장에서 다루는 것**
> - 곱과 합: 타입이 결합하는 두 가지 방식과 그 값의 개수 세기
> - `sealed` + `switch`가 왜 합 타입을 쓸 가치가 있게 만드는 기능인가
> - 리팩터링: nullable 필드 한 뭉치를 거짓말할 수 없는 타입으로 바꾸기
> - 레코드가 맞는 자리와, 타입이 잘못된 도구인 자리

## 상태 세어 보기

타입은 값의 집합이고, 셀 수 있습니다. `bool`은 2개. `Null`은 1개. 상수가 셋인
enum은 3개. 셀 수 있게 되면 타입을 결합하는 두 방식에 이름이 붙습니다.

- **곱(product)** 은 각각을 하나씩 갖습니다. 레코드 `(bool, bool)`은 2 × 2 = 4개의
  값을 갖습니다. 클래스의 필드가 곱입니다.
- **합(sum)** 은 여럿 중 하나를 갖습니다. `bool | Null`은 2 + 1 = 3개입니다.
  Dart에서는 `sealed` 계층이 합이고, (엄밀하진 않지만) `T?`도 그렇습니다.

설계 버그는 거의 언제나 같은 버그입니다. **타입이 도메인보다 많은 값을 갖는
것.** 가장 전형적인 모양이 이것입니다.

```dart run
// Four fields; 2 × 2 × 2 × 2 = 16 representable combinations…
class Request {
  Request(
      {this.loading = false,
      this.data,
      this.error,
      this.cancelled = false});
  final bool loading;
  final String? data;
  final String? error;
  final bool cancelled;
}

void main() {
  // …but this one is nonsense, and it compiles.
  final broken =
      Request(loading: true, data: 'ok', error: 'boom');
  print([broken.loading, broken.data, broken.error]);
}
```

의미 있는 상태는 넷입니다 — 로딩 중, 로딩 완료, 실패, 취소 — 그런데 타입은
열여섯을 허용합니다. 나머지 열둘이 버그가 사는 곳이고, 코드베이스에 있는 모든
`if (r.error != null && !r.loading)` 는 그중 하나를 손으로 덧댄 반창고입니다.

![표현 가능한 열여섯 상태, 진짜인 넷](diagrams/t3-1-state-space.svg)

*그림 3-1. 왼쪽 타입은 플래그 네 개의 곱이고, 도메인은 네 경우의 합이다. 대각선 바깥의 모든 칸은 코드가 처리하거나, 아니면 절대 일어나지 않기를 바라야 하는 상태다.*

## 합 타입, 그리고 그것을 값어치 있게 만드는 기능

```dart run
sealed class Request {
  const Request();
}

class Loading extends Request {
  const Loading();
}

class Loaded extends Request {
  const Loaded(this.data);
  final String data;
}

class Failed extends Request {
  const Failed(this.message);
  final String message;
}

class Cancelled extends Request {
  const Cancelled();
}

String render(Request r) => switch (r) {
  Loading() => 'spinner',
  Loaded(:final data) => 'showing $data',
  Failed(:final message) => 'error: $message',
  Cancelled() => 'cancelled',
};

void main() {
  const all = [
    Loading(),
    Loaded('42 rows'),
    Failed('timeout'),
    Cancelled()
  ];
  all.map(render).forEach(print);
}
```

네 경우, 정확히 네 상태, nullable 필드 없음, `default` 갈래 없음. 마지막 항목이
핵심입니다. `sealed`는 `switch`를 **빠짐없게(exhaustive)** 만들어 주므로, 다섯째
경우를 추가하면 그 타입을 다루는 모든 자리가 컴파일 오류가 되어 아직 생각하지
않은 것이 무엇인지 정확히 알려 줍니다. 빠짐없음 검사가 없는 합 타입은 그냥
단계를 더 거친 클래스 계층일 뿐이고, Dart 3이 그 빠진 절반을 채웠습니다.

`Either`가 쓰는 것도 같은 장치입니다 — `Left`와 `Right`의 sealed 합(16장)이고,
그래서 `Either`에 대한 `switch`에도 대비용 갈래가 필요 없습니다.

## 곱: 레코드, 그리고 그 한계

클래스를 만들기엔 격식이 과할 때, 레코드가 익명의 곱을 줍니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  // `attach` pairs each value with something derived from it:
  // a product, produced lazily, with no class to declare.
  final priced = fx(['apple', 'fig', 'banana'])
      .attach((name) => name.length)
      .toList();
  print(priced);

  final total = fx(priced).sumBy((row) => row.$2);
  print('total letters: $total');
}
```

짝지음이 *국소적*일 때 — 파이프라인의 중간 단계, 값 두 개짜리 반환 — 레코드가
맞는 도구입니다. 그 짝지음에 도메인 안의 이름이 생기고 규칙이 붙는 순간부터는
잘못된 도구인데, 레코드는 불변식을 실을 수 없기 때문입니다. `(String, int)`는
`int`가 음수가 아님을 약속하지 못하지만,
`class Money { Money(this.cents) : assert(cents >= 0); }` 는 할 수 있습니다.

> 🎓 **왜 "대수적(algebraic)" 자료형인가.** 곱은 크기를 곱하고 합은 더하며, 이
> 대수는 계속됩니다. `Either<A, B>`는 |A| + |B|개의 값을, `A?`는 |A| + 1개를,
> 함수 `A → B`는 |B|^|A|개를 갖습니다 — 문헌에서 화살표를 지수로 쓰는 이유죠.
> 동형 `(A, B) → C ≅ A → (B → C)` — 커링, 4장 — 은 `(c^b)^a = c^(b×a)`를 타입
> 수준에서 말한 것입니다. 이름은 장식이 아닙니다. 산수는 실제이고, 어떤
> 리팩터링이 의미를 보존하는지 예측해 줍니다.

## 세 단계 리팩터링

1. **센다.** 타입이 허용하는 상태 수와 도메인의 상태 수를 적습니다. 다르다면 그
   차이가 여러분의 버그 예산입니다.
2. **진짜 경우에 이름을 붙인다.** 경우마다 `sealed` 하위 클래스 하나씩, 각각
   그 경우에 필요한 데이터만 싣습니다 — `Loaded`에는 `data`가 있고 `message`는
   없으며, nullable은 아무것도 없습니다.
3. **가드를 지운다.** 불가능한 조합을 배제하려고 있던 `if (x != null && !y)`는
   전부 사라지고, 컴파일러가 지켜보는 `switch` 갈래로 바뀝니다.

보상은 우아함이 아니라 *다음* 변경이 검사된다는 것입니다. `Request`에
`Retrying`을 추가하면 컴파일 오류 목록이 나오는데, 그것은 컴파일러가 써 준,
잊어버릴 수 없는 할 일 목록입니다.

## 이것이 값을 하는 순간

잘못된 조합이 진짜 결함이 되는 곳, 그리고 경우가 늘어날 곳에 쓰세요. 요청/응답
상태, 파싱 결과, 프로토콜 메시지, 명세에 "또는"이 들어가는 모든 것.

정말로 열려 있는 데이터, 독립적인 숫자 셋뿐인 구조체에는 쓰지 마세요. 그리고
중요한 것 — JSON과 맞닿는 경계에서는 어차피 세상이 nullable 한 뭉치를 건네줍니다.
거기서 합 타입은 *파싱해 들어갈 대상*입니다. 한 곳에서 모양 없는 맵을 거짓말할
수 없는 값으로 바꾸면, 그 아래 모든 코드가 보장을 물려받습니다. 그 파싱이 4부의
주제입니다.

## 연습문제

1. `String`의 값이 *n*개일 때 `(bool, String?)`은 값이 몇 개인가요?
   `Either<bool, bool>`은요?
2. 빨강, 노랑, 초록, 또는 "이유가 붙은 점멸 노랑" 중 하나인 신호등을
   모델링하세요. 어느 경우가 데이터를 싣고, 여러분의 타입은 몇 개의 상태를
   허용하나요?
3. 이 장 첫머리의 `Request` 클래스에서 말이 안 되는 열두 상태를 적어 보세요.
   그중 여러분의 코드베이스가 지금 크래시할 것은 어느 것이고, 조용히 잘못된
   화면을 그릴 것은 어느 것인가요?
4. `Either<String, int>`와 `(String?, int?)` 모두 "실패 또는 숫자"를 표현할 수
   있습니다. 앞의 것을 택할 구체적인 이유를 하나 대세요.

## 정답과 해설

1. `(bool, String?)`은 2와 (*n* + 1)의 곱이므로 2*n* + 2개입니다.
   `Either<bool, bool>`은 합이므로 2 + 2 = 4개 — `(bool, bool)`과 개수는 같지만
   서로 다른 타입이고, 이 둘을 헷갈리는 것이 바로 이 장이 다루는 모델링
   오류입니다.
2. 상수 경우 셋에 `String reason`을 싣는 경우 하나: `sealed class Light`에
   `Red`, `Amber`, `Green`, `FlashingAmber(reason)`. 타입은 3 + *r* 개의 상태를
   허용하고 (*r* 은 가능한 이유 문자열의 수), 이는 정직합니다 — 점멸 노랑은
   실제로 빨강보다 더 많은 정보를 싣고 있으니까요.
3. 열여섯에서 진짜인 넷을 뺀 전부입니다. `loading`과 `data`, `loading`과
   `error`, `data`와 `error`, `cancelled`와 그 밖의 무엇이든, 그리고 넷 다
   null/false인 빈 상태. 빈 상태는 보통 크래시(그릴 것이 없음)이고, 조합들은
   보통 조용한 버그입니다. 렌더 함수의 첫 `if`가 이기고 나머지 상태는 읽히지도
   않은 채 버려지니까요.
4. `Either`는 합이므로 컴파일러가 정확히 한쪽만 존재함을 증명할 수 있고,
   `switch`가 대비 갈래 없이 양쪽을 덮습니다. `(String?, int?)`는 옵셔널 둘의
   곱입니다. 네 상태 중 둘 — 둘 다 null, 둘 다 non-null — 은 말이 안 되며 모든
   사용처에서 손으로 처리해야 합니다.
