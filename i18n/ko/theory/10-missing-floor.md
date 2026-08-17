---
slug: missing-floor
chapter: 10
part: 2
title: 없는 층
description: 고차 타입 — 그것이 무엇인지, Dart가 정확히 어디서 멈추는지, 코틀린 Arrow와 스칼라는 대신 무엇을 하는지, 그리고 모든 추상을 손으로 적는 대가를 FxDart가 함수 개수로 얼마나 치르는지.
---
# 없는 층

> **이 장에서 다루는 것**
> - 종(kind): 타입의 타입, 그리고 인자 없는 `List`가 서 있는 자리
> - 컴파일되지 않는 정확한 Dart 선언, 그리고 어떤 기교로도 되찾을 수 없는 이유
> - 스칼라, 하스켈, 코틀린 Arrow는 대신 무엇을 하는가
> - FxDart가 치르는 청구서, 함수 개수로 세어 보기

## 종(kind)

값에는 타입이 있습니다. 타입에는 **종(kind)** 이 있습니다.

`int`는 완성된 타입입니다. 그 타입의 변수를 선언할 수 있죠. 그 종은 `*`라고
씁니다. `List` 자체는 완성된 타입이 *아닙니다* — `List<int>`가 완성된
타입입니다. `List`는 타입에서 타입으로 가는 함수이고, 그 종은 `* → *`입니다.

| 대상 | 종 | 완성? |
|---|---|---|
| `int`, `String`, `List<int>` | `*` | 예 |
| `List`, `Future`, `Fx` | `* → *` | 인자 하나 필요 |
| `Either`, `Map` | `* → * → *` | 인자 둘 필요 |

5장부터 9장까지는 전부 종이 `* → *`인 타입에 관한 이야기였습니다. 펑터,
어플리커티브, 모나드, 순회 가능성은 타입이 아니라 *타입 생성자*의 성질입니다.
`List<int>`는 모나드가 아니고, `List`가 모나드입니다.

그 한 문장이 이 장의 전부입니다. 그 인터페이스를 적으려면 그 자체로 종이
`* → *`인 타입 매개변수 — **고차 타입(higher-kinded type)** — 가 필요합니다.

## Dart가 멈추는 선

```dart
// Does not compile. Dart type parameters are always kind `*`,
// so `M` is a complete type and cannot take an argument.
abstract class Monad<M> {
  M<A> of<A>(A value);
  M<B> flatMap<A, B>(M<A> box, M<B> Function(A) f);
}
```

이 오류는 문법의 문제가 아닙니다. Dart의 타입 변수는 *완성된* 타입만을
범위로 하므로, `M<A>`는 `3(4)`가 무의미한 것과 같은 방식으로 무의미합니다.
이는 의도된 설계 지점이고 — 1차 제네릭은 추론을 결정 가능하게, 오류 메시지를
읽을 만하게 유지합니다 — 우회할 버그가 아니라 천장입니다.

![탑이 멈추는 지점](diagrams/t10-1-hkt-wall.svg)

*그림 10-1. 탑의 모든 층은 타입 생성자에 관한 진술이다. Dart는 층을 한 타입씩 이야기할 수 있다. 그 모두를 한 번에 지탱할 들보에는 이 언어에 없는 종이 필요하다.*

우회로들은 모두 같은 방식으로 실패합니다 — 컴파일은 되고, 그다음 거짓말을
합니다.

```dart run
// The "defunctionalisation" trick: erase the constructor to a
// marker, then cast it back. It type-checks. It is not typed.
abstract class Kind<F, A> {}

class ListK<A> implements Kind<ListK<Never>, A> {
  ListK(this.value);
  final List<A> value;
}

abstract class Monad<F> {
  Kind<F, A> of<A>(A value);
  Kind<F, B> flatMap<A, B>(
      Kind<F, A> fa, Kind<F, B> Function(A) f);
}

class ListMonad implements Monad<ListK<Never>> {
  @override
  Kind<ListK<Never>, A> of<A>(A value) => ListK([value]);

  @override
  Kind<ListK<Never>, B> flatMap<A, B>(
    Kind<ListK<Never>, A> fa,
    Kind<ListK<Never>, B> Function(A) f,
  ) {
    // The cast is the whole problem: nothing checks it.
    final list = (fa as ListK<A>).value;
    return ListK(list
        .expand((a) => (f(a) as ListK<B>).value)
        .toList());
  }
}

void main() {
  final m = ListMonad();
  final r = m.flatMap<int, int>(
      m.of(3), (a) => ListK([a, a * 10]));
  print((r as ListK<int>).value);
}
```

