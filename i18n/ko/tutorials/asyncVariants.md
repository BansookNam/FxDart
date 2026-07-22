---
slug: asyncVariants
title: async variants — FxDart 101
description: FxDart의 *Async 명명 규칙 — 모든 지연 연산자와 집계 연산자에는 FxAsyncIterable용 짝이 있습니다. 라이브 플레이그라운드 포함.
heading: The <code>*Async</code> naming convention
section: 11
crumb: async variants
next: streams.html
nextLabel: streams
---
  <p class="hero-sub">모든 지연 연산자와 집계 연산자에는 FxAsyncIterable에서 동작하는 짝이 있습니다 — 동작은 같고, 콜백만 비동기 친화적입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    Dart에는 타입 없는 커링이 없기 때문에, FxDart는 하나의
    <code>map</code>을 오버로드해서 data-first 위치의
    <code>Iterable</code>과 <code>FxAsyncIterable</code> 양쪽에서
    동작하게 만들 수 없습니다. 매개변수 타입이 충돌하기 때문입니다.
    그래서 모든 지연 연산자와 집계 연산자는 최상위 함수로 두 가지
    형태를 제공합니다. <code>Iterable</code>용의 평범한 이름, 그리고
    콜백이 <code>R</code> 대신 <code>FutureOr&lt;R&gt;</code>를 반환하는
    <code>FxAsyncIterable</code>용 <code>*Async</code> 짝입니다. 이미 몇 가지는
    만나 보셨습니다. <code>map</code>/<code>mapAsync</code>,
    <code>filter</code>/<code>filterAsync</code>,
    <code>toList</code>/<code>toListAsync</code>,
    <code>reduce</code>/<code>reduceAsync</code>, <code>fold</code>/<code>foldAsync</code>,
    <code>each</code>/<code>eachAsync</code>, <code>find</code>/<code>findAsync</code> —
    라이브러리의 사실상 모든 함수가 이 규칙을 따릅니다.
  </p>
  <p>
    체인 형태에는 이런 구분이 필요 없습니다.
    <code>.toAsync()</code>를 호출하거나 <code>fxAsync</code>/<code>fxStream</code>에서
    시작하고 나면, 그 <code>FxAsync</code> 체인의 이후 메서드는 모두
    <strong>원래 이름</strong>을 그대로 씁니다 — <code>.mapAsync(...)</code>가 아니라
    <code>.map(...)</code>입니다. 수신자의 타입만으로 어느 쪽을 쓸지
    Dart가 이미 알 수 있기 때문입니다. 접미사는 모호함을 없애야 하는
    최상위 data-first 호출에만 존재합니다.
  </p>

  <h2>데모 1 · 짝지어 놓고 비교하기</h2>
  <p><code>FxAsyncIterable</code>을 다루는 순간, data-first 호출에는 항상
    <code>Async</code> 접미사가 필요합니다.</p>
  {{playground:0}}

  <h2>데모 2 · data-first 형태 vs. 체인 형태</h2>
  <p>
    <code>.toAsync()</code>가 수신자의 타입을 바꾸고 나면, 체인 형태는
    동기 버전과 똑같이 읽힙니다 — 접미사가 없습니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: data-first <code>map</code>의 <code>*Async</code> 짝을 사용해
    이 비동기 파이프라인의 모든 이름을 대문자로 바꿔 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="toAsync.html"><code>toAsync</code></a> — 비동기 파이프라인의 출발점 ·
    <a href="streams.html">Stream 브리지</a> — fromStream, fxStream, toStream ·
    <a href="concurrent.html"><code>concurrent</code></a> — 병렬 평가 ·
    <a href="map.html"><code>map</code></a> — 동기 원본
  </div>
