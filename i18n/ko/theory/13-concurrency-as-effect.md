---
slug: concurrency
chapter: 13
part: 3
title: 효과로서의 동시성
description: concurrent(n)은 원소가 언제 계산되는지만 바꾸고 무엇이 어떤 순서로 나오는지는 바꾸지 않는다 — 제한된 병렬성을 한 단어로 만들어 주는 보장, 그리고 그것을 구현하는 백채널.
---
# 효과로서의 동시성

> **이 장에서 다루는 것**
> - 보장: *언제*이지 *무엇*이 아니다 — 그리고 그래서 합성된다
> - "n만큼 넓게 가라"를 상류로 실어 나르는 백채널
> - 순서 보존, 그리고 그것을 포기했을 때의 대가
> - 틀리는 두 가지 방법: 상태 공유, 그리고 제한 없는 팬아웃

## 한 단어, 한 보장

```dart run
import 'package:fxdart/fxdart.dart';

Future<int> slowSquare(int n) async {
  await Future.delayed(const Duration(milliseconds: 40));
  return n * n;
}

void main() async {
  final input = [1, 2, 3, 4, 5, 6];
  final sw = Stopwatch()..start();

  final serial =
      await fx(input).toAsync().map(slowSquare).toList();
  final serialMs = sw.elapsedMilliseconds;

  sw.reset();
  final wide = await fx(input)
      .toAsync()
      .map(slowSquare)
      .concurrent(3)
      .toList();
  final wideMs = sw.elapsedMilliseconds;

  print(serial);
  print(wide);
  print('same result: ${serial.toString() == wide.toString()}');
  print('serial ~${serialMs}ms, concurrent(3) ~${wideMs}ms');
}
```

똑같은 리스트 둘, 그중 하나는 3분의 1의 시간에 만들어졌습니다. 그것이
`concurrent(n)`의 주장이고, 정확히 적어 둘 가치가 있습니다.

> `concurrent(n)`은 원소가 **언제** 계산되는지를 바꿉니다. **어떤** 원소가
> 계산되는지, 그것이 **무엇**으로 계산되는지, **어떤 순서**로 도착하는지는
> 바꾸지 않습니다.

하류의 모든 것 — fold, filter, 호출자 — 은 시계를 보지 않는 한 차이를 알 수
없습니다. 동시성은 다른 프로그램이 아니라 *평가에 대한 효과*로 더해집니다.

그래서 합성됩니다. 순서가 보존되므로 하류 fold에는 8장의 결합 법칙이면
충분하고, 겹쳐 실행을 애초에 합법으로 만드는 것은 6장의 독립성이며, 그것을
안전하게 만드는 것은 2장의 순수함입니다. 탑의 각 부분이 여기서 전제 조건으로
나타납니다.

## 백채널

12장은 당김 프로토콜에 상류를 가리키는 화살표가 있다고 했습니다. FxDart가 그 길로
보내는 것이 이것입니다.

평범한 당김은 "다음 원소를 달라"입니다. FxDart의 비동기 이터레이터는 인자를
받습니다. `iterator.next(concurrent)`, 여기서 `concurrent`는 너비를 실은
표식입니다. 그것을 받은 단계는 이렇게 할 수 있습니다.

- 이행한다 — 상류 당김 n개를 한꺼번에 시작하고, 결과를 붙들고 있다가 순서대로
  내준다; 또는
- 전달한다 — `map`은 혼자서 아무것도 병렬화할 수 없으므로 요청을 더 위로 넘긴다.

그래서 요청은 소비자에게서 실제로 넓힐 수 있는 단계까지 올라가고, 값들은 순서를
지키며 내려옵니다.

![요청은 위로, 값은 아래로](diagrams/t13-1-back-channel.svg)

*그림 13-1. `concurrent(3)`은 사슬 한복판의 버퍼가 아니라, 무언가 처리할 수 있을 때까지 상류로 올라가는 메시지다. 원소 셋이 동시에 날아가고 있지만 소비자는 여전히 1, 2, 3을 받는다.*

