---
slug: applicative
chapter: 6
part: 2
title: 어플리커티브
description: 펑터와 모나드 사이의 층 — 독립적인 효과를 결합하기. 왜 오류를 모아 보고하는 검증이 모나드로는 불가능한지, 그리고 FxDart의 accumulate 스코프는 어떻게 그것을 해내는지.
---
# 어플리커티브

> **이 장에서 다루는 것**
> - *의존적인* 단계와 *독립적인* 단계의 차이를, 타입으로
> - 어플리커티브: 서로를 보지 않는 여러 구조를 결합하기
> - 왜 모든 오류를 모으는 일이 모나드에게는 불가능하고 여기서는 자연스러운가
> - FxDart의 `map2`, `zipOrAccumulate`, 그리고 `accumulate` 스코프

## "그다음"의 두 가지 모양

1장의 `flatMap`은 두 번째가 첫 번째에 의존하는 단계들을 합성합니다. 사용자를
찾기 전에는 그 사용자의 주문을 조회할 수 없죠. 그 의존성은 타입에 적혀
있습니다 — `A → M<B>`는 첫 상자에서 값을 꺼내야 합니다.

하지만 실제 코드의 상당수에는 그런 의존성이 없습니다. 폼 검증을 보세요. 이름
검사는 나이를 필요로 하지 않고, 나이 검사는 이름을 필요로 하지 않습니다. 둘은
*독립적*이고, 그 둘을 결합하는 연산의 타입이 그렇다고 말합니다.

`map2 : F<A> × F<B> × ((A, B) → C) → F<C>`

`A`에서 두 번째 구조로 들어가는 화살표가 없습니다. 둘 다 이미 거기 있고, 함수는
결과를 합치기만 합니다. `map2`를 갖춘 타입은 (여기에 평범한 값을 들어 올리는
방법, 즉 1장의 `of`를 더해) **어플리커티브 펑터(applicative functor)** 입니다.

![의존적인 것과 독립적인 것](diagrams/t6-1-dependent-independent.svg)

*그림 6-1. `flatMap`은 첫 단계가 값을 내놓기 전에는 둘째 단계를 시작할 수 없다. `map2`는 처음부터 둘 다 갖고 있다 — 그래서 동시에 실행하는 것도, 두 실패를 함께 보고하는 것도 애초에 가능해진다.*

## `map2`로 빨리 실패하기

```dart run
import 'package:fxdart/fxdart.dart';

class User {
  const User(this.name, this.age);
  final String name;
  final int age;

  @override
  String toString() => 'User($name, $age)';
}

Either<String, String> vName(String s) =>
    s.isEmpty ? Either.left('name is empty') : Either.right(s);

Either<String, int> vAge(String s) {
  final n = int.tryParse(s);
  if (n == null) return Either.left('age is not a number');
  if (n < 0) return Either.left('age is negative');
  return Either.right(n);
}

void main() {
  print(vName('Ada').map2(vAge('36'), User.new));
  print(vName('').map2(vAge('36'), User.new));
  // Both wrong — but only the leftmost failure is reported.
  print(vName('').map2(vAge('nope'), User.new));
}
```

마지막 줄이 이 장이 존재하는 이유입니다. 사용자는 두 칸을 잘못 채웠는데 폼은
하나만 알려 줬습니다. *구조*가 그렇게 강제한 것이 아닙니다 — `Either` 둘 다
계산됐으니까요. 빨리 실패하는 것은 보고 방식이고, `map2`는 가장 왼쪽 실패만
보고합니다.

## 왜 모나드는 모을 수 없는가

`flatMap`만으로 누적 버전을 써 보려 하면, 노력의 문제가 아닌 벽에 부딪힙니다.

```dart
name.flatMap((n) => age.flatMap((a) => Either.right(User(n, a))));
```

`name`이 `Left`라면 바깥 `flatMap`이 단락 평가됩니다 — 그리고 `age`를 들여다볼
함수는 콜백 안에 있으므로 *아예 실행되지 않습니다*. `flatMap`의 타입은 둘째
단계가 첫 값의 함수라고 말하므로, 첫 값이 없으면 둘째 단계도 없습니다. 여기서
단락 평가는 정책 선택이 아니라 타입의 뜻입니다.

