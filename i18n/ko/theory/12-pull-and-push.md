---
slug: pull-and-push
chapter: 12
part: 3
title: 풀과 푸시
description: Iterable과 Stream은 형식적 쌍대다 — 누가 누구를 부르는가. 그 한 가지 차이가 배압, 취소, 그리고 어느 라이브러리가 맞는 도구인지를 결정하며, FxDart가 Stream 위에 서 있지 않은 이유다.
---
# 풀과 푸시

> **이 장에서 다루는 것**
> - 쌍대성: `Iterator`와 `Stream`은 누가 호출하느냐가 다르다
> - 거기서 떨어져 나오는 것들 — 배압, 취소, 시간
> - 왜 FxDart의 비동기 모델은 `Stream`이 아니라 당김 프로토콜인가
> - 다리들, 그리고 주어진 문제에서 어느 편을 고를 것인가

## 누가 누구를 부르는가

```
pull:  consumer asks  → producer answers   iterator.moveNext()
push:  producer calls → consumer receives  stream.listen(onData)
```

차이는 이게 전부이고, 이 장의 나머지는 전부 그 귀결입니다. 풀 소스는 *여러분이
부르는 함수*이고, 푸시 소스는 *여러분이 등록하는 콜백*입니다.

| | 풀 (`Iterable`, `FxAsyncIterable`) | 푸시 (`Stream`) |
|---|---|---|
| 속도를 정하는 쪽 | 소비자 | 생산자 |
| 배압 | 공짜 — 그냥 요청하지 않으면 됨 | 따로 마련해야 함 |
| 일찍 멈추기 | 당김을 멈춤 | 구독을 취소함 |
| 시간 | 모델에 없음 | 본질적으로 있음 |
| 잘 맞는 곳 | 컬렉션, 파일, 페이지 API | UI 이벤트, 소켓, 타이머 |

![누가 시작하는가](diagrams/t12-1-pull-push.svg)

*그림 12-1. 같은 값, 반대 방향의 화살표. 풀 사슬에서는 요청이 상류로 올라가고 값이 되돌아온다. 푸시 사슬에서는 값이 하류로 내려가고, 상류의 누구도 허락을 기다리지 않는다.*

형식적으로 이 둘은 쌍대(dual)입니다 — 한쪽의 화살표를 모두 뒤집으면 다른 쪽이
됩니다 — 그래서 연산자 어휘가 그토록 비슷하고(`map`, `filter`, `take`, `scan`이
양쪽에 다 있습니다) *실패 방식*은 정반대입니다.

## 배압이 실무적 차이다

소비자가 생산자보다 느리면 무언가가 양보해야 합니다.

풀 사슬에서는 아무것도 양보하지 않습니다. 소비자의 `next` 호출이 *곧* 시계이기
때문입니다. 느린 소비자는 그저 덜 자주 요청하고, 그사이 생산자는 놀고 있습니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() async {
  var produced = 0;

  final source = fx(range(1, 1000)).map((n) {
    produced++;
    return n;
  }).toAsync();

  // The consumer takes three and stops asking.
  final taken = await source.take(3).toList();

  print(taken);
  print('produced: $produced'); // not 999
}
```

푸시 사슬에서는 생산자가 아랑곳없이 계속 갑니다. Dart의 `Stream`은 이를
지원하는 소스에 대해서는 일시정지/재개로, 그렇지 않은 소스에 대해서는 버퍼로
처리합니다 — 속도 불일치가 컴파일 오류가 아니라 메모리 증가가 되는 것이죠.
전형적인 버그는 느린 리스너가 붙은 브로드캐스트 스트림입니다. 큐가 자라고,
지연이 자라고, 타입 어디에도 그런 말은 없었습니다.

## 왜 FxDart는 `Stream` 위에 서 있지 않은가

FxDart의 비동기 수열은 `FxAsyncIterable` — 당김 프로토콜 — 입니다. 이 라이브러리의
간판 기능이 소비자가 주도권을 쥐고 있어야만 성립하기 때문입니다.

`concurrent(n)`은 *상류*에게 원소 n개를 한 번에 평가해 달라고 요청합니다. 그
요청은 소비자에게서 소스 쪽으로, 뒤로 거슬러 올라가야 하는데, 그것이 바로 당김
프로토콜에 이미 화살표가 나 있는 방향입니다. FxDart는 `iterator.next(concurrent)`로
표식을 넘깁니다. 소비자가 "다음 것 하나 주세요, 그리고 참고로 이런 걸 n개
병렬로 돌리세요"라고 말하고, 상류의 모든 단계가 그것을 이행하거나 위로
전달합니다.

이것을 `Stream`으로 표현할 방법은 없습니다. 푸시 소스는 이미 달리고 있고, 소비자는
멈춰 달라고 요청할 수 있을 뿐 *더 넓게 가라*고는 할 수 없습니다. 옆 통로를
따로 만들어야 하는데 — Rx 계열 라이브러리의 여러 `parallel` 연산자가 그것입니다 —
그러고 나면 버퍼링과 순서를 손으로 다시 맞춰야 합니다.

```dart run
import 'package:fxdart/fxdart.dart';