연산자를 비싼 단계 *뒤에* 놓았는데도 그 단계에 영향을 주는 이유도 이것입니다.
표식이 위로 올라가니까요. `map(fetch).concurrent(3)`은 "이것들을 한 번에 세 개씩
가져다 달라"로 읽히고, 정확히 그렇게 동작합니다. `mapConcurrent(3, fetch)`는 그것을
미리 합쳐 둔 것입니다.

## 순서, 그리고 그것을 지키는 값

순서 보존은 공짜가 아닙니다. 2번 원소가 1번보다 먼저 끝나면 그 결과는
기다립니다. 그 대가로 순차 버전과 *같은* 수열을 얻고, 그래서 기존 파이프라인에
`concurrent(n)`을 끼워 넣으면서 나머지를 다시 읽지 않아도 됩니다.

정말로 상관없을 때는 완료 순서를 요청해 결과를 더 빨리 받으세요.

```dart run
import 'package:fxdart/fxdart.dart';

Future<String> job(String name, int ms) async {
  await Future.delayed(Duration(milliseconds: ms));
  return name;
}

void main() async {
  final jobs = [('slow', 90), ('quick', 10), ('mid', 45)];

  // Source order: 'slow' first, however long it takes.
  final ordered = await fx(jobs)
      .toAsync()
      .map((j) => job(j.$1, j.$2))
      .concurrent(3)
      .toList();
  print(ordered);

  // Completion order: whoever finishes first.
  final asDone = await fx(jobs)
      .toAsync()
      .map((j) => job(j.$1, j.$2))
      .concurrentPool(3)
      .toList();
  print(asDone);
}
```

`concurrentPool`은 "결정성을 지연 시간과 맞바꾸겠다"의 정직한 이름입니다. 결과를
각각 독립적으로 처리할 때 — 싱크에 쓰기, UI 갱신 — 쓰고, 하류 단계가 입력과의
위치 대응을 가정할 때는 절대 쓰지 마세요.

> 🎓 **동시성은 병렬성이 아니고, Dart는 그것을 문자 그대로 만듭니다.** 위의 모든
> 일은 아이솔레이트 하나에서 일어납니다. IO가 기다리는 동안 스레드 하나가 연속을
> 번갈아 실행할 뿐이죠. 위 어느 것도 CPU 바운드 코드를 빠르게 만들지 않습니다.
> 40ms짜리 *계산* 여섯 개는 `concurrent`가 있든 없든 240ms입니다. 두 번째 코어가
> 없으니까요. 겹치는 것은 기다림입니다. 진짜 병렬성이 필요하면 아이솔레이트가
> 필요하고, 아이솔레이트는 가변 상태를 공유할 수 없으므로 2장의 순수함이 규율이
> 아니라 기계적 요구 조건이 됩니다. 어휘는 똑바로 유지할 가치가 있습니다.
> `concurrent(n)`은 *진행 중인 작업량*을 제한하고, 아이솔레이트는 *코어*를
> 사 줍니다.

## 틀리는 두 가지 방법

**콜백 사이에 가변 상태를 공유하기.** `concurrent(n)`에서는 콜백 n개가 동시에
날아가고 있고 그 뒤섞임 순서는 명세되지 않습니다. `map` 안에서 카운터를 하나
올리는 것은 (한 아이솔레이트에서는 문장 사이에 선점이 없으므로) 괜찮지만,
await를 가로지르는 읽기-수정-쓰기는 그렇지 않습니다.

```dart run
import 'package:fxdart/fxdart.dart';

void main() async {
  var balance = 100;

  // Each callback reads, awaits, then writes — the read is stale
  // by the time the write happens.
  await fx([1, 2, 3])
      .toAsync()
      .map((n) async {
        final read = balance;
        await Future.delayed(const Duration(milliseconds: 10));
        balance = read - 10;
        return n;
      })
      .concurrent(3)
      .toList();

  print('balance: $balance (serial answer would be 70)');
}
```