어플리커티브는 엄밀히 더 약하고, 그 약함이 곧 기능입니다. `map2`는 결합하기 전에
두 구조를 *데이터로* 들고 있으므로, 구현은 자유롭게 둘 다 들여다보고 실패를 이어
붙일 수 있습니다.

## FxDart에서 오류 모으기

Dart에는 `Validated` 타입이 없습니다. FxDart는 Arrow 2.x를 따라 대신 누적
*스코프*를 제공합니다. `either` 안에서 하나 요청하세요.

```dart run
import 'package:fxdart/fxdart.dart';

class User {
  const User(this.name, this.age);
  final String name;
  final int age;

  @override
  String toString() => 'User($name, $age)';
}

Either<Nel<String>, User> parse(String name, String age) =>
    either((r) => r.zipOrAccumulate2(
          (br) {
            if (name.isEmpty) br.raise('name is empty');
            return name;
          },
          (br) {
            final n = int.tryParse(age);
            if (n == null) br.raise('age is not a number');
            if (n! < 0) br.raise('age is negative');
            return n;
          },
          User.new,
        ));

void main() {
  print(parse('Ada', '36'));
  print(parse('', '36'));
  print(parse('', 'nope')); // both failures, in branch order
}
```

모든 가지가 실행되고, 실패는 `NonEmptyList`로 이어 붙습니다(왜 평범한 `List`가
아닌지는 8장이 설명합니다). 가지가 다섯을 넘거나, 앞선 가지에 의존하는 규칙이
있다면 전체 스코프로 내려가세요.

```dart run
import 'package:fxdart/fxdart.dart';

Either<Nel<String>, String> checkout(
  String item,
  String qty,
  String coupon,
) =>
    either((r) => r.accumulate((acc) {
          final i = acc.accumulating((br) {
            if (item.isEmpty) br.raise('item required');
            return item;
          });
          final q = acc.accumulating((br) {
            final n = int.tryParse(qty);
            if (n == null) br.raise('qty is not a number');
            return n ?? 0;
          });
          // Dependent rule: only meaningful once qty parsed.
          final c = acc.dependent((br) {
            if (coupon.isNotEmpty && q.value > 10) {
              br.raise('coupon not valid in bulk');
            }
            return coupon;
          });
          return '${q.value} x ${i.value} ${c.value}'.trim();
        }));

void main() {
  print(checkout('mug', '2', ''));
  print(checkout('', 'x', 'SAVE5'));
  print(checkout('mug', '99', 'SAVE5'));
}
```

`accumulating`은 독립적인 가지를 실행하며 그 오류를 기록하고, `dependent`는
아직 아무 실패도 없을 때만 실행됩니다. 다른 가지의 값을 읽는 규칙은 그 값이
존재하지 않을 때 실행될 수 없으니까요. 독립과 의존이라는 이 장의 구분이 그대로
API가 된 것입니다.

> 🎓 **법칙과 진짜 정의.** 어플리커티브는 보통 `pure : A → F<A>` 와
> `ap : F<A → B> × F<A> → F<B>`(구조 *안의* 함수를 구조 안의 값에 적용)로
> 주어집니다. `map2`와 `ap`은 서로 정의할 수 있고, 기본이 커링이 아닌 언어에서는
> `map2` 쪽이 더 잘 읽히므로 FxDart는 그 얼굴을 내놓습니다. 네 법칙 — 항등, 합성,
> 준동형, 교환 — 은 예상대로의 말을 합니다. `pure`는 아무것도 더하지 않고, 적용은
> 합성이 그러하듯 결합적이라는 것. 모든 모나드는 어플리커티브이지만(`flatMap`으로
> `map2`를 만들 수 있습니다) 역은 성립하지 않으며, 이 장의 검증이 그 표준
> 반례입니다.

## 무엇을 고를 것인가

| 필요한 것 | 쓸 것 | 이유 |
|---|---|---|
| 2단계가 1단계의 값을 필요로 함 | `flatMap` / `either` 스코프 | 의존성이 실재함 |
| 단계가 독립적이고 첫 실패면 충분 | `map2` | 가장 값싸고 단락 평가됨 |
| 단계가 독립적이고 모든 실패를 보고 | `zipOrAccumulate` / `accumulate` | 어플리커티브 모양만이 할 수 있음 |
| 단계가 독립적이고 느림 | 어플리커티브 + 동시성 | 독립성이 겹쳐 실행을 합법으로 만듦 |

