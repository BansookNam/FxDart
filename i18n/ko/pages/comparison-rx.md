---
slug: comparison-rx
title: RxDart vs FxDart — 두 모델을 나란히 비교하기
description: 실전 과제 50개를 두 번씩 풉니다 — RxDart 스트림 vs FxDart pull 파이프라인 — 모든 쌍을 브라우저에서 바로 실행할 수 있고, 어느 모델이 맞는지 정직한 판정을 함께 제공합니다.
---
  <h1>RxDart vs FxDart</h1>
  <p class="hero-sub">
    같은 실전 과제를 두 번 풉니다: 왼쪽은 RxDart, 오른쪽은 FxDart입니다.
    두 버전 모두 브라우저에서 바로 실행되며 정확히 같은 결과를 출력합니다 —
    두 모델을 비교하고, 여러분의 문제가 실제로 어느 모델의 문제인지 직접
    판단해 보세요.
  </p>

  <p>
    이 두 라이브러리는 경쟁자라기보다 <strong>상호 보완재</strong>에
    가깝습니다. RxDart는 Dart의 <code>Stream</code>을 확장합니다 — 값이
    언제 도착할지 생산자가 결정하는 <em>push</em> 모델로, 실제 시간 기준
    연산자(<code>debounceTime</code>, <code>combineLatest</code>,
    <code>switchMap</code>)와 멀티캐스트(<code>BehaviorSubject</code>)가
    자연스럽습니다. FxDart는 이터러블 위에서 동작합니다 — 언제 요청할지
    소비자가 결정하는 <em>pull</em> 모델로, 지연 평가, 타입 있는 에러
    처리, 순서를 지키는 제한된 동시성
    (<code><a href="../tutorials/concurrent.html">.concurrent(n)</a></code>)이
    자연스럽고, 배압은 아예 문제가 되지 않습니다: 끌어오지 않는 것
    <em>자체가</em> 배압이기 때문입니다. 두 라이브러리는 브리지 —
    <code><a href="../tutorials/streams.html">fromStream / toStream</a></code> —
    에서 만나며, 아래 예제 중 몇 개는 일부러 두 라이브러리를 함께
    사용합니다.
  </p>

  <p>
    목록을 보기 전에 짚어 둘 습관이 하나 있습니다. 흔하지만, 잘못된
    습관이기 때문입니다. <code>Stream</code>에는 풍부한 연산자 어휘가
    딸려 있어서, 이미 손에 쥐고 있는 데이터를
    <code>Stream.fromIterable(orders)</code>로 감싸 오직
    <code>map</code>, <code>where</code>, <code>distinct</code>,
    <code>expand</code>와 유연한 체인을 쓰려 하고, 마지막에 결과를
    <code>await</code>로 되받는 유혹이 생깁니다. 그 문제에는 비동기적인
    구석이 하나도 없습니다. 값은 메모리에 있고, 질문에는 지금 당장
    답이 있으며, 끝의 <code>await</code>가 바로 그 증거입니다. 동기적인
    질문을 문법을 빌리려고 전달 메커니즘으로 바꿔 놓은 것이죠. 그렇게
    얻는 것은 어휘이고, 치르는 값은 원소 하나하나마다 붙는 구독,
    이벤트 루프 한 바퀴, 그리고 전달 단계입니다.
  </p>

  <p>
    아래 벤치마크가 그 대가를 숫자로 보여 줍니다.
    <strong>소스가 이미 메모리에 있는 예제 25개</strong>를 AOT 컴파일해
    <strong>N&nbsp;=&nbsp;1,000,000</strong>에서 측정하면, pull
    파이프라인이 <strong>25개 전부</strong>에서 더 빠릅니다 — 중앙값
    <strong>2.7배</strong>, 조기 종료 검색에서는
    <strong>88배</strong>까지 벌어지고
    (<a href="first-over-budget-rx.html">#1</a>, 78.9&nbsp;ms vs
    0.9&nbsp;ms), 무거운 리포트에서는 그 차이가 초 단위가 됩니다
    (<a href="stock-after-moves.html">#11</a>, 3.4&nbsp;s vs
    175&nbsp;ms). 반대로 일이 <em>정말로</em> 비동기적인 경우에는 같은
    측정에서 두 모델이 대등합니다: 그 16개 예제의 격차 중앙값은
    <strong>1.05배</strong>이고, 대부분 무승부 배지를 답니다. 이 대비가
    이 섹션을 한 줄로 요약합니다 — 스트림이 느린 것이 아니라, 동기적인
    데이터를 스트림에 통과시키면 애초에 필요하지 않았던 전달 비용을
    치르게 되는 것입니다.
  </p>

  <p>
    반대쪽도 그만큼 분명히 말해 두겠습니다: 문제가 정말
    <em>시간에 따라 도착하는 이벤트</em>에 관한 것이라면 — 사용자 입력,
    시세 틱, 소켓 — 스트림이 그 문제에 맞는 형태이고, 파이프라인 어휘를
    아무리 쌓아도 그것을 대신하지 못합니다. FxDart는 그
    아이디어를 흡수하는 것으로 이를 인정합니다:
    <strong>이벤트 레이어</strong>
    (<code><a href="../tutorials/fxEvents.html">fxEvents</a></code>)가
    Rx 스타일의 push 연산자들 — debounce, throttle, sample,
    combineLatest, switchMap, race, 그리고 <code>LiveValue</code> — 를
    평범한 Dart 스트림 위에 올려 주므로, Part&nbsp;4의 시간 형태
    쌍들은 연산자 대 연산자로 대등하게 만납니다. RxDart의 카탈로그는
    여전히 훨씬 크고, 그 일상적인 동사들을 넘어서면 여전히 RxDart를
    집어야 합니다. 이 쌍들이 드러내는 것은 이야기의 나머지 절반
    — 스트림으로 풀리는 문제가 사실은 스트림 옷을 입은 <em>데이터
    파이프라인</em>인 경우가 얼마나 많은가 — 입니다: 유한한 fetch,
    배치 변환, 페이지네이션 크롤링 같은 것들이죠. 그런 문제에서는 pull
    버전이 더 짧고, 순서가 보장되고, 타입이 있으며, 구독
    라이프사이클이 아예 필요 없습니다.
  </p>

  <p>
    <span class="badge verdict-fxdart">FxDart 승</span> — 이 문제에는 pull 모델이 더 잘 맞습니다 ·
    <span class="badge verdict-tie">우열 없음</span> — 두 모델 모두 깔끔하게 표현합니다 ·
    <span class="badge badge-async">async</span> — 비동기 파이프라인을 사용합니다
  </p>

  <p class="dim">
    과제가 처리량 형태인 페이지에는 <strong>Benchmark</strong> 섹션도
    함께 실려 있습니다 — 두 구현 모두 AOT 컴파일해 N=100과 큰 N
    헤드라인(동기 과제는 1M; 모든 요소가 이벤트 루프를 건너는 경우는
    10,000)에서 측정합니다. 실제 시간 기준 예제(#38–#46)는 일부러
    벤치마크하지 않았습니다: 디바운스 윈도와 샘플 틱은 파이프라인이
    아니라 시계를 측정하기 때문입니다.
  </p>