해법은 잠금이 아니라 그런 코드를 쓰지 않는 것입니다. 동시성 단계 안에서 공유
상태를 바꾸는 대신, 값을 돌려주고 순서가 *보장되는* 하류에서 접으세요.

**제한 없는 팬아웃.** `Future.wait(items.map(fetch))`는 전부 시작합니다. 열
개면 괜찮고, 만 개면 장애입니다. 너비 매개변수의 요점은 그 너비를 여러분이
고른다는 것이고, 맞는 숫자는 리스트 길이가 아니라 상대편의 한계에서 나옵니다.

## 이것이 값을 하는 순간

원소당 작업이 IO인 모든 파이프라인. HTTP 요청, 파일 읽기, 데이터베이스 왕복.
이득은 대체로 너비만큼이고, 상대편이 병목이 되는 지점까지입니다 — 그리고 첫
예제의 측정은 그 비율을 믿는 대신 여러분의 서비스에 대고 다시 해 봐야 할
측정입니다.

아이솔레이트 하나에서의 CPU 바운드 작업에는 아무 도움이 안 되고, 소스가 싸고
짧을 때는 오히려 해롭습니다. 제곱 여섯 개를 계산하려고 future 셋을 더 만드는 것은
오버헤드니까요. 지연 평가와 마찬가지로, 모델이 이득이 어디 있는지 알려 줍니다.
계산이 아니라 기다림입니다.

## 연습문제

1. 40ms짜리 요청 여섯 개가 `concurrent(3)`에서 약 90ms였습니다. `concurrent(6)`
   과 `concurrent(2)`의 시간을 예측한 뒤 실행해 보세요.
2. `map(fetch)` *뒤에* 놓인 `concurrent(n)`이 왜 `fetch`에 영향을 주나요?
   요청이 가는 방향으로 답하세요.
3. 동시성을 줄이지 않으면서 잔액 예제의 답이 결정적이 되도록 다시 쓰세요.
   그 수정은 상태가 어디 사는지에 대해 무엇을 바꿨나요?
4. `concurrentPool(4)` 뒤에 `.chunk(10)`이 따라옵니다. 무엇이 깨지나요?
   `concurrent(4)`였다면 같은 문제가 있을까요?

## 정답과 해설

1. `concurrent(6)`은 한 라운드, 즉 약 45ms여야 합니다. 여섯 기다림이 모두
   겹치니까요. `concurrent(2)`는 세 라운드, 약 130ms입니다. 공식은
   `ceil(개수 / n) × 지연` 이고, 너비를 고를 때 기억해 둘 만합니다.
2. 요청이 *상류*로 가기 때문입니다. `concurrent(3)`은 자기에게 도착하는 값을
   처리하는 것이 아니라 소스에 한 번에 셋을 요청하고, 그 소스가 `map(fetch)`
   단계이므로 요청 셋이 시작됩니다. 푸시 모델이었다면 요청할 대상이 없습니다 —
   요청은 이미 달리고 있을 테니까요.
3. 각 콜백에서 변화량을 돌려주고 나중에 접으세요.
   `.map((n) async { …; return -10; }).concurrent(3)` 다음
   `fold(100, (a, d) => a + d)`. 상태가 동시성 영역 밖, 순서가 보장되는 영역으로
   옮겨 갔습니다 — 이것이 일반적인 해법이고, `fold`가 파이프라인 안이 아니라
   뒤에서 실행되는 이유입니다.
4. *기계적으로는* 아무것도 깨지지 않습니다 — `chunk`는 도착하는 대로 묶습니다 —
   하지만 덩어리가 더 이상 입력 위치와 대응하지 않으므로, "0번 덩어리는 처음 열
   개 입력"이라고 가정한 코드는 이제 틀렸습니다. `concurrent(4)`였다면 순서가
   보존되므로 그 대응이 성립합니다. 결정성을 지연 시간과 맞바꾼 구체적인
   대가입니다.
