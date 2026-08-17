---
slug: purity
chapter: 2
part: 1
title: 순수함과 효과
description: 참조 투명성은 도덕이 아니라 치환 성질입니다. 이 장은 그것을 정확히 정의하고, 순수함이 사 주는 네 가지를 보이고, 평범한 Dart 코드 어디에 효과가 숨어 있는지 찾습니다.
---
# 순수함과 효과

> **이 장에서 다루는 것**
> - 어떤 식에도 적용할 수 있는 기계적 검사로서의 참조 투명성
> - 순수함이 사 주는 네 가지 능력 — 메모이제이션, 순서 바꾸기, 병렬화, 테스트
> - 평범한 Dart 코드에서 효과가 숨는 자리 (효과처럼 보이지 않는 것들까지)
> - 이음매: 순수한 핵심과 가장자리로 밀어낸 효과, 그리고 그 이음매에서 FxDart가 주는 것

## 치환 검사

함수가 **순수(pure)** 하다는 것은, 그 호출을 결과값으로 바꿔 놓아도 프로그램이
하는 일이 달라지지 않는다는 뜻입니다. 이 성질에는 이름이 있습니다 —
**참조 투명성(referential transparency)** — 그리고 이것은 취향의 문제가 아니라
기계적인 검사입니다.

```dart run
int double_(int n) => n * 2;

var log = <String>[];
int doubleAndLog(int n) {
  log.add('doubled $n');
  return n * 2;
}

void main() {
  // Substitution holds: double_(21) and 42 are the same thing.
  print([double_(21), double_(21)]);
  print([42, 42]);

  // Substitution fails: the two programs differ in `log`.
  print([doubleAndLog(21), doubleAndLog(21)]);
  print(log);
}
```

두 함수 모두 같은 수를 돌려줍니다. 하지만 그중 하나만이 그 주위의 프로그램을
다시 쓸 수 있게 해 줍니다. 그 차이가 — `void`라는 단어가 붙었는지도, 린터가
불평하는지도 아니라 — 바로 "순수함"의 뜻입니다.

![치환: 호출을 결과로 바꿔 놓기](diagrams/t2-1-substitution.svg)

*그림 2-1. 순수함이란 왼쪽 그림을 오른쪽 그림으로 다시 그려도 된다는 허가증이다. 손으로 하는 모든 리팩터링은 이 허가증에 기대고 있다.*

## 순수함이 사 주는 것

네 가지 능력이고, 여러분은 이미 넷 다 기대고 있습니다.

| 능력 | 왜 순수함이 필요한가 |
|---|---|
| **메모이제이션** | 결과를 캐시한다는 것은 두 번째 호출도 같은 일을 했을 것이라 가정하는 것 |
| **순서 바꾸기** | 한 줄을 옮긴다는 것은 그것이 언제 실행됐는지 아무도 안 본다고 가정하는 것 |
| **병렬화** | 두 호출을 동시에 돌린다는 것은 서로를 볼 수 없다고 가정하는 것 |
| **테스트** | 반환값만 검사한다는 것은 그 값이 이야기의 전부라고 가정하는 것 |

FxDart의 `memoize`가 가장 날카로운 예입니다. 순수한 함수에 대해서는 *옳고*,
순수하지 않은 함수에 대해서는 조용한 버그입니다.

```dart run
import 'package:fxdart/fxdart.dart';

int calls = 0;
int slowSquare(int n) {
  calls++;
  return n * n;
}

void main() {
  final fast = memoize(slowSquare);
  print([fast(9), fast(9), fast(9)]);
  print('underlying calls: $calls');
}
```

세 번 호출, 한 번 계산. `memoize` 안에는 `slowSquare`가 순수한지 확인하는
코드가 없습니다 — 그냥 *가정*합니다. 함수형 도구 대부분이 이런 모양입니다.
라이브러리는 장치를 주고, 법칙은 허가증을 주며, 약속을 지키는 것은 여러분
몫입니다.

## Dart에서 효과가 숨는 자리

**효과(effect)** 란 호출자가 반환값 외에 관찰할 수 있는 모든 것, 또는 결과가
인자 외의 무언가에 의존하는 모든 것입니다. Dart는 그것을 여럿 눈앞에 숨겨
둡니다.

- **공유 상태의 변경** — 가장 뻔한 것. 클로저가 잡은 `List`도 포함됩니다.
- **시계나 플랫폼 읽기** — `DateTime.now()`, `Platform.isIOS`. 같은 인자,
  다른 답.
- **난수** — FxDart가 `createSeededRandom`을 제공하는 이유입니다. 시드는
  효과를 다시 인자로 되돌립니다.
- **던지기(throw)** — 예외는 눈에 보이지 않는 두 번째 반환 통로입니다. 4부는
  그것에 보이는 통로를 주는 이야기입니다.