Future<String> fetch(String id) async {
  await Future.delayed(const Duration(milliseconds: 40));
  return 'data-$id';
}

void main() async {
  final ids = ['a', 'b', 'c', 'd', 'e', 'f'];
  final sw = Stopwatch()..start();

  // One at a time: six 40ms waits, serially.
  await fx(ids).toAsync().map(fetch).toList();
  final serial = sw.elapsedMilliseconds;

  sw.reset();
  // Three at a time, results still in source order.
  final out =
      await fx(ids).toAsync().map(fetch).concurrent(3).toList();
  final concurrent = sw.elapsedMilliseconds;

  print(out.first);
  print('serial ~${serial}ms, concurrent(3) ~${concurrent}ms');
}
```

두 번째 숫자가 첫 번째의 대략 3분의 1이 되게 하면서도 버퍼링 없이, 순서를 잃지
않고, 두 번째 API 없이 해내는 것이 당김 프로토콜입니다. 거기 딸려 오는 보장들이
13장의 주제입니다.

## 다리들

풀 라이브러리라고 해서 푸시를 무시한다는 뜻은 아닙니다. 실제 프로그램에는 둘 다
있습니다 — UI 이벤트는 진짜 푸시이고, 데이터베이스 페이지는 진짜 풀입니다 —
그래서 FxDart는 양방향으로 건너갑니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() async {
  // push → pull: a Stream becomes a pull chain.
  final ticks = Stream.fromIterable([1, 2, 3, 4, 5]);
  final doubled =
      await fxStream(ticks).map((n) => n * 2).take(3).toList();
  print(doubled);

  // pull → push: a chain becomes a Stream for the framework.
  final asStream =
      fx([1, 2, 3]).toAsync().map((n) => n + 10).toStream();
  print(await asStream.toList());
}
```

