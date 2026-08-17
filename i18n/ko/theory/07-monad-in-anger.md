---
slug: monad-in-anger
chapter: 7
part: 2
title: 모나드, 실전에서
description: 의존적인 단계를 실제로 이어 붙이기 — 클라이슬리 합성, 피라미드 문제, 네 언어의 do 표기법, 그리고 Dart의 async/await가 사실은 무엇인가.
---
# 모나드, 실전에서

> **이 장에서 다루는 것**
> - 클라이슬리 합성: 왜 `A → M<B>` 함수에는 자기만의 `∘`가 필요한가
> - 피라미드, 그리고 모든 언어가 그것을 펴려고 만드는 문법
> - `async`/`await`를 모나드 하나짜리 do 표기법으로 읽기
> - 진짜 한계인 "한 번에 모나드 하나", 그리고 Dart에서 그 대가

## 상자를 돌려주는 함수는 합성되지 않는다

4장은 `A → B`와 `B → C`를 합성해 `A → C`를 얻었습니다. 실패할 수 있는 단계로
같은 일을 해 봅시다.

- `parseId : String → Either<E, int>`
- `loadUser : int → Either<E, User>`

둘은 맞아떨어지지 않습니다. `parseId`의 출력은 `Either<E, int>`인데 `loadUser`는
맨 `int`를 원합니다. 평범한 합성은 불가능하고, 이것은 예외적인 경우가 아닙니다 —
*모든* 효과 있는 단계가 이 모양입니다.

`flatMap`이 그 해법이고, 여기에 합성 연산자를 만들어 주면 패턴이 눈에 보입니다.

```dart run
import 'package:fxdart/fxdart.dart';

// Kleisli composition: compose two "returns a box" functions.
Either<E, C> Function(A) kleisli<E, A, B, C>(
  Either<E, B> Function(A) f,
  Either<E, C> Function(B) g,
) =>
    (a) => f(a).flatMap(g);

Either<String, int> parseId(String s) {
  final n = int.tryParse(s);
  return n == null ? Either.left('bad id: $s') : Either.right(n);
}

Either<String, String> loadUser(int id) =>
    id == 1 ? Either.right('Ada') : Either.left('no user $id');

void main() {
  final lookup = kleisli(parseId, loadUser);
  print(lookup('1'));
  print(lookup('2'));
  print(lookup('x'));
}
```

`kleisli`는 `A → M<B>`와 `B → M<C>`를 합성해 `A → M<C>`를 만듭니다. 이 화살표들은
자기만의 범주를 이루고 — 그 모나드의 **클라이슬리 범주(Kleisli category)** —
1장의 세 법칙이 정확히 범주가 필요로 하는 것입니다. `of`가 항등 화살표(왼쪽·오른쪽
항등)이고, `flatMap`이 결합적인 합성입니다.

"모나드는 효과 있는 함수를 합성하는 방법"이라는 말의 내용이 이게 전부입니다.
효과가 합성을 깨뜨린 자리를 `flatMap`이 복원합니다.

![평범한 합성과 클라이슬리 합성](diagrams/t7-1-kleisli.svg)

*그림 7-1. 평범한 함수는 딸깍 맞물린다. 효과 있는 함수는 그러지 못한다 — 출력에 다음 입력이 받아 줄 수 없는 포장이 씌워져 있다. `flatMap`이 그 어댑터이고, 법칙은 그 어댑터가 보이지 않는다고 말한다.*

## 피라미드, 그리고 네 가지 탈출구

의존적인 단계 서넛을 손으로 합성하면 코드가 오른쪽으로 흘러갑니다.

```dart
parseId(raw).flatMap((id) =>
    loadUser(id).flatMap((user) =>
        loadOrders(user).flatMap((orders) =>
            Either.right(summarise(user, orders)))));
```

모나드가 있는 언어는 결국 이것을 펴는 문법을 갖게 됩니다. 같은 계산, 네 가지
표면입니다.

| 언어 | 문법 | 컴파일러가 내놓는 것 |
|---|---|---|
| 하스켈 | `do { id <- parseId raw; … }` | `>>=` 사슬 |
| 스칼라 | `for { id <- parseId(raw) } yield …` | `flatMap`/`map` 사슬 |
| 코틀린 (Arrow) | `either { val id = parseId(raw).bind() }` | 비국소 탈출이 있는 스코프 |
| Dart | `either((r) { final id = r.bind(parseId(raw)); … })` | 비국소 탈출이 있는 스코프 |

