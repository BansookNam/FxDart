---
slug: laziness
chapter: 11
part: 3
title: 지연 평가
description: 일 자체가 아니라 일에 대한 서술로서의 파이프라인 — 지연이 비용에 대해 바꾸는 것, 의미에 대해 바꾸는 것(없음), 그리고 여러분을 다치게 할 수 있는 두 가지.
---
# 지연 평가

> **이 장에서 다루는 것**
> - 서술과 실행, 그리고 어떤 연산자가 어느 쪽인가
> - 비용 모델: 일의 양은 *쓴 것*이 아니라 *소비한 것*에 비례한다
> - 왜 지연 평가는 2부의 어떤 법칙도 바꿀 수 없는가
> - 진짜 위험 둘: 파이프라인 안의 효과, 그리고 한 번만 읽히는 소스

## 두 종류의 연산자

체인을 쓰면 아무 일도 일어나지 않습니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  var calls = 0;
  final chain = fx([1, 2, 3, 4, 5]).map((n) {
    calls++;
    return n * 2;
  });

  print('after building the chain: $calls calls');
  print(chain.toList());
  print('after consuming it: $calls calls');
}
```

`map`, `filter`, `take`, `chunk`, `zip`은 **지연(lazy)** 연산자입니다 — 각각 단계
하나가 더 붙은 새 서술을 돌려줍니다. `toList`, `each`, `fold`, `first`, `sum`은
**종결(terminal)** 연산자입니다 — 값을 당겨 오고, 그제야 무언가가 실행됩니다.

둘을 구분하는 규칙은 반환 타입이고 결코 거짓말하지 않습니다. `Fx`가 다시
돌아왔다면 아직 아무 일도 없었습니다.

![서술, 그리고 당김](diagrams/t11-1-description-pull.svg)

*그림 11-1. 점선 사슬은 계획이다. 단계들이 이어져 있을 뿐 움직이는 값은 없다. 당기는 것은 종결 연산자이고, 값 하나가 사슬 전체를 지나간 뒤에야 다음 값이 출발한다.*

## 비용 모델

얼마나 당길지는 종결 연산자가 정하므로, 일의 양은 *소비한 것*에 비례합니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  var evaluated = 0;

  final result = fx(range(1, 1000000))
      .map((n) {
        evaluated++;
        return n * n;
      })
      .filter((n) => n.isOdd)
      .take(3)
      .toList();

  print(result);
  print('elements evaluated: $evaluated of 999,999');
}
```

백만 개 후보에서 세 개의 결과를 얻는 데 다섯 번의 계산. 같은 프로그램의 즉시
평가 버전은 백만 원소짜리 리스트를 만들고, 그것을 걸러 또 다른 리스트를 만들고,
셋만 남기고 전부 버립니다.

이 차이가 FxDart 자체 벤치마크에서 파이프라인이 손으로 쓴 루프를 *이기는*
경우로 나타납니다 — 루프가 원소당으로는 대개 더 빠르지만, 지연 사슬은 아예 그
일을 하기를 거부합니다. 14장이 양방향 모두에 숫자를 붙입니다.

같은 모델에서 두 가지 귀결이 더 떨어져 나옵니다.

- **무한 소스가 평범해집니다.** 무한히 많은 값에 대한 서술은 유한합니다. 멈춰야
  하는 것은 당김뿐입니다.
- **단락 평가가 자동입니다.** `first`, `any`, `find`는 답을 얻는 즉시 당김을
  멈추며, 상류 단계의 특별한 지원이 필요 없습니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  // An endless cycle, consumed finitely.
  print(fx([1, 2, 3]).cycle().take(7).toList());

  // `some` stops pulling at the first match.
  var checked = 0;
  final found = fx(range(1, 1000)).some((n) {
    checked++;
    return n > 4;
  });
  print([found, checked]);
}
```

## 지연 평가는 의미를 바꿀 수 없다

이 부분은 분명히 해 둘 가치가 있습니다. 지연 평가를 믿고 쓸 수 있게 해 주는 것이
바로 이것이니까요. 2부의 모든 법칙은 *값* 사이의 등식입니다. 펑터 법칙은
`m.map(f).map(g)`가 `m.map(g ∘ f)`와 같다고 말하고, 두 파이프라인이 같다는 것은
같은 원소를 같은 순서로 내놓는다는 뜻입니다.

평가가 *언제* 일어나는지는 그 등식의 일부가 아닙니다. 그러므로,

- `map` 두 단계를 융합하는 것은 합법입니다(펑터 합성 법칙);
- `filter`를 `map` 앞으로 옮기는 것은 술어가 매핑에 의존하지 *않을 때* 합법입니다 —
  이는 진짜 전제 조건이지 지연 평가의 문제가 아닙니다;
- 일을 빌드 시점에서 당김 시점으로 옮기는 것은 관찰 가능한 무엇도 바꾸지
  않습니다 — **콜백이 순수하기만 하다면.**

그 마지막 조건이 전부이고, 그것은 2장의 조건입니다. 순수한 파이프라인에서 지연
평가는 청구서 말고는 보이지 않습니다. 순수하지 않은 파이프라인에서는 어디서나
보이는데, 효과가 관찰하게 해 주는 것이 정확히 *언제* 일어났는가이기 때문입니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  final log = <String>[];

  // Built, never consumed: the effect never happens.
  final unused = fx([1, 2, 3]).map((n) {
    log.add('mapped $n');
    return n;
  });
  print('log after building: $log');

  // Same chain, consumed twice: the effect happens twice.
  final used = fx([1, 2]).map((n) {
    log.add('mapped $n');
    return n;
  });
  used.toList();
  used.toList();
  print('log after two pulls: $log');
  print(unused.take(0).toList());
}
```

