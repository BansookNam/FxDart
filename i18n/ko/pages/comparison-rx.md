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
    목록을 보기 전에 정직하게 한 가지 짚고 넘어가겠습니다: 문제가 정말
    <em>시간에 따라 도착하는 이벤트</em>에 관한 것이라면 — 사용자 입력,
    시세 틱, 소켓 — 스트림이 그 문제에 맞는 형태입니다. FxDart는 그
    아이디어를 흡수하는 것으로 이를 인정합니다: 0.7.3부터
    <strong>이벤트 레이어</strong>
    (<code><a href="../tutorials/fxEvents.html">fxEvents</a></code>)가
    Rx 스타일의 push 연산자들 — debounce, throttle, sample,
    combineLatest, switchMap, race, 그리고 <code>LiveValue</code> — 를
    평범한 Dart 스트림 위에 올려 주므로, 이제 Part&nbsp;4의 시간 형태
    쌍들은 연산자 대 연산자로 대등하게 만납니다. RxDart의 카탈로그는
    여전히 훨씬 큽니다; 이 쌍들이 드러내는 것은 이야기의 나머지 절반
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
    10,000)에서 측정합니다. 실제 시간 기준 예제(#39–#47)는 일부러
    벤치마크하지 않았습니다: 디바운스 윈도와 샘플 틱은 파이프라인이
    아니라 시계를 측정하기 때문입니다.
  </p>