동작하긴 합니다. 그 값을 보세요. 캐스트 셋, `Never` 유령 타입 하나, 그리고 어떤
호출자도 원하지 않는 반환 타입 `Kind<ListK<Never>, int>`. 모든 사용처가 진짜
타입으로 다시 캐스트하므로, 이 추상은 타입 오류가 런타임에 드러나는 제네릭
코드를 여러분 손에 쥐여 줍니다. Arrow 초기 버전이 코틀린에서 정확히 이렇게 했다가
버렸습니다. FxDart의 `ARROW_MIGRATION_BLOCKER.md`에 Dart에 대한 같은 결론이
적혀 있습니다.

## 다른 언어는 무엇을 하는가

- **하스켈**은 종이 언어 안에 있습니다.
  `class Monad m where (>>=) :: m a → (a → m b) → m b` 는 평범한 코드이고, 모든
  인스턴스가 그것에 대해 검사됩니다.
- **스칼라**는 고차 타입 매개변수(`F[_]`)를 가지므로, Cats는 `Traverse[F[_]]`를
  한 번 정의하고 모든 조합자를 공짜로 얻습니다.
- **코틀린**에는 둘 다 없고, **Arrow 1.x**는 위의 `Kind` 인코딩을 썼습니다.
  Arrow 2.x는 그것을 지웠습니다. 편의성이 충분히 나빴기에 팀은 구체 타입에
  *컨텍스트 리시버*와 `Raise` 스코프를 더한 쪽을 택했고, FxDart가 이식한 것이 그
  설계입니다.
- **Dart**에도 둘 다 없고, 그것을 더할 플러그인 체계도 없습니다. 그래서 FxDart는
  구체적인 경우들을 적고, 그렇다고 말합니다.

> 🎓 **실제로 잃는 것.** 표현력이 아닙니다 — 고차 타입 추상으로 쓸 수 있는 모든
> 프로그램은 타입마다 손으로도 쓸 수 있습니다. 잃는 것은 *추상에 대한 추상*
> 입니다. `traverse` 일곱 개가 아니라 하나, `sequence` 하나, 한 번만 검사하면 되는
> 법칙 한 벌. 고차 타입이 있는 언어에서는 새 효과 타입이 라이브러리 전체를 이미
> 갖춘 채로 도착하고, Dart에서는 텅 빈 채로 도착해 누군가 채워야 합니다. 차이는
> 프로그램의 능력이 아니라 라이브러리 유지 비용이고 — 그래서 합리적인 언어 설계
> 선택이면서 동시에 성가신 것입니다.

## 청구서, 세어 보기