앞의 둘은 *문법 설탕 해제(desugaring)* 입니다. 컴파일러가 블록을 메서드 호출로
다시 쓰며, 타입 검사기가 이름 붙일 수 있는 어떤 모나드에도 통합니다. 뒤의 둘은
아닙니다 — 다시 쓰는 일은 없고, 블록을 포기할 수 있는 `bind`를 가진 스코프
객체가 있을 뿐입니다. 15장이 그 장치와 Dart가 왜 그것을 강제했는지를 다룹니다.

결과는 어느 쪽이든 이렇게 읽힙니다.

```dart run
import 'package:fxdart/fxdart.dart';

Either<String, int> parseId(String s) {
  final n = int.tryParse(s);
  return n == null ? Either.left('bad id: $s') : Either.right(n);
}

Either<String, String> loadUser(int id) =>
    id == 1 ? Either.right('Ada') : Either.left('no user $id');

Either<String, List<String>> loadOrders(String user) =>
    user == 'Ada'
        ? Either.right(['mug', 'book'])
        : Either.left('none');

Either<String, String> summary(String raw) => either((r) {
      final id = r.bind(parseId(raw));
      final user = r.bind(loadUser(id));
      final orders = r.bind(loadOrders(user));
      return '$user bought ${orders.length} things';
    });

void main() {
  print(summary('1'));
  print(summary('2'));
  print(summary('nope'));
}
```

직선형 코드, 의존적인 세 단계, 실패 타입 하나, 피라미드 없음.

## `async`/`await`는 모나드 하나짜리 do 표기법이다

Dart는 이미 이 아이디어를 싣고 있습니다 — `Future`에 대해서만.

```dart run
Future<int> parseId(String s) async => int.parse(s);
Future<String> loadUser(int id) async =>
    id == 1 ? 'Ada' : 'nobody';

Future<String> summary(String raw) async {
  final id = await parseId(raw); // r.bind, spelled `await`
  final user = await loadUser(id);
  return 'user: $user';
}

void main() async {
  print(await summary('1'));
  print(await summary('7'));
}
```

한 줄 한 줄, 이것은 위의 `either` 블록에서 `r.bind`를 `await`로 바꾼 것입니다.
`async`가 스코프를 표시하고, `await`가 한 겹을 벗기고, 컴파일러가 본문을
연속(continuation)으로 다시 쓰는데 그것이 이름만 다른 `flatMap`입니다. 이것이
마법이 아니라 모나드라는 증거 — `Future<Future<T>>`에 `await`를 걸면 `Future<T>`가
나옵니다. 1장이 요구한 그 납작하게 만들기죠.

Dart가 하지 *않은* 것은 그것을 일반화하는 일입니다. `await`는 `Future`에(그리고
구조적 우연으로 `then`이 있는 것에) 통하고, `Either`용 `await`도, `Iterable`용
`await`도, 직접 만들 방법도 없습니다. 위 표의 모든 언어가 처음엔 같은 선택을
했다가 나중에 일반화했습니다. Dart의 `async`는 그 일반화가 멈춘 지점입니다.

> 🎓 **모나드는 포개지지 않습니다.** `Future<Either<E, A>>`가 있으면 모나드가
> 둘인데 그 쌍을 위한 `flatMap`은 없습니다. 스칼라는 *모나드 트랜스포머*
> (`EitherT[Future, E, A]`)를 꺼내 듭니다 — 조합마다 래퍼 하나에 리프트가 탑처럼
> 쌓이죠. 코틀린과 Dart는 스코프에게 두 몫을 맡겨 그 탑을 피합니다.
> `eitherAsync`는 `async` 본문 *안에서* `Raise` 스코프를 주므로, `await`가 시간을
> 맡고 `r.bind`가 실패를 맡으며 제3의 타입은 없습니다. 트랜스포머보다 강력한 것은
> 아닙니다 — 덜 일반적이고 훨씬 읽기 쉬우며, 누가 무엇을 치렀는지는 21장에 적혀
> 있습니다.

## 한 번에 모나드 하나