- **`print`와 IO** — 출력은 정의상 관찰 가능합니다.
- **동일성** — `List`의 상등은 참조 기준이므로, 새 리스트를 돌려주는 것과
  공유된 리스트를 돌려주는 것은 `identical`로 구분됩니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  // A seed makes randomness reproducible: same input, same
  // output, so a shuffle becomes testable.
  final a = shuffle([1, 2, 3, 4, 5], 7);
  final b = shuffle([1, 2, 3, 4, 5], 7);
  print(a);
  print('reproducible: ${a.toString() == b.toString()}');
}
```

> 🎓 **"순수함"은 우주가 아니라 언어의 관찰에 관한 것입니다.** 순수한 함수도
> CPU를 태우고, 메모리를 할당하고, 방을 덥힙니다. 순수함은 *프로그램*이 무엇을
> 관찰할 수 있는지를 기준으로 정의됩니다 — 어떤 Dart 코드도 두 식을 구분할 수
> 없다면 둘은 서로 바꿔 쓸 수 있습니다. 시간과 메모리는 그 렌즈 바깥에 있고,
> 그래서 14장은 그것들을 따로 측정해야 하며, "순수함"은 결코 "공짜"라는 뜻이
> 아닙니다.

## 이음매

효과가 하나도 없는 프로그램을 내놓는 사람은 없습니다. 목표는 효과가 *어디에*
있는지 아는 것입니다. 표준적인 배치는 **순수한 핵심과 효과가 있는 껍질**
입니다 — 파싱하고, 판단하고, 계산하는 일은 순수한 함수 안에서, 읽고 쓰는 일은
가장자리에서.

파이프라인은 이 이음매를 눈에 보이게 만듭니다. 지연 파이프라인은 일 자체가
아니라 일에 대한 *서술*이기 때문입니다. 효과가 어디 있는지 비교해 보세요.

```dart run
import 'package:fxdart/fxdart.dart';

class Order {
  const Order(this.id, this.total, this.status);
  final String id;
  final int total;
  final String status;
}

const orders = [
  Order('a', 120, 'paid'),
  Order('b', 40, 'refunded'),
  Order('c', 260, 'paid'),
];

// Pure core: data in, data out. No printing, no clock, no IO.
List<String> receipts(Iterable<Order> all) => fx(all)
    .filter((o) => o.status == 'paid')
    .sortByDesc((o) => o.total)
    .map((o) => '${o.id}: ${o.total}')
    .toList();

void main() {
  // Effectful shell: the one place that touches the world.
  receipts(orders).forEach(print);
}
```

`receipts`는 상등 비교만으로 테스트할 수 있습니다. 그리고 그 성질을 깨지 않고
파이프라인을 들여다봐야 할 때를 위해 `peek`이 *선언된* 이음매를 줍니다 —
숨겨진 효과가 아니라 *이름표가 붙은* 효과입니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() {
  final seen = <int>[];
  final result = fx(range(1, 6))
      // the effect is named, and it is the only one
      .peek(seen.add)
      .filter((n) => n.isEven)
      .toList();
  print(result);
  print(seen);
}
```

## 이것이 값을 하는 순간

순수함은 쌓아 두는 미덕이 아니라 써서 없애는 지렛대입니다. 캐시하고, 재시도하고,
순서를 바꾸고, 동시에 실행하고, 픽스처 없는 테스트를 쓰고 싶을 때 값을
합니다 — 즉 3부와 4부가 다루는 바로 그 상황들입니다. `concurrent(n)`(13장)이
안전한 이유는 그것이 순서 없이 실행하는 콜백들이 서로를 볼 수 없기 때문입니다.

효과 *자체가* 요점일 때는 비용만 듭니다. 로거, 마이그레이션 스크립트, UI 이벤트
핸들러 — 이런 것들을 격식으로 감싸 봐야 얻는 게 없습니다. 22장이 그 이야기를
길게 합니다.

## 연습문제

1. `List.of(items)`는 순수한가요? 호출자가 결과를 관찰하는 방법으로 `==`와
   `identical`을 모두 고려해 보세요.
2. Dart가 보기엔 순수하지만, 생성 이후 절대 바뀌지 않는 가변 필드에 의존하는
   함수를 써 보세요. 참조 투명한가요? 누군가 그 필드에서 `final`을 떼는 순간
   무엇이 깨지나요?
3. `int Function(int)` 타입 함수에 대한 `memoize`는 안전합니다. 인자 타입이
   가변 `List<int>`라면 무엇이 잘못되나요?
4. 위의 `receipts` 파이프라인에 요구사항을 하나 더합니다: 걸러진 주문을 모두
   기록할 것. `receipts`를 순수하지 않게 만들지 말고 해 보세요.

## 정답과 해설

1. **`==` 기준으로는 순수하고, `identical` 기준으로는 아닙니다.** 같은 인자로
   두 번 호출하면 서로 같은(equal) 리스트를 돌려주지만 같은 객체는 결코 아니므로,
   `identical`로 비교하는 프로그램은 두 호출을 구분할 수 있습니다. 이래서
   "순수함"은 언제나 어떤 관찰을 기준으로 말해야 합니다 — 1장의 `Future` 상등
   연습문제와 같은 미묘함입니다.
2. 예를 들어 `class Rate { const Rate(this.pct); final int pct;
   int apply(int n) => n * pct ~/ 100; }`. `pct`가 바뀔 수 없으므로 참조
   투명합니다. 인스턴스는 인자의 일부이고, 다만 인자가 아니라 수신자로 적혔을
   뿐입니다. `final`을 떼면 같은 호출이 두 가지 답을 돌려줄 수 있으므로 치환이
   깨집니다.
3. `memoize`는 인자를 키로 삼는데, 가변 리스트의 내용은 키로 쓰인 뒤에도 바뀔
   수 있습니다 — 호출자가 리스트를 바꾸고 다시 호출하면 *예전* 내용에 대한 답을
   받습니다. 캐시가 틀린 게 아니라 가정이 틀린 것입니다.
4. 걸러진 주문을 기록하는 대신 *돌려주세요* — `fork`나 `partition` 형태의 분리를
   쓰면 함수가 보고하는 내용이 완전해지고, 무엇을 출력할지는 호출자(껍질)가
   정합니다. 관찰만 하면 된다면 걸러진 가지에 `.peek(rejected.add)`를 쓰세요.
   여전히 이름 붙은 이음매의 선언된 효과이고, 핵심 안에는 IO가 없습니다.