두 놀라움은 같은 놀라움입니다. 지연 사슬은 *레시피*이고, 레시피는 0번 요리될
수도 두 번 요리될 수도 있습니다.

> 🎓 **지연, 엄격, 그리고 하스켈이 말하는 지연.** 하스켈은 *모든 식* 수준에서
> 기본이 지연입니다. 값은 강제되기 전까지 썽크(thunk)이고, 그래서 무한 자료구조와
> 쓰지 않으면 비용이 0인 `where` 절을 얻으며 — 강제되지 않은 썽크 사슬이 자라면
> 공간 누수를 얻습니다. Dart는 엄격하고, 지연 파이프라인은 *수열* 수준에서 지연을
> 다시 만들어 낸 것이며, 그 장치는 썽크가 아니라 당김 프로토콜입니다. 실무적
> 차이는 이렇습니다. 단락 평가와 스트리밍의 이득은 얻고, 한없이 쌓이는 썽크는
> 얻지도(디버그하지도) 않으며, 두 번 합성한 `fx(xs).map(f)`는 계획인 반면
> `let y = f x`는 이미 썽크입니다.

## 두 번째 위험: 한 번만 읽히는 소스

`List` 위의 파이프라인은 여러 번 당길 수 있습니다 — 리스트는 다시 읽을 수 있으니까요.
읽는 즉시 소비되는 소스 위의 파이프라인은 그럴 수 없습니다.

```dart run
import 'package:fxdart/fxdart.dart';

Iterable<int> readOnce() sync* {
  // A generator: iterating it again starts over, but a *stream*
  // or a socket would not — that is the shape to watch for.
  yield 1;
  yield 2;
}

void main() {
  final chain = fx(readOnce()).map((n) => n * 10);
  print(chain.toList());
  print(chain.toList()); // fine here — the generator restarts

  // The rule that always holds: if you need the values twice,
  // materialise once and re-read the list.
  final materialised = chain.toList();
  print([materialised.length, materialised.first]);
}
```

지침은 짧습니다. **한 번 소비하거나, 재료화하라.** 사슬을 소비자 둘이 쓴다면
`toList()`를 부르고 그 리스트를 공유하거나, 소스를 다시 실행하지 않고 당김
하나를 여럿으로 쪼개려고 존재하는 `fork`/`tee`를 쓰세요.

## 이것이 값을 하는 순간

파이프라인이 필요한 것보다 많이 만들어 낼 수 있을 때 지연 평가가 값을 합니다.
상위 N개 가져오기, 첫 일치 찾기, 도중에 그만둘 파일 스트리밍, 합쳐 놓으면 선택도가
높은 필터 조합. 메모리에도 값을 합니다 — 단계마다 리스트 하나가 아니라 원소
하나만 흐릅니다.

어차피 전부 소비되고 소스도 작을 때는 비용만 듭니다. 그때 원소당 프로토콜은
평범한 루프에 대한 순수 오버헤드이고, 14장이 그 양을 정확히 측정합니다.
디버깅 가능성에도 비용이 듭니다 — 지연 사슬 안의 스택 트레이스는 여러분의
파이프라인이 아니라 이터레이터 프레임을 보여 주며, 그것이 간접성의 값입니다.

## 연습문제

1. `fx(xs).map(f).toList()`와 `xs.map(f).toList()`는 같은 일을 합니다. FxDart
   버전이 이기기 시작하는 지점은 어디이고, 사슬의 어느 연산자가 그 원인인가요?
2. 원소 열 개짜리 소스에 `take(2)` 앞에서 `peek(print)`를 부르는 사슬의 출력을
   예측하세요. 몇 줄이 출력되고, 왜인가요?
3. 콜백이 실수로 두 번 실행되는 사슬을 써 보세요. 그런 다음 두 가지 방법으로
   고치세요.
4. `fx(range(1, 1000000)).map(expensive).first` — `expensive`는 몇 번
   실행되나요? `.first`를 `.last`로 바꾸면요?

## 정답과 해설

1. 즉시 평가 버전이 이미 해 버린 일을 어떤 단계가 *버리는* 순간부터 이깁니다 —
   `take`, `first`, `some`, `find`, 또는 비싼 `map` 앞에서 대부분을 걸러 내는
   `filter`. 그런 단계가 없으면 둘은 똑같은 일을 하고, 즉시 평가 버전 쪽이
   원소당 기계 장치가 적습니다.
2. 두 줄입니다. `take(2)`가 둘째 원소 뒤로는 당기지 않으므로 `peek`은 셋째
   원소부터는 질문조차 받지 않습니다 — 상류를 움직이는 것은 당김이고, 그 당김이
   멈춘 것입니다.
3. 변수에 담아 두고 종결 연산자를 두 번 부르는 사슬이면 됩니다. 위 예제가
   그렇습니다. 첫째 해법: `final xs = chain.toList();` 하고 `xs`를 두 번 쓰기.
   둘째 해법: `fork`/`tee`로 당김 하나를 소비자 둘로 쪼개어 소스는 여전히 한 번만
   읽히게 하기.
4. `.first`면 한 번입니다 — 당김 한 번으로 충족되니까요. `.last`면 999,999번
   전부입니다. `last`는 끝까지 가야 하므로 건너뛸 것이 남지 않습니다. 같은 사슬,
   같은 지연 평가, 정반대의 비용이고, 그것을 정하는 것은 전적으로 종결
   연산자입니다.