```dart run
import 'package:fxdart/fxdart.dart';

Future<Either<String, int>> fetchPort(String key) async =>
    key == 'http'
        ? Either.right(8080)
        : Either.left('unknown: $key');

Future<Either<String, String>> describe(String key) =>
    eitherAsync((r) async {
      // `await` sequences time; `r.bind` sequences failure.
      final port = r.bind(await fetchPort(key));
      return 'listening on $port';
    });

void main() async {
  print(await describe('http'));
  print(await describe('gopher'));
}
```

효과 둘, 직선형 블록 하나, `EitherT` 없음. 대가는 FxDart가 손으로 써 둔 조합에서만
통한다는 것입니다 — `eitherAsync`, `nullable`, `catching`. 여러분이 확장할 수 있는
일반적인 장치는 없는데, "임의의 모나드"를 표현하려면 Dart에 없는 타입 기능이
필요하기 때문입니다. 그것이 10장입니다.

## 이것이 값을 하는 순간

같은 오류 타입으로 실패할 수 있는 의존적인 단계가 셋 이상일 때 스코프를 쓰세요 —
파싱하고, 불러오고, 권한을 확인하고, 계산하기. 피라미드가 나타나는 모양이고,
손으로 쓴 `if (x == null) return null` 사슬이 실패 이유를 조용히 잃어버리는
모양입니다.

단계가 독립적일 때는 쓰지 마세요(6장: 누적과 동시성을 잃습니다). 단계가 하나뿐일
때도(평범한 `Either.map`이 더 많은 것을 말해 줍니다), 실패가 진짜로 예외적이고
호출자가 손쓸 수 없을 때도 마찬가지입니다(18장).

## 연습문제

1. `Future`용 `kleisli`를 작성하세요 — `A → Future<B>`와 `B → Future<C>`의 합성.
   기존 Dart 메서드 중 무엇을 얇게 감싼 것인가요?
2. `Either`의 클라이슬리 항등 화살표는 `Either.right`입니다.
   `kleisli(Either.right, f)`와 `kleisli(f, Either.right)`가 모두 `f`처럼
   동작함을 보이고, 방금 쓴 두 모나드 법칙의 이름을 대세요.
3. `summary` 블록을 `flatMap`만으로 다시 쓴 뒤, 두 버전의 줄 수와 최대 들여쓰기
   깊이를 세어 보세요. 몇 단계부터 스코프 버전이 이기기 시작하나요?
4. `await`는 `Future<Future<T>>`를 납작하게 만듭니다. 그것은 5장의 `map`과 비교해
   `Future.then`의 시그니처에 대해 무엇을 말해 주나요?

## 정답과 해설

1. `Future<C> Function(A) k<A, B, C>(Future<B> Function(A) f,
   Future<C> Function(B) g) => (a) => f(a).then(g);`. `then`을 감싼 것이고,
   `then`이 곧 `Future`의 `flatMap`입니다 — 그리고 그 메서드는 `map` 노릇도
   하는데, 그것이 4번 문제의 주제입니다.
2. `kleisli(Either.right, f)`를 `a`에 적용하면 `Either.right(a).flatMap(f)`이고,
   **왼쪽 항등**에 의해 `f(a)`입니다. `kleisli(f, Either.right)`를 `a`에 적용하면
   `f(a).flatMap(Either.right)`이고, **오른쪽 항등**에 의해 `f(a)`입니다. 이 두
   법칙이 정확히 "`of`는 클라이슬리 범주의 항등 화살표다"라는 진술입니다.
3. `flatMap` 버전은 줄 수는 비슷하지만 세 겹으로 중첩되고 닫는 괄호가 줄줄이
   달립니다. 스코프 버전은 평평하게 유지됩니다. 갈림길은 두 단계이고, 세 단계면
   승부가 나지 않으며, 네 단계쯤이면 피라미드 버전은 괄호 안에 버그를 모으기
   시작합니다.
4. `then`은 `map`이 하지 않는 방식으로 오버로드되어 있습니다. `B Function(A)`와
   `Future<B> Function(A)` 둘 다 받고, 후자의 경우 납작하게 만듭니다. 즉 `then`은
   `map`과 `flatMap`을 한 메서드로 합친 것이고, 그래서 편리하며, 동시에 `Future`만
   써서는 탑의 두 층 차이를 결코 배우지 못하는 이유이기도 합니다.