마지막 줄을 사람들이 놓칩니다. `concurrent(n)`(13장)은 단계들이 서로에게
의존하지 않을 때 정확히 적용 가능하며, 그것은 오류 누적을 가능하게 하는 조건과
같습니다. 독립성이 둘 다 사 주고, `flatMap`은 그것을 써 버립니다.

## 이것이 값을 하는 순간

폼과 페이로드 검증은 당연하고, 그 밖에도 설정 로딩(첫 개가 아니라 빠진 키를 모두
한 번에 보고), CSV 임포트(7행이 아니라 잘못된 모든 행), 그리고 사람이 오류를
읽고 한 번에 고칠 모든 곳. 판단 기준은 단순합니다 — *사용자가 모든 문제를 한꺼번에
보고 싶어 할까?* 그렇다면 어플리커티브가 필요합니다.

실패가 진짜로 순차적일 때(사용자가 존재하기 전에는 주문을 검사할 수 없음),
또는 잘못될 수 있는 일이 정확히 하나뿐일 때는 건너뛰세요. 규칙 하나짜리
`accumulate`는 보상 없는 격식입니다.

## 연습문제

1. `Future`에도 표준 라이브러리에 `map2` 모양의 조합자가 있습니다. 이름을 대고,
   왜 그것은 두 future를 동시에 실행할 수 있는데 `f1.then((_) => f2)`는 못 하는지
   설명하세요.
2. `flatMap`과 `map`만으로 `Either`의 `map2`를 작성하세요. 그런 다음 여러분이 쓴
   버전이 왜 오류를 모을 수 없는지 타입에 관한 한 문장으로 설명하세요.
3. `checkout` 예제에서 쿠폰 규칙의 `dependent`를 `accumulating`으로 바꾸면
   `checkout('', 'x', 'SAVE5')`가 무엇을 출력할지 예측하세요. 형제 가지를 읽는
   규칙에 왜 `dependent`가 더 안전한 기본값인가요?
4. `Set`은 어플리커티브인가요? `map2`는 무슨 뜻이 될 것이며, "두 집합을 결합한다"에
   대한 여러분의 직관과 맞나요?

## 정답과 해설

1. `Future.wait([a, b])` 입니다 — 이미 만들어진 두 future를 받으므로, 호출되기
   전에 둘 다 실행 중입니다. `a.then((_) => b)`는 `b`를 콜백 안에서 만들므로
   `a`가 끝나기 전에는 `b`가 존재조차 할 수 없습니다. 그 차이가 정확히 `map2`와
   `flatMap`의 차이이고, 벽시계 시간으로 눈에 보입니다.
2. `a.flatMap((x) => b.map((y) => f(x, y)))`. 오류를 모을 수 없는 이유는 `b.map`이
   `x`의 함수 안에 들어앉아 있기 때문입니다. `a`가 `Left`면 그 함수는 결코
   적용되지 않으므로 `b`의 실패는 검사조차 되지 않습니다. 둘째 값을 손댈 수 없게
   만드는 것이 바로 `A → Either<E, C>`라는 타입입니다.
3. `accumulating`이면 `qty`가 실패했는데도 쿠폰 가지가 실행되고, 그 안에서
   `q.value`를 읽는 순간 폭발합니다 — 스코프 끝이 아니라 가지 안에서 누적된
   오류가 raise 되는 것이죠. `dependent`는 그것을 불가능하게 만들려고
   존재합니다. 이미 오류가 있으면 블록을 통째로 건너뛰며, 형제의 `.value`를 읽는
   모든 규칙에 그것이 옳은 기본값입니다.
4. 그렇습니다. 집합에서의 `map2`는 결과를 중복 제거한 데카르트 곱입니다 —
   `{1,2}`와 `{10,20}`을 `+`로 결합하면 `{11, 21, 12, 22}`입니다. 이는
   비결정성 해석(각 집합은 "이 값들 중 하나")과 맞고, 1장에서 `List`를 모나드로
   만든 그 해석과 같습니다. zip 방식 직관과는 맞지 *않으며*, 그 둘 중 무엇을
   고르느냐가 하스켈에 `[]`와 `ZipList`라는 별개의 어플리커티브가 있는 이유입니다.
