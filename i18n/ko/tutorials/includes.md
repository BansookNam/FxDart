---
slug: includes
title: includes — FxDart 101
description: FxDart includes 튜토리얼 — 이터러블에 값이 들어 있는지 == 로 확인하는 방법과 단축 평가, 동기·비동기 사용법을 살펴봅니다.
heading: <code>contains</code>
section: 8
crumb: contains
prev: findIndex.html
prevLabel: findIndex
next: isEmpty.html
nextLabel: isEmpty
---
  <p class="hero-sub">이터러블이 어떤 값을 담고 있으면 true를 반환합니다. 비교는 <code>==</code>로 합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>includes</code>는 FxTS의 모양을 그대로 따르는 얇은 래퍼입니다.
    동기 쪽은 말 그대로 <code>iterable.contains(a)</code>라서 별도의 체인
    메서드가 없습니다 — <code>Fx</code>는 이미 <code>Iterable</code>에서
    <code>.contains()</code>를 물려받고 있고, 동작도 완전히 같습니다.
    비동기 버전인 <code>includesAsync</code>는
    <a href="some.html"><code>someAsync</code></a> 위에 얹혀 있으며
    (술어로 <code>b == a</code>를 씁니다), 덕분에 단축 평가도 그대로
    물려받습니다. 일치하는 값을 찾는 순간 소스에서 값을 끌어오는 것을
    멈춥니다.
  </p>
  <p>
    동등성은 Dart의 <code>==</code>로 확인하므로, 직접 만든 클래스에
    <code>operator ==</code>를 재정의해 두었다면 그것을 따릅니다.
    원시 타입에만 쓸 수 있는 것이 아닙니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 단축 평가 확인</h2>
  <p><code>includesAsync</code>가 멈추기 전까지 원소 5개 중 2개만 소비됩니다:</p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>includes</code>로 <code>requestId</code>가 허용된 값인지 확인해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="some.html"><code>some</code></a> — <code>includesAsync</code>의 토대가 되는 함수 ·
    <a href="find.html"><code>find</code></a> — 불리언 대신 일치하는 값 자체를 얻기 ·
    <a href="findIndex.html"><code>findIndex</code></a> — 대신 위치를 얻기 ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — 가까운 곳에 있는 또 다른 값 기반 검사
  </div>