FxDart는 명시적으로 푸시 모양인 계층도 싣습니다 — 평범한 `Stream` 위의 Rx 스타일
연산자인 `fxEvents` — 진짜로 시간과 브로드캐스트에 관한 문제를 위해서입니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() async {
  final clicks =
      Stream.fromIterable(['a', 'a', 'b', 'b', 'b', 'c']);

  // Push-side operators: same names, producer-driven semantics.
  final out = await fxEvents(clicks)
      .map((s) => s.toUpperCase())
      .where((s) => s != 'B')
      .toList();
  print(out);
}
```

고르는 기준은 이것입니다. **다음 값이 언제 존재하는지를 누가 정하는가?** 답이
"바깥세상"이라면 여러분은 푸시 쪽에 있고 거기 머물러야 합니다. 답이 "소비하는
쪽"이라면 풀이 더 단순하고 배압을 공짜로 줍니다.

> 🎓 **정확히 쌍대라는 뜻.** 이터레이터는 `() → Option<(A, Iterator<A>)>` 이고 —
> 소비자가 적용합니다. 옵저버는 `((A) → Unit) → Unit` 이고 — 생산자가 여러분의
> 콜백을 적용합니다. 한쪽의 화살표를 모두 뒤집으면 다른 쪽이 나옵니다. Rx를 만든
> 사람들이 "Rx는 `IEnumerable`의 쌍대"라고 말한 것이 이 뜻입니다. 쌍대성은 어느
> 쪽에서 어떤 연산자가 어려운지도 예측합니다. `zip`은 풀에서 쉽고(양쪽에 요청하고
> 둘 다 기다리면 됩니다) 푸시에서는 버퍼링이 필요합니다. 반대로 `debounce`는
> 푸시에서 자연스럽고(흘러간 시간에 관한 것이니까요) 풀에서는 무의미합니다.
> 요청과 요청 사이에는 아무 일도 일어나지 않으니까요.

## 각각이 값을 하는 순간

풀은 데이터가 이미 *거기 있고* 속도를 여러분이 정할 때입니다. 컬렉션, 파일,
페이지 단위 HTTP, 데이터베이스 커서, 도중에 그만 읽을 수도 있는 모든 것,
"한 번에 N개"가 여러분이 선언하고 싶은 정책인 모든 것.

푸시는 여러분의 준비와 무관하게 데이터가 *도착할* 때입니다. 사용자 입력,
웹소켓, 센서, 타이머, 그리고 여러 소비자가 같은 이벤트를 봐야 하는 모든 곳.
클릭 스트림을 풀 수열로 모델링하려 들면 버퍼를 손으로, 그것도 형편없이 쓰게
됩니다.

피해야 할 실수는 익숙한 연산자 이름을 쓰려고 반대편으로 변환하는 것입니다.
어휘가 마음에 든다고가 아니라 *문제*의 모양이 바뀔 때 다리를 건너세요.

## 연습문제

1. 풀 사슬의 `take(3)`은 생산자를 멈춥니다. `Stream`에서 그에 해당하는 것은
   무엇이고, 이미 날아가고 있던 값들은 어떻게 되나요?
2. 풀 사슬에서 `debounce`가 왜 불가능한가요? 그것이 무슨 뜻이 될지 서술하고,
   어느 부분이 앞뒤가 맞지 않는지 말하세요.
3. 페이지당 100행을 돌려주는 HTTP API를 두 방식 모두로 모델링한 뒤, "첫 일치에서
   멈추기"가 어느 쪽에서 더 싸고 요청 몇 개나 차이 나는지 말하세요.
4. `Stream`에는 `asBroadcastStream`이, 풀 사슬에는 `fork`/`tee`가 있습니다. 둘 다
   소비자 둘이 소스 하나를 보게 해 줍니다. 한 소비자가 느릴 때 무엇이 본질적으로
   다른가요?

## 정답과 해설

1. `subscription.cancel()` 입니다. 이미 내보내진 값은 사라졌고, 생산자가 계산
   중이던 값은 끝까지 계산된 뒤 버려집니다 — 생산자는 애초에 허락을 기다리고
   있지 않았으므로 취소는 장벽이 아니라 요청입니다. 풀 사슬에서 "멈춤"은 그저 다음
   호출이 없는 것이므로, 버려질 무언가가 날아가고 있지 않습니다.
2. `debounce`는 "X 시간 안에 다른 것이 오지 않았을 때만 내보내라"는 뜻입니다.
   풀 사슬에서는 스스로 오는 것이 없습니다. 다음 값은 여러분이 요청하는 바로 그때
   존재하므로 그 시간 창은 언제나 비어 있고, 연산자는 `map`으로 퇴화합니다.
   생산자의 타이밍에 *관한* 연산자, 즉 푸시에만 있는 연산자의 가장 명확한 예입니다.
3. 풀: 소비자가 현재 페이지를 다 쓰면 다음 페이지를 가져오는 `FxAsyncIterable`.
   푸시: 가능한 한 빨리 페이지를 가져오는 `Stream`. "첫 일치에서 멈추기"는 일치가
   1페이지에 있다면 풀 모델에서 정확히 요청 한 번이 듭니다. 푸시 버전은 그때쯤
   보통 여러 페이지를 이미 가져왔고, 차이는 상한이 없으며 지연 시간에 비례해
   커집니다.
4. `asBroadcastStream`은 모든 리스너에게 생산자의 속도로 같은 이벤트를 줍니다.
   느린 리스너는 버퍼링하거나 흘리며, 생산자를 늦출 수 없습니다. `fork`/`tee`는
   *당김*을 쪼개므로 공유된 소스는 두 소비자가 모두 요청했을 때만 전진합니다 —
   느린 소비자가 빠른 쪽을 붙잡는 것이고, 이는 설계대로 동작하는 배압이며,
   활성보다 정확성이 중요할 때 옳은 기본값입니다.