2부의 모든 추상은 고차 타입이 있는 언어가 한 번 쓰는 것을 FxDart는 타입마다
씁니다. 구체적으로, 연산 하나 — 순회 — 를 위해 라이브러리가 싣는 것은 이렇습니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  final xs = <Either<String, int>>[
    Either.right(1),
    Either.left('bad'),
    Either.right(3),
  ];

  // Four spellings of "swap the structures", because there is no
  // way to write one that works for every effect type.
  print(sequenceEither(xs));
  print(flattenOrAccumulate(xs));
  print(separateEither(xs));
  print(fx(xs).sequence());
  // …plus sequenceEitherAsync, flattenOrAccumulateAsync,
  //   mapOrAccumulateAsync for the async chain.
}
```

거래를 정직하게 보려면 반대쪽도 봐야 합니다. 이것들은 구체적이기 때문에
*빠르고* 타입이 정확합니다. `sequenceEither`는 `Either<L, List<R>>`를
돌려줍니다 — `Kind<F, List<R>>`도 아니고, 손으로 풀어야 하는 래퍼도 아닙니다.
Dart의 추론이 동작하고, 에디터가 자동완성하며, 오류가 여러분의 코드를 가리킵니다.
`Kind` 인코딩의 제네릭 버전이라면 캐스트 없이는 아무도 쓸 수 없는 무언가를
돌려줄 것입니다.

## 이것이 여러분에게 중요해질 때

대개는 중요하지 않습니다 — "당연히 있어야 할" 제네릭 조합자를 찾아 나서기
전까지는. 이 장이 그 검색의 답입니다. 그것은 없고, 있을 수 없으며, 구체적인
버전이 저기 있습니다.

라이브러리를 설계할 때는 중요합니다. "`map`이 있는 아무 컨테이너"를 추상화하려고
애쓰는 자신을 발견하면 멈추세요. Dart에서는 구체적인 두세 버전을 쓰고 이름을 잘
붙이는 편이 낫습니다. 손을 뻗고 있는 그 추상은 돌려주는 것보다 비쌉니다.

하스켈이나 스칼라를 아이디어를 얻으려 읽을 때도 중요합니다 — 읽을 가치가
있습니다. 다만 글자가 아니라 구조로 번역하세요. 그들의 한 줄짜리 제네릭 정의는
여러분의 구체적인 메서드가 되고, 다형성은 살아남지 못해도 법칙은 번역을 견딥니다.

## 연습문제

1. `Map`의 종은 무엇인가요? `Map<String, dynamic>`은요? 가상의 `Traverse`
   인터페이스는요?
2. 위의 `Kind` 인코딩을 `Either`로 확장하고 그것의 `flatMap`을 작성하세요.
   캐스트가 몇 개 필요하고, 잘못된 캐스트라면 어디서 터지나요?
3. `Fx<T>`에는 `map`, `flatMap`, `sequence` 형태의 종결자가 있습니다.
   `dynamic`이나 공통 상위 타입 없이 "`map`이 있는 아무 FxDart 타입"을 받는 함수를
   쓸 수 있나요? 답을 종의 언어로 설명하세요.
4. Dart는 `T extends Comparable<T>`를 허용합니다. 그것이 왜 이 장의 반례가
   아닌가요?

## 정답과 해설

1. `Map`은 `* → * → *`(인자 둘)이고, `Map<String, dynamic>`은 `*`이며,
   `Traverse`는 `(* → *) → *` 일 것입니다 — *타입 생성자*를 받아 타입을 내놓죠.
   마지막 종이 정확히 Dart가 적을 수 없는 것이고, 그 괄호가 언어가 멈추는
   지점입니다.
2. 최소 두 개입니다 — `Kind<F, A>`를 `EitherK<E, A>`로 풀 때 하나, `f`의 결과에
   하나. 터지는 곳은 런타임이고, 누군가 `ListK`를 `Either` 모나드 인스턴스에
   넘기는 순간입니다. 둘 다 `Kind<F, _>`로 지워지므로 타입 시스템은 애초에
   보고 있지 않았습니다.
3. 쓸 수 없습니다. 그런 함수에는 종이 `* → *`인 매개변수("`F<A>`에 `map`이 있는
   어떤 `F`")가 필요한데, Dart의 매개변수는 전부 종이 `*`입니다. 남은 우회로는
   정확히 나쁜 셋뿐입니다. `dynamic`, 공통 상위 타입(`Fx`와 `Either`에는 없고
   있어서도 안 됩니다), 그리고 `Kind` 캐스트 인코딩.
4. `T extends Comparable<T>`는 *완성된* 타입을 제약합니다 — `T`는 여전히 종이
   `*`이고, `Comparable<T>`는 그 위의 한계(bound)이지 고차 매개변수가 아닙니다.
   F-한정 다형성은 다른 문제를 푸는 다른 기능이고, "대부분의 코드에 충분히
   제네릭한 것"과 "고차인 것"이 별개의 축임을 잘 보여 주는 예입니다.
